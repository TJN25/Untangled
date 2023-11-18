extends State

class_name PlayerDash

@export var player: Player

var direction: float = 0
var player_dash: bool = false
var dash_time: float = 0.0

func Enter():
	player.collision_box.scale.y = 0.8
#	print("Player is dashing")
	player_dash = true
	player.throw_animation_time = 0
	dash_time = 0

func Exit():
	player.collision_box.scale.y = 1

	
func Update(delta: float):
	if player.knocked_back:
		Transitioned.emit(self, "PlayerKnockback", "player")

func Physics_Update(delta):
	if player.throw_animation_time < player.MAX_THROW_ANIMATION_TIME * 0.75:
		player.throw_animation_time += delta
		direction = Input.get_axis("left", "right")
		direction = direction * 0.5
		#do_sideways_movement(delta, direction)
		do_floor_check(delta)
		player.velocity = player.velocity/player.DRAG_FACTOR
		
	else:
		dash_time += delta
		if player_dash:
			do_dash(player.throw_direction, player.dash_speed)
		else:
			direction = Input.get_axis("left", "right")
			if Input.is_action_just_pressed("jump"):
				player.jump_buffer = 0
			do_wall_check(delta)
			do_jump_pressed(delta)
		if not Input.is_action_pressed("throw_down") and not Input.is_action_pressed("throw_up") and not Input.is_action_pressed("throw_left") and not Input.is_action_pressed("throw_right") and dash_time > player.max_dash_time/2:
			player.velocity = player.velocity/player.DRAG_FACTOR
			do_floor_check(delta)
			do_sideways_movement(delta, direction)
			player.velocity.x = clamp(player.velocity.x, -player.MAX_SPEED, player.MAX_SPEED)
			player.velocity.y = clamp(player.velocity.y, player.JUMP_VELOCITY*2, -player.JUMP_VELOCITY*2)
		
		
	if dash_time > player.max_dash_time:
		if player.is_on_floor():
			Transitioned.emit(self, "PlayerGround", "player")
		else:
			Transitioned.emit(self, "PlayerAir", "player")


func do_floor_check(_delta):
	if not player.is_on_floor():
		if player.velocity.y < 0:
			player.air_hang = 0
			player.velocity.y += player.gravity * _delta
		else:
			if player.air_hang < player.AIR_HANG:
				player.velocity.y += player.gravity * 0.1 * _delta
				player.air_hang += _delta
			else:
				player.velocity.y += player.gravity * _delta * player.GRAVITY_DOWN_ADJUST

func do_wall_check(_delta):
	if player.wall_collider.wall_direction != 0:
		player.coyote_wall_time
	else:
		player.coyote_wall_time += _delta

func do_jump_pressed(_delta):
	if player.jump_buffer < player.JUMP_BUFFER:
		player.jump_buffer += _delta


func do_sideways_movement(_delta, _direction):
	if _direction:
		if player.control_counter < player.CONTROL_LIMIT:
			player.velocity.x += _direction * player.speed
		else:
			player.velocity.x += _direction * player.speed
	else:
		player.velocity.x = player.velocity.x/player.DRAG_FACTOR

func do_coyote_check(_delta):
	if player.is_on_floor():
		player.coyote_time = 0
	elif player.coyote_time <= player.COYOETE_TIME:
		player.velocity.y += player.gravity * 0.1 * _delta
		player.coyote_time += _delta

func do_dash(_throw_direction, _speed):
	if _throw_direction.x == 0:
		player.velocity = _speed * _throw_direction/2
	else:
		player.velocity = _speed * _throw_direction
	player_dash = false

