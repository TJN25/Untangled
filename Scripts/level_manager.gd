extends Control


@export var level_1: PackedScene
@export var LEVEL_2: PackedScene
@export var LEVEL_3: PackedScene
@export var LEVEL_4: PackedScene

@onready var main: GameManager = get_parent()

func _on_level_1_pressed():
	main.level_loaded = true
	var inst = level_1.instantiate()
	get_parent().add_child(inst)
	queue_free()


func _on_level_2_pressed():
	main.level_loaded = true
	var inst = LEVEL_2.instantiate()
	get_parent().add_child(inst)
	queue_free()


func _on_level_3_pressed():
	main.level_loaded = true
	var inst = LEVEL_3.instantiate()
	get_parent().add_child(inst)
	queue_free()


func _on_level_4_pressed():
	main.level_loaded = true
	var inst = LEVEL_4.instantiate()
	get_parent().add_child(inst)
	queue_free()

