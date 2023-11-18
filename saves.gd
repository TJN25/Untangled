extends Control

@export var LEVEL_MANAGER: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_game(_save_id):
	var inst = LEVEL_MANAGER.instantiate()
	owner.owner.add_child(inst)
	inst.save_id = _save_id
	inst._do_level_controller_setup()
	hide()



func _on_save_1_pressed() -> void:
	load_game("_1")


func _on_save_2_pressed() -> void:
	load_game("_2")


func _on_save_3_pressed() -> void:
	load_game("_3")
