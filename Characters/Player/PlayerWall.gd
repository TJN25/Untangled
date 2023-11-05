extends State

class_name PlayerWall

@export var player: CharacterBody2D 

var direction: float = 0

func Enter():
	pass
	
func Update(delta: float):
	if player.health_component.health < 1:
		Transitioned.emit(self, "PlayerDead", "player")
	if Input.is_action_just_pressed("jump"):
		player.jump_button_pressed = true
	if Input.is_action_just_pressed("return_ball") and not player.ball.ball_attached and player.player_energy > 50:
		Transitioned.emit(self, "PlayerDrag", "player")
	update_animation()
func Physics_Update(delta):
	move_player(delta)

func move_player(delta):
	do_coyote_check(delta)
	if player.jump_button_pressed:
		jump_pressed(delta)
	else:
		if player.velocity.y < 0:		
			player.velocity.y += player.gravity * delta
		else:
			player.velocity.y += player.gravity * player.GRAVITY_DOWN_ADJUST * delta
	direction = Input.get_axis("left", "right")
	if direction:
		player.velocity.x = player.velocity.x + direction * player.SPEED
func do_coyote_check(delta):
	if player.left_raycast.is_colliding() or player.right_raycast.is_colliding():
		player.coyote_counter = 0
		player.control_counter = 0
	elif player.coyote_counter <= player.COYETE_TIME:
		player.coyote_counter += delta
	else:
		Transitioned.emit(self, "PlayerAir", "player")

func jump_pressed(delta):
	if player.coyote_counter < player.COYETE_TIME or player.jump_buffer < player.JUMP_BUFFER:
		do_jump(player.JUMP_VELOCITY, player.MAX_SPEED)
		Transitioned.emit(self, "PlayerAir", "player")

func do_jump(jump_height, speed):
	player.foot_particles.amount = 20
	player.coyote_counter = player.COYETE_TIME + 1
	player.jump_buffer = player.JUMP_BUFFER + 1
	player.velocity.y = jump_height
	if player.left_raycast.is_colliding():
		player.velocity.x = speed
	elif player.right_raycast.is_colliding():
		player.velocity.x = -speed
	player.can_jump = false
	player.jump_button_pressed = false
	player.has_double_jumped = false
	player.playback.travel("jump")

func update_facing_direction():
	if player.left_raycast.is_colliding():
		player.sprite.flip_h = true
	elif player.right_raycast.is_colliding():
		player.sprite.flip_h = false

func update_animation():
	player.animation_tree.set("parameters/Move/blend_position", direction)
	update_facing_direction()
