extends ProgressBar

var player_energy: float
var player_max_energy: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = max_value


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_energy_changed(_player_energy, _max_player_energy):
	#print("Energy changed")
	value = _player_energy
	size.x = _max_player_energy
