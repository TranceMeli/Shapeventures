extends Node2D

@export var light_enemy_scene: PackedScene
@export var fast_enemy_scene: PackedScene
@export var big_enemy_scene: PackedScene
@export var big_enemy_chance := 0.15  # 15% Chance bei jedem Spawn-Tick

var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func _on_light_enemy_timer_timeout() -> void:
	spawn_light_enemy()
	
	# Bei jedem light_enemy Timer — zufällig auch big_enemy spawnen
	if rng.randf() < big_enemy_chance:
		spawn_big_enemy()

func _on_fast_enemy_timer_timeout() -> void:
	spawn_fast_enemy()

func spawn_light_enemy():
	var enemy = light_enemy_scene.instantiate()
	var viewport_size: Vector2 = get_viewport().size
	var random_x := rng.randf_range(0, viewport_size.x)
	enemy.global_position = Vector2(random_x, -50)
	get_parent().get_node("Enemies").add_child(enemy)

func spawn_fast_enemy():
	var enemy = fast_enemy_scene.instantiate()
	var viewport_size: Vector2 = get_viewport().size
	var random_y := rng.randf_range(0, viewport_size.y)
	var spawn_left := rng.randf() < 0.5
	
	var spawn_x: float
	if spawn_left:
		spawn_x = -100
		enemy.velocity = Vector2.RIGHT * enemy.speed
	else:
		spawn_x = viewport_size.x + 50
		enemy.velocity = Vector2.LEFT * enemy.speed
	
	enemy.global_position = Vector2(spawn_x, random_y)
	get_parent().get_node("Enemies").add_child(enemy)

func spawn_big_enemy():
	if big_enemy_scene == null:
		return
	var enemy = big_enemy_scene.instantiate()
	var viewport_size: Vector2 = get_viewport().size
	var random_x := rng.randf_range(100, viewport_size.x - 100)
	enemy.global_position = Vector2(random_x, -100)
	get_parent().get_node("Enemies").add_child(enemy)
