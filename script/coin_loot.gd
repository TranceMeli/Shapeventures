extends BaseLoot

@export var coin_amount := 1

func on_pickup():
	Global.add_coins(coin_amount)
