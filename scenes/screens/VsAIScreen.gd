# scenes/screens/VsAIScreen.gd — Choix galaxie et niveau IA
extends Control

func _ready() -> void:
	var container := get_node_or_null("GalaxyList")
	if not container: return
	for galaxy in Galaxies.GALAXIES:
		var btn := Button.new()
		var profile := AI.get_ai_profile(galaxy["id"])
		btn.text = galaxy["name"] + " — IA " + profile["name"] + "\n★" + str(galaxy["stake"])
		btn.pressed.connect(func(g=galaxy, p=profile):
			AudioManager.sfx_click(); HapticManager.light()
			GameManager.start_ai_game(g["id"], p["level"]))
		container.add_child(btn)
