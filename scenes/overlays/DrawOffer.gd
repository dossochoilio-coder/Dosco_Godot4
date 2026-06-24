# scenes/overlays/DrawOffer.gd
# Overlay modal proposant la nulle à l'adversaire (humain ou IA)
# Affiché quand l'adversaire propose la nulle OU quand le joueur veut proposer
extends Control

signal draw_accepted
signal draw_declined

enum Mode { RECEIVED, SENT }

var _mode: Mode = Mode.RECEIVED
var _ai_level: String = "n3"
var _ai_opp_pieces: int = 0
var _my_pieces: int = 0
var _ai_infiltrating: bool = false

@onready var title_label: Label = $Panel/VBox/Title
@onready var subtitle_label: Label = $Panel/VBox/Subtitle
@onready var btn_accept: Button = $Panel/VBox/Buttons/BtnAccept
@onready var btn_decline: Button = $Panel/VBox/Buttons/BtnDecline
@onready var hint_label: Label = $Panel/VBox/Hint

func _ready() -> void:
	btn_accept.pressed.connect(_on_accept)
	btn_decline.pressed.connect(_on_decline)
	_update_ui()

# Afficher pour une proposition REÇUE de l'adversaire
func show_received(ai_level: String = "", ai_pieces: int = 0,
                   my_pieces: int = 0, infiltrating: bool = false) -> void:
	_mode = Mode.RECEIVED
	_ai_level = ai_level
	_ai_opp_pieces = ai_pieces
	_my_pieces = my_pieces
	_ai_infiltrating = infiltrating
	_update_ui()
	show()
	HapticManager.medium()
	AudioManager.sfx_alert()

# Afficher pour confirmation d'envoi
func show_sent() -> void:
	_mode = Mode.SENT
	_update_ui()
	show()

func _update_ui() -> void:
	if _mode == Mode.RECEIVED:
		title_label.text = "🤝 " + LangManager.t("NULLE PROPOSÉE")
		subtitle_label.text = LangManager.t("L'adversaire propose la nulle.")
		btn_accept.text = LangManager.t("ACCEPTER")
		btn_decline.text = LangManager.t("REFUSER")
		btn_accept.show()
		btn_decline.show()
		hint_label.hide()
	else:
		title_label.text = "🤝 " + LangManager.t("PROPOSER LA NULLE ?")
		subtitle_label.text = LangManager.t("Soumettre une proposition de match nul.")
		btn_accept.text = LangManager.t("PROPOSER")
		btn_decline.text = LangManager.t("ANNULER")
		btn_accept.show()
		btn_decline.show()
		hint_label.hide()

func _on_accept() -> void:
	HapticManager.light()
	AudioManager.sfx_click()
	if _mode == Mode.RECEIVED:
		# IA : décider selon niveau et position
		if not _ai_level.is_empty():
			_ai_decide_draw()
		else:
			draw_accepted.emit()
	else:
		draw_accepted.emit()
	hide()

func _on_decline() -> void:
	HapticManager.light()
	AudioManager.sfx_click()
	draw_declined.emit()
	hide()

# Logique IA : accepte ou refuse selon sa position
func _ai_decide_draw() -> void:
	var diff := _ai_opp_pieces - _my_pieces
	var accept: bool

	match _ai_level:
		"n2": accept = diff <= 0 and not _ai_infiltrating
		"n3": accept = diff < 0 and not _ai_infiltrating
		"n4": accept = diff < -1 and not _ai_infiltrating
		"n6": accept = diff < -2 and not _ai_infiltrating
		_:    accept = diff < -3 and not _ai_infiltrating

	await get_tree().create_timer(0.7).timeout

	if accept:
		draw_accepted.emit()
	else:
		draw_declined.emit()
		# Message contextuel
		var msg: String
		if _ai_infiltrating:
			msg = LangManager.t("L'IA est en position de gagner. Nulle refusée.")
		elif diff > 0:
			msg = LangManager.t("L'IA a l'avantage. Nulle refusée.")
		else:
			msg = LangManager.t("L'adversaire a refusé la nulle")
		# Notifier le parent
		get_parent().show_hint(msg, 2.8)
