extends Node

class_name Items

var items: Array
var collected_items: Dictionary
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func save():
#	print(collected_items)
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"collected_items" : collected_items
	}
	return save_dict

func do_item_setup(_collected_items):
	collected_items = _collected_items
	items = get_children()
	if collected_items.size() == 0:
#		print("Collected item size " + str(collected_items.size()))
		for item in items:
			item.item_collected.connect(_on_item_collected)
			collected_items[item.name] = [false]
	else:
		for item in items:
			if collected_items[item.name][0]:
				item.queue_free()
			else:
				item.item_collected.connect(_on_item_collected)

func _on_item_collected(item):
	collected_items[item.name] = [true]
