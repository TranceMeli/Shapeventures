extends Control


func _on_continue_pressed():
	get_tree().paused = false
	visible = false
	
func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scene/ui/menu.tscn")
	
func _on_quit_pressed():
	get_tree().quit()
