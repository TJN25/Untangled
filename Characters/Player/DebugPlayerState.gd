extends Label

@export var state_machine : PlayerStateMachine
@export var player: Player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#text = "State: " + state_machine.current_state.name
	text = "Can wall jump: " + str(not player.wall_collider.wall_colliding_left and not player.wall_collider.wall_colliding_right)
