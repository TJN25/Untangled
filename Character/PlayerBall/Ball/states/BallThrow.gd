extends State

class_name BallThrow

@export var ball: Ball

var throw_ball: bool = false
var distance_to_target: float


func Enter() -> void:
	ball.throw_animation_time = 0
#	distance_to_target = 15
	throw_ball = false

func Update(delta: float) -> void:
	if ball.knocked_back:
		Transitioned.emit(self, "BallKnockback", "ball")

func Physics_Update(delta: float) -> void:
	#print("Ball throw speed " + str(ball.throw_direction * ball.MAX_SPEED))
	if not throw_ball:
		do_throw_animation(delta)
	else:
		do_throw()
		if ball.position.distance_to(ball.target_position) > ball.return_distance:
			Transitioned.emit(self, "BallReturn", "ball")
		do_floor_check(delta)

func do_throw_animation(delta):
	if ball.throw_animation_time > ball.MAX_THROW_ANIMATION_TIME:
		ball.velocity = Vector2.ZERO
		throw_ball = true
	else:
		ball.throw_animation_time += delta
		ball.position = ball.target_position 
#
#
func do_throw():
	ball.velocity = ball.throw_direction * ball.MAX_SPEED

func do_floor_check(delta):
	for i in ball.get_slide_collision_count():
		var collision = ball.get_slide_collision(i)
		if collision:
			Transitioned.emit(self, "BallReturn", "ball")

func _on_return_ball():
	Transitioned.emit(self, "BallReturn", "ball")
