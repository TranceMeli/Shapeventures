extends Control

var selected := "square"

func _ready():
	$HBoxContainer/SquareCard/SquareButton.pressed.connect(_on_square_button_pressed)
	$HBoxContainer/SiameseCard/SiameseButton.pressed.connect(_on_siamese_button_pressed)
	$HBoxContainer/VampireCard/VampireButton.pressed.connect(_on_vampire_button_pressed)
	$HBoxContainer/BeamCard/BeamButton.pressed.connect(_on_beam_button_pressed)
	$HBoxContainer2/PlayButton.pressed.connect(_on_play_button_pressed)
	$HBoxContainer2/BackButton.pressed.connect(_on_back_button_pressed)
	_highlight(selected)

func _on_square_button_pressed():
	selected = "square"
	_highlight(selected)

func _on_siamese_button_pressed():
	selected = "siamese"
	_highlight(selected)

func _on_vampire_button_pressed():
	selected = "vampire"
	_highlight(selected)

func _on_beam_button_pressed():
	selected = "beam"
	_highlight(selected)

func _highlight(character: String):
	var buttons := {
		"square": $HBoxContainer/SquareCard/SquareButton,
		"siamese": $HBoxContainer/SiameseCard/SiameseButton,
		"vampire": $HBoxContainer/VampireCard/VampireButton,
		"beam": $HBoxContainer/BeamCard/BeamButton,
	}
	for key in buttons:
		var button: Button = buttons[key]
		button.modulate = Color.WHITE
		if key == character:
			# Auswahl: Cyan-Füllung statt Gelb-Modulate (das würde das Lila verfärben)
			var style := StyleBoxFlat.new()
			style.bg_color = Color(0.02, 0.67, 0.78)
			style.set_content_margin_all(10)
			button.add_theme_stylebox_override("normal", style)
			button.add_theme_stylebox_override("hover", style)
			button.add_theme_color_override("font_color", Color(0.04, 0, 0.19))
			button.add_theme_color_override("font_hover_color", Color(0.04, 0, 0.19))
		else:
			button.remove_theme_stylebox_override("normal")
			button.remove_theme_stylebox_override("hover")
			button.remove_theme_color_override("font_color")
			button.remove_theme_color_override("font_hover_color")

func _on_play_button_pressed():
	Global.selected_character = selected
	get_tree().change_scene_to_file("res://scene/main.tscn")

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scene/ui/menu.tscn")
