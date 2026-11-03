extends Node2D

signal shield_deactivated

@export var shield_scene: PackedScene
@export var max_charges := 3
var charges := 5
var active_shield: Node2D = null
var shield_active := false

func toggle_shield(player: Node2D):
	if shield_active:
		deactivate_shield()
	else:
		if charges <= 0:
			print("kein shield mehr!")
			return
		activate_shield(player)

func activate_shield(player: Node2D):
	if shield_active:
		return
	active_shield = shield_scene.instantiate()
	player.add_child(active_shield)
	active_shield.position = Vector2.ZERO
	active_shield.connect("shield_hit", _on_shield_hit)
	active_shield.connect("shield_broken", _on_shield_broken)
	shield_active = true
	charges -= 1
	if Global.ui:
		Global.ui.set_shield(charges)

func add_charge(amount := 1):
	charges = min(charges + amount, max_charges)
	if Global.ui:
		Global.ui.set_shield(charges)

func _on_shield_hit():
	pass

func deactivate_shield():
	if active_shield:
		active_shield.queue_free()
		active_shield = null
	shield_active = false
	emit_signal("shield_deactivated")

func _on_shield_broken():
	deactivate_shield()
