extends Area2D

class_name Brambles

@export var light: PointLight2D
@export var max_light_energy: float
@export var brambles_block: PackedScene
@export var block_points: BramblesMarkers

var number_of_blocks: float
var blocks: Array[bool]
var active_blocks: float
var current_energy_area: HitboxComponent = null

func _ready() -> void:
	#print("Max light energy for brambles " + str(max_light_energy))
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	for child in block_points.get_children():
		if child is Marker2D:
			var inst = brambles_block.instantiate()
			add_child(inst)
			inst.global_position = child.global_position 
			inst.is_low_health.connect(_on_is_low_health)
			inst.brambles_id = number_of_blocks
			blocks.append(true)
			number_of_blocks += 1
	#print("Number of brambles " + str(number_of_blocks))
	active_blocks = number_of_blocks
	do_light_energy()

func _process(delta: float) -> void:
	#print("Adding energy for brambles area " + str(current_energy_area))
	if current_energy_area:
		var player_energy = PlayerEnergy.new()
		player_energy.energy_added = (number_of_blocks - active_blocks) * delta
		current_energy_area.energy_hit(player_energy)

func do_light_energy():
	light.energy = (1 - active_blocks/number_of_blocks) * max_light_energy
	#print("Light energy for brambles " + str(light.energy))

func save():
	var save_dict = {
		"blocks" : blocks
	}
	return save_dict
#
#func do_item_setup(_collected_items):
#	collected_items = _collected_items
#	items = get_children()
#	if collected_items.size() == 0:
#		print("Collected item size " + str(collected_items.size()))
#		for item in items:
#			item.item_collected.connect(_on_item_collected)
#			collected_items[item.name] = [false]
#	else:
#		for item in items:
#			if collected_items[item.name][0]:
#				item.queue_free()
#			else:
#				item.item_collected.connect(_on_item_collected)



func _on_is_low_health(brambles_id):
	blocks[brambles_id] = false
	active_blocks -= 1
	active_blocks = clamp(active_blocks, 0, number_of_blocks)
	do_light_energy()
	print("Brambles blocks " + str(blocks))

func _on_area_entered(area):
	if area is HitboxComponent:
		if area.hitbox_category == "player":
			current_energy_area = area

func _on_area_exited(area):
	if area is HitboxComponent:
		if area.hitbox_category == "player":
			current_energy_area = null
