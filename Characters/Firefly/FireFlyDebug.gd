extends Label


@export var firefly : Firefly


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = "Light: " + str(firefly.light.energy)
