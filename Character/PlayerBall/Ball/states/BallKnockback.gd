extends State

class_name BallKnockback

@export var ball: Ball

var knockback_timer: float = 0
var knockback_done: bool = false

func Enter() -> void:
	knockback_done = false
	knockback_timer = 0
	do_knockback()

func Exit() -> void:
	ball.knocked_back = false
	ball.knockback_velocity = Vector2.ZERO

func Update(delta: float) -> void:
	knockback_timer += delta
	if ball.position.distance_to(ball.target_position) < 50:
		Transitioned.emit(self, "BallFollow", "ball")
	if knockback_timer > ball.KNOCKBACK_TIME:
		Transitioned.emit(self, "BallReturn", "ball")

func Physics_Update(delta: float) -> void:
	if knockback_timer < ball.KNOCKBACK_TIME/4:
		pass
	elif knockback_timer < ball.KNOCKBACK_TIME and not knockback_done:
		do_knockback()
	else:
		ball.velocity = ball.velocity / 1.2


func do_knockback():
	ball.velocity = -ball.velocity
	knockback_done = true
