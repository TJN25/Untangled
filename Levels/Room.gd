extends Node2D

class_name Room

signal is_room_exited(room_name, target_room, target_index)

@export var room_name: String
@onready var items: Items = $Items
@onready var brambles: Brambles = $Brambles
@onready var exits: Exits = $Exits
@onready var player_ball_controller: PlayerBallController = $PlayerBallController
@onready var energy_bar: ProgressBar = $CanvasLayer/EnergyBar/EnergyLevel
#@onready var camera: Camera2D = $Camera2D

var save_id

var inventory_resources: Dictionary = {"BasicBall" = "res://Character/PlayerBall/Inventory/Resources/balls/BasicBall.tres", "KnockbackBall" = "res://Character/PlayerBall/Inventory/Resources/balls/KnockbackBall.tres", 
"do_knockback" = "res://Character/PlayerBall/Inventory/Resources/powerups/do_knockback.tres", "do_wall_jump" = "res://Character/PlayerBall/Inventory/Resources/powerups/do_wall_jump.tres", 
"increase_jumps" = "res://Character/PlayerBall/Inventory/Resources/powerups/increase_jumps.tres", "increase_knockback" = "res://Character/PlayerBall/Inventory/Resources/powerups/increase_knockback.tres",
"DashBall" = "res://Character/PlayerBall/Inventory/Resources/balls/DashBall.tres", "do_dash" = "res://Character/PlayerBall/Inventory/Resources/powerups/do_dash.tres"}

var spawn_index: int = 0
var spawn_location: Vector2 = Vector2.ZERO
var collected_items

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	

func do_exits():
	for exit in exits.get_children():
		exit.is_exited.connect(_on_is_exited)
		if exit.index == spawn_index:
			spawn_location = exit.spawnpoint.global_position
	player_ball_controller.global_position = spawn_location	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
#	print(collected_items)

func save_room():
	var save_game = FileAccess.open("user://saveroom" + save_id + room_name + ".save", FileAccess.WRITE)
	if not items.has_method("save"):
		return
	var node_data = items.call("save")
	var json_string = JSON.stringify(node_data)
	save_game.store_line(json_string)
	
#	if not brambles.has_method("save"):
#		return
#	node_data = brambles.call("save")
#	json_string = JSON.stringify(node_data)
#	save_game.store_line(json_string)

func save_player():
	var save_game = FileAccess.open("user://saveplayer" + save_id + ".save", FileAccess.WRITE)
	# Check the node has a save function.
	if not player_ball_controller.has_method("save"):
#		print("Items node is missing a save() function, skipped")
		return
		# Call the node's save function.
	var node_data = player_ball_controller.call("save")
		# JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(node_data)

	# Store the save dictionary as a new line in the save file.
	save_game.store_line(json_string)

func load_room():
	if not FileAccess.file_exists("user://saveroom" + save_id + room_name + ".save"):
		items.do_item_setup({})
		return
	var save_game = FileAccess.open("user://saveroom" + save_id + room_name + ".save", FileAccess.READ)
	var i = 0
	while save_game.get_position() < save_game.get_length():
		print(i)
		i += 1
		var json_string = save_game.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		var node_data = json.get_data()
		print(node_data)
		items.collected_items = node_data["collected_items"]
		items.do_item_setup(node_data["collected_items"])

func load_player():
	if not FileAccess.file_exists("user://saveplayer" + save_id + ".save"):
		return
	var save_game = FileAccess.open("user://saveplayer" + save_id + ".save", FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
#			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		var node_data = json.get_data()
		for powerup in node_data["player_powerups"]:
			var powerup_object = load(inventory_resources[powerup])
			player_ball_controller.inventory.player_powerups.append(powerup_object)
		for powerup in node_data["powerups_not_in_use"]:
			var powerup_object = load(inventory_resources[powerup])
			player_ball_controller.inventory.powerups_not_in_use.append(powerup_object)
		for ball in node_data["extra_balls"]:
			var ball_object = load(inventory_resources[ball])
			player_ball_controller.inventory.extra_balls.append(ball_object)
		player_ball_controller.inventory.balls_in_use = []
		for ball in node_data["balls_in_use"]:
			var ball_object = load(inventory_resources[ball])
			player_ball_controller.inventory.balls_in_use.append(ball_object)
		for ball in node_data["powerups_in_use_ui"]:
			player_ball_controller.inventory.powerups_in_use_ui[ball] = []
			for powerup in node_data["powerups_in_use_ui"][ball]:
				var powerup_object = load(inventory_resources[powerup])
				player_ball_controller.inventory.powerups_in_use_ui[ball].append(powerup_object)


		for powerup in node_data["player_powerups"]:
			player_ball_controller.inventory.powerups_not_in_use.append(powerup)
		player_ball_controller.inventory.max_ball_slots = node_data["max_ball_slots"]
		player_ball_controller.max_powerups = node_data["max_powerups"]
		player_ball_controller.slot_selected = node_data["slot_selected"]
#		print("Slot selected in load " + str(player_ball_controller.slot_selected))
		player_ball_controller.energy_level = node_data["energy_level"]
	player_ball_controller.set_ball_features()
	player_ball_controller.player.energy_component.is_energy_changed.connect(energy_bar._on_energy_changed)
	#is_room_exited.connect(get_parent()._on_is_room_exited)
	do_exits()
	player_ball_controller.is_slot_selected.connect($CanvasLayer/Slots._on_slot_selected)
	player_ball_controller.set_ball_features()
#	print("Slot selected in room ready " + str(player_ball_controller.slot_selected))
	$CanvasLayer/Slots.slot_selected = player_ball_controller.slot_selected
	$CanvasLayer/Slots.update_slots()

func _on_is_exited(_target_room, _target_index):
	print("Room exited " + room_name)
	save_room()
	save_player()
	is_room_exited.emit(room_name, _target_room, _target_index)
