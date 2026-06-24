# src/core/GameState.gd — État complet d'une partie DOSCO
class_name GameState
extends RefCounted

enum Mode { VS_AI, LOCAL_2P, ONLINE }
enum Status { WAITING, PLAYING, FINISHED }

var board: Dictionary = {}
var turn: String = "W"
var moves_since_capture: int = 0
var last_move: String = ""
var move_history: Array = []
var result: Dictionary = {}
var status: Status = Status.WAITING
var mode: Mode = Mode.VS_AI
var player_color: String = "W"
var ai_diff: String = "n3"
var galaxy_id: String = "voie_lactee"
var selected: String = ""
var valid_moves: Array = []
var valid_captures: Array = []

func reset(p_mode: Mode, p_player_color: String = "W",
           p_ai_diff: String = "n3", p_galaxy: String = "voie_lactee") -> void:
	board = _deep_copy(Constants.INIT_BOARD)
	turn = "W"
	moves_since_capture = 0
	last_move = ""
	move_history = []
	result = {}
	status = Status.PLAYING
	mode = p_mode
	player_color = p_player_color
	ai_diff = p_ai_diff
	galaxy_id = p_galaxy
	selected = ""
	valid_moves = []
	valid_captures = []

func select(coord: String) -> void:
	selected = coord
	var mv := Rules.get_moves(coord, board)
	valid_moves = mv["moves"]
	valid_captures = mv["captures"]

func deselect() -> void:
	selected = ""
	valid_moves = []
	valid_captures = []

func apply_move(from_coord: String, to_coord: String) -> bool:
	if from_coord.is_empty() or to_coord.is_empty(): return false
	if not board.has(from_coord): return false
	if board[from_coord]["color"] != turn: return false

	var mv_data := Rules.get_moves(from_coord, board)
	var is_capture := to_coord in mv_data["captures"]
	var is_move    := to_coord in mv_data["moves"]
	if not is_capture and not is_move: return false

	# Capture obligatoire
	var all_mv := Rules.get_all_moves(turn, board)
	var has_cap := false
	for m in all_mv:
		if m["is_capture"]: has_cap = true; break
	if has_cap and not is_capture: return false

	# Appliquer
	var piece = board[from_coord].duplicate()
	board.erase(from_coord)
	board[to_coord] = piece
	last_move = to_coord
	moves_since_capture = 0 if is_capture else moves_since_capture + 1
	move_history.append({"from": from_coord, "to": to_coord, "capture": is_capture})

	# Fin de partie ?
	var end_result = Rules.check_end(board, to_coord, turn, moves_since_capture)
	if end_result != null:
		result = end_result
		status = Status.FINISHED
	else:
		turn = "B" if turn == "W" else "W"

	deselect()
	return true

func is_finished() -> bool:
	return status == Status.FINISHED

func get_winner() -> String:
	return result.get("winner", "")

func _deep_copy(d: Dictionary) -> Dictionary:
	var copy := {}
	for k in d: copy[k] = d[k].duplicate()
	return copy
