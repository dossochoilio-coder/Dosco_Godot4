# scenes/Main.gd — Routeur principal DOSCO
extends Control

@onready var screen_container: Control = $ScreenContainer
@onready var transition_overlay: ColorRect = $TransitionOverlay

const SCREENS := {
	"splash":     "res://scenes/screens/SplashScreen.tscn",
	"login":      "res://scenes/screens/LoginScreen.tscn",
	"home":       "res://scenes/screens/HomeScreen.tscn",
	"online":     "res://scenes/screens/OnlineScreen.tscn",
	"vsai":       "res://scenes/screens/VsAIScreen.tscn",
	"game":       "res://scenes/game/GameBoard.tscn",
	"tournament": "res://scenes/screens/TournamentScreen.tscn",
	"ranking":    "res://scenes/screens/RankingScreen.tscn",
	"shop":       "res://scenes/screens/ShopScreen.tscn",
	"customize":  "res://scenes/screens/CustomizeScreen.tscn",
	"profile":    "res://scenes/screens/ProfileScreen.tscn",
	"missions":   "res://scenes/screens/MissionsScreen.tscn",
	"settings":   "res://scenes/screens/SettingsScreen.tscn",
	"rules":      "res://scenes/screens/RulesScreen.tscn",
	"tutorial":   "res://scenes/screens/TutorialScreen.tscn",
}

var _current: Node = null
var _current_name: String = ""

func _ready() -> void:
	GameManager.screen_changed.connect(_navigate)
	transition_overlay.color = Color(0.016, 0.031, 0.118, 0)
	_load_screen("splash")

func _navigate(name: String) -> void:
	if name == _current_name: return
	var tw := create_tween()
	tw.tween_property(transition_overlay, "color:a", 1.0, 0.15)
	tw.tween_callback(func(): _load_screen(name))
	tw.tween_property(transition_overlay, "color:a", 0.0, 0.2)

func _load_screen(name: String) -> void:
	if _current:
		_current.queue_free()
		_current = null
	if not SCREENS.has(name):
		push_error("Écran inconnu: " + name)
		return
	var scene := load(SCREENS[name]).instantiate()
	_current = scene
	_current_name = name
	screen_container.add_child(scene)
