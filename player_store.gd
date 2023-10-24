extends Control

@export var wall_jump_cost: int = 200
@export var blast_cost: int = 200
@export var smash_cost: int = 200

@onready var player: Player = get_node("../../Links/Player")


var store_open: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event: InputEvent):
	if event.is_action_pressed("player_store"):
		print("pressed")
		store_open = !store_open
		if store_open:
			get_tree().paused = true
			show()
		else:
			get_tree().paused = false
			hide()


func _on_resume_pressed():
	get_tree().paused = false
	hide()


func _on_wall_jump_pressed():
	if player.max_player_energy > wall_jump_cost:
		player.can_wall_jump = true
		player.max_player_energy -= wall_jump_cost




func _on_blast_pressed():
	if player.max_player_energy > blast_cost:
		player.can_blast = true
		player.max_player_energy -= blast_cost


func _on_smash_pressed():
	if player.max_player_energy > smash_cost:
		player.can_smash = true
		player.max_player_energy -= smash_cost
