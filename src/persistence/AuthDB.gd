# src/persistence/AuthDB.gd
extends Node

const USERS_FILE := "user://users.json"
const SESSION_FILE := "user://session.json"

func get_users() -> Dictionary:
    if FileAccess.file_exists(USERS_FILE):
        var f := FileAccess.open(USERS_FILE, FileAccess.READ)
        var data := JSON.parse_string(f.get_as_text())
        f.close()
        return data if data else {}
    return {}

func save_session(session: Dictionary) -> void:
    var f := FileAccess.open(SESSION_FILE, FileAccess.WRITE)
    f.store_string(JSON.stringify(session))
    f.close()
