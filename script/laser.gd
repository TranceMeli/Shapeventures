extends Area2D

var speed := 600
var direction := Vector2.UP

# func _ready():
	# area_entered.connect(_on_laser_projectile_entered)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	# Wenn außerhalb löschen
	if global_position.y < -100:
		queue_free()

func _on_laser_projectile_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		area.take_damage(1)
		queue_free()