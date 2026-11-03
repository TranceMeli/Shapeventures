# bullet.gd
extends Area2D

var direction := Vector2.ZERO
@export var bullet_speed := 300.0
@export var damage := 1

func _ready():
	add_to_group("enemy_attack")
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	global_position += direction * bullet_speed * delta
	
	# Wenn außerhalb des Bildschirms — löschen
	var screen = get_viewport_rect().size
	if global_position.x < -50 or global_position.x > screen.x + 50:
		queue_free()
	if global_position.y < -50 or global_position.y > screen.y + 50:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.apply_damage(damage)
		queue_free()
