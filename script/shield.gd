extends Area2D


signal shield_hit
signal shield_broken

@export var max_hits := 5
var hits := 0

func _ready():
	print("Shield spawned at: ", global_position)
	

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_attack"):
		area.queue_free()
		hits += 1
		print("shield absorbed hit", hits)
		emit_signal("shield_hit")
		
		if hits >= max_hits:
			emit_signal("shield_broken")
			queue_free()

		
func _on_timer_timeout():
	emit_signal("shield_broken")
	queue_free()
