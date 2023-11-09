extends Control


@export var ball_container_in_use: GridContainer

@export var player: Player 

@export var hidden_slot: Resource
@export var available_slot: Resource

var slots_ball_in_use: Array 

func _ready():
	slots_ball_in_use = ball_container_in_use.get_children()
	update_slots()

func update_slots():
	for i in range(slots_ball_in_use.size()):
		if i > player.inventory.max_ball_slots:
			slots_ball_in_use[i].modulate = Color(1,1,1,0)
		elif i == player.slot_selected:
			slots_ball_in_use[i].modulate = Color(1,1,1,1)
			slots_ball_in_use[i].update(available_slot)
		else:
			slots_ball_in_use[i].modulate = Color(1,1,1,0.5)
			slots_ball_in_use[i].update(available_slot)
	for i in range(min(player.inventory.balls_in_use.size(), slots_ball_in_use.size())):
		slots_ball_in_use[i].update(player.inventory.balls_in_use[i])

func _input(event: InputEvent):
	if event.is_action_pressed("change_ball_slot"):
		update_slots()


func _on_timer_timeout():
	update_slots()
	$Timer.start()
