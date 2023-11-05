extends State

class_name BallFollow

@export var ball: CharacterBody2D 



var JUMP_VELOCITY: float
var gravity: float
var mouse_dir: Vector2

func Enter():
	ball.audio_ball_throw.stop()
	ball.throw_direction = Vector2.ZERO
	ball.ball_thrown_signal.emit(false, Vector2.ZERO)
	ball.ball_attached = true
	#ball.ball_attack = false
	
	

func Update(delta: float):
	if ball.player.health_component.health  < 1:
		Transitioned.emit(self, "BallControl", "ball")
	#ball.update_trajectory(delta, -ball.JUMP_VELOCITY, ball.MAX_SPEED*3)
#	if Input.is_action_just_pressed("throw_ball"):
#		Transitioned.emit(self, "BallThrow", "ball")
	if Input.get_axis("throw_left", "throw_right") or Input.get_axis("throw_up", "throw_down"):
		ball.throw_direction.x = Input.get_axis("throw_left", "throw_right")
		ball.throw_direction.y = Input.get_axis("throw_up", "throw_down")
		Transitioned.emit(self, "BallAttack", "ball")
#	if Input.is_action_just_pressed("return_ball"):
#		Transitioned.emit(self, "BallAttack", "ball")
func Physics_Update(delta):
	ball.position = ball.player.position + Vector2(-15, -15)


