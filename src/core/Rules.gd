# src/core/Rules.gd — Règles de jeu DOSCO (implémentation complète)
extends Node

func get_moves(coord: String, board: Dictionary) -> Dictionary:
	var star = board.get(coord)
	if not star: return {"moves": [], "captures": []}

	var color: String = star["color"]
	var type_name: String = star["type"]
	if not Constants.DIRS.has(color) or not Constants.DIRS[color].has(type_name):
		return {"moves": [], "captures": []}

	var dirs: Array = Constants.DIRS[color][type_name]
	var cr := Constants.to_cr(coord)
	var moves := []; var captures := []

	for d in dirs:
		var dest := Constants.to_coord(cr["c"] + d[0], cr["r"] + d[1])
		if dest.is_empty(): continue
		var occ = board.get(dest)
		if occ == null: moves.append(dest)
		elif occ["color"] != color: captures.append(dest)

	return {"moves": moves, "captures": captures}

func get_all_moves(color: String, board: Dictionary) -> Array:
	var result := []; var has_capture := false
	for coord in board:
		if board[coord]["color"] != color: continue
		var mv := get_moves(coord, board)
		if mv["captures"].size() > 0: has_capture = true; break
	for coord in board:
		if board[coord]["color"] != color: continue
		var mv := get_moves(coord, board)
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
	var whites := []; var blues := []
	for coord in board:
		if board[coord]["color"] == "W": whites.append(coord)
		else: blues.append(coord)

	if whites.is_empty():
		return {"winner": "B", "reason": "Élimination", "type": "elimination"}
	if blues.is_empty():
		return {"winner": "W", "reason": "Élimination", "type": "elimination"}

	if last_move == Constants.INFILTRATION_B and board.has(Constants.INFILTRATION_B) \
			and board[Constants.INFILTRATION_B]["color"] == "B":
		return {"winner": "B", "reason": "Infiltration", "type": "infiltration"}
	if last_move == Constants.INFILTRATION_W and board.has(Constants.INFILTRATION_W) \
			and board[Constants.INFILTRATION_W]["color"] == "W":
		return {"winner": "W", "reason": "Infiltration", "type": "infiltration"}

	if moves_since_capture >= Constants.MAX_MOVES_NO_CAPTURE:
		return {"winner": null, "reason": "Nulle — 50 coups", "type": "draw"}

	return null

func apply_move(board: Dictionary, mv: Dictionary) -> Dictionary:
	var new_board := board.duplicate(true)
	var piece = new_board[mv["from"]].duplicate()
	new_board.erase(mv["from"])
	new_board[mv["to"]] = piece
	return new_board
