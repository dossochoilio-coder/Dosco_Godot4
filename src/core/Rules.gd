# src/core/AI.gd — Moteur IA DOSCO (autoload)
# PAS de class_name ici — conflit avec le nom de l'autoload "AI"
extends Node

var _deadline_ms: int = 0

func eval_board(board: Dictionary, color: String) -> int:
	var opp: String  = "B" if color == "W" else "W"
	var score: int   = 0
	for coord in board:
		var star: Dictionary = board[coord] as Dictionary
		var is_me: bool      = star["color"] == color
		var pv: int          = Constants.PIECE_VALUES.get(star["type"], 50) as int
		var cr: Dictionary   = Constants.to_cr(coord)
		var r: int           = cr["r"] as int
		if is_me:
			score += pv
			var adv_me: int = r if color == "W" else (8 - r)
			score += adv_me * 6
			if coord in Constants.CENTER_CELLS: score += 25
			if color == "W" and Constants.NEAR_INFIL_W.has(coord):
				score += Constants.NEAR_INFIL_W[coord] as int
			elif color == "B" and Constants.NEAR_INFIL_B.has(coord):
				score += Constants.NEAR_INFIL_B[coord] as int
		else:
			score -= pv
			var adv_opp: int = r if opp == "W" else (8 - r)
			score -= adv_opp * 5
			if coord in Constants.CENTER_CELLS: score -= 22
			if opp == "W" and Constants.NEAR_INFIL_W.has(coord):
				score -= (Constants.NEAR_INFIL_W[coord] as int) + 20
			elif opp == "B" and Constants.NEAR_INFIL_B.has(coord):
				score -= (Constants.NEAR_INFIL_B[coord] as int) + 20
	return score

func order_moves(moves: Array, board: Dictionary, killers: Array) -> Array:
	var scored: Array = []
	for mv in moves:
		var mv_d: Dictionary = mv as Dictionary
		var s: int = 0
		if board.has(mv_d["to"]):
			s += (Constants.PIECE_VALUES.get((board[mv_d["to"]] as Dictionary)["type"], 50) as int) * 10
		if mv_d["to"] in [Constants.INFILTRATION_W, Constants.INFILTRATION_B]: s += 500
		var key: String = str(mv_d["from"]) + "-" + str(mv_d["to"])
		if key in killers: s += 80
		scored.append({"mv": mv_d, "score": s})
	scored.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return (a["score"] as int) > (b["score"] as int))
	var result: Array = []
	for x in scored: result.append((x as Dictionary)["mv"])
	return result

func minimax_ab(board: Dictionary, depth: int, alpha: int, beta: int,
               is_max: bool, color: String, last_move: String,
               msc: int, killers: Array) -> int:
	var opp: String       = "B" if color == "W" else "W"
	var cur_color: String = color if is_max else opp
	var end_result: Variant = Rules.check_end(board, last_move, cur_color, msc)
	if end_result != null:
		var er: Dictionary = end_result as Dictionary
		var w: Variant     = er.get("winner")
		if w == null: return 0
		if str(w) == color: return 50000 - (10 - depth) * 100
		return -50000 + (10 - depth) * 100
	if depth == 0: return eval_board(board, color)
	if _deadline_ms > 0 and Time.get_ticks_msec() > _deadline_ms:
		return eval_board(board, color)
	var raw_moves: Array = Rules.get_all_moves(cur_color, board)
	if raw_moves.is_empty(): return eval_board(board, color)
	var moves: Array = order_moves(raw_moves, board, killers)
	var best: int = -99999 if is_max else 99999
	for mv in moves:
		var mv_d: Dictionary  = mv as Dictionary
		var new_board: Dictionary = Rules.apply_move(board, mv_d)
		var is_cap: bool      = mv_d.get("is_capture", false) as bool
		var new_msc: int      = 0 if is_cap else msc + 1
		var sc: int = minimax_ab(new_board, depth - 1, alpha, beta,
		                         not is_max, color, str(mv_d["to"]), new_msc, killers)
		if is_max:
			if sc > best: best = sc
			if best > alpha: alpha = best
		else:
			if sc < best: best = sc
			if best < beta: beta = best
		if beta <= alpha:
			var key: String = str(mv_d["from"]) + "-" + str(mv_d["to"])
			if key not in killers: killers.append(key)
			if killers.size() > 8: killers.pop_front()
			break
	return best

func search_best_move(board: Dictionary, color: String, depth: int) -> Variant:
	var moves: Array = Rules.get_all_moves(color, board)
	if moves.is_empty(): return null
	var ordered: Array = order_moves(moves, board, [])
	var best: Variant  = null
	var best_val: int  = -99999
	var killers: Array = []
	for mv in ordered:
		var mv_d: Dictionary  = mv as Dictionary
		var new_board: Dictionary = Rules.apply_move(board, mv_d)
		var is_cap: bool = mv_d.get("is_capture", false) as bool
		var sc: int = minimax_ab(new_board, depth - 1, -99999, 99999,
		                         false, color, str(mv_d["to"]), 0 if is_cap else 1, killers)
		if sc > best_val: best_val = sc; best = mv_d
	return best

func iterative_deepening(board: Dictionary, color: String,
                          max_depth: int, budget_ms: int) -> Variant:
	var moves: Array = Rules.get_all_moves(color, board)
	if moves.is_empty(): return null
	if moves.size() == 1: return moves[0]
	_deadline_ms = Time.get_ticks_msec() + budget_ms
	var best: Variant  = order_moves(moves, board, [])[0]
	for d: int in range(2, max_depth + 1):
		if Time.get_ticks_msec() > _deadline_ms: break
		var killers: Array  = []
		var local_best: Variant = null
		var local_val: int  = -99999
		var ordered: Array  = order_moves(moves, board, [])
		for mv in ordered:
			if Time.get_ticks_msec() > _deadline_ms: break
			var mv_d: Dictionary  = mv as Dictionary
			var new_board: Dictionary = Rules.apply_move(board, mv_d)
			var is_cap: bool = mv_d.get("is_capture", false) as bool
			var sc: int = minimax_ab(new_board, d - 1, -99999, 99999,
			                         false, color, str(mv_d["to"]), 0 if is_cap else 1, killers)
			if sc > local_val: local_val = sc; local_best = mv_d
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
	if profiles.has(galaxy_id): return profiles[galaxy_id] as Dictionary
	return profiles["voie_lactee"] as Dictionary
