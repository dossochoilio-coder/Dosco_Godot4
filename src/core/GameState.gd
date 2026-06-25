# src/core/GameState.gd
class_name GameState
extends RefCounted

enum Mode { VS_AI, LOCAL_2P, ONLINE }
enum Status { WAITING, PLAYING, FINISHED }

var board: Dictionary = {}
var turn: String = "W"
var moves_since_capture: int = 0
var last_move: String = ""
var result: Dictionary = {}
var status: Status = Status.WAITING
var mode: Mode = Mode.VS_AI
var player_color: String = "W"
var ai_diff: String = "n3"
var galaxy_id: String = "voie_lactee"
var selected: String = ""
var valid_moves: Array = []
var valid_captures: Array = []

func reset(p_mode: Mode, p_player_color: String = "W", p_ai_diff: String = "n3", p_galaxy: String = "voie_lactee") -> void:
    board.clear()
    turn = "W"
    moves_since_capture = 0
    last_move = ""
    result.clear()
    status = Status.PLAYING
    mode = p_mode
    player_color = p_player_color
    ai_diff = p_ai_diff
    galaxy_id = p_galaxy
    selected = ""
    valid_moves.clear()
    valid_captures.clear()

func is_finished() -> bool:
    return status == Status.FINISHED

func apply_move(from_c: String, to_c: String) -> bool:
    if not board.has(from_c):
        return false

    var piece: Dictionary = board[from_c]
    board.erase(from_c)
    board[to_c] = piece

    if to_c in valid_captures:
        moves_since_capture = 0
    else:
        moves_since_capture += 1

    last_move = to_c
    return true
