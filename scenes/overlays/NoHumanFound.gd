# scenes/overlays/NoHumanFound.gd
# Affiché après 10s de recherche sans adversaire humain
# Propose : jouer contre l'IA du niveau de la galaxie | Continuer la recherche | Annuler
extends Control

signal play_vs_ai(galaxy_id: String)
signal continue_search
signal cancel_search

var _galaxy_id: String = "voie_lactee"

@onready var ai_name_lbl: Label = $Panel/VBox/AIName
@onready var galaxy_lbl: Label = $Panel/VBox/Galaxy
@onready var btn_vs_ai: Button = $Panel/VBox/Buttons/BtnVsAI
@onready var btn_continue: Button = $Panel/VBox/Buttons/BtnContinue
@onready var btn_cancel: Button = $Panel/VBox/Buttons/BtnCancel

func _ready() -> void:
	btn_vs_ai.pressed.connect(_on_vs_ai)
	btn_continue.pressed.connect(_on_continue)
	btn_cancel.pressed.connect(_on_cancel)

func show_for_galaxy(galaxy_id: String) -> void:
	_galaxy_id = galaxy_id
	var profile := AI.get_ai_profile(galaxy_id)
	var galaxy := Galaxies.get_galaxy(galaxy_id)
	ai_name_lbl.text = "🤖 IA " + LangManager.t(profile["name"])
	galaxy_lbl.text = LangManager.t("AUCUN JOUEUR CONNECTÉ") + \
		"\n" + galaxy.get("name", "")
	btn_vs_ai.text = LangManager.t("JOUER CONTRE L'IA")
	btn_continue.text = LangManager.t("CONTINUER LA RECHERCHE")
	btn_cancel.text = LangManager.t("ANNULER")
	show()
	HapticManager.medium()
	AudioManager.sfx_alert()

func _on_vs_ai() -> void:
	HapticManager.light()
	AudioManager.sfx_click()
	play_vs_ai.emit(_galaxy_id)
	hide()

func _on_continue() -> void:
	HapticManager.light()
	AudioManager.sfx_click()
	continue_search.emit()
	hide()

func _on_cancel() -> void:
	HapticManager.light()
	AudioManager.sfx_click()
	cancel_search.emit()
	hide()
