extends Node

class_name BallStateMachine

@export var inital_state: State

var current_state: State
var states :  Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(_on_child_transition)
	
	if	inital_state:
		inital_state.Enter()
		current_state = inital_state

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_state:
		current_state.Update(delta)

func _physics_process(delta):
	if current_state:
		current_state.Physics_Update(delta)

func _on_child_transition(state, new_state_name, character):
	if character != "ball":
		return
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if not new_state:
		return
	
	if current_state:
		current_state.Exit()
	
	new_state.Enter()
	
	current_state = new_state
