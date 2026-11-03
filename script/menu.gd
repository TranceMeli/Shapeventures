extends Control


func _on_start_pressed() -> void:
	print("start pressed")
	#get_tree().change_scene_to_file("res://scene/main.tscn")
	get_tree().change_scene_to_file("res://scene/ui/character_select.tscn")


func _on_settings_pressed() -> void:
	print("settings pressed")


func _on_exit_pressed() -> void:
	print("exit pressed")
	get_tree().quit()
