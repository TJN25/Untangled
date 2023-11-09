extends Panel

class_name InventoryUISlot

@onready var item_visual: Sprite2D = $ItemDisplay


func update(item):
	if not item:
		item_visual.visible = false
	else:
		#print(item.name)
		item_visual.modulate = item.colour
		item_visual.visible = true
		item_visual.texture = item.texture
