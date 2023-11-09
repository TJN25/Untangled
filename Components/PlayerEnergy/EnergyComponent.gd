extends Node2D

class_name EnergyComponent

@export var MAX_PLAYER_ENERGY: float = 10000

var player_energy: float

func _ready():
	player_energy = MAX_PLAYER_ENERGY
	
func energy_hit(_energy: PlayerEnergy):
	player_energy += _energy.energy_added
