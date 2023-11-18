extends State

class_name BallFollow

signal is_following

@export var ball = Ball

func Enter():
	ball.motion_mode = 1
	is_following.emit()
	ball.throw_direction = Vector2.ZERO

	
func Exit():
	ball.motion_mode = 0

func Update(delta: float):
	pass

func Physics_Update(delta):
	ball.position = ball.target_position

func _on_is_thrown(_throw_direction):
	ball.throw_direction = _throw_direction
	Transitioned.emit(self, "BallThrow", "ball")

