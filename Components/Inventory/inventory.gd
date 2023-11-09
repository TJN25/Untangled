extends Node

class_name Inventory

@export var balls_in_use: Array[InventoryBall]
@export var extra_balls: Array[InventoryBall]
@export var powerups_not_in_use: Array[InventoryPowerup]
@export var other_items: Array[InventoryItem]
@export var powerups_in_use: Dictionary = {"Player" = [], "BasicBall" = [], "KnockbackBall" = []}

var powerups_in_use_ui: Dictionary = {"Player" = [], "BasicBall" = [], "KnockbackBall" = [], "SmashBall" = [], "StickBall" = [], "MoveBall" = [], "BounceBall" = [], "LargeLight" = []}
var max_ball_slots: int = 0


func update(item: Resource):
	if item is InventoryBall:
		if len(balls_in_use) - 1 >= max_ball_slots:
			extra_balls.append(item)
		else:
			balls_in_use.append(item)
	elif item is InventoryPowerup:
		powerups_not_in_use.append(item)
	else:
		print(item.name)
