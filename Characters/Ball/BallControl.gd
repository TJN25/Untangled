extends State

class_name BallControl

@export var ball: CharacterBody2D 
var mouse_dir: Vector2
var return_ball: bool = true
var attach_cooldown: float = 0

var wait_counter: float = 0
var wait_for_press: float = 0.05

var move_timer: float = 0.0


func Enter():
	move_timer = 0
	ball.motion_mode = 0
	ball.ball_attached = false
	ball.can_jump = true

func Update(delta: float):
	ball.player.energy_component.player_energy -= ball.player.energy_cost * delta
	wait_counter += delta
	if ball.player.state_machine.current_state.name == "PlayerAir":
		Transitioned.emit(self, "BallReturn", "ball")
	if ball.player.state_machine.current_state.name != "PlayerDead":
		move_timer += delta
		if move_timer > ball.player.max_move_time:
			Transitioned.emit(self, "BallReturn", "ball")
func Physics_Update(delta):
	do_coyote_check(delta)
	do_floor_check(delta)
	move_player(delta)

func move_player(delta):
	if Input.get_axis("throw_left", "throw_right"):
		ball.jump_button_pressed = true
		ball.throw_direction.x = Input.get_axis("throw_left", "throw_right")
	if  Input.get_axis("throw_up", "throw_down"):
		ball.jump_button_pressed = true
		ball.throw_direction.y = Input.get_axis("throw_up", "throw_down")
	if not ball.can_jump and (Input.is_action_pressed("throw_left") or Input.is_action_pressed("throw_right") or Input.is_action_pressed("throw_down")) and not Input.is_action_pressed("throw_up"):
		if Input.is_action_pressed("throw_left"):
			ball.throw_direction.x = -1
		elif Input.is_action_pressed("throw_right"):
			ball.throw_direction.x = 1
		elif Input.is_action_pressed("throw_down"):
			ball.throw_direction.y = 1
		do_jump(ball.MAX_SPEED/50, ball.MAX_SPEED)
	if ball.jump_button_pressed and wait_counter > wait_for_press:
		do_jump_pressed(delta)
	ball.velocity.x = clamp(ball.velocity.x, -ball.MAX_SPEED, ball.MAX_SPEED)
	ball.velocity.y = clamp(ball.velocity.y, -ball.MAX_SPEED, ball.MAX_SPEED)
func do_floor_check(delta):
	#Add the gravity.
	if ball.is_on_floor() or ball.is_on_wall() or ball.is_on_ceiling():
		ball.can_jump = true
	if ball.vertical_raycast.is_colliding():
		pass
	if not ball.is_on_floor():
		if ball.velocity.y < 0:	
			ball.velocity.y += ball.gravity * delta * 0.75
		else:
			ball.velocity.y += ball.gravity * ball.player.GRAVITY_DOWN_ADJUST * delta * 0.75

func do_jump_pressed(delta):
	ball.jump_buffer += delta
	if ball.can_jump or ball.throw_direction.y == 0:
		do_jump(ball.MAX_SPEED, ball.MAX_SPEED)
		ball.jump_button_pressed = false


func do_coyote_check(delta):
	if ball.is_on_floor() or ball.left_raycast.is_colliding() or ball.right_raycast.is_colliding():
		ball.coyote_counter = 0
	elif ball.coyote_counter <= ball.player.COYETE_TIME:
		ball.coyote_counter += delta

func do_jump(jump_height, speed):
	ball.audio_ball_throw.play()
	ball.ball_attached = false
	ball.can_jump = false
	wait_counter = 0
	if ball.throw_direction.x != 0:
		ball.velocity.x += ball.throw_direction.x * speed/5
	if ball.throw_direction.y != 0:
		ball.velocity.y = ball.throw_direction.y * speed
	ball.throw_direction = Vector2(0.0, 0.0)
