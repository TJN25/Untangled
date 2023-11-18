extends State

class_name PlayerAir

@export var player: Player

var direction: float = 0
var jump_counter: int = 0
var do_long_jump: bool = false

func Enter():
	player.control_counter = player.CONTROL_LIMIT + 1
	if Input.is_action_pressed("jump"):
		do_long_jump = true
	else:
		do_long_jump = false
	jump_counter = player.max_jumps
#	player.coyote_dash = player.COYETE_TIME + 1
#	player.audio_landing.play()
	player.coyote_time = 0
	player.coyote_wall_time = 0
	player.has_double_jumped = false
	
func Update(delta: float):
	if player.knocked_back:
		Transitioned.emit(self, "PlayerKnockback", "player")
#	update_animation()
#	if player.velocity.x < 5 and player.velocity.x > -5 and player.is_on_floor():
#		player.foot_particles.amount = 1

func Physics_Update(delta):
	if do_long_jump:
		if not Input.is_action_pressed("jump"):
			do_long_jump = false
	direction = Input.get_axis("left", "right")
	if Input.is_action_just_pressed("jump"):
		player.jump_buffer = 0
	do_floor_check(delta)
	do_wall_check(delta)
	do_jump_pressed(delta)
	do_sideways_movement(delta, direction)
	if not player.control_counter < player.CONTROL_LIMIT:
		player.velocity.x = clamp(player.velocity.x, -player.MAX_SPEED, player.MAX_SPEED)
	player.velocity.y = clamp(player.velocity.y, player.JUMP_VELOCITY*1.5, -player.JUMP_VELOCITY*1.5)


func do_floor_check(_delta):
	if not player.is_on_floor():
		if player.velocity.y < 0 and do_long_jump:
			player.collision_box.scale.y = 0.3
			player.air_hang = 0
			player.velocity.y += player.gravity * _delta
		elif player.velocity.y < 0 and not do_long_jump:
			player.velocity.y += player.gravity * _delta * player.GRAVITY_DOWN_ADJUST * 3
		else:
			player.collision_box.scale.y = 1
			if player.air_hang < player.AIR_HANG:
				player.velocity.y += player.gravity * 0.8 * _delta
				player.air_hang += _delta
			else:
				player.velocity.y += player.gravity * _delta * player.GRAVITY_DOWN_ADJUST
	else:
		Transitioned.emit(self, "PlayerGround", "player")

func do_wall_check(_delta):
	if player.wall_collider.wall_direction != 0:
		player.coyote_wall_time = 0
	else:
		player.coyote_wall_time += _delta
	if player.is_on_wall() and player.jump_buffer < player.JUMP_BUFFER and not player.wall_collider.wall_colliding_left and not player.wall_collider.wall_colliding_right and player.velocity.y >=0:
		do_jump(_delta, player.JUMP_VELOCITY)
	elif player.coyote_wall_time < player.COYOETE_TIME and player.jump_buffer < player.JUMP_BUFFER and player.can_wall_jump:
		do_wall_jump(_delta, player.JUMP_VELOCITY, player.MAX_SPEED * player.wall_collider.wall_direction * 2)



func do_jump_pressed(_delta):
	if player.jump_buffer < player.JUMP_BUFFER:
		player.jump_buffer += _delta
		if not player.has_double_jumped and jump_counter > 0:
			do_jump(_delta, player.DOUBLE_JUMP_VELOCITY)
			jump_counter -= 1
			player.has_double_jumped = true
			do_long_jump = true

func do_jump(_delta, _speed):
	player.jump_buffer = player.JUMP_BUFFER + 1
	player.coyote_time = player.COYOETE_TIME + 1
	player.velocity.y = _speed

func do_wall_jump(_delta, _jump, _speed):
	player.jump_buffer = player.JUMP_BUFFER + 1
	player.coyote_time = player.COYOETE_TIME + 1
	player.velocity.y = _jump
	player.velocity.x = _speed
	player.control_counter = 0
	do_long_jump = true

func do_sideways_movement(_delta, _direction):
	if player.control_counter < player.CONTROL_LIMIT:
		player.control_counter += _delta
		if _direction:
			player.velocity.x += _direction * player.speed/10
	elif _direction:
		player.velocity.x += _direction * player.speed
	else:
		player.velocity.x = player.velocity.x/player.DRAG_FACTOR


func _on_is_thrown(_throw_direction):
#	print("Player dash from air " + str(player.can_dash))
	if player.can_dash and _throw_direction.y == 0:
		player.throw_direction = _throw_direction
		Transitioned.emit(self, "PlayerDash", "player")
	elif player.can_vertical_dash and _throw_direction.x == 0:
		player.throw_direction = _throw_direction
		Transitioned.emit(self, "PlayerDash", "player")
	elif player.can_diagonal_dash:
		player.throw_direction = _throw_direction
		Transitioned.emit(self, "PlayerDash", "player")
	elif player.knockback_collisions.collision_direction != Vector2.ZERO:
		player.knocked_back = true
		if player.knockback_collisions.collision_direction.x == 0:
			player.knockback_velocity = player.knockback_collisions.collision_direction * player.JUMP_VELOCITY * 1.5
		else:
			player.knockback_velocity = -player.knockback_collisions.collision_direction * player.MAX_SPEED * 1.5	
			Transitioned.emit(self, "PlayerKnockback", "player")

