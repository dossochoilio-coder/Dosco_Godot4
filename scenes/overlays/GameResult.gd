# scenes/overlays/GameResult.gd
# Overlay fin de partie : victoire / défaite / nulle
# Affiche le résultat, les étoiles gagnées/perdues, propose revanche ou lobby
extends Control

signal request_rematch
signal go_lobby

@onready var icon_lbl: Label = $Panel/VBox/Icon
@onready var result_lbl: Label = $Panel/VBox/Result
@onready var reason_lbl: Label = $Panel/VBox/Reason
@onready var stars_lbl: Label = $Panel/VBox/Stars
@onready var btn_rematch: Button = $Panel/VBox/Buttons/BtnRematch
@onready var btn_lobby: Button = $Panel/VBox/Buttons/BtnLobby

func _ready() -> void:
	btn_rematch.pressed.connect(_on_rematch)
	btn_lobby.pressed.connect(_on_lobby)

func show_result(winner: String, player_color: String,
                 reason: String, stake: int,
                 is_online: bool = false) -> void:
	var is_win := (winner == player_color)
	var is_draw := winner.is_empty()

	if is_draw:
		icon_lbl.text = "🤝"
		result_lbl.text = LangManager.t("NULLE")
		result_lbl.modulate = Color(0.9, 0.75, 0.2)
		stars_lbl.text = "±0 ⭐"
		stars_lbl.modulate = Color(0.7, 0.7, 0.7)
	elif is_win:
		icon_lbl.text = "🏆"
		result_lbl.text = LangManager.t("VICTOIRE")
		result_lbl.modulate = Color(0.25, 0.95, 0.55)
		stars_lbl.text = "+" + str(stake) + " ⭐"
		stars_lbl.modulate = Color(0.95, 0.78, 0.2)
	else:
		icon_lbl.text = "💫"
		result_lbl.text = LangManager.t("DÉFAITE")
		result_lbl.modulate = Color(1.0, 0.4, 0.45)
		stars_lbl.text = "-" + str(stake) + " ⭐"
		stars_lbl.modulate = Color(0.8, 0.35, 0.4)

	reason_lbl.text = _translate_reason(reason)
	btn_rematch.visible = is_online
	btn_rematch.text = LangManager.t("REVANCHE")
	btn_lobby.text = LangManager.t("LOBBY")

	show()
	_play_sounds(is_win, is_draw)

func _translate_reason(reason: String) -> String:
	if reason.contains("Infiltration"):
		return LangManager.t("INFILTRATION")
	elif reason.contains("Élimination") or reason.contains("Elimination"):
		return LangManager.t("ÉLIMINATION")
	elif reason.contains("Nulle") or reason.contains("Nulle"):
		return LangManager.t("NULLE") + " (50 coups)"
	elif reason.contains("abandon"):
		return LangManager.t("ABANDON")
	return reason

func _play_sounds(is_win: bool, is_draw: bool) -> void:
	if is_draw:
		AudioManager.play_sfx("draw")
	elif is_win:
		AudioManager.play_music("victory", false)
		HapticManager.victory()
	else:
		AudioManager.play_sfx("defeat")

func _on_rematch() -> void:
	HapticManager.light()
	AudioManager.sfx_click()
	request_rematch.emit()
	hide()

func _on_lobby() -> void:
	HapticManager.light()
	AudioManager.sfx_click()
	go_lobby.emit()
	hide()
