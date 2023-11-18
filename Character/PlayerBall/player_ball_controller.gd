extends Node2D

class_name PlayerBallController

signal is_thrown(throw_direction)
signal is_item_collected
signal is_slot_selected(slot_selected)

@export var player: Player
@export var ball: Ball
@onready var inventory: Inventory = $Inventory
@export var camera_marker: RemoteTransform2D

#movement defaults
const JUMP_HEIGHT: float = 208
const JUMP_DISTANCE: float = 160
const DOUBLE_JUMP_HEIGHT: float = 128 
const MAX_SPEED: float = 350
const ACCEL_TIME: float = 1
const DRAG_FACTOR: float = 1.4
const DASH_HEIGHT: float = 128
var TIME_Y: float = 0.45
var JUMP_VELOCITY: float
var DOUBLE_JUMP_VELOCITY: float
var gravity: float = 1800
var fixed_dash_speed: float
var return_distance: float = 300
var return_speed: float

#other defaults
const MAX_LIGHT_SCALE: float = 1.5

#Timer caps
const AIR_HANG = 0.04
const GRAVITY_DOWN_ADJUST = 2.5
const COYOETE_TIME: float = 0.2
const JUMP_BUFFER: float = 0.1
const CONTROL_LIMIT: float = 0.07
const THROW_WAIT: float = 0.05


#variables to track for both player and ball
var throw_direction: Vector2 = Vector2.ZERO
var ball_following: bool = true
var slot_selected: int = 0
var throw_pressed: bool = false
var throw_buffer: float = 0
#upgradable variables
var max_throws: int = 1
var max_jumps: int = 0
var max_dash_time: float = 0.1
var MAX_THROW_ANIMATION_TIME =  0.05
var throw_animation_time: float
var max_powerups: int = 2
var dash_speed: float
var player_max_speed: float
var ball_max_speed: float
var player_speed: float
var ball_speed: float
var can_wall_jump: bool = false
var ball_attack_damage: int = 5
var player_attack_damage: float = 1

#trackers for upgradable variables
var throw_counter: int
var throw_timer: float = 0

#ball and player features to set based on powerups
var current_ball: InventoryBall
var current_scale: Vector2 = Vector2.ZERO
var can_dash: bool = false
var can_vertical_dash: bool = false
var can_diagonal_dash: bool = false
var energy_level: float = 0


var player_features_dict_fixed: Dictionary = {"gravity" : 1990, "MAX_SPEED" : 350, "JUMP_VELOCITY" : -910, "DOUBLE_JUMP_VELOCITY" : -560,
"speed" : 350, "AIR_HANG" : 0.04, "GRAVITY_DOWN_ADJUST" : 2.5, "COYOETE_TIME" : 0.2, "JUMP_BUFFER" : 0.1, "CONTROL_LIMIT" : 0.07,
"DRAG_FACTOR" : 1.4, "MAX_THROW_ANIMATION_TIME" : 0.05, "max_dash_time" : 0.1, "dash_speed" : -365, "can_dash" : false, "max_jumps" : 0,
"max_throws" : 1, "can_wall_jump" : false, "can_diagonal_dash" : false, "can_vertical_dash" : false, "ATTACK_DAMAGE" : 1}


var player_features_dict: Dictionary = {"gravity" : 1990, "MAX_SPEED" : 350, "JUMP_VELOCITY" : -910, "DOUBLE_JUMP_VELOCITY" : -560,
"speed" : 350, "AIR_HANG" : 0.04, "GRAVITY_DOWN_ADJUST" : 2.5, "COYOETE_TIME" : 0.2, "JUMP_BUFFER" : 0.1, "CONTROL_LIMIT" : 0.07,
"DRAG_FACTOR" : 1.4, "MAX_THROW_ANIMATION_TIME" : 0.05, "max_dash_time" : 0.1, "dash_speed" : -365, "can_dash" : false, "max_jumps" : 0,
"max_throws" : 1, "can_wall_jump" : false, "can_diagonal_dash" : false, "can_vertical_dash" : false, "ATTACK_DAMAGE" : 1}

var ball_features_dict_fixed: Dictionary = {"gravity" : 1990, "MAX_SPEED" : 1050, "JUMP_VELOCITY" : -910, "DOUBLE_JUMP_VELOCITY" : -560,
"speed" : 1050, "AIR_HANG" : 0.04, "GRAVITY_DOWN_ADJUST" : 2.5, "COYOETE_TIME" : 0.2, "JUMP_BUFFER" : 0.1, "CONTROL_LIMIT" : 0.07,
"DRAG_FACTOR" : 1.4, "MAX_THROW_ANIMATION_TIME" : 0.05, "return_distance" : 300, "return_speed" : 2100, "can_dash" : false, "max_jumps" : 0,
"max_throws" : 1, "can_wall_jump" : false}

var ball_features_dict: Dictionary = {"gravity" : 1990, "MAX_SPEED" : 1050, "JUMP_VELOCITY" : -910, "DOUBLE_JUMP_VELOCITY" : -560,
"speed" : 1050, "AIR_HANG" : 0.04, "GRAVITY_DOWN_ADJUST" : 2.5, "COYOETE_TIME" : 0.2, "JUMP_BUFFER" : 0.1, "CONTROL_LIMIT" : 0.07,
"DRAG_FACTOR" : 1.4, "MAX_THROW_ANIMATION_TIME" : 0.05, "return_distance" : 300, "return_speed" : 2100, "can_dash" : false, "max_jumps" : 0,
"max_throws" : 1, "can_wall_jump" : false}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TIME_Y = JUMP_DISTANCE/MAX_SPEED
	JUMP_VELOCITY = -2*JUMP_HEIGHT/TIME_Y
	DOUBLE_JUMP_VELOCITY = -2*DOUBLE_JUMP_HEIGHT/TIME_Y
	gravity = 2*JUMP_HEIGHT/(TIME_Y*TIME_Y)
	fixed_dash_speed = -DASH_HEIGHT/0.35
	dash_speed = fixed_dash_speed
	throw_counter = max_throws
	return_speed = MAX_SPEED * 6
	throw_animation_time = MAX_THROW_ANIMATION_TIME
	ball_max_speed = MAX_SPEED * 3
	ball_speed = 5 * MAX_SPEED/ACCEL_TIME
	player_max_speed = MAX_SPEED
	player_speed = MAX_SPEED/ACCEL_TIME
	set_player_movement()
	set_ball_movement()
	for child in ball.state_machine.get_children():
		if child is State:
			if child.has_method("_on_is_thrown"):
				is_thrown.connect(child._on_is_thrown)
			for _signal in child.get_signal_list():
				if _signal.name == "is_following":
					child.is_following.connect(_on_is_following)
	for child in player.state_machine.get_children():
		if child is State:
			if child.has_method("_on_is_thrown"):
				is_thrown.connect(child._on_is_thrown)
	for child in player.get_children():
		if child is AttackComponent:
			is_thrown.connect(child._on_is_attack)
	player.is_knocked_back.connect(_on_is_knocked_back)
	ball.is_knocked_back.connect(_on_is_knocked_back)
	player.energy_component.is_energy_changed.connect(adjust_lighting)
	set_ball_features()

func _input(event: InputEvent):
	if event.is_action_pressed("change_ball_slot"):
		is_item_collected.emit()
		slot_selected += 1
		if slot_selected > len(inventory.balls_in_use) - 1:
			slot_selected = 0
		is_slot_selected.emit(slot_selected)
#		print("Slot selected in event " + str(slot_selected))
		set_ball_features()

func set_player_movement():
	player_features_dict_fixed["JUMP_VELOCITY"] = JUMP_VELOCITY
	player_features_dict_fixed["DOUBLE_JUMP_VELOCITY"] = DOUBLE_JUMP_VELOCITY
	player_features_dict_fixed["gravity"] = gravity
	player_features_dict_fixed["MAX_SPEED"] = player_max_speed
	player_features_dict_fixed["speed"] = player_speed
	player_features_dict_fixed["AIR_HANG"] = AIR_HANG
	player_features_dict_fixed["GRAVITY_DOWN_ADJUST"] = GRAVITY_DOWN_ADJUST
	player_features_dict_fixed["COYOETE_TIME"] = COYOETE_TIME
	player_features_dict_fixed["JUMP_BUFFER"] = JUMP_BUFFER
	player_features_dict_fixed["CONTROL_LIMIT"] = CONTROL_LIMIT
	player_features_dict_fixed["DRAG_FACTOR"] = DRAG_FACTOR
	player_features_dict_fixed["MAX_THROW_ANIMATION_TIME"] = throw_animation_time
	player_features_dict_fixed["max_dash_time"] = max_dash_time
	player_features_dict_fixed["dash_speed"] = dash_speed
	player_features_dict_fixed["can_dash"] = can_dash
	player_features_dict_fixed["max_jumps"] = max_jumps
	player_features_dict_fixed["can_wall_jump"] = can_wall_jump
	player_features_dict_fixed["can_diagonal_dash"] = can_diagonal_dash
	player_features_dict_fixed["can_vertical_dash"] = can_vertical_dash
	player_features_dict_fixed["ATTACK_DAMAGE"] = player_attack_damage
	reset_dictionaries()
	player.features_dict = player_features_dict
	player.update_features()

func set_ball_movement():
	ball_features_dict_fixed["gravity"] = gravity
	ball_features_dict_fixed["MAX_SPEED"] = ball_max_speed
	ball_features_dict_fixed["JUMP_VELOCITY"] = JUMP_VELOCITY
	ball_features_dict_fixed["DOUBLE_JUMP_VELOCITY"] = DOUBLE_JUMP_VELOCITY
	ball_features_dict_fixed["speed"] = ball_speed
	ball_features_dict_fixed["AIR_HANG"] = AIR_HANG
	ball_features_dict_fixed["GRAVITY_DOWN_ADJUST"] = GRAVITY_DOWN_ADJUST
	ball_features_dict_fixed["COYOETE_TIME"] = COYOETE_TIME
	ball_features_dict_fixed["JUMP_BUFFER"] = JUMP_BUFFER
	ball_features_dict_fixed["CONTROL_LIMIT"] = CONTROL_LIMIT
	ball_features_dict_fixed["DRAG_FACTOR"] = DRAG_FACTOR
	ball_features_dict_fixed["MAX_THROW_ANIMATION_TIME"] = throw_animation_time
	ball_features_dict_fixed["return_speed"] = return_speed
	ball_features_dict_fixed["return_distance"] = return_distance
	ball_features_dict_fixed["ATTACK_DAMAGE"] = ball_attack_damage
	reset_dictionaries()
	ball.features_dict = ball_features_dict
	ball.update_features()

func update_ball():
	ball.target_position = player.position + Vector2(15, 15) * player.player_facing
	ball.global_target_position = player.global_position

func throw_ball(delta):
	if player.is_on_floor():
		throw_counter = max_throws
	if player.knocked_back:
		throw_counter = max_throws
	if throw_timer < THROW_WAIT and throw_timer > 0:
		throw_timer += delta
	elif throw_timer >= THROW_WAIT:
		is_thrown.emit(throw_direction)
		var player_energy = PlayerEnergy.new()
		player_energy.energy_added = -5
		player.hitbox_component.energy_hit(player_energy)
		ball_following = false
		throw_pressed = false
		throw_timer = 0
		throw_direction = Vector2.ZERO
		throw_counter -= 1
		adjust_lighting()
	if Input.is_action_just_pressed("ball_down") or Input.is_action_just_pressed("ball_up") or Input.is_action_just_pressed("ball_right") or Input.is_action_just_pressed("ball_left"):
		throw_buffer = 0
		throw_pressed = true
		if Input.get_axis("ball_left", "ball_right") or Input.get_axis("ball_up", "ball_down"):
			throw_direction.x = Input.get_axis("ball_left", "ball_right")
			throw_direction.y = Input.get_axis("ball_up", "ball_down")
	if throw_pressed:
		if throw_counter > 0 and ball_following:
			if throw_timer == 0:
				throw_timer += delta
		else:
			throw_buffer += delta
		if throw_buffer > JUMP_BUFFER:
			throw_pressed = false

func adjust_lighting():
	var energy_level = player.energy_component.player_energy/player.energy_component.max_player_energy
#	print("light energy level" + str(energy_level))
	energy_level = clamp(energy_level, 0.3, 1)
#	if do_bright_light:
#		if current_scale != Vector2(energy_level*MAX_LIGHT_SCALE*bright_light_value, energy_level*MAX_LIGHT_SCALE*bright_light_value):
#			current_scale = Vector2(energy_level*MAX_LIGHT_SCALE*bright_light_value, energy_level*MAX_LIGHT_SCALE*bright_light_value)
#			ball.ball_light.scale = Vector2(energy_level*MAX_LIGHT_SCALE*bright_light_value, energy_level*MAX_LIGHT_SCALE*bright_light_value)
#	else:
	if current_scale != Vector2(energy_level*MAX_LIGHT_SCALE, energy_level*MAX_LIGHT_SCALE):
		current_scale = Vector2(energy_level*MAX_LIGHT_SCALE, energy_level*MAX_LIGHT_SCALE)
		ball.ball_light.scale = Vector2(energy_level*MAX_LIGHT_SCALE, energy_level*MAX_LIGHT_SCALE)

func reset_dictionaries():
	for key in player_features_dict_fixed:
		player_features_dict[key] = player_features_dict_fixed[key]
	for key in ball_features_dict_fixed:
		ball_features_dict[key] = ball_features_dict_fixed[key]

func assign_powerups(_current_powerup, _player: bool):
#	print("Assigning " + _current_powerup.name)
	if _player:
		_current_powerup.set_player_features()
		for key in _current_powerup.player_resources_dict:
			if key in player_features_dict:
				if _current_powerup.player_resources_dict[key] is bool:
					if "dash" in key:
						continue
					player_features_dict[key] = _current_powerup.player_resources_dict[key]
				else:
					player_features_dict[key] += _current_powerup.player_resources_dict[key]
		player.update_features()
	elif _current_powerup.MODIFY_PLAYER_VALUES:
		_current_powerup.set_ball_features()
		_current_powerup.set_player_features()
		for key in _current_powerup.ball_resources_dict:
			if key in ball_features_dict:
				if _current_powerup.ball_resources_dict[key] is bool:
					ball_features_dict[key] = _current_powerup.ball_resources_dict[key]
				else:
					ball_features_dict[key] += _current_powerup.ball_resources_dict[key]
		ball.update_features()
		for key in _current_powerup.player_resources_dict:
			if key in player_features_dict:
				if "jump" in key:
					print(key)
					continue
				if _current_powerup.player_resources_dict[key] is bool:
					player_features_dict[key] = _current_powerup.player_resources_dict[key]
				else:
					player_features_dict[key] += _current_powerup.player_resources_dict[key]
		player.update_features()
	else:
		_current_powerup.set_ball_features()
		for key in _current_powerup.ball_resources_dict:
			if key in ball_features_dict:
				if _current_powerup.ball_resources_dict[key] is bool:
					ball_features_dict[key] = _current_powerup.ball_resources_dict[key]
				else:
					ball_features_dict[key] += _current_powerup.ball_resources_dict[key]
		ball.update_features()
	print(player.dash_speed)

func set_ball_features():
	reset_dictionaries()
	print(player_features_dict)
#	print("Slot selected in set_ball_features " + str(slot_selected))
#	can_dash = false
#	can_vertical_dash = false
#	can_diagonal_dash = false
#	can_wall_jump = false
#	dash_speed = fixed_dash_speed
#	ball_attack_damage = 5
#	max_dash_time = 0.1
#	max_throws = 1
#	max_jumps = 0
#	return_speed = MAX_SPEED * 6
#	ball_max_speed = MAX_SPEED * 3
#	ball_speed = 3 * MAX_SPEED/ACCEL_TIME
#	player_max_speed = MAX_SPEED
#	player_speed = MAX_SPEED/ACCEL_TIME
#	throw_animation_time = MAX_THROW_ANIMATION_TIME
	if slot_selected > len(inventory.balls_in_use) - 1:
		slot_selected = 0
	current_ball = inventory.balls_in_use[slot_selected]
	var current_powerups: Array = inventory.powerups_in_use[current_ball.name]
	var current_changing_powerups: Array = inventory.powerups_in_use_ui[current_ball.name]
	var player_powerups: Array = inventory.player_powerups
	for i in range(current_powerups.size()):
		assign_powerups(current_powerups[i], false)
	for i in range(current_changing_powerups.size()):
		assign_powerups(current_changing_powerups[i], false)
	for i in range(player_powerups.size()):
		assign_powerups(player_powerups[i], true)
	ball.sprite_canvas_item.set_modulate(current_ball.colour)
#	set_player_movement()
#	set_ball_movement()

func set_lighting():
	pass

func save():
	var player_powerups: Array = []
	for powerup in inventory.player_powerups:
		player_powerups.append(powerup.name)
	var powerups_not_in_use: Array = []
	for powerup in inventory.powerups_not_in_use:
		powerups_not_in_use.append(powerup.name)
	var balls_in_use: Array = []
	for ball in inventory.balls_in_use:
		balls_in_use.append(ball.name)
	var extra_balls: Array = []
	for ball in inventory.extra_balls:
		extra_balls.append(ball.name)
	var powerups_in_use_ui: Dictionary = {}
	for ball in inventory.powerups_in_use_ui:
		powerups_in_use_ui[ball] = []
		for powerup in inventory.powerups_in_use_ui[ball]:
			powerups_in_use_ui[ball].append(powerup.name)
			
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"player_powerups" : player_powerups,
		"balls_in_use" : balls_in_use,
		"extra_balls" : extra_balls,
		"powerups_in_use_ui" : powerups_in_use_ui,
		"powerups_not_in_use" : powerups_not_in_use,
		"max_ball_slots" : inventory.max_ball_slots,
		"max_powerups" : max_powerups,
		"slot_selected" : slot_selected,
		"energy_level" : energy_level
	}
	return save_dict

		

#signal responses

func _on_is_following():
	ball_following = true
	#throw_counter = max_throws


func _on_item_collected(item):
	is_item_collected.emit()

func _on_is_knocked_back():
	throw_counter = max_throws

func _process(delta: float) -> void:
	camera_marker.position = player.position
	update_ball()
	#adjust_lighting()
	throw_ball(delta)




