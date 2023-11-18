extends Node2D

class_name EnergyComponent

signal is_energy_changed(player_energy, max_player_energy)

@export var MAX_PLAYER_ENERGY: float = 10000

var player_energy: float
var max_player_energy: float = 100

func _ready():
	player_energy = max_player_energy

func energy_hit(_energy: PlayerEnergy):
	#print("Energy added " + str(_energy.energy_added))
	player_energy += _energy.energy_added
	player_energy = clamp(player_energy, 0, max_player_energy)
	is_energy_changed.emit(player_energy, max_player_energy)

func increase_max_energy(_energy: PlayerEnergy):
	max_player_energy += _energy.energy_added
	max_player_energy = clamp(max_player_energy, 0, MAX_PLAYER_ENERGY)
	is_energy_changed.emit(player_energy, max_player_energy)
