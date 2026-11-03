class_name Fx

# Kleiner Pixel-Partikelausbruch an einer Weltposition; räumt sich selbst auf.
static func burst(at: Vector2, color: Color, amount := 12, speed := 220.0, size := 5.0, lifetime := 0.4) -> void:
	var scene := (Engine.get_main_loop() as SceneTree).current_scene
	if scene == null:
		return

	var fade := Gradient.new()
	fade.set_color(0, color)
	fade.set_color(1, Color(color, 0.0))

	var p := CPUParticles2D.new()
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = amount
	p.lifetime = lifetime
	p.direction = Vector2.ZERO
	p.spread = 180.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = speed * 0.4
	p.initial_velocity_max = speed
	p.scale_amount_min = size * 1.2
	p.scale_amount_max = size * 2.0
	p.color_ramp = fade
	p.z_index = 5
	p.position = at
	p.emitting = true
	p.finished.connect(p.queue_free)
	scene.add_child.call_deferred(p)
