extends Control

@export var game_manager: GameManager
@export var level_manager: PackedScene

signal pause_button_pressed(button_pressed: String)

const test_value: int = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_game_toggle_game_paused(is_paused):
	if is_paused:
		show()
	else:
		hide()

func _on_main_menu_pressed():
	pause_button_pressed.emit("main_menu")
	hide()


func _on_resume_pressed():
	game_manager.game_paused = false


func _on_levels_pressed():
	pause_button_pressed.emit("levels")
	hide()

func _on_exit_pressed():
	get_tree().quit()
