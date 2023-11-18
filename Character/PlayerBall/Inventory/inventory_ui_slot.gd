extends Panel

class_name InventoryUISlot

signal is_slot_pressed(slot_number, slot_type)

@export var slot_number: int
@export var slot_type: String
@onready var item_visual: Sprite2D = $ItemDisplay


func update(item):
	if not item:
		item_visual.visible = false
	else:
		item_visual.modulate = item.colour
		item_visual.visible = true
		item_visual.texture = item.texture


func _on_button_pressed() -> void:
	is_slot_pressed.emit(slot_number, slot_type)
