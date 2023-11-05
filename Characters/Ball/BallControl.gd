extends State

class_name BallControl

@export var ball: CharacterBody2D 
var mouse_dir: Vector2
var return_ball: bool = true
var attach_cooldown: float = 0

var wait_counter: float = 0
var wait_for_press: float = 0.05
# Ball can be thrown by player
# on collision, ball will return to player
# ball does not pull player
# ball is not given control

func Enter():
	ball.ball_attached = false
	
func Update(delta: float):
	wait_counter += delta
	if ball.player.health_component.health > 10:
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
	if ball.jump_button_pressed and wait_counter > wait_for_press:
		do_jump_pressed(delta)

func do_floor_check(delta):
	#Add the gravity.
	if ball.vertical_raycast.is_colliding():
		pass
	elif ball.velocity.y < 0:	
		ball.velocity.y += ball.gravity * delta
	else:
		ball.velocity.y += ball.gravity * ball.player.GRAVITY_DOWN_ADJUST * delta
	for i in ball.get_slide_collision_count():
		var collision = ball.get_slide_collision(i)
		if collision:
			ball.velocity = ball.velocity.bounce(collision.get_normal()) * 0.5

	
func do_jump_pressed(delta):
	ball.jump_buffer += delta
	if not ball.has_double_jumped and ball.coyote_counter >= ball.player.COYETE_TIME:
		do_jump(ball.MAX_SPEED, ball.MAX_SPEED)
		ball.has_double_jumped = true
		ball.jump_button_pressed = false
	elif ball.jump_buffer > ball.player.JUMP_BUFFER:
		ball.jump_button_pressed = false
		ball.jump_buffer = 0
		return
	if ball.coyote_counter < ball.player.COYETE_TIME or ball.jump_buffer < ball.player.JUMP_BUFFER:
		do_jump(ball.MAX_SPEED, ball.MAX_SPEED)
		ball.has_double_jumped = false

func do_coyote_check(delta):
	if ball.is_on_floor() or ball.left_raycast.is_colliding() or ball.right_raycast.is_colliding():
		ball.coyote_counter = 0
	elif ball.coyote_counter <= ball.player.COYETE_TIME:
		ball.coyote_counter += delta

	
func do_jump(jump_height, speed):
	#ball.audio_ball_throw.play()
	ball.ball_attached = false
	wait_counter = 0
	ball.velocity = ball.throw_direction * speed
	#ball.ball_thrown_signal.emit(true, Vector2(ball.velocity.x, ball.velocity.y))
	ball.throw_direction = Vector2.ZERO
