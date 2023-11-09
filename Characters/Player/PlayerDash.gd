extends State

class_name PlayerDash

@export var player: CharacterBody2D 

var direction: float = 0.0
var dash_time: float = 0.0
var cap_speed: bool = false

var speed: float

func Enter():
	cap_speed = false
	player.jump_button_pressed = true
	dash_time = 0.0
	player.audio_jump.play()
	speed = player.DASH_SPEED - player.ball_knockback_value -player.JUMP_VELOCITY
func Exit():
	player.player_dashed = true
	if player.ball_direction.y == 0:
		player.coyote_dash = 0

	
func Update(delta: float):
	dash_time += delta
	if player.health_component.health < 1:
		Transitioned.emit(self, "PlayerDead", "player")
	if dash_time > player.max_dash_time:
		Transitioned.emit(self, "PlayerAir", "player")
	update_animation()



func Physics_Update(delta):
	move_player(delta)

func move_player(delta):
	player.foot_particles.amount = 0
	do_floor_check(delta)
	if player.jump_button_pressed:
		jump_pressed(delta)
	direction = Input.get_axis("left", "right")
	if direction and player.velocity.x > -player.MAX_SPEED and player.velocity.x < player.MAX_SPEED:
		if player.is_on_floor():
			player.velocity.x += player.velocity.x + direction * player.SPEED/10
		else:
			player.velocity.x += player.velocity.x + direction * player.SPEED/10
	
	if player.max_dash_speed < speed:
		player.velocity.x = clamp(player.velocity.x, -player.max_dash_speed, player.max_dash_speed)
	elif speed < player.MAX_SPEED:
		player.velocity.x = clamp(player.velocity.x, -player.MAX_SPEED, player.MAX_SPEED)
	else:
		player.velocity.x = clamp(player.velocity.x, -speed, speed)
	player.velocity.y = clamp(player.velocity.y, -speed, speed*2)
	
	if cap_speed:
		player.velocity.x = clamp(player.velocity.x, -player.MAX_SPEED, player.MAX_SPEED)
		
	
	if not Input.is_action_pressed("throw_down") and not Input.is_action_pressed("throw_up") and not Input.is_action_pressed("throw_left") and not Input.is_action_pressed("throw_right") and dash_time > player.max_dash_time/2:
		player.velocity = player.velocity/player.DRAG_FACTOR
		cap_speed = true
	
func do_floor_check(delta):
	#Add the gravity.
	if not player.is_on_floor() and player.ball_direction.y != 0:
		if player.wall_counter > player.COYETE_TIME or (not player.left_raycast.is_colliding() and not player.right_raycast.is_colliding()) or player.velocity.y < 0:
			if player.velocity.y < 0:		
				player.velocity.y += player.gravity * delta
			else:
				player.audio_jump.stop()
				player.velocity.y += player.gravity * player.GRAVITY_DOWN_ADJUST * delta
		
func jump_pressed(delta):
	player.jump_buffer += delta
	do_jump()
	player.jump_button_pressed = false
		

func do_jump():
	player.velocity.y = -player.ball_direction.y * speed
	player.velocity.x -= player.ball_direction.x * speed

func update_facing_direction():
	if player.velocity.x > 0:
		player.sprite.flip_h = false
	elif player.velocity.x < 0:
		player.sprite.flip_h = true

func update_animation():
	player.animation_tree.set("parameters/Move/blend_position", direction)
	update_facing_direction()
