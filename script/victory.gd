extends Control

func _ready():
	$ColorRect/CenterContainer/VBoxContainer/NextLevelButton.connect("pressed", _on_next_level_pressed)
	$ColorRect/CenterContainer/VBoxContainer/MenuButton.connect("pressed", _on_menu_pressed)

func _on_next_level_pressed():
	get_tree().change_scene_to_file("res://scene/main.tscn")  # später level2.tscn

func _on_menu_pressed():
	Global.reset_run()
	get_tree().change_scene_to_file("res://scene/ui/menu.tscn")
