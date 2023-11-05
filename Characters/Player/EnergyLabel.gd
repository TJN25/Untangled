extends Label

@export var player: Player

func _process(delta):
	text = "Energy: " +  str(player.player_energy)
