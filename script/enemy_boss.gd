extends EnemyBase

@export var boss_score := 500
@export var bullet_scene: PackedScene
@export var beam_scene: PackedScene
@export var bullet_count := 6
@export var move_speed := 150.0
@export var zickzack_range := 300.0

var beam_instance: Node2D = null
var using_beam := false
var beam_tween: Tween = null

# Zickzack
var direction := 1.0
var screen_width: float
var center_x: float

func _ready():
	super._ready()
	is_boss = true
	screen_width = get_viewport_rect().size.x
	center_x = screen_width / 2
	global_position = Vector2(center_x, 150)
	# $ShootTimer.timeout.connect(_on_shoot_timer_timeout)
	# $WeaponTimer.timeout.connect(_on_weapon_timer_timeout)
	$ShootTimer.start()
	$WeaponTimer.start()

const BOSS_BAR_COLOR := Color(0.66, 0.54, 1.0)

func _setup_healthbar():
	# Breiter Balken oben am Bildschirm statt über dem Boss
	hide_at_full = false
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)

	healthbar = _make_bar(Vector2(1200, 24), 3, BOSS_BAR_COLOR)
	healthbar.position = Vector2(360, 50)
	layer.add_child(healthbar)

	var label := Label.new()
	label.text = "Boss"
	label.position = Vector2(260, 52)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 16)
	layer.add_child(label)

func _bar_color() -> Color:
	return BOSS_BAR_COLOR

func _physics_process(delta: float) -> void:
	# Zickzack nur im mittleren Bereich
	global_position.x += move_speed * direction * delta
	if global_position.x >= center_x + zickzack_range:
		direction = -1.0
	if global_position.x <= center_x - zickzack_range:
		direction = 1.0

	# Beam folgt Boss Position und BeamArm Rotation
	if beam_instance:
		beam_instance.global_position = global_position
		beam_instance.rotation = $BeamArm.rotation

func _on_weapon_timer_timeout():
	using_beam = !using_beam if randf() > 0.5 else using_beam
	if using_beam:
		_start_beam()
	else:
		_stop_beam()

func _on_shoot_timer_timeout():
	if not using_beam:
		shoot_circle()

func shoot_circle():
	if bullet_scene == null:
		return
	for i in bullet_count:
		var angle = (TAU / bullet_count) * i
		var dir = Vector2(cos(angle), sin(angle))
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.direction = dir
		get_tree().current_scene.call_deferred("add_child", bullet)

func _start_beam():
	if beam_instance or beam_scene == null:
		return
	beam_instance = beam_scene.instantiate()
	beam_instance.global_position = global_position
	get_tree().current_scene.add_child(beam_instance)
	$BeamArm.rotation_degrees = 0.0
	beam_tween = create_tween()
	beam_tween.set_loops()
	beam_tween.tween_property($BeamArm, "rotation_degrees", 360.0, 4.0)

func _stop_beam():
	if beam_tween:
		beam_tween.kill()
		beam_tween = null
	if beam_instance:
		beam_instance.active = false
		beam_instance.queue_free()
		beam_instance = null

func take_damage(amount):
	apply_damage(amount)

func die():
	Fx.burst(global_position, Color(1.0, 0.05, 1.0), 90, 520.0, 9.0, 1.0)
	Fx.burst(global_position, Color(1.0, 0.85, 0.29), 60, 400.0, 7.0, 0.8)
	Fx.burst(global_position, Color.WHITE, 40, 300.0, 5.0, 0.6)
	_stop_beam()
	Global.add_score(boss_score)
	drop_loot()
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		explosion.global_position = global_position
		get_tree().current_scene.add_child(explosion)
	get_tree().current_scene.level_complete()
	queue_free()
