extends Area2D

class_name ItemComponent

signal item_collected

@export var feature: String
@export var player: Player
@export var item_type: Resource

# Called when the node enters the scene tree for the first time.
func _ready():
	area_entered.connect(_on_area_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(area):
	if area is HitboxComponent:
		if area.hitbox_category == "player":
			item_collected.emit()
			if feature == "ball_shell":
				player.inventory.max_ball_slots += 1
				player.set_ball_features()
				queue_free()
			elif feature:
				player.inventory.update(item_type)
				player.set_ball_features()
				queue_free()

