extends Node2D

var paused := false

@export var star_scene: PackedScene
@export var star_count := 30
@export var scroll_speed := 250.0

@export var enemies_to_kill := 25
@export var boss_scene: PackedScene
var enemies_killed := 0
var boss_spawned := false

var stars: Array[Node2D] = []
var screen_size: Vector2

func _ready():
	screen_size = get_viewport_rect().size
	spawn_stars()
	spawn_player()
	$Music.play()

func spawn_player():
	var char_data = Global.characters[Global.selected_character]
	var player = load(char_data["scene_path"]).instantiate()
	player.global_position = Vector2(screen_size.x / 2, screen_size.y - 100)
	add_child(player)

func spawn_stars():
	for i in star_count:
		var star = star_scene.instantiate()
		star.position = Vector2(
			randf_range(0, screen_size.x),
			randf_range(0, screen_size.y)
		)
		$ScrollingBackground.add_child(star)
		stars.append(star)

func _process(delta: float) -> void:
	scroll_stars(delta)

func scroll_stars(delta):
	for star in stars:
		star.position.y += scroll_speed * delta
		if star.position.y > screen_size.y + 64:
			star.position.y = -64
			star.position.x = randf_range(0, screen_size.x)

func enemy_killed():
	enemies_killed += 1
	print("Gegner: ", enemies_killed, "/", enemies_to_kill)
	if enemies_killed >= enemies_to_kill and not boss_spawned:
		spawn_boss()

func spawn_boss():
	print("spawn_boss aufgerufen!")
	if boss_scene == null:
		print("Boss scene nicht zugewiesen!")
		return
	boss_spawned = true
	
	# Spawner stoppen
	$Spawner/LightEnemyTimer.stop()
	$Spawner/FastEnemyTimer.stop()
	$Spawner/BigEnemyTimer.stop()
	
	# Alle vorhandenen Gegner entfernen
	for enemy in $Enemies.get_children():
		enemy.queue_free()
	
	var boss = boss_scene.instantiate()
	boss.global_position = Vector2(screen_size.x / 2, -100)
	# deferred: spawn_boss wird aus einem Physik-Callback (Laser-Treffer) aufgerufen
	add_child.call_deferred(boss)
	print("Boss gespawnt!")

func level_complete():
	print("level_complete aufgerufen!")
	print(get_stack())  # zeigt wo der Aufruf herkommt
	get_tree().change_scene_to_file.call_deferred("res://scene/ui/victory.tscn")

func get_enemies_left() -> int:
	return enemies_to_kill - enemies_killed

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	paused = !paused
	get_tree().paused = paused
	$PauseMenu.visible = paused

func _on_fast_enemy_timer_timeout() -> void:
	pass