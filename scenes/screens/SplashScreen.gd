# SplashScreen.gd — Écran de démarrage DOSCO
extends Control

func _ready() -> void:
	AudioManager.play_music("ambient")
	var tw := create_tween()
	tw.tween_interval(2.0)
	tw.tween_callback(_go_next)

func _go_next() -> void:
	var session := AuthDB.get_session()
	if session.has("uid"):
		GameManager.login(session)
	else:
		GameManager.navigate("login")
