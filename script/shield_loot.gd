extends BaseLoot

@export var charge_amount := 1

func on_pickup():
	if Global.player and Global.player.has_node("ShieldController"):
		Global.player.get_node("ShieldController").add_charge(charge_amount)
