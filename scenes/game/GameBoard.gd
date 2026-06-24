# scenes/game/GameBoard.gd
extends Control

signal move_played(from_c: String, to_c: String)
signal game_over(result: Dictionary)

var game_state: GameState = null
var player_color: String  = "W"
var ai_diff: String       = "n3"
var is_online: bool       = false

@onready var cells_node:      Node    = $Board/Cells
@onready var pieces_node:     Node    = $Board/Pieces
@onready var hud:             Control = $HUD
@onready var ai_timer:        Timer   = $AITimer
@onready var result_overlay:  Control = $ResultOverlay

const CELL_SIZE:   float   = 46.0
const BOARD_ORIGIN: Vector2 = Vector2(14.0, 100.0)
const COL_CELL:    Color   = Color(0.04, 0.07, 0.17, 0.92)
const COL_SEL:     Color   = Color(0.28, 0.65, 1.00, 0.55)
const COL_MOVE:    Color   = Color(0.18, 0.90, 0.62, 0.38)
const COL_CAP:     Color   = Color(1.00, 0.32, 0.32, 0.55)
const COL_WHITE:   Color   = Color(0.96, 0.97, 1.00)
const COL_BLUE:    Color   = Color(0.40, 0.65, 1.00)

var _cell_rects:  Dictionary = {}
var _piece_rects: Dictionary = {}

func _ready() -> void:
	ai_timer.one_shot = true
	ai_timer.timeout.connect(_ai_play)
	var config: Dictionary = SaveManager.load_pending_game()
	if config.is_empty():
		config = {"galaxy": "voie_lactee", "ai": "n3", "mode": "vsai", "color": "W"}
	_start(config)

func _start(cfg: Dictionary) -> void:
	is_online     = cfg.get("mode", "vsai") == "online"
	player_color  = cfg.get("color", "W")
	ai_diff       = cfg.get("ai", "n3")
	var galaxy_id: String = cfg.get("galaxy", "voie_lactee")
	game_state = GameState.new()
	game_state.reset(
		GameState.Mode.ONLINE if is_online else GameState.Mode.VS_AI,
		player_color, ai_diff, galaxy_id)
	_build_visuals()
	_refresh()
	_check_ai()

func _build_visuals() -> void:
	for c in cells_node.get_children(): c.queue_free()
	for c in pieces_node.get_children(): c.queue_free()
	_cell_rects.clear(); _piece_rects.clear()
	for row_idx in Constants.BOARD_LAYOUT.size():
		var row: Array = Constants.BOARD_LAYOUT[row_idx]
		for col_idx in row.size():
			var coord: Variant = row[col_idx]
			if coord == null: continue
			var coord_str: String = str(coord)
			var pos: Vector2 = _coord_pos(coord_str)
			var cell: ColorRect = ColorRect.new()
			cell.size = Vector2(CELL_SIZE - 2.0, CELL_SIZE - 2.0)
			cell.position = pos
			cell.color = COL_CELL
			cells_node.add_child(cell)
			_cell_rects[coord_str] = cell

func _coord_pos(coord: String) -> Vector2:
	var cr: Dictionary = Constants.to_cr(coord)
	return BOARD_ORIGIN + Vector2(cr["c"] * CELL_SIZE, cr["r"] * CELL_SIZE)

func _refresh() -> void:
	if game_state == null: return
	for coord in _cell_rects:
		var cell: ColorRect = _cell_rects[coord]
		if coord == game_state.selected: cell.color = COL_SEL
		elif coord in game_state.valid_captures: cell.color = COL_CAP
		elif coord in game_state.valid_moves: cell.color = COL_MOVE
		else: cell.color = COL_CELL
	for c in pieces_node.get_children(): c.queue_free()
	_piece_rects.clear()
	for coord in game_state.board:
		var star: Dictionary = game_state.board[coord]
		var rect: ColorRect = ColorRect.new()
		rect.size = Vector2(CELL_SIZE * 0.7, CELL_SIZE * 0.7)
		rect.position = _coord_pos(coord) + Vector2(CELL_SIZE * 0.15, CELL_SIZE * 0.15)
		rect.color = COL_WHITE if star["color"] == "W" else COL_BLUE
		pieces_node.add_child(rect)
		_piece_rects[coord] = rect

func _input(event: InputEvent) -> void:
	if game_state == null or game_state.is_finished(): return
	if is_online and game_state.turn != player_color: return
	var pos: Vector2 = Vector2.ZERO
	if event is InputEventScreenTouch:
		if not (event as InputEventScreenTouch).pressed: return
		pos = (event as InputEventScreenTouch).position
	elif event is InputEventMouseButton:
		if not (event as InputEventMouseButton).pressed: return
		if (event as InputEventMouseButton).button_index != MOUSE_BUTTON_LEFT: return
		pos = (event as InputEventMouseButton).position
	else: return
	_handle_touch(pos)

func _handle_touch(pos: Vector2) -> void:
	var coord: String = _pos_to_coord(pos)
	if coord.is_empty(): return
	if not game_state.selected.is_empty():
		if coord == game_state.selected:
			game_state.deselect(); _refresh(); return
		if coord in game_state.valid_moves or coord in game_state.valid_captures:
			_play(game_state.selected, coord); return
		if game_state.board.has(coord) and \
				(game_state.board[coord] as Dictionary).get("color","") == game_state.turn:
			game_state.select(coord); AudioManager.sfx_move()
			HapticManager.selection(); _refresh(); return
		game_state.deselect(); _refresh(); return
	if game_state.board.has(coord) and \
			(game_state.board[coord] as Dictionary).get("color","") == game_state.turn:
		game_state.select(coord); AudioManager.sfx_move()
		HapticManager.selection(); _refresh()

func _pos_to_coord(pos: Vector2) -> String:
	for coord in _cell_rects:
		var r: ColorRect = _cell_rects[coord]
		if Rect2(r.position, r.size).has_point(pos): return coord
	return ""

func _play(from_c: String, to_c: String) -> void:
	var is_capture: bool = to_c in game_state.valid_captures
	var ok: bool = game_state.apply_move(from_c, to_c)
	if not ok: return
	if is_capture: AudioManager.sfx_capture(); HapticManager.capture()
	else: AudioManager.sfx_move(); HapticManager.move()
	if is_online: NetworkManager.send_move(from_c, to_c)
	move_played.emit(from_c, to_c)
	_refresh()
	if game_state.is_finished(): _on_end()
	else: _check_ai()

func _check_ai() -> void:
	if is_online or game_state == null or game_state.is_finished(): return
	if game_state.turn == player_color: return
	var profile: Dictionary = AI.get_ai_profile(game_state.galaxy_id)
	var delay_range: Array  = profile.get("delay_ms", [300, 500])
	var delay: float = (delay_range[0] + randf() * (delay_range[1] - delay_range[0])) / 1000.0
	ai_timer.wait_time = delay
	ai_timer.start()

func _ai_play() -> void:
	if game_state == null or game_state.is_finished(): return
	var mv: Variant = AI.get_ai_move(game_state.board, game_state.turn, game_state.ai_diff)
	if mv != null: _play((mv as Dictionary)["from"], (mv as Dictionary)["to"])

func _on_end() -> void:
	var r: Dictionary = game_state.result
	var winner: String = r.get("winner", "")
	var stake: int = (Galaxies.get_galaxy(game_state.galaxy_id) as Dictionary).get("stake", 0)
	if winner == player_color: AudioManager.sfx_victory(); HapticManager.victory()
	else: AudioManager.sfx_defeat()
	GameManager.finalize_game(winner, stake)
	if result_overlay: result_overlay.show()
	game_over.emit(r)

func apply_online_move(from_c: String, to_c: String) -> void:
	_play(from_c, to_c)

func show_hint(_msg: String, _duration: float = 2.0) -> void:
	pass
