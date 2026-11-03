extends BaseLoot

@export var heal_amount := 1

func on_pickup():
	Global.player.heal(heal_amount)
