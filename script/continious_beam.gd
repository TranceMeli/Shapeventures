extends Node2D

var damage_per_second := 20
var active := true

func _ready():
	$Line2D.points = [Vector2.ZERO, $ShapeCast2D.target_position]

func _physics_process(delta: float) -> void:
	if not active:
		return

	$ShapeCast2D.force_shapecast_update()

	var end_pos = $ShapeCast2D.target_position
	if $ShapeCast2D.is_colliding():
		end_pos = $ShapeCast2D.get_collision_point(0) - global_position

	# Line2D aktualisieren!
	$Line2D.points = [Vector2.ZERO, end_pos]

	var hit_count = $ShapeCast2D.get_collision_count()
	for i in hit_count:
		var target = $ShapeCast2D.get_collider(i)
		# Nur Spieler treffen, keine Gegner!
		if target.has_method("apply_damage") and target.is_in_group("player"):
			target.apply_damage(damage_per_second * delta)
