extends Area2D
class_name EnemyBase

@export var max_health := 1
@export var velocity: Vector2 = Vector2.ZERO
@export var score := 0
@export var loot_table: Array[PackedScene] = []
@export var drop_chance := 0.3
@export var speed := 100
@export var explosion_scene: PackedScene

var health := max_health
var is_boss := false

func _ready():
	health = max_health  # ← wichtig! sonst bleibt health auf 1
	_setup_healthbar()

func _physics_process(delta: float) -> void:
	global_position += velocity * delta

const BAR_BG := Color(0.04, 0, 0.19)
const BAR_CYAN := Color(0.02, 0.67, 0.78)
const BAR_LOW := Color(1.0, 0.35, 0.42)
const BAR_LOW_THRESHOLD := 0.3

var hide_at_full := false
var healthbar: ProgressBar
var _fill_style: StyleBoxFlat
var _bar_border_style: StyleBoxFlat

func _make_bar(size: Vector2, border_width: int, fill_color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.name = "HealthBar"
	bar.max_value = max_health
	bar.value = health
	bar.size = size
	bar.show_percentage = false
	bar.z_index = 10

	_fill_style = StyleBoxFlat.new()
	_fill_style.bg_color = fill_color
	bar.add_theme_stylebox_override("fill", _fill_style)

	_bar_border_style = StyleBoxFlat.new()
	_bar_border_style.bg_color = BAR_BG
	_bar_border_style.set_border_width_all(border_width)
	_bar_border_style.border_color = fill_color
	bar.add_theme_stylebox_override("background", _bar_border_style)
	return bar

func _setup_healthbar():
	# Kleiner Balken über dem Gegner (hide_at_full = true: erst nach dem ersten Treffer)
	healthbar = _make_bar(Vector2(52, 10), 2, BAR_CYAN)
	healthbar.position = Vector2(-26, -50)
	healthbar.visible = not hide_at_full
	add_child(healthbar)

func _update_healthbar() -> void:
	if healthbar == null:
		return
	healthbar.visible = not hide_at_full or health < max_health
	healthbar.value = max(health, 0)
	var low := health <= max_health * BAR_LOW_THRESHOLD
	var color := BAR_LOW if low else _bar_color()
	_fill_style.bg_color = color
	_bar_border_style.border_color = color

func _bar_color() -> Color:
	return BAR_CYAN

func apply_damage(amount: float) -> void:
	health -= amount
	on_hit()
	_update_healthbar()
	_flash()
	Fx.burst(global_position, Color.WHITE, 8, 200.0, 4.0, 0.25)

	if health <= 0:
		die()

func _flash() -> void:
	modulate = Color(2, 2, 2)
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.12)

func on_hit() -> void:
	pass

func die():
	Fx.burst(global_position, Color(1.0, 0.05, 1.0), 28, 380.0, 7.0, 0.6)
	Fx.burst(global_position, Color(1.0, 0.85, 0.29), 16, 260.0, 5.0, 0.5)
	drop_loot()
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		explosion.global_position = global_position
		get_tree().current_scene.add_child(explosion)
	if not is_boss:
		Global.enemy_killed()  # ← nur wenn kein Boss!
	queue_free()

func drop_loot():
	if loot_table.is_empty():
		return
	if randf() > drop_chance:
		return
	var loot_scene: PackedScene = loot_table.pick_random()
	var loot = loot_scene.instantiate()
	loot.global_position = global_position
	get_tree().current_scene.call_deferred("add_child", loot)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if Global.selected_character == "vampire":
			body.heal(1)
			die()
		else:
			body.apply_damage(1)
			knockback_from_player(body)

func knockback_from_player(player):
	var dir = (global_position - player.global_position).normalized()
	global_position += dir * 40
