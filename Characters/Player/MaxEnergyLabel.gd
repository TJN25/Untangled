extends Label


@export var player: Player

func _process(delta):
	text = "Max Energy: " +  str(player.max_player_energy)
