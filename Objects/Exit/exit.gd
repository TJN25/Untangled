extends Area2D

class_name Exit

signal is_exited(target_room, target_index)

@export var index: int
@export var target_room: String
@export var target_index: int
@onready var spawnpoint: Marker2D = $Marker2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(_on_area_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_entered(area):
	if area is HitboxComponent:
		if area.hitbox_category == "player":
			is_exited.emit(target_room, target_index)
