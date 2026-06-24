# scenes/screens/MissionsScreen.gd
extends Control

func _ready() -> void:
	var back := get_node_or_null("BackButton")
	if back: back.pressed.connect(func(): AudioManager.sfx_click(); GameManager.navigate("home"))
