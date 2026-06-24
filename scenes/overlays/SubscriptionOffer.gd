# scenes/overlays/SubscriptionOffer.gd
# Overlay proposant les forfaits d'abonnement après inscription
# Traduit fidèlement depuis showSubOffer dans LoginScreen HTML
extends Control

signal plan_chosen(plan_id: String)
signal skipped

@onready var plans_container: VBoxContainer = $Scroll/VBox/Plans
@onready var btn_skip: Button = $Scroll/VBox/BtnSkip
@onready var welcome_lbl: Label = $Scroll/VBox/Welcome
@onready var user_lbl: Label = $Scroll/VBox/UserName
@onready var desc_lbl: Label = $Scroll/VBox/Desc

const PLANS := [
	{
		"id": "dosco_naine_monthly",
		"icon": "⭐", "label": "NAINE",
		"price": "0,99€", "daily_stars": 50,
		"color": Color(0.35, 0.7, 1.0),
		"perks": ["50 ⭐ / jour", "Sans publicités", "Badge Naine Bleue"],
	},
	{
		"id": "dosco_supernova_monthly",
		"icon": "💫", "label": "SUPERNOVA",
		"price": "1,99€", "daily_stars": 150,
		"color": Color(0.95, 0.75, 0.2),
		"popular": true,
		"perks": ["150 ⭐ / jour", "Sans publicités", "Badge Supernova", "Skin exclusif"],
	},
	{
		"id": "dosco_trou_noir_monthly",
		"icon": "🌑", "label": "TROU NOIR",
		"price": "4,99€", "daily_stars": 500,
		"color": Color(0.8, 0.4, 1.0),
		"perks": ["500 ⭐ / jour", "Sans publicités", "Tous les badges", "Tous les skins", "+10pts / victoire"],
	},
]

func _ready() -> void:
	btn_skip.text = LangManager.t("Continuer sans abonnement (avec pubs)")
	btn_skip.pressed.connect(_on_skip)

func show_for_user(user: Dictionary) -> void:
	welcome_lbl.text = LangManager.t("BIENVENUE !")
	user_lbl.text = user.get("name", "Commandant")
	desc_lbl.text = LangManager.t(
		"Choisissez un forfait pour jouer sans pubs et recevoir des étoiles quotidiennes.")
	_build_plans()
	show()

func _build_plans() -> void:
	for child in plans_container.get_children():
		child.queue_free()

	for plan in PLANS:
		var panel := PanelContainer.new()
		var vbox := VBoxContainer.new()
		panel.add_child(vbox)
		plans_container.add_child(panel)

		# Badge populaire
		if plan.get("popular", false):
			var badge := Label.new()
			badge.text = "⭐ LE PLUS POPULAIRE"
			badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			vbox.add_child(badge)

		# Header : icône + nom + prix
		var hbox := HBoxContainer.new()
		vbox.add_child(hbox)
		var icon_lbl := Label.new()
		icon_lbl.text = plan["icon"]
		hbox.add_child(icon_lbl)
		var name_lbl := Label.new()
		name_lbl.text = plan["label"]
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.modulate = plan["color"]
		hbox.add_child(name_lbl)
		var price_lbl := Label.new()
		price_lbl.text = plan["price"] + " / mois"
		price_lbl.modulate = plan["color"]
		hbox.add_child(price_lbl)

		# Avantages
		for perk in plan["perks"]:
			var perk_lbl := Label.new()
			perk_lbl.text = "✓ " + perk
			vbox.add_child(perk_lbl)

		# Bouton S'abonner
		var btn := Button.new()
		btn.text = "S'abonner →"
		btn.custom_minimum_size = Vector2(0, 42)
		var plan_id: String = plan["id"]
		btn.pressed.connect(func():
			AudioManager.sfx_connect()
			HapticManager.light()
			plan_chosen.emit(plan_id)
			hide())
		vbox.add_child(btn)

func _on_skip() -> void:
	AudioManager.sfx_click()
	HapticManager.light()
	skipped.emit()
	hide()
