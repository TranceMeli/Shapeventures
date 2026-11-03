extends Area2D

@export var fuse_time := 2.0
@export var explosion_radius := 150.0
@export var fall_speed := 200.00
@export var damage := 2

var exploded := false

func _ready():
	$CollisionShape2D.set_deferred("disabled", false)
	$FuseTimer.wait_time = fuse_time
	$FuseTimer.start()
	
func _physics_process(delta: float) -> void:
	if not exploded:
		global_position.y += fall_speed * delta
		
		if global_position.y > get_viewport_rect().size.y + 50:
			queue_free()
			
func explode():
	exploded = true
	
	for body in get_tree().get_nodes_in_group("player"):
		if body.global_position.distance_to(global_position) <= explosion_radius:
			body.apply_damage(damage)

	queue_free()
	
func _on_fuse_timer_timeout():
	explode()
