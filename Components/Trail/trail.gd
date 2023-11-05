extends Line2D

class_name Trail

@onready var curve:= Curve2D.new()

@export var MAX_POINTS: int = 2000


func _process(delta: float) -> void: 
	curve.add_point(get_parent().position)
	if curve.get_baked_points().size() > MAX_POINTS:
		curve.remove_point(0)
	points = curve.get_baked_points()

func stop():
	set_process(false)
	var tw:= get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 3.0)
	await tw.finished
	queue_free()
	
static func create() -> Trail:
	var scn = preload("res://Components/Trail/trail.tscn")
	return scn.instantiate()
