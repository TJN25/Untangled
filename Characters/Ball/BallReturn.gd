extends State

class_name BallReturn

@export var ball: CharacterBody2D 

var mouse_dir: Vector2
var return_ball: bool = true
var jump_button_pressed: bool = false
var speed: float

func Enter():
	ball.make_path()
	speed = ball.PLAYER_FORCE + ball.player.return_speed

func Update(delta: float):
	ball.player.energy_component.player_energy -= ball.player.energy_cost * delta
	ball.throw_jump_buffer += delta
	if Input.get_axis("throw_left", "throw_right"):
		ball.throw_direction.x = Input.get_axis("throw_left", "throw_right")
		ball.throw_jump_buffer = 0
	if  Input.get_axis("throw_up", "throw_down"):
		ball.throw_direction.y = Input.get_axis("throw_up", "throw_down")
		ball.throw_jump_buffer = 0
		

func Physics_Update(delta):
	move_relative_to_player(delta)
	do_floor_check(delta)


func move_relative_to_player(delta):
	ball.trajectory_line_1.hide()
	ball.player_position = ball.player.global_position
	var dir = ball.to_local(ball.navigation_agent.get_next_path_position()).normalized()
	var diff = ball.player_position - ball.global_position
	ball.distance_to_player = ball.global_position.distance_to(ball.player_position)
	ball.angle_to_player = diff.angle()
	if ball.distance_to_player > 40:
		ball.velocity = dir * speed
	else:
		Transitioned.emit(self, "BallFollow", "ball")


func do_floor_check(delta):
	#Add the gravity.
	if not ball.is_on_floor() and not ball.ball_attached:
		if ball.velocity.y < 0:	
			ball.velocity.y += ball.gravity * delta
		else:
			ball.velocity.y += ball.gravity * ball.player.GRAVITY_DOWN_ADJUST * delta

