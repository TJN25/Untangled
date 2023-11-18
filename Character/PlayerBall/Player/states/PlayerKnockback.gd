extends State

class_name PlayerKnockback

@export var player: Player

var knockback_timer: float = 0
var knockback_done: bool = false
var direction: int = 0


func Enter() -> void:
	knockback_done = false
	knockback_timer = 0
	do_knockback()

func Exit() -> void:
	player.knocked_back = false
	player.knockback_velocity = Vector2.ZERO

func Update(delta: float) -> void:
	knockback_timer += delta
	if knockback_timer > player.KNOCKBACK_TIME:
		Transitioned.emit(self, "PlayerAir", "player")


func Physics_Update(delta: float) -> void:
	if knockback_timer < player.KNOCKBACK_TIME and not knockback_done:
		do_knockback()
	else:
		player.velocity = player.velocity / 1.2
	direction = Input.get_axis("left", "right")
	if Input.is_action_just_pressed("jump"):
		player.jump_buffer = 0
		do_wall_check(delta)
		do_jump_pressed(delta)
	do_sideways_movement(delta, direction)
	player.velocity.x = clamp(player.velocity.x, -player.MAX_SPEED, player.MAX_SPEED)
#	player.velocity.y = clamp(player.velocity.y, player.JUMP_VELOCITY*2, -player.JUMP_VELOCITY*2)

func do_knockback():
	if player.velocity.y > 0:
		player.velocity.y = player.knockback_velocity.y
	else:
		player.velocity = player.knockback_velocity
	knockback_done = true



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
