# src/autoloads/GameManager.gd
extends Node

signal screen_changed(screen: String)
signal stars_updated(amount: int)
signal user_logged_in(user: Dictionary)

var current_screen: String = ""
var current_user: Dictionary = {}
var is_logged_in: bool = false
var lang: String = "fr"
var stars: int = 100
var wins: int = 0
var losses: int = 0
var win_streak: int = 0
var season_pts: int = 0
var selected_galaxy: Dictionary = {}
var server_leaderboard: Array = []

func _ready() -> void:
	_load_session()
	_load_season()
	_detect_lang()

func navigate(screen: String) -> void:
	current_screen = screen
	screen_changed.emit(screen)

func login(user: Dictionary) -> void:
	current_user = user
	is_logged_in = true
	AuthDB.save_session(user)
	stars = user.get("stars", 100)
	wins  = user.get("wins",  0)
	losses = user.get("losses", 0)
	user_logged_in.emit(user)
	navigate("home")

func logout() -> void:
	current_user = {}
	is_logged_in = false
	stars = 100; wins = 0; losses = 0
	AuthDB.clear_session()
	navigate("login")

func start_ai_game(galaxy_id: String, ai_level: String) -> void:
	selected_galaxy = Galaxies.get_galaxy(galaxy_id)
	SaveManager.save_pending_game({"galaxy": galaxy_id, "ai": ai_level, "mode": "vsai"})
	navigate("game")

func start_online_game(galaxy_id: String, player_color: String) -> void:
	selected_galaxy = Galaxies.get_galaxy(galaxy_id)
	SaveManager.save_pending_game({"galaxy": galaxy_id, "color": player_color, "mode": "online"})
	navigate("game")

func add_stars(amount: int) -> void:
	stars += amount
	_save_season()
	stars_updated.emit(stars)

func deduct_stars(amount: int) -> bool:
	if stars < amount: return false
	stars -= amount
	_save_season()
	stars_updated.emit(stars)
	return true

func finalize_game(winner: String, stake: int) -> void:
	var cfg: Dictionary = SaveManager.load_pending_game()
	var player_color: String = cfg.get("color", "W")
	var is_win: bool  = (winner == player_color)
	var is_draw: bool = winner.is_empty()
	if is_win:
		add_stars(stake); wins += 1; win_streak += 1; season_pts += 10 + stake / 10
	elif not is_draw:
		deduct_stars(stake); losses += 1; win_streak = 0
	_save_season()

func _load_session() -> void:
	var s: Dictionary = AuthDB.get_session()
	if s.has("uid"):
		current_user = s; is_logged_in = true
		stars  = s.get("stars",  100)
		wins   = s.get("wins",   0)
		losses = s.get("losses", 0)

func _load_season() -> void:
	var s: Dictionary = SaveManager.load_season()
	if not s.is_empty():
		stars      = s.get("stars",      stars)
		wins       = s.get("wins",       wins)
		losses     = s.get("losses",     losses)
		win_streak = s.get("winStreak",  0)
		season_pts = s.get("pts",        0)

func _save_season() -> void:
	SaveManager.save_season_data({
		"stars": stars, "wins": wins, "losses": losses,
		"winStreak": win_streak, "pts": season_pts})

func _detect_lang() -> void:
	var sys: String = OS.get_locale_language()
	lang = sys if sys in ["fr","en","es","ar","pt"] else "fr"
	LangManager.set_lang(lang)
