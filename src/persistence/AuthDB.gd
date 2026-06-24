# src/persistence/SaveManager.gd
extends Node

const SAVE_FILE   := "user://save_data.json"
const SEASON_FILE := "user://season.json"

func save_data(data: Dictionary) -> void: _write(SAVE_FILE, data)
func load_data() -> Dictionary: return _read(SAVE_FILE)
func save_season_data(data: Dictionary) -> void: _write(SEASON_FILE, data)
func load_season() -> Dictionary: return _read(SEASON_FILE)

func save_pending_game(config: Dictionary) -> void:
	var data: Dictionary = load_data()
	data["pending_game"] = config
	save_data(data)

func load_pending_game() -> Dictionary:
	var data: Dictionary = load_data()
	var pg: Variant = data.get("pending_game")
	if pg is Dictionary: return pg as Dictionary
	return {}

func clear_pending_game() -> void:
	var data: Dictionary = load_data()
	data.erase("pending_game")
	save_data(data)

func _read(path: String) -> Dictionary:
	if not FileAccess.file_exists(path): return {}
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null: return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Dictionary: return parsed as Dictionary
	return {}

func _write(path: String, data: Dictionary) -> void:
	var f: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if f == null: return
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
