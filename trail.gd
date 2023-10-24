extends Line2D

class_name MyTrail

@onready var curve:= Curve2D.new()
const MAX_POINTS: int = 50



func _process(delta: float) -> void: 
	curve.add_point(get_parent().position)
	if curve.get_baked_points().size() > MAX_POINTS:
		curve.remove_point(0)
	points = curve.get_baked_points()

func stop():
	set_process(false)
	queue_free()
	
static func create() -> Trail:
	var scn = preload("res://trail.tscn")
	return scn.instantiate()
