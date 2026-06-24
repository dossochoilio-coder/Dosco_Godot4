# scenes/screens/OnlineScreen.gd — Sélection galaxie + recherche en ligne
extends Control

enum View { LOBBY, SEARCH, GAME_RESULT }
var _view: View = View.LOBBY
var _selected_galaxy: Dictionary = {}
var _search_elapsed: float = 0.0
var _no_human: bool = false

const SEARCH_TIMEOUT := 10.0

func _ready() -> void:
	_selected_galaxy = Galaxies.GALAXIES[0]
	_build_galaxy_list()
	_connect_network()
	_set_view(View.LOBBY)

func _process(delta: float) -> void:
	if _view == View.SEARCH:
		_search_elapsed += delta
		_update_search_timer()
		if _search_elapsed >= SEARCH_TIMEOUT and not _no_human:
			_no_human = true
			_show_no_human_options()

func _build_galaxy_list() -> void:
	var container := get_node_or_null("Lobby/GalaxyList")
	if not container: return
	for child in container.get_children(): child.queue_free()
	for galaxy in Galaxies.GALAXIES:
		var btn := Button.new()
		var affordable: bool = GameManager.stars >= galaxy["stake"]
		btn.text = galaxy["name"] + "\n★" + str(galaxy["stake"])
		btn.disabled = not affordable
		btn.pressed.connect(func(g=galaxy):
			if GameManager.stars < g["stake"]: return
			AudioManager.sfx_click(); HapticManager.light()
			_selected_galaxy = g
			_start_search())
		container.add_child(btn)

func _start_search() -> void:
	_search_elapsed = 0.0
	_no_human = false
	_set_view(View.SEARCH)
	GameManager.selected_galaxy = _selected_galaxy
	var stars := GameManager.stars
	if NetworkManager.is_connected_to_server():
		NetworkManager.find_match(_selected_galaxy["id"], stars)
	else:
		NetworkManager.connect_to_server(
			GameManager.current_user.get("name", "Joueur"), stars)

func _connect_network() -> void:
	if not NetworkManager.game_started.is_connected(_on_game_start):
		NetworkManager.game_started.connect(_on_game_start)
	if not NetworkManager.error_received.is_connected(_on_net_error):
		NetworkManager.error_received.connect(_on_net_error)

func _on_game_start(data: Dictionary) -> void:
	_no_human = false
	var player_color: String = data.get("color", "W")
	GameManager.start_online_game(_selected_galaxy["id"], player_color)

func _on_net_error(_msg: String) -> void:
	if _view == View.SEARCH:
		_no_human = true
		_show_no_human_options()

func _show_no_human_options() -> void:
	var overlay := get_node_or_null("NoHumanOverlay")
	if overlay: overlay.show()

func _update_search_timer() -> void:
	var lbl := get_node_or_null("Search/Timer")
	if lbl: lbl.text = str(int(SEARCH_TIMEOUT - _search_elapsed)) + "s"

func _set_view(v: View) -> void:
	_view = v
	get_node_or_null("Lobby").visible = (v == View.LOBBY) if get_node_or_null("Lobby") else false
	get_node_or_null("Search").visible = (v == View.SEARCH) if get_node_or_null("Search") else false

func _on_accept_ai() -> void:
	var profile := AI.get_ai_profile(_selected_galaxy["id"])
	GameManager.start_ai_game_online(_selected_galaxy["id"], profile["level"])

func _on_cancel_search() -> void:
	NetworkManager.cancel_search()
	_set_view(View.LOBBY)
