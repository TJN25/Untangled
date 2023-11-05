extends Node

class_name GameManager

var level_loaded: bool = false

var game_paused: bool = false:
	get:
		return game_paused
	set(value):
		game_paused = value
		get_tree().paused = game_paused
		emit_signal("toggle_game_paused", game_paused)

signal toggle_game_paused(is_paused: bool)

signal quit_level

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel") and level_loaded:
		game_paused = !game_paused

func _process(delta):
	pass

func _on_pause_menu_pause_button_pressed(button_pressed):
	if button_pressed == "main_menu":
		game_paused = false
		level_loaded = false
		quit_level.emit()
	if button_pressed == "levels":
		game_paused = false
		level_loaded = false
		quit_level.emit()
		var inst = $CanvasLayer/MainMenu.LEVEL_MANAGER.instantiate()
		add_child(inst)


func _on_level_loaded():
	level_loaded = true


func _on_main_menu_level_loaded_from_main():
	level_loaded = true
