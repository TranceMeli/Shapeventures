extends Node2D

func _ready():
	$Particles.emitting = true
	await get_tree().create_timer($Particles.lifetime + 0.1).timeout
	queue_free()
