extends Control

var level_scene: PackedScene = load("res://scene/main.tscn")

# Called when the node enters the scene tree for the first time.
var input_delay := 0.7  # verhindert Sofort-Neustart durch den Klick beim Sterben

func _ready() -> void:
	$CenterContainer/VBoxContainer/Label2.text = str(Global.score)


func _process(delta: float) -> void:
	input_delay -= delta
	if input_delay <= 0.0 and Input.is_action_just_pressed("shoot"):
		Global.reset_run()
		get_tree().change_scene_to_packed(level_scene)
