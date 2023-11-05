extends State

class_name BallAttack

@export var ball: CharacterBody2D 
var mouse_dir: Vector2
var return_ball: bool = true
var jump_button_pressed: bool = false
var direction: Vector2 = Vector2.ZERO
var wait_for_press: float = 0.05
var wait_counter: float = 0
var can_jump: bool = true

func Enter():
	can_jump = true
	ball.audio_ball_throw.play()
	wait_counter = 0

func Update(delta: float):
	wait_counter += delta
	ball.player_position = ball.player.global_position
	ball.distance_to_player = ball.global_position.distance_to(ball.player_position)
	if ball.distance_to_player > ball.player.ball_throw_range:
		Transitioned.emit(self, "BallReturn", "ball")
	if ball.distance_to_player < 50 and ball.player.state_machine.current_state.name == "PlayerDrag":
		Transitioned.emit(self, "BallFollow", "ball")
	if wait_counter > wait_for_press and can_jump:
		jump_button_pressed = true
		can_jump = false

func Physics_Update(delta):
	move_player(delta)
	do_floor_check(delta)

func move_player(delta):
	if Input.get_axis("throw_left", "throw_right"):
		ball.throw_direction.x = Input.get_axis("throw_left", "throw_right")
	if  Input.get_axis("throw_up", "throw_down"):
		ball.throw_direction.y = Input.get_axis("throw_up", "throw_down")
	if jump_button_pressed:
		do_jump(ball.MAX_SPEED*4.5, ball.MAX_SPEED*4.5)
	ball.trajectory_line_1.hide()

func do_floor_check(delta):
	#Add the gravity.
	if ball.velocity.y < 0:	
		ball.velocity.y += ball.gravity * delta
	else:
		ball.velocity.y += ball.gravity * ball.player.GRAVITY_DOWN_ADJUST * delta

	for i in ball.get_slide_collision_count():
		var collision = ball.get_slide_collision(i)
		if collision:
			Transitioned.emit(self, "BallReturn", "ball")
	
func do_jump(jump_height, speed):
	jump_button_pressed = false
	ball.ball_attached = false
	ball.velocity = ball.throw_direction * speed
	if ball.throw_direction.y == 0:
		ball.velocity.y = -jump_height/16
	ball.ball_thrown_signal.emit(true, ball.throw_direction)
