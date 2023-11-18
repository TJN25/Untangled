extends State

class_name PlayerGround


@export var player: Player

var direction: float = 0


func Enter():
	pass
#	player.coyote_dash = player.COYETE_TIME + 1
#	player.audio_landing.play()
#	player.coyote_time = 0
#	player.has_double_jumped = false
	
func Update(delta: float):
	if player.knocked_back:
		Transitioned.emit(self, "PlayerKnockback", "player")

func Physics_Update(delta):
	pass
	direction = Input.get_axis("left", "right")
	if Input.is_action_just_pressed("jump"):
		player.jump_buffer = 0
	do_coyote_check(delta)
	if player.coyote_time > player.COYOETE_TIME:
		Transitioned.emit(self, "PlayerAir", "player")
	do_jump_pressed(delta)
	do_sideways_movement(delta, direction)
	player.velocity.x = clamp(player.velocity.x, -player.MAX_SPEED, player.MAX_SPEED)
	player.velocity.y = clamp(player.velocity.y, player.JUMP_VELOCITY*2, -player.JUMP_VELOCITY*2)


func do_coyote_check(_delta):
	if player.is_on_floor():
		player.coyote_time = 0
	elif player.coyote_time <= player.COYOETE_TIME:
		player.velocity.y += player.gravity * 0.1 * _delta
		player.coyote_time += _delta
	else:
		Transitioned.emit(self, "PlayerAir", "player")

func do_jump_pressed(_delta):
	if player.jump_buffer < player.JUMP_BUFFER:
		player.jump_buffer += _delta
		if player.coyote_time < player.COYOETE_TIME:
			do_jump(_delta, player.JUMP_VELOCITY)
		elif not player.has_double_jumped and player.can_double_jump:
			do_jump(_delta, player.DOUBLE_JUMP_VELOCITY)
			player.has_double_jumped = true

func do_jump(_delta, _speed):
	player.jump_buffer = player.JUMP_BUFFER + 1
	player.coyote_time = player.COYOETE_TIME + 1
	player.velocity.y = _speed
	Transitioned.emit(self, "PlayerAir", "player")

func do_sideways_movement(_delta, _direction):
	if _direction:
		player.velocity.x += _direction * player.speed
	else:
		player.velocity.x = player.velocity.x/(player.DRAG_FACTOR + 0.6)

func _on_is_thrown(_throw_direction):
#	print("Throw emmited to player " + str(player.can_dash))
	if _throw_direction.y >=0 and player.can_dash:
		player.throw_direction = _throw_direction
		Transitioned.emit(self, "PlayerDash", "player")
	elif player.knockback_collisions.collision_direction != Vector2.ZERO:
		player.knocked_back = true
		if player.knockback_collisions.collision_direction.x == 0:
			player.knockback_velocity = player.knockback_collisions.collision_direction * player.JUMP_VELOCITY * 1.5
		else:
			player.knockback_velocity = -player.knockback_collisions.collision_direction * player.MAX_SPEED * 1.5
			Transitioned.emit(self, "PlayerKnockback", "player")
