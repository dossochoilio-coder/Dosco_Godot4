# scenes/overlays/NavDrawer.gd
# Menu de navigation latéral (hamburger)
# Traduit depuis le composant NAV_ITEMS du HTML
extends Control

signal navigate(screen: String)

@onready var items_list: VBoxContainer = $Panel/Scroll/Items
@onready var player_name_lbl: Label = $Panel/Header/Name
@onready var stars_lbl: Label = $Panel/Header/Stars
@onready var btn_close: Button = $Panel/Header/BtnClose
@onready var btn_logout: Button = $Panel/Footer/BtnLogout

const NAV_ITEMS := [
	{"icon": "🏠", "key": "Accueil",    "screen": "home"},
	{"icon": "🌐", "key": "En Ligne",   "screen": "online"},
	{"icon": "🤖", "key": "VS IA",      "screen": "vsai"},
	{"icon": "🏆", "key": "Tournois",   "screen": "tournament"},
	{"icon": "⭐", "key": "Classement", "screen": "ranking"},
	{"icon": "📶", "key": "Missions",   "screen": "missions"},
	{"icon": "📻", "key": "Boutique",   "screen": "shop"},
	{"icon": "🎨", "key": "Skins",      "screen": "customize"},
	{"icon": "👤", "key": "Profil",     "screen": "profile"},
	{"icon": "📖", "key": "Règles",     "screen": "rules"},
	{"icon": "🎓", "key": "Tutoriel",   "screen": "tutorial"},
	{"icon": "📜", "key": "Histoire",   "screen": "story"},
	{"icon": "⚙️", "key": "Réglages",  "screen": "settings"},
]

func _ready() -> void:
	btn_close.pressed.connect(close)
	if btn_logout:
		btn_logout.text = LangManager.t("DÉCONNEXION")
		btn_logout.pressed.connect(func():
			GameManager.logout(); close())
	_build_items()
	_refresh_header()

func _build_items() -> void:
	for child in items_list.get_children():
		child.queue_free()
	for item in NAV_ITEMS:
		var btn := Button.new()
		btn.text = item["icon"] + "  " + LangManager.t(item["key"])
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size = Vector2(0, 44)
		var screen_name: String = item["screen"]
		btn.pressed.connect(func():
			AudioManager.sfx_click(); HapticManager.light()
			navigate.emit(screen_name)
			GameManager.navigate(screen_name)
			close())
		items_list.add_child(btn)

func _refresh_header() -> void:
	var u := GameManager.current_user
	player_name_lbl.text = u.get("name", "Commandant")
	stars_lbl.text = "★ " + str(GameManager.stars)

func open() -> void:
	_refresh_header()
	show()
	HapticManager.light()
	AudioManager.sfx_click()
	# Animation slide-in depuis la gauche
	position.x = -300
	var tw := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(self, "position:x", 0.0, 0.22)

func close() -> void:
	var tw := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(self, "position:x", -300.0, 0.18)
	tw.tween_callback(hide)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		# Clic hors du panel → fermer
		var panel := get_node_or_null("Panel")
		if panel:
			var rect := Rect2(panel.global_position, panel.size)
			if not rect.has_point(event.position):
				close()
