extends EnemyBase

@export var big_enemy_score := 100
@export var bullet_scene: PackedScene
@export var bullet_count := 8      # Kugeln im Kreis
@export var shoot_interval := 1.5  # Sekunden zwischen Salven

func _ready():
	super._ready()
	velocity = Vector2(0, speed)
	$ShootTimer.wait_time = shoot_interval
	$ShootTimer.start()

func _physics_process(delta):
	global_position += velocity * delta
	
	if global_position.y > get_viewport_rect().size.y + 50:
		queue_free()

func shoot_circle():
	if bullet_scene == null:
		return
	
	for i in bullet_count:
		var angle = (TAU / bullet_count) * i  # TAU = 360° in Radians
		var dir = Vector2(cos(angle), sin(angle))
		
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.direction = dir
		get_tree().current_scene.call_deferred("add_child", bullet)

func take_damage(amount):
	apply_damage(amount)

func die():
	Global.add_score(big_enemy_score)
	super.die()

func _on_shoot_timer_timeout():
	shoot_circle()
