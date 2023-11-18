extends Label


@export var ball: Ball
@export var state_machine: BallStateMachine

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = "State: " + state_machine.current_state.name
#	text = "Ball knocked back: " + str(ball.knocked_back)
#	text = "Can wall jump: " + str(player.coyote_wall_time)
