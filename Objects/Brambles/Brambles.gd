extends Area2D

class_name Brambles

@export var light: PointLight2D
@export var max_light_energy: float
@export var brambles_block: PackedScene
@export var block_points: BramblesMarkers
@export var boss: Boss1

var number_of_blocks: float
var blocks: Array
var active_blocks: float
var current_energy_area: HitboxComponent = null

func _ready() -> void:
	#print("Max light energy for brambles " + str(max_light_energy))
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _process(delta: float) -> void:
	#print("Adding energy for brambles area " + str(current_energy_area))
	if current_energy_area:
		var player_energy = PlayerEnergy.new()
		player_energy.energy_added = (number_of_blocks - active_blocks) * delta
		current_energy_area.energy_hit(player_energy)

func do_light_energy():
	light.energy = (1 - active_blocks/number_of_blocks) * max_light_energy
#	print("Light energy for brambles " + str(light.energy))

func save():
	var save_dict = {
		"blocks" : blocks
	}
	return save_dict
#
func do_brambles_setup(_blocks):
	blocks = _blocks
	var counter = 0
	for child in block_points.get_children():
		if child is Marker2D:
			if blocks.size() != 0:
				if not blocks[counter]:
#					print("continuing " + str(blocks[counter]))
					number_of_blocks += 1
					counter += 1
					continue
				counter += 1
			var inst = brambles_block.instantiate()
			add_child(inst)
			inst.global_position = child.global_position 
			inst.is_low_health.connect(_on_is_low_health)
			inst.brambles_id = number_of_blocks
			blocks.append(true)
			number_of_blocks += 1
			if counter == 1:
				if boss is Boss1:
					boss.is_boss_dead.connect(inst._on_boss_dead)

	#print("Number of brambles " + str(number_of_blocks))
	active_blocks = number_of_blocks
	do_light_energy()




func _on_is_low_health(brambles_id):
	blocks[brambles_id] = false
	active_blocks -= 1
	active_blocks = clamp(active_blocks, 0, number_of_blocks)
	do_light_energy()
#	print("Brambles blocks " + str(blocks))

func _on_area_entered(area):
	if area is HitboxComponent:
		if area.hitbox_category == "player":
			current_energy_area = area

func _on_area_exited(area):
	if area is HitboxComponent:
		if area.hitbox_category == "player":
			current_energy_area = null
