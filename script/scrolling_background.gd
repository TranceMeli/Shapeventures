extends Node2D

@export var scroll_speed := 300.0
var screen_height: float

func _ready():
	screen_height = get_viewport_rect().size.y

func _process(delta):
	position.y += scroll_speed * delta
	if position.y >= screen_height:
		position.y = 0.0
