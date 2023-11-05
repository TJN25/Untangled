extends Label


@export var player: Player

func _process(delta):
	text = "Health: " +  str(player.health_component.health)
