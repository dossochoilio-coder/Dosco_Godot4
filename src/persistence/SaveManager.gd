# src/persistence/SaveManager.gd — Persistance locale DOSCO
extends Node

const SAVE_FILE   := "user://save_data.json"
const SEASON_FILE := "user://season.json"

func save_data(data: Dictionary) -> void:
	_write(SAVE_FILE, data)

func load_data() -> Dictionary:
	return _read(SAVE_FILE)

func save_season_data(data: Dictionary) -> void:
	_write(SEASON_FILE, data)

func load_season() -> Dictionary:
	return _read(SEASON_FILE)

func save_pending_game(game_config: Dictionary) -> void:
	var data := load_data()
	data["pending_game"] = game_config
	save_data(data)

func load_pending_game() -> Dictionary:
	return load_data().get("pending_game", {})

func clear_pending_game() -> void:
	var data := load_data()
	data.erase("pending_game")
	save_data(data)

func save_season(stars: int, wins: int, losses: int) -> void:
	save_season_data({"stars": stars, "wins": wins, "losses": losses})

func _read(path: String) -> Dictionary:
	if not FileAccess.file_exists(path): return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null: return {}
	var parsed := JSON.parse_string(f.get_as_text())
	f.close()
	return parsed if parsed is Dictionary else {}

func _write(path: String, data: Dictionary) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null: return
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
