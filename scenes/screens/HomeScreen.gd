# scenes/screens/HomeScreen.gd — Menu principal DOSCO
extends Control

@onready var lbl_name: Label = $Body/PlayerBanner/Name
@onready var lbl_stars: Label = $Body/PlayerBanner/Stars
@onready var btn_online: Button = $Body/CTAs/BtnOnline
@onready var btn_vsai: Button = $Body/CTAs/BtnVsAI

func _ready() -> void:
	_refresh_ui()
	GameManager.stars_updated.connect(func(_s): _refresh_ui())
	if btn_online:
		btn_online.pressed.connect(func():
			AudioManager.sfx_connect(); HapticManager.light()
			GameManager.navigate("online"))
	if btn_vsai:
		btn_vsai.pressed.connect(func():
			AudioManager.sfx_click(); HapticManager.light()
			GameManager.navigate("vsai"))

func _refresh_ui() -> void:
	var u := GameManager.current_user
	if lbl_name:  lbl_name.text = u.get("name", "Commandant")
	if lbl_stars: lbl_stars.text = "★ " + str(GameManager.stars)
