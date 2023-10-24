extends Node2D

@export var brambles: PackedScene
@export var navigation_path: PackedScene


var rng = RandomNumberGenerator.new()
var spawn_counter: int = 2
var brambles_counter: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	var inst = brambles.instantiate()
	add_child(inst)
	inst.brambles_destroyed.connect(_on_brambles_destroyed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_brambles_destroyed():
	brambles_counter -= 1



func _on_timer_timeout():
	print("timeout")
	var rnd_number = rng.randi_range(0, 20)
	print(rnd_number)
	if brambles_counter > 0 and brambles_counter < 10:
		if rnd_number > spawn_counter/brambles_counter:
			var inst = brambles.instantiate()
			add_child(inst)
			inst.brambles_destroyed.connect(_on_brambles_destroyed)
			var rnd_x = rng.randi_range(-50, 50)
			var rnd_y = rng.randi_range(-50, 50)
			inst.global_position = global_position + Vector2(rnd_x, rnd_y)
			spawn_counter += 1
			brambles_counter += 1
	$SpawnTimer.start()
