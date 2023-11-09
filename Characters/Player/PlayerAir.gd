extends State

class_name PlayerAir

@export var player: CharacterBody2D 

var direction: float = 0.0
var air_hang: float = 0.0
var dash_drag_counter: float = 0

func Enter():
	player.audio_jump.play()
	dash_drag_counter = 0

func Exit():
	player.player_dashed = false
	
	
func Update(delta: float):
	if player.health_component.health < 1:
		Transitioned.emit(self, "PlayerDead", "player")
	player.control_counter += delta
	if Input.is_action_just_pressed("jump"):
		player.jump_buffer = 0
		player.jump_button_pressed = true
	if Input.is_action_just_pressed("return_ball") and not player.ball.ball_attached and player.player_energy > 50:
		Transitioned.emit(self, "PlayerDrag", "player")
	update_animation()



func Physics_Update(delta):
	move_player(delta)

func move_player(delta):
	player.foot_particles.amount = 0
	do_floor_check(delta)
	if player.jump_button_pressed:
		jump_pressed(delta)
	direction = Input.get_axis("left", "right")
	if direction:
		if player.control_counter < player.CONTROL_LIMIT:
			player.velocity.x = player.velocity.x + direction * player.SPEED/10
		else:
			player.velocity.x = player.velocity.x + direction * player.SPEED
	else:
		player.velocity.x = player.velocity.x/player.DRAG_FACTOR
	player.velocity.x = clamp(player.velocity.x, -player.MAX_SPEED, player.MAX_SPEED)
	if player.ball_thrown:
		if player.can_knockback_ball:
			player.ball_thrown = false
			Transitioned.emit(self, "PlayerDash", "player")
		player.ball_thrown = false
	
	
func do_floor_check(delta):
	#Add the gravity.
	if not player.is_on_floor() and player.coyote_dash > player.COYETE_TIME:
		if player.wall_counter > player.COYETE_TIME or (not player.left_raycast.is_colliding() and not player.right_raycast.is_colliding()) or player.velocity.y < 0:
			if player.velocity.y < 0:
				if player.player_dashed and dash_drag_counter < 0.05:
					dash_drag_counter += delta
					player.velocity.y = player.velocity.y/player.DRAG_FACTOR
				air_hang = 0		
				player.velocity.y += player.gravity * delta
			else:
				if air_hang < player.AIR_HANG:
					player.velocity.y += player.gravity * 0.1 * delta
				else:
					player.velocity.y += player.gravity * player.GRAVITY_DOWN_ADJUST * delta
				player.audio_jump.stop()
				air_hang += delta
		elif not player.jump_button_pressed:
			player.velocity.y = player.velocity.y/10
	if player.is_on_floor():
		Transitioned.emit(self, "PlayerGround", "player")
	if player.left_raycast.is_colliding() or player.right_raycast.is_colliding():
		pass
		#Transitioned.emit(self, "PlayerWall", "player")
	player.coyote_dash += delta
	
	if player.is_on_wall() and player.jump_buffer < player.JUMP_BUFFER and not player.wall_collider.wall_colliding_left and not player.wall_collider.wall_colliding_right:
		do_jump(player.JUMP_VELOCITY)
		player.jump_button_pressed = false

func jump_pressed(delta):
	player.jump_buffer += delta
	if not player.has_double_jumped and player.can_double_jump:
		do_jump(player.DOUBLE_JUMP_VELOCITY)
		player.has_double_jumped = true
		player.jump_button_pressed = false
	elif player.jump_buffer > player.JUMP_BUFFER:
		player.jump_button_pressed = false
		

func do_jump(jump_height):
	player.foot_particles.amount = 5
	player.coyote_counter = player.COYETE_TIME + 1
	player.jump_buffer = player.JUMP_BUFFER + 1
	player.velocity.y = jump_height
	player.can_jump = false
	player.jump_button_pressed = false
	player.control_counter = player.CONTROL_LIMIT + 1

func update_facing_direction():
	if player.velocity.x > 0:
		player.sprite.flip_h = false
	elif player.velocity.x < 0:
		player.sprite.flip_h = true

func update_animation():
	player.animation_tree.set("parameters/Move/blend_position", direction)
	update_facing_direction()
