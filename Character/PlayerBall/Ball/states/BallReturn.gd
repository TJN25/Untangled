extends State

class_name BallReturn

@export var ball: Ball

var throw_ball: bool = false
var distance_to_target: float


func Enter() -> void:
	pass

func Update(delta: float) -> void:
	if ball.position.distance_to(ball.target_position) < 50:
		Transitioned.emit(self, "BallFollow", "ball")
	if ball.knocked_back:
		Transitioned.emit(self, "BallKnockback", "ball")

func Physics_Update(delta: float) -> void:
	do_track()


func do_track():
	var dir = ball.to_local(ball.navigation_agent.get_next_path_position()).normalized()
	ball.velocity = dir * ball.return_speed
	ball.velocity.x = clamp(ball.velocity.x, -ball.return_speed, ball.return_speed)
	ball.velocity.y = clamp(ball.velocity.y, -ball.return_speed, ball.return_speed)

func _on_return_ball():
	Transitioned.emit(self, "BallFollow", "ball")
