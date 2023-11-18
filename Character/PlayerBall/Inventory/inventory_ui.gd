extends Control

class_name InventoryUI

@export var ball_container_in_use: GridContainer
@export var extra_ball_container: GridContainer
@export var bonus_powerups_in_use: GridContainer
@export var bonus_powerups_not_in_use: GridContainer
@export var player_powerups_container: GridContainer
@export var player: PlayerBallController

@export var hidden_slot: Resource
@export var available_slot: Resource

@onready var hover_label: Label = $NinePatchRect/Label

var slots_ball_in_use: Array 
var slots_extra_balls: Array 
var powerups_in_use: Array
var extra_powerups: Array
var player_powerups: Array

var is_open: bool = false

var target_slot: Dictionary = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
var selected_slot: Dictionary = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false}

var player_slots_length: int
var balls_in_use_slots_length: int
var extra_balls_slots_length: int
var powerups_slots_length: int
var extra_powerups_slots_length: int

var max_in_use_slots: int 
var in_use_length: int 
var extra_length: int 
var extra_powerups_length: int
var player_length: int

var any_pressed: bool = false

var pressed_category: String = ""
var pressed_index_main: int = -1
var pressed_index_minor: int = -1

var current_pressed_category = ""
var current_pressed_index_main = -1
var current_pressed_index_minor = -1

var item_to_move
var item_to_replace

func _ready():
	slots_ball_in_use = ball_container_in_use.get_children()
	slots_extra_balls = extra_ball_container.get_children()
	powerups_in_use = bonus_powerups_in_use.get_children()
	extra_powerups = bonus_powerups_not_in_use.get_children()
	player_powerups = player_powerups_container.get_children()
	for slot in slots_ball_in_use:
		slot.is_slot_pressed.connect(_on_slot_pressed)
	for slot in slots_extra_balls:
		slot.is_slot_pressed.connect(_on_slot_pressed)
	for slot in powerups_in_use:
		slot.is_slot_pressed.connect(_on_slot_pressed)
	for slot in extra_powerups:
		slot.is_slot_pressed.connect(_on_slot_pressed)
	for slot in player_powerups:
		slot.is_slot_pressed.connect(_on_slot_pressed)
	
	player_slots_length = player_powerups.size()
	balls_in_use_slots_length = slots_ball_in_use.size()
	extra_balls_slots_length = slots_extra_balls.size()
	powerups_slots_length = powerups_in_use.size()
	extra_powerups_slots_length = extra_powerups.size()
	hide()

func _input(event: InputEvent):
	if event.is_action_pressed("inventory"):
		#update_slots()
		is_open = !is_open
		if is_open:
			update_slots()
			get_tree().paused = true
			show()
		else:
			get_tree().paused = false
			player.set_ball_features()
			hide()
	if event.is_action_pressed("pause_menu") and is_open:
		#update_slots()
		is_open = !is_open
		if is_open:
			get_tree().paused = true
			show()
		else:
			get_tree().paused = false
			player.set_ball_features()
			hide()


func update_slots():
	max_in_use_slots = player.inventory.max_ball_slots
	in_use_length = len(player.inventory.balls_in_use) -1
	extra_length = len(player.inventory.extra_balls) - 1
	extra_powerups_length = len(player.inventory.powerups_not_in_use) - 1 
	player_length = len(player.inventory.player_powerups) - 1
	for i in range(slots_ball_in_use.size()):
		if i > max_in_use_slots:
			slots_ball_in_use[i].update(hidden_slot)
		else:
			slots_ball_in_use[i].update(available_slot)
	for i in range(slots_ball_in_use.size()):
		if i > extra_length:
			slots_extra_balls[i].update(available_slot)
	for i in range(min(player.inventory.balls_in_use.size(), slots_ball_in_use.size())):
		slots_ball_in_use[i].update(player.inventory.balls_in_use[i])
	for i in range(min(player.inventory.extra_balls.size(), slots_extra_balls.size())):
		slots_extra_balls[i].update(player.inventory.extra_balls[i])

	for i in range(extra_powerups.size()):
		if i > extra_powerups_length:
			extra_powerups[i].update(available_slot)
	for i in range(min(player.inventory.powerups_not_in_use.size(), extra_powerups.size())):
		extra_powerups[i].update(player.inventory.powerups_not_in_use[i])
	for i in range(player_powerups.size()):
		if i > player_length:
			player_powerups[i].update(available_slot)
	for i in range(min(player.inventory.player_powerups.size(), player_powerups.size())):
		player_powerups[i].update(player.inventory.player_powerups[i])
	for i in range(slots_ball_in_use.size()):
		if i > in_use_length:
			for j in range(4):
				var current_index = 6 * j + i
				powerups_in_use[current_index].update(hidden_slot)
		else:
			var current_target = player.inventory.balls_in_use[i].name
			var current_array = player.inventory.powerups_in_use_ui[current_target]
			for j in range(4):
				var current_index = 6 * j + i
				if j < player.max_powerups:
					if len(current_array) - 1 < j:
						powerups_in_use[current_index].update(available_slot)
					else:
						powerups_in_use[current_index].update(current_array[j])
				else:
					powerups_in_use[current_index].update(hidden_slot)
	#player.set_ball_features()

func do_move_item():
	var target_name: String
	var target_powerups: Array
	var selected_name: String
	var selected_powerups: Array
	if target_slot["category"] == "powerup_in_use":
#		if in_use_length < target_slot["index_main"]:
#			return
		target_name = player.inventory.balls_in_use[target_slot["index_main"]].name
		target_powerups = player.inventory.powerups_in_use_ui[target_name]

	if selected_slot["category"] == "powerup_in_use":
#		if in_use_length < selected_slot["index_main"]:
#			return
		selected_name = player.inventory.balls_in_use[selected_slot["index_main"]].name
		selected_powerups = player.inventory.powerups_in_use_ui[selected_name]

	#both balls are in the in use array
	if target_slot["category"] == "ball_in_use" and selected_slot["category"] == "ball_in_use":

		#the first slot clicked is empty
		if target_slot["available_slot"]:
			#assign the item as the second click, remove it, and add it to the end
			item_to_move = player.inventory.balls_in_use[selected_slot["index_main"]] 
			player.inventory.balls_in_use.erase(item_to_move)
			player.inventory.balls_in_use.append(item_to_move)
			highlight_selected()
			target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
			return
		#the second slot clicked is empty
		if selected_slot["available_slot"]:
			#assign the item as the first click, remove it, and add it to the end
			item_to_move = player.inventory.balls_in_use[target_slot["index_main"]]
			player.inventory.balls_in_use.erase(item_to_move)
			player.inventory.balls_in_use.append(item_to_move)
			highlight_selected()
			target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
			return

		#both slots contain a ball
		#assign the item to move as the first click
		item_to_move = player.inventory.balls_in_use[target_slot["index_main"]]
		#assign the item to replace as the second click
		item_to_replace = player.inventory.balls_in_use[selected_slot["index_main"]]
		#remove both items from the array
		player.inventory.balls_in_use.erase(item_to_move)
		player.inventory.balls_in_use.erase(item_to_replace)
		#if the first click is a lower index then the second item, in the first position first.
		#otherwise insert the first item, in the second position first.
		if target_slot["index_main"] < selected_slot["index_main"]:
			player.inventory.balls_in_use.insert(target_slot["index_main"], item_to_replace)
			player.inventory.balls_in_use.insert(selected_slot["index_main"], item_to_move)
		else:
			player.inventory.balls_in_use.insert(selected_slot["index_main"], item_to_move)
			player.inventory.balls_in_use.insert(target_slot["index_main"], item_to_replace)
		highlight_selected()
		target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
		return

	# if the first click is in use and the second is extra
	if target_slot["category"] == "ball_in_use" and selected_slot["category"] == "extra_ball":	
		#check if one of the slots is empty
		if target_slot["available_slot"]:
			#check if both are empty and return
			if selected_slot["available_slot"]:
				return
			item_to_move = player.inventory.extra_balls[selected_slot["index_main"]]
			player.inventory.extra_balls.erase(item_to_move)
			player.inventory.balls_in_use.append(item_to_move)
			highlight_selected()
			target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
			return
		if selected_slot["available_slot"]:
			#do not remove the only ball
			if in_use_length == 0:
				return
			item_to_move = player.inventory.balls_in_use[target_slot["index_main"]]
			player.inventory.balls_in_use.erase(item_to_move)
			player.inventory.extra_balls.append(item_to_move)
			highlight_selected()
			target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
			return

		#assign the first click to the in use array and the second click to the extra array
		item_to_move = player.inventory.balls_in_use[target_slot["index_main"]]
		item_to_replace = player.inventory.extra_balls[selected_slot["index_main"]]
		player.inventory.balls_in_use.erase(item_to_move)
		player.inventory.extra_balls.erase(item_to_replace)
		player.inventory.balls_in_use.insert(target_slot["index_main"], item_to_replace)
		player.inventory.extra_balls.insert(selected_slot["index_main"], item_to_move)
		highlight_selected()
		target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
		return

	if target_slot["category"] == "extra_ball" and selected_slot["category"] == "ball_in_use":	
		#check if one of the slots is empty
		if target_slot["available_slot"]:
			#check if both are empty and return
			if selected_slot["available_slot"]:
				return
			item_to_move = player.inventory.balls_in_use[selected_slot["index_main"]]
			player.inventory.balls_in_use.erase(item_to_move)
			player.inventory.extra_balls.append(item_to_move)
			highlight_selected()
			target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
			return
		if selected_slot["available_slot"]:
			item_to_move = player.inventory.extra_balls[target_slot["index_main"]]
			player.inventory.extra_balls.erase(item_to_move)
			player.inventory.balls_in_use.append(item_to_move)
			highlight_selected()
			target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
			return

		#assign the first click to the in use array and the second click to the extra array
		item_to_move = player.inventory.extra_balls[target_slot["index_main"]]
		item_to_replace = player.inventory.balls_in_use[selected_slot["index_main"]]
		player.inventory.extra_balls.erase(item_to_move)
		player.inventory.balls_in_use.erase(item_to_replace)
		player.inventory.extra_balls.insert(target_slot["index_main"], item_to_replace)
		player.inventory.balls_in_use.insert(selected_slot["index_main"], item_to_move)
		highlight_selected()
		target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
		return

	if target_slot["category"] == "powerup_in_use" and selected_slot["category"] == "powerup_in_use":
		if target_slot["available_slot"]:
			#check if both are empty and return
			if selected_slot["available_slot"]:
				return
			item_to_move = player.inventory.powerups_in_use_ui[selected_name][selected_slot["index_minor"]]
			player.inventory.powerups_in_use_ui[selected_name].erase(item_to_move)
			player.inventory.powerups_in_use_ui[target_name].append(item_to_move)
			highlight_selected()
			target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
			return
		if selected_slot["available_slot"]:
			item_to_move = player.inventory.powerups_in_use_ui[target_name][target_slot["index_minor"]]
			player.inventory.powerups_in_use_ui[target_name].erase(item_to_move)
			player.inventory.powerups_in_use_ui[selected_name].append(item_to_move)
			highlight_selected()
			target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
			return
		#both slots contain a ball
		#assign the item to move as the first click
		item_to_move = player.inventory.powerups_in_use_ui[target_name][target_slot["index_minor"]]
		#assign the item to replace as the second click
		item_to_replace = player.inventory.powerups_in_use_ui[selected_name][selected_slot["index_minor"]]
		#remove both items from the array
		player.inventory.powerups_in_use_ui[target_name].erase(item_to_move)
		player.inventory.powerups_in_use_ui[selected_name].erase(item_to_replace)
		#if the first click is a lower index then the second item, in the first position first.
		#otherwise insert the first item, in the second position first.
		if target_slot["index_main"] < selected_slot["index_main"]:
			player.inventory.powerups_in_use_ui[target_name].insert(target_slot["index_minor"], item_to_replace)
			player.inventory.powerups_in_use_ui[selected_name].insert(selected_slot["index_minor"], item_to_move)
		else:
			player.inventory.powerups_in_use_ui[selected_name].insert(selected_slot["index_minor"], item_to_move)
			player.inventory.powerups_in_use_ui[target_name].insert(target_slot["index_minor"], item_to_replace)
		highlight_selected()
		target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
		return


	if target_slot["category"] == "powerup_in_use" and selected_slot["category"] == "extra_powerup":
		#check if one of the slots is empty
		if target_slot["available_slot"]:
			#check if both are empty and return
			if selected_slot["available_slot"]:
				return
			item_to_move = player.inventory.powerups_not_in_use[selected_slot["index_main"]]
			player.inventory.powerups_not_in_use.erase(item_to_move)
			player.inventory.powerups_in_use_ui[target_name].append(item_to_move)
			highlight_selected()
			target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
			return
		if selected_slot["available_slot"]:
			item_to_move = player.inventory.powerups_in_use_ui[target_name][target_slot["index_minor"]]
			player.inventory.powerups_in_use_ui[target_name].erase(item_to_move)
			player.inventory.powerups_not_in_use.append(item_to_move)
			highlight_selected()
			target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
			return

		#assign the first click to the in use array and the second click to the extra array
		item_to_move = player.inventory.powerups_in_use_ui[target_name][target_slot["index_minor"]]
		item_to_replace = player.inventory.powerups_not_in_use[selected_slot["index_main"]]
		player.inventory.powerups_in_use_ui[target_name].erase(item_to_move)
		player.inventory.powerups_not_in_use.erase(item_to_replace)
		player.inventory.powerups_in_use_ui[target_name].insert(target_slot["index_minor"], item_to_replace)
		player.inventory.powerups_not_in_use.insert(selected_slot["index_main"], item_to_move)
		highlight_selected()
		target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
		return

	if target_slot["category"] == "extra_powerup" and selected_slot["category"] == "powerup_in_use":
		#check if one of the slots is empty
		if selected_slot["available_slot"]:
			#check if both are empty and return
			if target_slot["available_slot"]:
				return
			item_to_move = player.inventory.powerups_not_in_use[target_slot["index_main"]]
			player.inventory.powerups_not_in_use.erase(item_to_move)
			player.inventory.powerups_in_use_ui[selected_name].append(item_to_move)
			highlight_selected()
			target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
			return
		if target_slot["available_slot"]:
			item_to_move = player.inventory.powerups_in_use_ui[selected_name][selected_slot["index_minor"]]
			player.inventory.powerups_in_use_ui[selected_name].erase(item_to_move)
			player.inventory.powerups_not_in_use.append(item_to_move)
			highlight_selected()
			target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
			return

		#assign the first click to the in use array and the second click to the extra array
		item_to_move = player.inventory.powerups_not_in_use[target_slot["index_main"]]
		item_to_replace = player.inventory.powerups_in_use_ui[selected_name][selected_slot["index_minor"]]
		player.inventory.powerups_in_use_ui[selected_name].erase(item_to_move)
		player.inventory.powerups_not_in_use.erase(item_to_replace)
		player.inventory.powerups_in_use_ui[selected_name].insert(selected_slot["index_minor"], item_to_replace)
		player.inventory.powerups_not_in_use.insert(target_slot["index_main"], item_to_move)
		highlight_selected()
		target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
		return
		
	if target_slot["category"] == "powerup_in_use" and selected_slot["category"] == "player":
		#check if one of the slots is empty
		if target_slot["available_slot"]:
			#check if both are empty and return
			if selected_slot["available_slot"]:
				return
			item_to_move = player.inventory.player_powerups[selected_slot["index_main"]]
			player.inventory.player_powerups.erase(item_to_move)
			player.inventory.powerups_in_use_ui[target_name].append(item_to_move)
			highlight_selected()
			target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
			return
		if selected_slot["available_slot"]:
			item_to_move = player.inventory.powerups_in_use_ui[target_name][target_slot["index_minor"]]
			player.inventory.powerups_in_use_ui[target_name].erase(item_to_move)
			player.inventory.player_powerups.append(item_to_move)
			highlight_selected()
			target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
			return

		#assign the first click to the in use array and the second click to the extra array
		item_to_move = player.inventory.powerups_in_use_ui[target_name][target_slot["index_minor"]]
		item_to_replace = player.inventory.player_powerups[selected_slot["index_main"]]
		player.inventory.powerups_in_use_ui[target_name].erase(item_to_move)
		player.inventory.player_powerups.erase(item_to_replace)
		player.inventory.powerups_in_use_ui[target_name].insert(target_slot["index_minor"], item_to_replace)
		player.inventory.player_powerups.insert(selected_slot["index_main"], item_to_move)
		highlight_selected()
		target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
		return

	if target_slot["category"] == "extra_powerup" and selected_slot["category"] == "player":
		#check if one of the slots is empty
		if selected_slot["available_slot"]:
			#check if both are empty and return
			if target_slot["available_slot"]:
				return
			item_to_move = player.inventory.powerups_not_in_use[target_slot["index_main"]]
			player.inventory.powerups_not_in_use.erase(item_to_move)
			player.inventory.player_powerups.append(item_to_move)
			highlight_selected()
			target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
			return
		if target_slot["available_slot"]:
			item_to_move = player.inventory.player_powerups[selected_slot["index_main"]]
			player.inventory.player_powerups.erase(item_to_move)
			player.inventory.powerups_not_in_use.append(item_to_move)
			highlight_selected()
			target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
			return

		#assign the first click to the in use array and the second click to the extra array
		item_to_move = player.inventory.powerups_not_in_use[target_slot["index_main"]]
		item_to_replace = player.inventory.player_powerups[selected_slot["index_main"]]
		player.inventory.player_powerups.erase(item_to_move)
		player.inventory.powerups_not_in_use.erase(item_to_replace)
		player.inventory.player_powerups.insert(selected_slot["index_main"], item_to_replace)
		player.inventory.powerups_not_in_use.insert(target_slot["index_main"], item_to_move)
		highlight_selected()
		target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
		return
		
		
	if target_slot["category"] == "player" and selected_slot["category"] == "powerup_in_use":
		#check if one of the slots is empty
		if selected_slot["available_slot"]:
			#check if both are empty and return
			if target_slot["available_slot"]:
				return
			item_to_move = player.inventory.player_powerups[target_slot["index_main"]]
			player.inventory.player_powerups.erase(item_to_move)
			player.inventory.powerups_in_use_ui[selected_name].append(item_to_move)
			highlight_selected()
			target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
			return
		if target_slot["available_slot"]:
			item_to_move = player.inventory.powerups_in_use_ui[selected_name][selected_slot["index_minor"]]
			player.inventory.powerups_in_use_ui[selected_name].erase(item_to_move)
			player.inventory.player_powerups.append(item_to_move)
			highlight_selected()
			target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
			return

		#assign the first click to the in use array and the second click to the extra array
		item_to_move = player.inventory.player_powerups[target_slot["index_main"]]
		item_to_replace = player.inventory.powerups_in_use_ui[selected_name][selected_slot["index_minor"]]
		player.inventory.powerups_in_use_ui[selected_name].erase(item_to_move)
		player.inventory.player_powerups.erase(item_to_replace)
		player.inventory.powerups_in_use_ui[selected_name].insert(selected_slot["index_minor"], item_to_replace)
		player.inventory.player_powerups.insert(target_slot["index_main"], item_to_move)
		highlight_selected()
		target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
		return
		
		
	if target_slot["category"] == "player" and selected_slot["category"] == "extra_powerup":
		#check if one of the slots is empty
		if selected_slot["available_slot"]:
			#check if both are empty and return
			if target_slot["available_slot"]:
				return
			item_to_move = player.inventory.player_powerups[target_slot["index_main"]]
			player.inventory.player_powerups.erase(item_to_move)
			player.inventory.powerups_not_in_use.append(item_to_move)
			highlight_selected()
			target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
			return
		if target_slot["available_slot"]:
			item_to_move = player.inventory.powerups_not_in_use[selected_slot["index_main"]]
			player.inventory.powerups_not_in_use.erase(item_to_move)
			player.inventory.player_powerups.append(item_to_move)
			highlight_selected()
			target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
			return
		#assign the first click to the in use array and the second click to the extra array
		item_to_move = player.inventory.player_powerups[target_slot["index_main"]]
		item_to_replace = player.inventory.powerups_not_in_use[selected_slot["index_main"]]
		player.inventory.powerups_not_in_use.erase(item_to_move)
		player.inventory.player_powerups.erase(item_to_replace)
		player.inventory.powerups_not_in_use.insert(selected_slot["index_main"], item_to_replace)
		player.inventory.player_powerups.insert(target_slot["index_main"], item_to_move)
		highlight_selected()
		target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
		return


func update_label():
	if not target_slot["clicked"]:
		hover_label.text = ""
		return
	if target_slot["available_slot"]:		
		hover_label.text = "Empty"
	elif target_slot["category"] == "ball_in_use":
		hover_label.text = player.inventory.balls_in_use[target_slot["index_main"]].name
	elif target_slot["category"] == "extra_ball":
		hover_label.text = player.inventory.extra_balls[target_slot["index_main"]].name
	elif target_slot["category"] == "powerup_in_use":
		var target_name = player.inventory.balls_in_use[target_slot["index_main"]].name
		hover_label.text = player.inventory.powerups_in_use_ui[target_name][target_slot["index_minor"]].name
	elif target_slot["category"] == "extra_powerup":
		hover_label.text = player.inventory.powerups_not_in_use[target_slot["index_main"]].name
	elif target_slot["category"] == "player":
		hover_label.text = player.inventory.player_powerups[target_slot["index_main"]].name
	else:
		hover_label.text = ""

func highlight_selected():
	if target_slot["category"] == "ball_in_use":
		if not target_slot["clicked"]:
			slots_ball_in_use[target_slot["index_main"]].modulate = Color(0.5,0.5,1,1)
			target_slot["clicked"] = true
			selected_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false}
			return
		else:
			slots_ball_in_use[target_slot["index_main"]].modulate = Color(1,1,1,1)
			target_slot["clicked"] = false
			return
	if target_slot["category"] == "extra_ball":
		if not target_slot["clicked"]:
			slots_extra_balls[target_slot["index_main"]].modulate = Color(0.5,0.5,1,1)
			target_slot["clicked"] = true
			selected_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false}
			return
		else:
			slots_extra_balls[target_slot["index_main"]].modulate = Color(1,1,1,1)
			target_slot["clicked"] = false
			return
	if target_slot["category"] == "extra_powerup":
		if not target_slot["clicked"]:
			extra_powerups[target_slot["index_main"]].modulate = Color(0.5,0.5,1,1)
			target_slot["clicked"] = true
			selected_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false}
			return
		else:
			extra_powerups[target_slot["index_main"]].modulate = Color(1,1,1,1)
			target_slot["clicked"] = false
			return
	if target_slot["category"] == "player":
		if not target_slot["clicked"]:
			player_powerups[target_slot["index_main"]].modulate = Color(0.5,0.5,1,1)
			target_slot["clicked"] = true
			selected_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false}
			return
		else:
			player_powerups[target_slot["index_main"]].modulate = Color(1,1,1,1)
			target_slot["clicked"] = false
			return
	if target_slot["category"] == "powerup_in_use":
		var selected_index = target_slot["index_main"] * 3 + target_slot["index_minor"]
		if not target_slot["clicked"]:
			powerups_in_use[selected_index].modulate = Color(0.5,0.5,1,1)
			target_slot["clicked"] = true
			selected_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false}
			return
		else:
			powerups_in_use[selected_index].modulate = Color(1,1,1,1)
			target_slot["clicked"] = false
			return

func select_slot(_pressed_category: String, _pressed_index_main: int):
	max_in_use_slots = player.inventory.max_ball_slots
	in_use_length = len(player.inventory.balls_in_use) -1
	extra_length = len(player.inventory.extra_balls) - 1
	player_length = len(player.inventory.player_powerups) - 1
	extra_powerups_length = len(player.inventory.powerups_not_in_use) - 1
	
	if not target_slot["clicked"]:
		if _pressed_category == "ball_in_use":
			if max_in_use_slots < _pressed_index_main:
				return
			if in_use_length < _pressed_index_main:
				target_slot["available_slot"] = true
		if _pressed_category == "extra_ball":
			if extra_length + 1 < _pressed_index_main:
				return
			if extra_length < _pressed_index_main:
				target_slot["available_slot"] = true
		if _pressed_category == "player":
			if player_length + 1 < _pressed_index_main:
				return
			if player_length < _pressed_index_main:
				target_slot["available_slot"] = true
		if _pressed_category == "extra_powerup":
			if len(player.inventory.powerups_not_in_use) < _pressed_index_main:
				return
			if len(player.inventory.powerups_not_in_use) - 1 < _pressed_index_main:
				target_slot["available_slot"] = true
		if _pressed_category == "powerup_in_use":
			var _index_minor = _pressed_index_main % 4
			if _index_minor >= player.max_powerups:
				return
			var _index_major =  floor(float(_pressed_index_main)/float(4))
			if in_use_length < _index_major:
				return
			var current_target = player.inventory.balls_in_use[_index_major].name
			var current_powerups = player.inventory.powerups_in_use_ui[current_target]
			if len(current_powerups) <= _index_minor:
				target_slot["available_slot"] = true
			target_slot["index_minor"] = _index_minor
			target_slot["category"] = _pressed_category
			target_slot["index_main"] = _index_major
		else:
			target_slot["category"] = _pressed_category
			target_slot["index_main"] = _pressed_index_main
		highlight_selected()
		update_label()
	else:
		if (target_slot["category"] == "ball_in_use" or target_slot["category"] == "extra_ball") and not (_pressed_category == "ball_in_use" or _pressed_category == "extra_ball"):
			return
		if target_slot["category"] == _pressed_category and target_slot["index_main"] == _pressed_index_main:
			highlight_selected()
			target_slot = {"category" = null, "index_main" = null, "index_minor" = null, "available_slot" = false, "clicked" = false}
			return
		if _pressed_category == "ball_in_use":
			if max_in_use_slots < _pressed_index_main:
				return
			if in_use_length < _pressed_index_main:
				selected_slot["available_slot"] = true
		if _pressed_category == "extra_ball":
			if extra_length + 1 < _pressed_index_main:
				return
			if extra_length < _pressed_index_main:
				selected_slot["available_slot"] = true
		if _pressed_category == "extra_powerup":
			if len(player.inventory.powerups_not_in_use) < _pressed_index_main:
				return
			if len(player.inventory.powerups_not_in_use) - 1 < _pressed_index_main:
				selected_slot["available_slot"] = true
		if _pressed_category == "player":
			if player_length + 1 < _pressed_index_main:
				return
			if player_length < _pressed_index_main:
				selected_slot["available_slot"] = true
		if _pressed_category == "powerup_in_use":
			var _index_minor = _pressed_index_main % 4
			if _index_minor >= player.max_powerups:
				return
			var _index_major =  floor(float(_pressed_index_main)/float(4))
			if in_use_length < _index_major:
				return
			var current_target = player.inventory.balls_in_use[_index_major].name
			var current_powerups = player.inventory.powerups_in_use_ui[current_target]
			if len(current_powerups) <= _index_minor:
				selected_slot["available_slot"] = true
			selected_slot["index_minor"] = _index_minor
			selected_slot["category"] = _pressed_category
			selected_slot["index_main"] = _index_major
		else:
			selected_slot["category"] = _pressed_category
			selected_slot["index_main"] = _pressed_index_main
		do_move_item()
		update_slots()
		update_label()
	
func _on_slot_pressed(_slot_number, _slot_type):
	select_slot(_slot_type, _slot_number)
	
