# src/core/Rules.gd
extends Node

func get_moves(coord: String, board: Dictionary) -> Dictionary:
	var star: Variant = board.get(coord)
	if star == null: return {"moves": [], "captures": []}
	var star_d: Dictionary = star as Dictionary
	var color: String = star_d["color"]
	var type_name: String = star_d["type"]
	if not Constants.DIRS.has(color) or not Constants.DIRS[color].has(type_name):
		return {"moves": [], "captures": []}
	var dirs: Array = Constants.DIRS[color][type_name]
	var cr: Dictionary = Constants.to_cr(coord)
	var moves: Array = []
	var captures: Array = []
	for d in dirs:
		var dest: String = Constants.to_coord(cr["c"] + int(d[0]), cr["r"] + int(d[1]))
		if dest.is_empty(): continue
		var occ: Variant = board.get(dest)
		if occ == null:
			moves.append(dest)
		else:
			if (occ as Dictionary)["color"] != color: captures.append(dest)
	return {"moves": moves, "captures": captures}

func get_all_moves(color: String, board: Dictionary) -> Array:
	var result: Array = []
	var has_capture: bool = false
	for coord in board:
		if (board[coord] as Dictionary)["color"] != color: continue
		var mv: Dictionary = get_moves(coord, board)
		if (mv["captures"] as Array).size() > 0: has_capture = true; break
	for coord in board:
		if (board[coord] as Dictionary)["color"] != color: continue
		var mv: Dictionary = get_moves(coord, board)
		if has_capture:
			for cap in mv["captures"]:
				result.append({"from": coord, "to": cap, "is_capture": true})
		else:
			for dest in mv["moves"]:
				result.append({"from": coord, "to": dest, "is_capture": false})
			for cap in mv["captures"]:
				result.append({"from": coord, "to": cap, "is_capture": true})
	return result

func check_end(board: Dictionary, last_move: String, _color: String,
               moves_since_capture: int) -> Variant:
	var whites: Array = []
	var blues: Array  = []
	for coord in board:
		if (board[coord] as Dictionary)["color"] == "W": whites.append(coord)
		else: blues.append(coord)
	if whites.is_empty():
		return {"winner": "B", "reason": "Elimination", "type": "elimination"}
	if blues.is_empty():
		return {"winner": "W", "reason": "Elimination", "type": "elimination"}
	if last_move == Constants.INFILTRATION_B \
			and board.has(Constants.INFILTRATION_B) \
			and (board[Constants.INFILTRATION_B] as Dictionary)["color"] == "B":
		return {"winner": "B", "reason": "Infiltration", "type": "infiltration"}
	if last_move == Constants.INFILTRATION_W \
			and board.has(Constants.INFILTRATION_W) \
			and (board[Constants.INFILTRATION_W] as Dictionary)["color"] == "W":
		return {"winner": "W", "reason": "Infiltration", "type": "infiltration"}
	if moves_since_capture >= Constants.MAX_MOVES_NO_CAPTURE:
		return {"winner": null, "reason": "Nulle 50 coups", "type": "draw"}
	return null

func apply_move(board: Dictionary, mv: Dictionary) -> Dictionary:
	var new_board: Dictionary = board.duplicate(true)
	var piece: Dictionary = (new_board[mv["from"]] as Dictionary).duplicate()
	new_board.erase(mv["from"])
	new_board[mv["to"]] = piece
	return new_board
