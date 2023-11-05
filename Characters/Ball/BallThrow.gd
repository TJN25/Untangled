extends State

class_name BallThrow

@export var ball: CharacterBody2D 
var mouse_dir: Vector2
var return_ball: bool = true
var jump_button_pressed: bool = false
var attach_cooldown: float = 0

# Ball can be thrown by player
# on collision, ball will return to player
# ball does not pull player
# ball is not given control

func Enter():
	attach_cooldown = 0
	jump_button_pressed = true

	
func Update(delta: float):
	ball.player_position = ball.player.global_position
	ball.distance_to_player = ball.global_position.distance_to(ball.player_position)
	if ball.distance_to_player > 1000:
		Transitioned.emit(self, "BallReturn", "ball")
	if ball.distance_to_player < 50 and ball.player.state_machine.current_state.name == "PlayerDrag":
		Transitioned.emit(self, "BallFollow", "ball")
	elif ball.distance_to_player < 50:
		pass
	if ball.ball_attack:
		ball.ball_attack = false
		ball.audio_collision_ball.play(0.0)
		Transitioned.emit(self, "BallReturn", "ball")
	attach_cooldown += delta
		
func Physics_Update(delta):
	move_player(delta)
	do_floor_check(delta)

func move_player(delta):
	ball.trajectory_line_1.hide()
	if jump_button_pressed:
		do_jump(-ball.JUMP_VELOCITY, ball.MAX_SPEED*3)

func do_floor_check(delta):
	#Add the gravity.
	if ball.velocity.y < 0:	
		ball.velocity.y += ball.gravity * delta
	else:
		ball.velocity.y += ball.gravity * ball.player.GRAVITY_DOWN_ADJUST * delta
	
	if attach_cooldown > 0.1:
		ball.player_position = ball.player.global_position
		ball.distance_to_player = ball.position.distance_to(ball.player_position)
		if ball.distance_to_player < 40:
			Transitioned.emit(self, "BallFollow", "ball")
	
	for i in ball.get_slide_collision_count():
		var collision = ball.get_slide_collision(i)
		if collision:
			Transitioned.emit(self, "BallReturn", "ball")
	if ball.ball_in_brambles:
		Transitioned.emit(self, "BallReturn", "ball")
	
func do_jump(jump_height, speed):
	ball.ball_attached = false
	mouse_dir = (ball.get_global_mouse_position() - ball.global_position).normalized()
	var mouse_angle = mouse_dir.angle()
	jump_button_pressed = false
	if mouse_angle > 0:
		ball.velocity = mouse_dir * speed
	elif speed * tan(mouse_angle) > jump_height or speed * tan(mouse_angle) < -jump_height:
		ball.velocity.x  = -jump_height/tan(mouse_angle)
		ball.velocity.y = -jump_height
	else:
		if mouse_angle + PI/2 > 0:
			ball.velocity.x  = speed
			ball.velocity.y = speed * tan(mouse_angle)
		else:
			ball.velocity.x  = -speed
			ball.velocity.y = -speed * tan(mouse_angle)
	ball.ball_thrown_signal.emit(true, Vector2(ball.velocity.x, ball.velocity.y))
