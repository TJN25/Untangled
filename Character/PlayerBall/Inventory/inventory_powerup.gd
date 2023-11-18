extends Resource

class_name InventoryPowerup

@export_category("Basic details")
@export var name: String
@export var texture: Texture2D
@export var colour: Color
@export var INCREMENT_FEATURE: bool = true
@export var MODIFY_PLAYER_VALUES: bool = false

@export_category("Feature toggles")
@export var _can_wall_jump: bool = false
@export var _can_drag: bool = false
@export var _can_dash: bool = false
@export var _can_vertical_dash: bool = false
@export var _can_diagonal_dash: bool = false

@export_category("Feature values")
@export var _max_jumps: int = -1
@export var _max_throws: int = -1
@export var _dash_speed: float = -1
@export var _ball_max_speed: float = -1
@export var _ball_speed: float = -1
@export var _return_speed: float = -1
@export var _return_distance: float = -1
@export var _player_max_speed: float = -1
@export var _player_speed: float = -1
@export var _throw_animation_time: float = -1
@export var _ball_attack_damage: float = -1
@export var _max_dash_time: float = -1
@export var _player_hit_range: float = -1
@export var _player_attack_damage: float = -1
@export var _cost: float = -1

var player_resources_dict: Dictionary = {}
var ball_resources_dict: Dictionary = {}


func _init() -> void:
	pass

func set_player_features():
	if _throw_animation_time != -1:
		player_resources_dict["MAX_THROW_ANIMATION_TIME"] = _throw_animation_time
	if _max_dash_time != -1:
		player_resources_dict["max_dash_time"] = _max_dash_time
	if _dash_speed != -1:
		player_resources_dict["dash_speed"] = _dash_speed
	if _can_dash:
		player_resources_dict["can_dash"] = _can_dash
	if _max_jumps != -1:
		player_resources_dict["max_jumps"] = _max_jumps
	if _max_throws != -1:
		player_resources_dict["max_throws"] = _max_throws
	if _can_wall_jump:
		player_resources_dict["can_wall_jump"] = _can_wall_jump
	if _can_diagonal_dash:
		player_resources_dict["can_diagonal_dash"] = _can_diagonal_dash
	if _can_vertical_dash:
		player_resources_dict["can_vertical_dash"] = _can_vertical_dash
	if _player_attack_damage != -1:
#		print("Player attack value is " + str(_player_attack_damage))
		player_resources_dict["ATTACK_DAMAGE"] = _player_attack_damage
#	print("Player features for " + name + " : " + str(player_resources_dict))

func set_ball_features():
	if _throw_animation_time != -1:
		ball_resources_dict["MAX_THROW_ANIMATION_TIME"] = _throw_animation_time
	if _max_jumps != -1:
		ball_resources_dict["max_jumps"] = _max_jumps
	if _max_throws != -1:
		ball_resources_dict["max_throws"] = _max_throws
	if _can_wall_jump:
		ball_resources_dict["can_wall_jump"] = _can_wall_jump
	if _ball_attack_damage != -1:
		ball_resources_dict["ATTACK_DAMAGE"] = _ball_attack_damage
	if _ball_max_speed != -1:
		ball_resources_dict["MAX_SPEED"] = _ball_max_speed
	if _ball_speed != -1:
		ball_resources_dict["speed"] = _ball_speed
	if _return_distance != -1:
		ball_resources_dict["return_distance"] = _return_distance
	if _return_speed != -1:
		ball_resources_dict["return_speed"] = _return_speed
#	print("Ball features for " + name + " : " + str(ball_resources_dict))
