extends EnemyBase

@export var light_enemy_score := 20

func _ready():
	super._ready()
	loot_table = [
		preload("res://scene/loot/HeartLoot.tscn"),
		preload("res://scene/loot/ShieldLoot.tscn"),
		preload("res://scene/loot/CoinLoot.tscn")
	]
	drop_chance = 0.3
	velocity = Vector2(0, speed)

func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	if global_position.y > get_viewport_rect().size.y + 50:
		queue_free()

func take_damage(amount):
	apply_damage(amount)

func die():
	Global.add_score(light_enemy_score)
	super.die()
