extends State

class_name PlayerDrag

@export var player: CharacterBody2D 

var direction: float = 0

func Enter():
	pass
	
func Exit():
	player.camera_tracker.position = Vector2(0,0)

func Update(delta: float):
	if player.health_component.health < 1:
		Transitioned.emit(self, "PlayerDead", "player")
	if Input.is_action_just_pressed("return_ball"):
		Transitioned.emit(self, "PlayerAir", "player")
	if player.ball.ball_attached:
		Transitioned.emit(self, "PlayerAir", "player")
	if player.player_energy < 50:
		Transitioned.emit(self, "PlayerAir", "player")
	player.player_energy -= player.HEALTH_INCREMENT*10 * delta
	update_animation()
func Physics_Update(delta):
	move_player(delta)

func move_player(delta):
	var diff = player.ball.global_position - player.global_position
	player.camera_tracker.position = diff
	var angle_to_ball = diff.angle()
	player.velocity.y = player.BALL_FORCE*sin(angle_to_ball)
	player.velocity.x = player.BALL_FORCE*sin(angle_to_ball + PI/2)

func update_facing_direction():
	if player.left_raycast.is_colliding():
		player.sprite.flip_h = true
	elif player.right_raycast.is_colliding():
		player.sprite.flip_h = false

func update_animation():
	player.animation_tree.set("parameters/Move/blend_position", direction)
	update_facing_direction()
