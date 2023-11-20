extends Area2D

class_name ItemComponent

signal item_collected(item)

@export var feature: String
@export var player: PlayerBallController
@export var item_type: Resource

@onready var sprite: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.texture = item_type.texture
	sprite.modulate = item_type.colour
	area_entered.connect(_on_area_entered)
	item_collected.connect(player._on_item_collected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(area):
	if area is HitboxComponent:
		if area.hitbox_category == "player":
			item_collected.emit(self)
#			print("removed")
			if feature == "ball_shell":
				player.inventory.max_ball_slots += 1
#				player.set_ball_features()
				queue_free()
			elif feature == "extra_powerup":
				player.max_powerups += 1
				queue_free()
			elif feature:
				player.inventory.update(item_type)
#				player.set_ball_features()
				queue_free()

