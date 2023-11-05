extends State

class_name PlayerDead

@export var player: CharacterBody2D 

var direction: float = 0

func Enter():
	pass
	
func Exit():
	player.camera_tracker.position = Vector2(0,0)
	#player.sprite.rotation = 0

func Update(delta: float):
	if player.health_component.health > 10:
		Transitioned.emit(self, "PlayerAir", "player")
	update_animation()

func Physics_Update(delta):
	move_player(delta)

func move_player(delta):
	var diff = player.ball.global_position - player.global_position
	player.camera_tracker.position = diff
	var angle_to_ball = diff.angle()
	player.velocity.y = player.BALL_FORCE*sin(angle_to_ball)/5
	player.velocity.x = player.BALL_FORCE*sin(angle_to_ball + PI/2)/5

func update_facing_direction():
	#player.sprite.rotation = PI/2
	if player.left_raycast.is_colliding():
		player.sprite.flip_h = true
	elif player.right_raycast.is_colliding():
		player.sprite.flip_h = false

func update_animation():
	player.animation_tree.set("parameters/Move/blend_position", direction)
	update_facing_direction()
