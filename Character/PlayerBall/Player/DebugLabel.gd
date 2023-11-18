extends Label


@export var player: Player
@export var state_machine: PlayerStateMachine

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = "Air state: " + state_machine.current_state.name
	#text = "Velocity: " + str(player.is_on_floor())
#	text = "Can wall jump: " + str(player.control_counter < player.CONTROL_LIMIT)
