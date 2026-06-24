# scenes/screens/LoginScreen.gd — Auth DOSCO
extends Control

var _tab: String = "login"  # "login" | "register"
var _show_sub_offer: bool = false
var _pending_user: Dictionary = {}

@onready var tab_login: Button = $Container/Tabs/TabLogin
@onready var tab_register: Button = $Container/Tabs/TabRegister
@onready var field_name: LineEdit = $Container/Fields/FieldName
@onready var field_email: LineEdit = $Container/Fields/FieldEmail
@onready var field_pass: LineEdit = $Container/Fields/FieldPass
@onready var btn_submit: Button = $Container/BtnSubmit
@onready var btn_guest: Button = $Container/BtnGuest
@onready var lbl_error: Label = $Container/LblError
@onready var email_row: Control = $Container/Fields/FieldEmail
@onready var sub_offer: Control = $SubOffer

func _ready() -> void:
	_set_tab("login")
	tab_login.pressed.connect(func(): _set_tab("login"))
	tab_register.pressed.connect(func(): _set_tab("register"))
	btn_submit.pressed.connect(_submit)
	btn_guest.pressed.connect(_guest)
	field_pass.secret = true
	lbl_error.text = ""
	if sub_offer: sub_offer.hide()

func _set_tab(t: String) -> void:
	_tab = t
	email_row.visible = (t == "register")
	btn_submit.text = LangManager.t("S'inscrire") if t == "register" else LangManager.t("SE CONNECTER")
	field_name.placeholder_text = LangManager.t("Pseudo ou email") if t == "login" else LangManager.t("Pseudo")
	tab_login.modulate.a = 0.5 if t == "register" else 1.0
	tab_register.modulate.a = 0.5 if t == "login" else 1.0

func _submit() -> void:
	lbl_error.text = ""
	var name_val := field_name.text.strip_edges()
	var email_val := field_email.text.strip_edges() if _tab == "register" else ""
	var pass_val := field_pass.text

	HapticManager.light()
	AudioManager.sfx_click()

	var result: Dictionary
	if _tab == "register":
		result = AuthDB.register(name_val, email_val, pass_val)
	else:
		result = AuthDB.login(name_val, pass_val)

	if result.has("error"):
		lbl_error.text = result["error"]
		AudioManager.sfx_error()
		HapticManager.medium()
		return

	AudioManager.sfx_victory()

	if _tab == "register":
		_pending_user = result["user"]
		_show_subscription_offer()
	else:
		GameManager.login(result["user"])

func _guest() -> void:
	HapticManager.light()
	var result := AuthDB.guest_login()
	if result.has("user"):
		GameManager.login(result["user"])

func _show_subscription_offer() -> void:
	_show_sub_offer = true
	if sub_offer: sub_offer.show()

func _on_subscribe_chosen(plan_id: String) -> void:
	# Déclencher l'achat Google Play puis connexion
	# En attendant l'intégration : connexion directe
	GameManager.login(_pending_user)

func _on_skip_subscription() -> void:
	GameManager.login(_pending_user)
