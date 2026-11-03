extends Area2D
class_name BaseLoot

@export var fall_speed := 100.0
@export var fall_duration := 0.2
var target_player: CharacterBody2D = null
var fall_timer := 0.0

func _ready():
	target_player = Global.player

func _physics_process(delta: float) -> void:
	if target_player == null:
		target_player = Global.player
		if target_player == null:
			return

	if fall_timer < fall_duration:
		fall_timer += delta
		global_position.y += fall_speed * delta
		return

	# Zum Spieler fliegen
	var dir = (target_player.global_position - global_position).normalized()
	global_position += dir * fall_speed * 4 * delta

func _on_BaseLoot_body_entered(body):
	if body.is_in_group("player"):
		Fx.burst(global_position, Color(1.0, 0.85, 0.29), 12, 220.0, 5.0, 0.4)
		on_pickup()
		queue_free()

func on_pickup():
	pass
