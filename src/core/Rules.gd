# src/core/Rules.gd
extends Node

func get_moves(coord: String, board: Dictionary) -> Dictionary:
    # Placeholder - full implementation from original
    return {"moves": [], "captures": []}

func get_all_moves(color: String, board: Dictionary) -> Array:
    return []

func check_end(board: Dictionary, last_move: String, color: String, moves_since_capture: int) -> Variant:
    return null

func apply_move(board: Dictionary, mv: Dictionary) -> Dictionary:
    var new_board = board.duplicate(true)
    if mv.has("from") and mv.has("to"):
        if new_board.has(mv["from"]):
            new_board[mv["to"]] = new_board[mv["from"]]
            new_board.erase(mv["from"])
    return new_board
