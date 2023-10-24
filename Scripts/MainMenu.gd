extends Control

signal level_loaded_from_main

@export var LEVEL_MANAGER: PackedScene
@export var LEVEL_1: PackedScene

@onready var main_menu = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass




func _on_levels_pressed():
	#main_menu.quit_level = false
	var inst = LEVEL_MANAGER.instantiate()
	owner.add_child(inst)
	hide()


func _on_play_pressed():
	#main_menu.quit_level = false
	level_loaded_from_main.emit()
	var inst = LEVEL_1.instantiate()
	owner.add_child(inst)
	hide()


func _on_pause_menu_pause_button_pressed(button_pressed):
	if button_pressed == "main_menu":
		#main_menu.quit_level = true
		show()


func _on_exit_pressed():
	get_tree().quit()
