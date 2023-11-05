extends Area2D

class_name ItemComponent

@export var feature: String
@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready():
	area_entered.connect(_on_area_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(area):
	if area is HitboxComponent:
		if area.hitbox_category == "player":
			if feature == "can_knockback_ball":
				#player.can_knockback_ball = true
				player.ball_slots_list.append('Boost')
				player.set_ball_features()
				queue_free()
			elif feature == "increase_ball_knockback" and player.ball_knockback_value > 2:
				player.ball_knockback_value -= 50
				queue_free()
			elif feature == "can_down_smash":
				player.can_blast =true
				player.set_ball_features()
				queue_free()
			elif feature == "ball_shell":
				player.max_ball_slots += 1
				player.set_ball_features()
				queue_free()
			elif feature == "ball_throw_range":
				player.ball_throw_range += 100
				player.set_ball_features()
				queue_free()
