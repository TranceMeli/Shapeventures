extends Node

var xp := 0
var xp_to_next := 100
var level := 1
var score := 0
var coin := 0
var player: Node = null
var ui: Node = null
var selected_character := "square"

var characters := {
	"square": {
		"speed": 600,
		"max_health": 5,
		"sprite": preload("res://assets/square.png"),
		"scene_path": "res://scene/player/player_square.tscn",
		"shoot_pattern": [Vector2(0, -1), Vector2(0, -1)],
		"max_energy": 10.0,
		"energy_recharge": 2.0,
		"shoot_energy_cost": 1.0,
		"beam_drain_rate": 0.0
	},
	"siamese": {
		"speed": 700,
		"max_health": 4,
		"sprite": preload("res://assets/siamese.png"),
		"scene_path": "res://scene/player/player_siamese.tscn",
		"shoot_pattern": [Vector2(0, -1), Vector2(0, -1)],
		"max_energy": 10.0,
		"energy_recharge": 4.0,
		"shoot_energy_cost": 2.0,
		"beam_drain_rate": 0.0
	},
	"vampire": {
		"speed": 500,
		"max_health": 3,
		"sprite": preload("res://assets/vampire.png"),
		"scene_path": "res://scene/player/player_vampire.tscn",
		"shoot_pattern": [],
		"max_energy": 0.0,
		"energy_recharge": 0.0,
		"shoot_energy_cost": 0.0,
		"beam_drain_rate": 0.0
	},
	"beam": {
		"speed": 450,
		"max_health": 4,
		"sprite": preload("res://assets/beam_laser.png"),
		"scene_path": "res://scene/player/player_beam.tscn",
		"shoot_pattern": [],
		"max_energy": 100.0,
		"energy_recharge": 20.0,
		"shoot_energy_cost": 0.0,
		"beam_drain_rate": 30.0
	}
}

signal score_changed(value)
signal coin_changed(value)
signal level_up(level)
signal xp_changed(xp, xp_to_next)
signal enemy_killed_signal

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)
	Global.add_xp(amount)

func add_coins(amount) -> void:
	coin += amount
	coin_changed.emit(coin)

func add_xp(amount):
	xp += amount
	if xp >= xp_to_next:
		xp -= xp_to_next
		level += 1
		xp_to_next = int(xp_to_next * 1.25)
		level_up.emit(level)
	xp_changed.emit(xp, xp_to_next)

func reset_run() -> void:
	score = 0
	coin = 0
	xp = 0
	xp_to_next = 100
	level = 1

func enemy_killed():
	var main = get_tree().current_scene
	if main.has_method("enemy_killed"):
		main.enemy_killed()
	enemy_killed_signal.emit()
