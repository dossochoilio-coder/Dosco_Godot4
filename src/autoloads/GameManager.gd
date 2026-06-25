# src/autoloads/GameManager.gd
extends Node

signal screen_changed(screen: String)
signal stars_updated(amount: int)
signal user_logged_in(user: Dictionary)

var current_user: Dictionary = {}
var stars: int = 100
var wins: int = 0
var losses: int = 0
var win_streak: int = 0
var season_pts: int = 0
var selected_galaxy: Dictionary = {}
var lang: String = "fr"

func _ready() -> void:
    _load_session()
    _load_season()
    _detect_lang()

func navigate(screen: String) -> void:
    screen_changed.emit(screen)

func _load_session() -> void:
    var s: Dictionary = SaveManager.load_data()
    if s.has("uid"):
        current_user = s

func _load_season() -> void:
    var s: Dictionary = SaveManager.load_season()
    stars = s.get("stars", 100)
    wins = s.get("wins", 0)
    losses = s.get("losses", 0)
    win_streak = s.get("winStreak", 0)
    season_pts = s.get("pts", 0)

func _save_season() -> void:
    SaveManager.save_season_data({
        "stars": stars,
        "wins": wins,
        "losses": losses,
        "winStreak": win_streak,
        "pts": season_pts
    })

func _detect_lang() -> void:
    var sys: String = OS.get_locale_language()
    lang = sys if sys in ["fr","en","es","ar","pt"] else "fr"
    LangManager.set_lang(lang)

func add_stars(amount: int) -> void:
    stars += amount
    _save_season()
    stars_updated.emit(stars)
