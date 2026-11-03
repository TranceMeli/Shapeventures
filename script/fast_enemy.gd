extends EnemyBase

@export var fast_enemy_score := 40
@export var bomb_scene: PackedScene

func _ready() -> void:
	super._ready()
	# Startposition und Richtung (links/rechts) kommen vom Spawner
	var dir_x := -1.0 if velocity.x < 0 else 1.0
	var angle = randf_range(deg_to_rad(-20), deg_to_rad(20))
	velocity = Vector2(dir_x * speed, tan(angle) * speed)

func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	var screen := get_viewport_rect().size
	if global_position.x < -200 or global_position.x > screen.x + 200:
		queue_free()
	elif global_position.y < -100 or global_position.y > screen.y + 50:
		queue_free()

func take_damage(amount):
	apply_damage(amount)

func die():
	Global.add_score(fast_enemy_score)
	drop_bomb()
	super.die()
	
func drop_bomb():
	if bomb_scene == null:
		return
	var bomb = bomb_scene.instantiate()
	bomb.global_position = global_position
	get_tree().current_scene.call_deferred("add_child", bomb)
