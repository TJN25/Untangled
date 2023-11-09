extends Label

@export var state_machine : BallStateMachine
@export var ball: Ball

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#text = "State: " + state_machine.current_state.name
	text = "Ball: " + ball.player.current_ball.name
