# scenes/game/GameBoard.gd — Plateau de jeu DOSCO
extends Control

signal move_played(from_c: String, to_c: String)
signal game_over(result: Dictionary)

var game_state: GameState = null
var player_color: String = "W"
var ai_diff: String = "n3"
var is_online: bool = false

@onready var cells_node: Node = $Board/Cells
@onready var pieces_node: Node = $Board/Pieces
@onready var hud: Control = $HUD
@onready var ai_timer: Timer = $AITimer
@onready var result_overlay: Control = $ResultOverlay

const CELL_SIZE := 46.0
const BOARD_ORIGIN := Vector2(14.0, 100.0)
# Couleurs UI
const COL_CELL_IDLE   := Color(0.04, 0.07, 0.16, 0.92)
const COL_SELECTED    := Color(0.28, 0.65, 1.00, 0.55)
const COL_VALID_MOVE  := Color(0.18, 0.90, 0.62, 0.38)
const COL_CAPTURE     := Color(1.00, 0.32, 0.32, 0.55)
const COL_WHITE_PIECE := Color(0.96, 0.97, 1.00)
const COL_BLUE_PIECE  := Color(0.40, 0.65, 1.00)

# Noeuds visuels
var _cell_rects: Dictionary = {}   # coord → ColorRect
var _piece_rects: Dictionary = {}  # coord → ColorRect

func _ready() -> void:
	ai_timer.one_shot = true
	ai_timer.timeout.connect(_ai_play)
	var config := SaveManager.load_pending_game()
	if config.is_empty(): config = {"galaxy": "voie_lactee", "ai": "n3", "mode": "vsai"}
	_start(config)

func _start(cfg: Dictionary) -> void:
	is_online = cfg.get("mode","vsai") == "online"
	player_color = cfg.get("color","W")
	ai_diff = cfg.get("ai","n3")
	var galaxy_id := cfg.get("galaxy","voie_lactee")
	game_state = GameState.new()
	game_state.reset(
		GameState.Mode.ONLINE if is_online else GameState.Mode.VS_AI,
		player_color, ai_diff, galaxy_id)
	_build_board_visuals()
	_refresh()
	_check_ai()

# ── Visuals ────────────────────────────────────────────────────
func _build_board_visuals() -> void:
	for c in cells_node.get_children(): c.queue_free()
	for c in pieces_node.get_children(): c.queue_free()
	_cell_rects.clear(); _piece_rects.clear()

	for row_idx in Constants.BOARD_LAYOUT.size():
		for col_idx in Constants.BOARD_LAYOUT[row_idx].size():
			var coord = Constants.BOARD_LAYOUT[row_idx][col_idx]
			if coord == null: continue
			var pos := _coord_pos(coord)
			# Cellule
			var cell := ColorRect.new()
			cell.size = Vector2(CELL_SIZE - 2, CELL_SIZE - 2)
			cell.position = pos
			cell.color = COL_CELL_IDLE
			cells_node.add_child(cell)
			_cell_rects[coord] = cell
			# Zone tactile
			var area := Area2D.new()
			var coll := CollisionShape2D.new()
			var shape := RectangleShape2D.new()
			shape.size = Vector2(CELL_SIZE - 2, CELL_SIZE - 2)
			coll.shape = shape
			area.position = pos + Vector2(CELL_SIZE/2 - 1, CELL_SIZE/2 - 1)
			area.add_child(coll)
			area.set_meta("coord", coord)
			cells_node.add_child(area)

func _coord_pos(coord: String) -> Vector2:
	var cr := Constants.to_cr(coord)
	return BOARD_ORIGIN + Vector2(cr["c"] * CELL_SIZE, cr["r"] * CELL_SIZE)

func _refresh() -> void:
	if game_state == null: return
	# Reset couleurs cellules
	for coord in _cell_rects:
		_cell_rects[coord].color = COL_CELL_IDLE
	# Surbrillances sélection
	if not game_state.selected.is_empty():
		if _cell_rects.has(game_state.selected):
			_cell_rects[game_state.selected].color = COL_SELECTED
	for coord in game_state.valid_moves:
		if _cell_rects.has(coord): _cell_rects[coord].color = COL_VALID_MOVE
	for coord in game_state.valid_captures:
		if _cell_rects.has(coord): _cell_rects[coord].color = COL_CAPTURE
	# Pièces
	for c in pieces_node.get_children(): c.queue_free()
	_piece_rects.clear()
	for coord in game_state.board:
		var star = game_state.board[coord]
		var rect := ColorRect.new()
		rect.size = Vector2(CELL_SIZE * 0.7, CELL_SIZE * 0.7)
		rect.position = _coord_pos(coord) + Vector2(CELL_SIZE * 0.15, CELL_SIZE * 0.15)
		rect.color = COL_WHITE_PIECE if star["color"] == "W" else COL_BLUE_PIECE
		pieces_node.add_child(rect)
		_piece_rects[coord] = rect
	_update_hud()

# ── Input ──────────────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if game_state == null or game_state.is_finished(): return
	if is_online and game_state.turn != player_color: return
	if event is InputEventScreenTouch and event.pressed:
		_handle_touch(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_touch(event.position)

func _handle_touch(pos: Vector2) -> void:
	var coord := _pos_to_coord(pos)
	if coord.is_empty(): return
	if not game_state.selected.is_empty():
		if coord == game_state.selected:
			game_state.deselect(); _refresh(); return
		if coord in game_state.valid_moves or coord in game_state.valid_captures:
			_play(game_state.selected, coord); return
		if game_state.board.has(coord) and game_state.board[coord]["color"] == game_state.turn:
			game_state.select(coord); AudioManager.sfx_move(); HapticManager.selection(); _refresh(); return
		game_state.deselect(); _refresh(); return
	if game_state.board.has(coord) and game_state.board[coord]["color"] == game_state.turn:
		game_state.select(coord); AudioManager.sfx_move(); HapticManager.selection(); _refresh()

func _pos_to_coord(pos: Vector2) -> String:
	for coord in _cell_rects:
		var r := _cell_rects[coord]
		var rect := Rect2(r.position, r.size)
		if rect.has_point(pos): return coord
	return ""

func _play(from_c: String, to_c: String) -> void:
	var capture := to_c in game_state.valid_captures
	var ok := game_state.apply_move(from_c, to_c)
	if not ok: return
	if capture: AudioManager.sfx_capture(); HapticManager.capture()
	else: AudioManager.sfx_move(); HapticManager.move()
	if is_online: NetworkManager.send_move(from_c, to_c)
	move_played.emit(from_c, to_c)
	_refresh()
	if game_state.is_finished(): _end()
	else: _check_ai()

# ── IA ─────────────────────────────────────────────────────────
func _check_ai() -> void:
	if is_online or game_state == null or game_state.is_finished(): return
	if game_state.turn == player_color: return
	var profile := AI.get_ai_profile(game_state.galaxy_id)
	var delay := (profile["delay_ms"][0] + randf() * \
		(profile["delay_ms"][1] - profile["delay_ms"][0])) / 1000.0
	ai_timer.wait_time = delay
	ai_timer.start()

func _ai_play() -> void:
	if game_state == null or game_state.is_finished(): return
	var mv = AI.get_ai_move(game_state.board, game_state.turn, game_state.ai_diff)
	if mv != null: _play(mv["from"], mv["to"])

# ── Fin ────────────────────────────────────────────────────────
func _end() -> void:
	var r := game_state.result
	var winner: String = r.get("winner","")
	var stake: int = Galaxies.get_galaxy(game_state.galaxy_id).get("stake", 0)
	if winner == player_color: AudioManager.sfx_victory(); HapticManager.victory()
	else: AudioManager.sfx_defeat()
	GameManager.finalize_game(winner, stake)
	if result_overlay: result_overlay.show()
	game_over.emit(r)

func _update_hud() -> void:
	if hud and hud.has_method("update_hud"): hud.update_hud(game_state)

# ── Réseau (messages reçus) ─────────────────────────────────────
func apply_online_move(from_c: String, to_c: String) -> void:
	_play(from_c, to_c)

func _on_back_to_home() -> void:
	SaveManager.clear_pending_game()
	GameManager.navigate("home")
