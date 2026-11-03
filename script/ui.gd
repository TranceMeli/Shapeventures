extends CanvasLayer

static var red_heart = load("res://assets/red_heart.png")
static var empty_heart = load("res://assets/red_heart_empty.png")
static var blue_shield = load("res://assets/blue_heart.png")
static var empty_shield = load("res://assets/blue_heart_empty.png")
static var coin = load("res://assets/coin.png")

var time_elapsed := 0

@onready var health_container = %HealthContainer
@onready var shield_container = %ShieldContainer
@onready var beam_bar = %BeamBar
@onready var score_label = %ScoreLabel
@onready var enemies_label = %EnemiesLabel
@onready var coin_label = %CoinLabel
@onready var level_label = %LevelLabel
@onready var xp_bar = %XPBar

func _ready() -> void:
	Global.ui = self
	Global.score_changed.connect(_on_score_changed)
	_on_score_changed(Global.score)
	Global.coin_changed.connect(_on_coin_changed)
	_on_coin_changed(Global.coin)
	Global.xp_changed.connect(_on_xp_changed)
	Global.enemy_killed_signal.connect(_update_enemies_left)
	level_label.text = "LVL " + str(Global.level)
	_update_enemies_left()

func _update_enemies_left():
	var main = get_tree().current_scene
	if main.has_method("get_enemies_left"):
		enemies_label.text = "Left " + str(main.get_enemies_left())

func _on_xp_changed(xp, xp_to_next):
	xp_bar.max_value = xp_to_next
	xp_bar.value = xp
	level_label.text = "LVL " + str(Global.level)

func _on_score_changed(value: int) -> void:
	score_label.text = "%06d" % value

func _on_coin_changed(value):
	coin_label.text = str(value)

func set_health(amount):
	for child in health_container.get_children():
		child.queue_free()
	var max_hp = Global.player.max_health if Global.player else 5
	for i in max_hp:
		var icon = TextureRect.new()
		icon.custom_minimum_size = Vector2(32, 32)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if i < amount:
			icon.texture = red_heart
		else:
			icon.texture = empty_heart
		health_container.add_child(icon)

func set_shield(amount):
	for child in shield_container.get_children():
		child.queue_free()
	var max_charges = 3
	if Global.player and Global.player.has_node("ShieldController"):
		max_charges = Global.player.get_node("ShieldController").max_charges
	for i in max_charges:
		var icon = TextureRect.new()
		icon.custom_minimum_size = Vector2(32, 32)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if i < amount:
			icon.texture = blue_shield
		else:
			icon.texture = empty_shield
		shield_container.add_child(icon)

func set_gem(amount):
	coin_label.text = str(amount)

func set_beam_energy(current: float, maximum: float):
	if beam_bar:
		beam_bar.max_value = maximum
		beam_bar.value = current
