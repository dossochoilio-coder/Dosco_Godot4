# scenes/screens/LoginScreen.gd — Auth DOSCO
extends Control

var _tab: String = "login"  # "login" | "register"
var _show_sub_offer: bool = false
var _pending_user: Dictionary = {}

# Sécurisation des nodes
@onready var tab_login = get_node_or_null("Container/Tabs/TabLogin")
@onready var tab_register = get_node_or_null("Container/Tabs/TabRegister")
@onready var field_name = get_node_or_null("Container/Fields/FieldName")
@onready var field_email = get_node_or_null("Container/Fields/FieldEmail")
@onready var field_pass = get_node_or_null("Container/Fields/FieldPass")
@onready var btn_submit = get_node_or_null("Container/BtnSubmit")
@onready var btn_guest = get_node_or_null("Container/BtnGuest")
@onready var lbl_error = get_node_or_null("Container/LblError")
@onready var email_row = get_node_or_null("Container/Fields/FieldEmail")
@onready var sub_offer = get_node_or_null("SubOffer")

func _ready() -> void:
    _set_tab("login")

    if tab_login:
        tab_login.pressed.connect(func(): _set_tab("login"))

    if tab_register:
        tab_register.pressed.connect(func(): _set_tab("register"))

    if btn_submit:
        btn_submit.pressed.connect(_submit)

    if btn_guest:
        btn_guest.pressed.connect(_guest)

    if field_pass:
        field_pass.secret = true

    if lbl_error:
        lbl_error.text = ""

    if sub_offer:
        sub_offer.hide()

# Fonction sécurisée (LangManager peut être absent en CI)
func _tr(txt: String) -> String:
    if Engine.has_singleton("LangManager"):
        return LangManager.t(txt)
    return txt

func _set_tab(t: String) -> void:
    _tab = t

    if email_row:
        email_row.visible = (t == "register")

    if btn_submit:
        btn_submit.text = _tr("S'inscrire") if t == "register" else _tr("SE CONNECTER")

    if field_name:
        field_name.placeholder_text = _tr("Pseudo ou email") if t == "login" else _tr("Pseudo")

    if tab_login and tab_register:
        tab_login.modulate.a = 0.5 if t == "register" else 1.0
        tab_register.modulate.a = 0.5 if t == "login" else 1.0

func _submit() -> void:
    if lbl_error:
        lbl_error.text = ""

    var name_val := field_name.text.strip_edges() if field_name else ""
    var email_val := field_email.text.strip_edges() if (_tab == "register" and field_email) else ""
    var pass_val := field_pass.text if field_pass else ""

    if Engine.has_singleton("HapticManager"):
        HapticManager.light()

    if Engine.has_singleton("AudioManager"):
        AudioManager.sfx_click()

    var result: Dictionary
    if _tab == "register":
        result = AuthDB.register(name_val, email_val, pass_val)
    else:
        result = AuthDB.login(name_val, pass_val)

    if result.has("error"):
        if lbl_error:
            lbl_error.text = result["error"]

        if Engine.has_singleton("AudioManager"):
            AudioManager.sfx_error()

        if Engine.has_singleton("HapticManager"):
            HapticManager.medium()
        return

    if Engine.has_singleton("AudioManager"):
        AudioManager.sfx_victory()

    if _tab == "register":
        _pending_user = result["user"]
        _show_subscription_offer()
    else:
        GameManager.login(result["user"])

func _guest() -> void:
    if Engine.has_singleton("HapticManager"):
        HapticManager.light()

    var result := AuthDB.guest_login()
    if result.has("user"):
        GameManager.login(result["user"])

func _show_subscription_offer() -> void:
    _show_sub_offer = true
    if sub_offer:
        sub_offer.show()

func _on_subscribe_chosen(plan_id: String) -> void:
    GameManager.login(_pending_user)

func _on_skip_subscription() -> void:
    GameManager.login(_pending_user)
``
