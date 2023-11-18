extends Control


@export var ball_container_in_use: GridContainer
@export var player_ball_controller: PlayerBallController

@export var hidden_slot: Resource
@export var available_slot: Resource

var slots_ball_in_use: Array 
var slot_selected: int

func _ready():
	player_ball_controller.is_item_collected.connect(_on_item_collected)
	slots_ball_in_use = ball_container_in_use.get_children()
	for slot in slots_ball_in_use:
		slot.is_slot_pressed.connect(_on_slot_pressed)
	slot_selected = player_ball_controller.slot_selected
	update_slots()
#
func update_slots():
#	print("Max ball slots " + str(player_ball_controller.inventory.max_ball_slots))
#	print("Slot selected in update_slots " + str(player_ball_controller.slot_selected))
	for i in range(slots_ball_in_use.size()):
		if i > player_ball_controller.inventory.max_ball_slots:
			slots_ball_in_use[i].modulate = Color(1,1,1,0)
		elif i == slot_selected:
			slots_ball_in_use[i].modulate = Color(1,1,1,1)
			slots_ball_in_use[i].update(available_slot)
		else:
			slots_ball_in_use[i].modulate = Color(1,1,1,0.5)
			slots_ball_in_use[i].update(available_slot)
	for i in range(min(player_ball_controller.inventory.balls_in_use.size(), slots_ball_in_use.size())):
		slots_ball_in_use[i].update(player_ball_controller.inventory.balls_in_use[i])
#
#func _input(event: InputEvent):
#	if event.is_action_pressed("change_ball_slot"):
#		update_slots()

func _on_slot_pressed():
	slot_selected = player_ball_controller.slot_selected
	update_slots()

func _on_slot_selected(_slot_selected):
	slot_selected = _slot_selected
	update_slots()

func _on_item_collected():
	slot_selected = player_ball_controller.slot_selected
	update_slots()
