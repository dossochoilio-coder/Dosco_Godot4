# scenes/screens/LoginScreen.gd
extends Control

var _tab: String = "login"
var _pending_user: Dictionary = {}

@onready var tab_login: Button = $Container/Tabs/TabLogin
@onready var tab_register: Button = $Container/Tabs/TabRegister
@onready var field_name: LineEdit = $Container/Fields/FieldName
@onready var field_email: LineEdit = $Container/Fields/FieldEmail
@onready var field_pass: LineEdit = $Container/Fields/FieldPass
@onready var btn_submit: Button = $Container/BtnSubmit
@onready var btn_guest: Button = $Container/BtnGuest
@onready var lbl_error: Label = $Container/LblError

func _ready() -> void:
    _set_tab("login")
    tab_login.pressed.connect(func(): _set_tab("login"))
    tab_register.pressed.connect(func(): _set_tab("register"))
    btn_submit.pressed.connect(_submit)
    btn_guest.pressed.connect(_guest)
    field_pass.secret = true
    lbl_error.text = ""

func _set_tab(t: String) -> void:
    _tab = t
    btn_submit.text = "S'inscrire" if t == "register" else "SE CONNECTER"
    tab_login.modulate.a = 0.5 if t == "register" else 1.0
    tab_register.modulate.a = 0.5 if t == "login" else 1.0

func _submit() -> void:
    lbl_error.text = ""
    var name_val := field_name.text.strip_edges()
    HapticManager.light()
    AudioManager.sfx_click()

    var result: Dictionary
    if _tab == "register":
        result = AuthDB.register(name_val, field_email.text.strip_edges(), field_pass.text)
    else:
        result = AuthDB.login(name_val, field_pass.text)

    if result.has("error"):
        lbl_error.text = result["error"]
        AudioManager.sfx_error()
        return

    AudioManager.sfx_victory()
    if _tab == "register":
        _pending_user = result["user"]
    else:
        GameManager.login(result["user"])
func _guest() -> void:
    lbl_error.text = ""
    HapticManager.light()
    AudioManager.sfx_click()

    var guest_user := {
        "name": "Guest",
        "uid": "guest"
    }

    GameManager.current_user = guest_user
    GameManager.user_logged_in.emit(guest_user)
    GameManager.navigate("home")
