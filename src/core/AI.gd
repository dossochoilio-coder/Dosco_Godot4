# src/core/AI.gd — Moteur IA DOSCO (autoload)
# IMPORTANT: pas de class_name ici (conflit avec le nom de l'autoload "AI")
extends Node

var _deadline_ms: int = 0

func eval_board(board: Dictionary, color: String) -> int:
	var opp := "B" if color == "W" else "W"
	var score := 0
	for coord in board:
		var star: Dictionary = board[coord]
		var is_me: bool = star["color"] == color
		var pv: int = Constants.PIECE_VALUES.get(star["type"], 50)
		var cr: Dictionary = Constants.to_cr(coord)
		var r: int = cr["r"]
		if is_me:
			score += pv
			var advance: int = r if color == "W" else (8 - r)
			score += advance * 6
			if coord in Constants.CENTER_CELLS: score += 25
			if color == "W" and Constants.NEAR_INFIL_W.has(coord):
				score += Constants.NEAR_INFIL_W[coord]
			elif color == "B" and Constants.NEAR_INFIL_B.has(coord):
				score += Constants.NEAR_INFIL_B[coord]
		else:
			score -= pv
			var advance: int = r if opp == "W" else (8 - r)
			score -= advance * 5
			if coord in Constants.CENTER_CELLS: score -= 22
			if opp == "W" and Constants.NEAR_INFIL_W.has(coord):
				score -= Constants.NEAR_INFIL_W[coord] + 20
			elif opp == "B" and Constants.NEAR_INFIL_B.has(coord):
				score -= Constants.NEAR_INFIL_B[coord] + 20
	return score

func order_moves(moves: Array, board: Dictionary, killers: Array) -> Array:
	var scored: Array = []
	for mv in moves:
		var s: int = 0
		if board.has(mv["to"]):
			s += Constants.PIECE_VALUES.get(board[mv["to"]]["type"], 50) * 10
		if mv["to"] in [Constants.INFILTRATION_W, Constants.INFILTRATION_B]: s += 500
		var key: String = mv["from"] + "-" + mv["to"]
		if key in killers: s += 80
		scored.append({"mv": mv, "score": s})
	scored.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["score"] > b["score"])
	var result: Array = []
	for x in scored: result.append(x["mv"])
	return result

func minimax_ab(board: Dictionary, depth: int, alpha: int, beta: int,
               is_max: bool, color: String, last_move: String,
               msc: int, killers: Array) -> int:
	var opp: String = "B" if color == "W" else "W"
	var cur_color: String = color if is_max else opp
	var end_result = Rules.check_end(board, last_move, cur_color, msc)
	if end_result != null:
		if end_result["winner"] == color: return 50000 - (10 - depth) * 100
		elif end_result["winner"] == null: return 0
		else: return -50000 + (10 - depth) * 100
	if depth == 0: return eval_board(board, color)
	if _deadline_ms > 0 and Time.get_ticks_msec() > _deadline_ms:
		return eval_board(board, color)
	var raw_moves: Array = Rules.get_all_moves(cur_color, board)
	if raw_moves.is_empty(): return eval_board(board, color)
	var moves: Array = order_moves(raw_moves, board, killers)
	var best: int = -99999 if is_max else 99999
	for mv in moves:
		var new_board: Dictionary = Rules.apply_move(board, mv)
		var new_msc: int = 0 if mv["is_capture"] else msc + 1
		var sc: int = minimax_ab(new_board, depth - 1, alpha, beta,
		                         not is_max, color, mv["to"], new_msc, killers)
		if is_max:
			if sc > best: best = sc
			if best > alpha: alpha = best
		else:
			if sc < best: best = sc
			if best < beta: beta = best
		if beta <= alpha:
			var key: String = mv["from"] + "-" + mv["to"]
			if key not in killers: killers.append(key)
			if killers.size() > 8: killers.pop_front()
			break
	return best

func search_best_move(board: Dictionary, color: String, depth: int) -> Variant:
	var moves: Array = Rules.get_all_moves(color, board)
	if moves.is_empty(): return null
	var ordered: Array = order_moves(moves, board, [])
	var best: Variant = null
	var best_val: int = -99999
	var killers: Array = []
	for mv in ordered:
		var new_board: Dictionary = Rules.apply_move(board, mv)
		var sc: int = minimax_ab(new_board, depth - 1, -99999, 99999,
		                         false, color, mv["to"], 0, killers)
		if sc > best_val: best_val = sc; best = mv
	return best

func iterative_deepening(board: Dictionary, color: String,
                          max_depth: int, budget_ms: int) -> Variant:
	var moves: Array = Rules.get_all_moves(color, board)
	if moves.is_empty(): return null
	if moves.size() == 1: return moves[0]
	_deadline_ms = Time.get_ticks_msec() + budget_ms
	var best: Variant = order_moves(moves, board, [])[0]
	for d in range(2, max_depth + 1):
		if Time.get_ticks_msec() > _deadline_ms: break
		var killers: Array = []
		var local_best: Variant = null
		var local_val: int = -99999
		var ordered: Array = order_moves(moves, board, [])
		for mv in ordered:
			if Time.get_ticks_msec() > _deadline_ms: break
			var new_board: Dictionary = Rules.apply_move(board, mv)
			var sc: int = minimax_ab(new_board, d - 1, -99999, 99999,
			                         false, color, mv["to"], 0, killers)
			if sc > local_val: local_val = sc; local_best = mv
		if local_best != null: best = local_best
	_deadline_ms = 0
	return best

func get_ai_move(board: Dictionary, color: String, diff: String) -> Variant:
	var moves: Array = Rules.get_all_moves(color, board)
	if moves.is_empty(): return null
	match diff:
		"n1": return moves[randi() % moves.size()]
		"n2":
			if randf() < 0.15: return moves[randi() % moves.size()]
			return search_best_move(board, color, 2)
		"n3":
			if randf() < 0.10: return moves[randi() % moves.size()]
			return search_best_move(board, color, 3)
		"n4":
			if randf() < 0.05: return moves[randi() % moves.size()]
			return search_best_move(board, color, 4)
		"n6": return iterative_deepening(board, color, 6, 1500)
		_:    return iterative_deepening(board, color, 7, 2500)

func get_ai_profile(galaxy_id: String) -> Dictionary:
	var profiles: Dictionary = {
		"voie_lactee": {"name": "NEBULEUSE",  "level": "n2", "delay_ms": [150, 250]},
		"andromede":   {"name": "PULSARE",    "level": "n3", "delay_ms": [300, 500]},
		"sombrero":    {"name": "QUASAR",     "level": "n4", "delay_ms": [500, 700]},
		"tourbillon":  {"name": "SUPERNOVA",  "level": "n6", "delay_ms": [700, 1000]},
		"cigare":      {"name": "TROU NOIR",  "level": "n7", "delay_ms": [1000, 1600]},
	}
	return profiles.get(galaxy_id, profiles["voie_lactee"])
