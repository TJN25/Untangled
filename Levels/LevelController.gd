extends Node2D

@export var rooms: Dictionary
@export var starting_room: String = "caves_1"
@export var starting_index: int = 2
@onready var cover_screen: ColorRect = $CanvasLayer/ColorRect

var save_id: String

var room_transitions: Array = [["caves_0", "caves_1"], ["caves_0", "caves_2"], ["caves_0", "caves_3"], ["caves_0", "caves_1"], ["caves_2", "caves_4"], ["caves_1"]]

var rooms_dictionary: Dictionary = {"caves_0" : [["caves_1", 0], ["caves_2", 0], ["caves_3", 0], ["caves_1", 1]], "caves_1" : [["caves_0", 0], ["caves_0", 3]], "caves_2" : [["caves_0", 1], ["caves_4", 0]], "caves_3" : [], "caves_4" : []}

var current_room: String
var current_inst

const COVER_TIMEOUT: float = 0.5
var cover_timer: float = 0
var room_exit: bool = true
var do_move: bool = false
var moved: bool = false
var room_name: String
var exit_index: int = 5
var target_index: int
var target_room: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if cover_timer > COVER_TIMEOUT:
		cover_screen.hide()
		room_exit = false
	else:
		cover_timer += delta
		cover_screen.modulate = Color(1,1,1,1 - cover_timer)
	if room_exit:
#		print("Cover time " + str(cover_timer))
		do_room_exit()

func do_room_exit():
#	print("Room exit current room " + current_room)
#	print("Room exit new room " + room_name)
	if not current_room == room_name:
		do_move = false
		moved = true
	if cover_timer > 2 * COVER_TIMEOUT/3:
		cover_screen.modulate = Color(1,1,1,1 - (3 * (cover_timer - 0.33333))/COVER_TIMEOUT)
#		print("Screen cover going down " + str(cover_screen.modulate))
	elif cover_timer > COVER_TIMEOUT/3 and cover_timer < 2 * COVER_TIMEOUT/3:
		if not moved:
			do_move = true
		cover_screen.modulate = Color(1,1,1,1)
	else:
		cover_screen.modulate = Color(1,1,1, 3 * cover_timer/COVER_TIMEOUT)
#		print("Screen cover going up " + str(cover_screen.modulate))
	
	cover_screen.show()
	if do_move:
#		print("Different room  " + str(not room == current_room))
		if not target_room == current_room:
			current_inst.queue_free()
			var inst = rooms[target_room].instantiate()
			current_inst = inst
			add_child(inst)
			current_room = inst.room_name
			inst.is_room_exited.connect(_on_is_room_exited)
			inst.spawn_index = target_index
			inst.save_id = save_id
			inst.load_room()
			inst.load_player()
			inst.do_exits()
#			inst.camera.global_position = inst.player_ball_controller.player.global_position
			do_move = false
			moved = true
			return
	

func _on_is_room_exited(_room_name, _target_room, _target_name):
	cover_timer = 0
	room_name = _room_name
#	exit_index = _exit_index
	target_index = _target_name
	target_room = _target_room
	room_exit = true
	do_move = false
	moved = false

func _do_level_controller_setup():
	dir_contents("user://", "tmp")
	var inst = rooms[starting_room].instantiate()
	current_inst = inst
	add_child(inst)
	inst.is_room_exited.connect(_on_is_room_exited)
	current_room = inst.room_name
	inst.spawn_index = starting_index
	inst.save_id = save_id
	inst.load_room()
	inst.load_player()
	inst.do_exits()
#	inst.camera.global_position = inst.player_ball_controller.player.global_position
	cover_timer = COVER_TIMEOUT + 1
	cover_screen.hide()

func dir_contents(path, _string):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
#				print("Found directory: " + file_name)
			else:
#				print("Found file: " + file_name)
				if _string in file_name:
					dir.remove(path + file_name)
#					print(_string + " found in " + path + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
