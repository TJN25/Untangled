extends PointLight2D

@export var max_energy = 1.5

var can_increase: bool = false



# Called when the node enters the scene tree for the first time.
func _ready():
	energy = 0
	set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if energy <= max_energy:
		energy += delta
	else:
		energy = max_energy
		set_process(false)

func _on_area_2d_area_entered(area):
	if area is HitboxComponent:
		if area.hitbox_category == "player":
			set_process(true)
