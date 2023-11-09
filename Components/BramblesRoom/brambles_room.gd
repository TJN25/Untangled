extends Node2D


@export var main_light: PointLight2D
@export var brambles_component: BramblesComponent

@export_category("lighting values")
@export var MAX_LIGHT_INTENSITY: float = 0.8
@export var MAX_LIGHT_SCALE: float = 1


var brambles_list: Array = [BramblesBlock]
var active_brambles: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	brambles_list = brambles_component.get_children()
	active_brambles = len(brambles_list)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for brambles in brambles_list:
		active_brambles += brambles.brambles_counter
		adjust_lighting()


func adjust_lighting():
	main_light.energy = 1 - active_brambles/len(brambles_list)
