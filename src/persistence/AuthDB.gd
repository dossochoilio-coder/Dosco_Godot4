# src/persistence/AuthDB.gd
extends Node

const USERS_FILE   := "user://users.json"
const SESSION_FILE := "user://session.json"

func get_users() -> Dictionary:
	var result: Dictionary = _read(USERS_FILE)
	return result

func save_users(users: Dictionary) -> void:
	_write(USERS_FILE, users)

func get_session() -> Dictionary:
	var result: Dictionary = _read(SESSION_FILE)
	return result

func save_session(session: Dictionary) -> void:
	_write(SESSION_FILE, session)

func clear_session() -> void:
	if FileAccess.file_exists(SESSION_FILE):
		DirAccess.remove_absolute(SESSION_FILE)

func register(name: String, email: String, password: String) -> Dictionary:
	name = name.strip_edges()
	email = email.strip_edges().to_lower()
	if name.length() < 3: return {"error": "Pseudo trop court (min. 3 caractères)."}
	if email.is_empty(): return {"error": "Email requis."}
	if password.length() < 4: return {"error": "Mot de passe trop court (min. 4)."}
	var users: Dictionary = get_users()
	var uname_key: String = "@" + name.to_lower()
	if users.has(email) or users.has(uname_key):
		return {"error": "Ce pseudo ou cet email est déjà utilisé."}
	var uid: String = "u_" + str(Time.get_ticks_msec())
	var session: Dictionary = {
		"uid": uid, "name": name, "email": email,
		"stars": 100, "wins": 0, "losses": 0, "pts": 0, "t": "Sirus",
	}
	var record: Dictionary = session.duplicate()
	record["_hash"] = password.sha256_text()
	users[email] = record
	users[uname_key] = record
	save_users(users)
	save_session(session)
	return {"user": session}

func login(identifier: String, password: String) -> Dictionary:
	identifier = identifier.strip_edges()
	var users: Dictionary = get_users()
	var key: String = identifier.to_lower()
	if not key.contains("@"): key = "@" + key
	var record: Variant = users.get(key)
	if record == null: record = users.get(identifier.to_lower())
	if record == null: return {"error": "Compte introuvable."}
	if (record as Dictionary).get("_hash", "") != password.sha256_text():
		return {"error": "Mot de passe incorrect."}
	var session: Dictionary = _strip_private(record as Dictionary)
	save_session(session)
	return {"user": session}

func guest_login() -> Dictionary:
	var uid: String = "guest_" + str(Time.get_ticks_msec())
	var session: Dictionary = {"uid": uid, "name": "Invité", "stars": 100,
	                            "wins": 0, "losses": 0, "pts": 0, "t": "Sirus"}
	save_session(session)
	return {"user": session}

func logout() -> void:
	clear_session()

func _strip_private(record: Dictionary) -> Dictionary:
	var s: Dictionary = record.duplicate()
	s.erase("_hash")
	return s

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
