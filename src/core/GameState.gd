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

func reset(p_mode: Mode, p_player_color: String = "W", p_ai_diff: String = "n3", p_galaxy: String = "voie_lactee") -> void:
    # In a real implementation, this would load from Constants.INIT_BOARD
    board = {}
    turn = "W"
    moves_since_capture = 0
    last_move = ""
    result = {}
    status = Status.PLAYING
    mode = p_mode
    player_color = p_player_color
    ai_diff = p_ai_diff
    galaxy_id = p_galaxy
    selected = ""

func is_finished() -> bool:
    return status == Status.FINISHED

func get_winner() -> String:
    return result.get("winner", "")
