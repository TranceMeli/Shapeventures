extends CharacterBody2D

var beam_instance: Node2D = null
@export var laser_scene: PackedScene
@export var continious_beam_scene: PackedScene
@export var max_health := 5
var health := max_health
var speed := 600
var auto_scroll := 250.0
var siamese_shots_remaining := 3
var siamese_max_shots := 3

# Energie — für alle Chars
var energy := 100.0
var max_energy := 100.0
var energy_recharge := 15.0
var shoot_energy_cost := 1.0
var beam_drain_rate := 30.0
var beam_active := false

# Charakter
var shoot_pattern: Array = []
var facing_up := true
var flip_cooldown := 1.0
var flip_timer := 0.0

func _ready():
	add_to_group("player")
	Global.player = self
	_load_character()
	_add_trail()

func _add_trail():
	var fade := Gradient.new()
	fade.set_color(0, Color(0.02, 0.67, 0.78, 0.8))
	fade.set_color(1, Color(0.02, 0.67, 0.78, 0.0))
	var trail := CPUParticles2D.new()
	trail.amount = 14
	trail.lifetime = 0.35
	trail.local_coords = false
	trail.position = Vector2(0, 26)
	trail.direction = Vector2.DOWN
	trail.spread = 20.0
	trail.gravity = Vector2.ZERO
	trail.initial_velocity_min = 60.0
	trail.initial_velocity_max = 120.0
	trail.scale_amount_min = 5.0
	trail.scale_amount_max = 8.0
	trail.color_ramp = fade
	trail.show_behind_parent = true
	add_child(trail)

func _load_character():
	var char_data = Global.characters[Global.selected_character]
	speed = char_data["speed"]
	max_health = char_data["max_health"]
	health = max_health
	shoot_pattern = char_data["shoot_pattern"].duplicate()
	max_energy = char_data["max_energy"]
	energy = max_energy
	energy_recharge = char_data["energy_recharge"]
	shoot_energy_cost = char_data["shoot_energy_cost"]
	beam_drain_rate = char_data["beam_drain_rate"]
	$Sprite2D.texture = char_data["sprite"]
	if Global.ui:
		Global.ui.set_health(health)
		Global.ui.set_beam_energy(energy, max_energy)

func apply_damage(amount):
	if has_node("ShieldController"):
		if $ShieldController.shield_active:
			# Dauerschaden (Beam, < 1 pro Tick) verbraucht das Schild nicht sofort
			if amount >= 1:
				$ShieldController.deactivate_shield()
			return
	health -= amount
	# Dauerschaden (Beam) nur sparsam mit Partikeln begleiten
	if amount >= 1:
		Fx.burst(global_position, Color(1.0, 0.35, 0.42), 20, 300.0, 6.0, 0.5)
	if Global.ui:
		Global.ui.set_health(health)
	print("player HP", health)
	if health <= 0:
		die()

func _physics_process(delta: float):
	if flip_timer > 0:
		flip_timer -= delta

	if Global.selected_character != "siamese":
		rotation = 0

	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)

	if input_direction.length() > 0:
		input_direction = input_direction.normalized()

	velocity = input_direction * speed
	velocity.y -= auto_scroll
	move_and_slide()

	var screen = get_viewport_rect().size
	position.x = clamp(position.x, 0, screen.x)
	position.y = clamp(position.y, 0, screen.y)

	if beam_instance:
		beam_instance.global_position = $BeamPos.global_position

	if Input.is_action_just_pressed("shield"):
		if has_node("ShieldController"):
			$ShieldController.toggle_shield(self)

	# Energie verwalten
	if Global.selected_character == "beam":
		if beam_active:
			energy -= beam_drain_rate * delta
			if energy <= 0:
				energy = 0
				_stop_beam_beamer()
		else:
			energy = min(energy + energy_recharge * delta, max_energy)
	else:
		if max_energy > 0:
			energy = min(energy + energy_recharge * delta, max_energy)

	if Global.ui:
		Global.ui.set_beam_energy(energy, max_energy)

func _input(event):
	if event.is_action_pressed("shoot"):
		shoot()
		if has_node("AudioStreamPlayer2D"):
			$AudioStreamPlayer2D.play()

	if event.is_action_pressed("flip") and Global.selected_character == "siamese":
		flip()

	if Global.selected_character == "beam":
		if event.is_action_pressed("beam"):
			if energy > 0:
				_start_beam_beamer()
		if event.is_action_released("beam"):
			_stop_beam_beamer()

func flip():
	if flip_timer > 0:
		return
	flip_timer = flip_cooldown
	facing_up = !facing_up
	siamese_shots_remaining = siamese_max_shots
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees",
		0.0 if facing_up else 180.0, 0.2)

func shoot():
	if shoot_pattern.is_empty():
		return

	if energy < shoot_energy_cost:
		return

	if Global.selected_character == "siamese":
		if siamese_shots_remaining <= 0:
			return
		siamese_shots_remaining -= 1

	energy -= shoot_energy_cost
	if Global.ui:
		Global.ui.set_beam_energy(energy, max_energy)

	var spawn_positions = []
	for i in shoot_pattern.size():
		var node_name = "LaserStartPos" if i == 0 else "LaserStartPos" + str(i + 1)
		if has_node(node_name):
			spawn_positions.append(get_node(node_name).global_position)

	for i in spawn_positions.size():
		var laser = laser_scene.instantiate()
		laser.direction = shoot_pattern[i] if i < shoot_pattern.size() else Vector2(0, -1)
		laser.global_position = spawn_positions[i]
		get_tree().current_scene.add_child(laser)

func _start_beam_beamer():
	if beam_instance:
		return
	beam_active = true
	beam_instance = continious_beam_scene.instantiate()
	beam_instance.global_position = $BeamPos.global_position
	get_tree().current_scene.add_child(beam_instance)

func _stop_beam_beamer():
	beam_active = false
	if beam_instance:
		beam_instance.active = false
		beam_instance.queue_free()
		beam_instance = null

func start_beam():
	if beam_instance:
		return
	beam_instance = continious_beam_scene.instantiate()
	beam_instance.global_position = $BeamPos.global_position
	get_tree().current_scene.add_child(beam_instance)

func stop_beam():
	if beam_instance:
		beam_instance.active = false
		beam_instance.queue_free()
		beam_instance = null

func die():
	print("player is dead")
	get_tree().change_scene_to_file.call_deferred("res://scene/ui/game_over.tscn")

func heal(amount):
	health = min(health + amount, max_health)
	if Global.ui:
		Global.ui.set_health(health)
