extends Label

@export var player: Player

func _process(delta):
	text = "Energy: " +  str(int(player.energy_component.player_energy))
