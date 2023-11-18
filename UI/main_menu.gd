extends Control

signal level_loaded_from_main

@onready var SAVE_MANAGER: Control = $saves
@onready var main_menu: Panel = $Panel
@export var LEVEL_1: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	SAVE_MANAGER.hide()
	main_menu.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass




func _on_levels_pressed():
	main_menu.hide()
	SAVE_MANAGER.show()


func _on_play_pressed():
	var inst = LEVEL_1.instantiate()
	owner.add_child(inst)
	inst.save_id = "tmp_save"
	inst._do_level_controller_setup()
	hide()


func _on_pause_menu_pause_button_pressed(button_pressed):
	if button_pressed == "main_menu":
		#main_menu.quit_level = true
		show()


func _on_exit_pressed():
	get_tree().quit()
