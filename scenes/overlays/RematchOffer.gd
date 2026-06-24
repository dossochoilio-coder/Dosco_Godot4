# scenes/overlays/RematchOffer.gd
# Overlay affiché quand l'adversaire propose une revanche
# OU quand le joueur veut en proposer une
extends Control

signal rematch_accepted
signal rematch_declined
signal rematch_requested

enum Mode { INCOMING, OUTGOING }
var _mode: Mode = Mode.INCOMING

@onready var title_lbl: Label = $Panel/VBox/Title
@onready var msg_lbl: Label = $Panel/VBox/Message
@onready var btn_accept: Button = $Panel/VBox/Buttons/BtnAccept
@onready var btn_decline: Button = $Panel/VBox/Buttons/BtnDecline
@onready var timer_lbl: Label = $Panel/VBox/Timer

const TIMEOUT_SEC := 30

var _timer_elapsed: float = 0.0
var _ticking: bool = false

func _ready() -> void:
	btn_accept.pressed.connect(_on_accept)
	btn_decline.pressed.connect(_on_decline)
	timer_lbl.hide()

func _process(delta: float) -> void:
	if not _ticking: return
	_timer_elapsed += delta
	var remaining := TIMEOUT_SEC - int(_timer_elapsed)
	timer_lbl.text = str(remaining) + "s"
	if remaining <= 0:
		_ticking = false
		rematch_declined.emit()
		hide()

# Afficher l'invitation REÇUE
func show_incoming() -> void:
	_mode = Mode.INCOMING
	title_lbl.text = "⚔️ " + LangManager.t("REVANCHE")
	msg_lbl.text = LangManager.t("L'adversaire propose une revanche !")
	btn_accept.text = LangManager.t("ACCEPTER")
	btn_decline.text = LangManager.t("REFUSER")
	timer_lbl.show()
	_timer_elapsed = 0.0
	_ticking = true
	show()
	HapticManager.medium()
	AudioManager.sfx_alert()

# Afficher l'envoi d'une demande
func show_outgoing() -> void:
	_mode = Mode.OUTGOING
	title_lbl.text = "⚔️ " + LangManager.t("REVANCHE")
	msg_lbl.text = LangManager.t("Demande de revanche envoyée…")
	btn_accept.hide()
	btn_decline.text = LangManager.t("ANNULER")
	timer_lbl.hide()
	_ticking = false
	show()

# Réponse reçue : l'adversaire a accepté
func on_rematch_accepted() -> void:
	_ticking = false
	rematch_accepted.emit()
	hide()

# Réponse reçue : l'adversaire a refusé
func on_rematch_declined() -> void:
	_ticking = false
	msg_lbl.text = LangManager.t("L'adversaire a refusé la revanche.")
	btn_accept.hide()
	btn_decline.text = LangManager.t("RETOUR")
	await get_tree().create_timer(2.0).timeout
	hide()

func _on_accept() -> void:
	HapticManager.light()
	AudioManager.sfx_connect()
	_ticking = false
	if _mode == Mode.INCOMING:
		rematch_accepted.emit()
	else:
		rematch_requested.emit()
	hide()

func _on_decline() -> void:
	HapticManager.light()
	AudioManager.sfx_click()
	_ticking = false
	rematch_declined.emit()
	hide()
