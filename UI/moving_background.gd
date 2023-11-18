extends Sprite2D


@export var layer: float = 1
@export var speed_offset: float = 0.01
@export var camera: Camera2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x = -camera.position.x * layer * speed_offset + 500
