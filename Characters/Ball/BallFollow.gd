extends State

class_name BallFollow

@export var ball: CharacterBody2D 



var JUMP_VELOCITY: float
var gravity: float
var mouse_dir: Vector2

func Enter():
	ball.motion_mode = 1
	#ball.audio_ball_throw.stop()
	ball.throw_direction = Vector2.ZERO
	ball.ball_thrown_signal.emit(false, Vector2.ZERO)
	ball.ball_attached = true
	#ball.ball_attack = false
	
func Exit():
	ball.motion_mode = 0

func Update(delta: float):
	if ball.player.do_bright_light:
		ball.player.energy_component.player_energy -= ball.player.energy_cost * delta
	if ball.player.state_machine.current_state.name == "PlayerDead" or ball.player.state_machine.current_state.name == "PlayerDrag":
		Transitioned.emit(self, "BallControl", "ball")
	if ball.player.throw_counter > 0:
		if Input.is_action_just_pressed("throw_down") or Input.is_action_just_pressed("throw_up") or Input.is_action_just_pressed("throw_left") or Input.is_action_just_pressed("throw_right"):
			if Input.get_axis("throw_left", "throw_right") or Input.get_axis("throw_up", "throw_down"):
				ball.throw_direction.x = Input.get_axis("throw_left", "throw_right")
				ball.throw_direction.y = Input.get_axis("throw_up", "throw_down")
				if ball.player.ball_can_move:
					Transitioned.emit(self, "BallControl", "ball")
				else:
					Transitioned.emit(self, "BallAttack", "ball")
		elif ball.throw_jump_buffer < ball.player.JUMP_BUFFER/2:
			ball.throw_jump_buffer = ball.player.JUMP_BUFFER + 1
			if ball.player.ball_can_move:
				Transitioned.emit(self, "BallControl", "ball")
			else:
				Transitioned.emit(self, "BallAttack", "ball")
#	if Input.is_action_just_pressed("return_ball"):
#		Transitioned.emit(self, "BallAttack", "ball")
func Physics_Update(delta):
	ball.position = ball.player.position + Vector2(-15, -15)


