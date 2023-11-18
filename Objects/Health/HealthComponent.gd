extends Node2D

class_name HealthComponent

signal is_low_health
#signal is_knockback()

@export var MAX_HEALTH: float = 10

var health: float
var max_health: float

func _ready():
	max_health = MAX_HEALTH
	health = max_health
	
func damage(attack: Attack):
	health -= attack.attack_damage
	health = clamp(health, -1, max_health)
	if health <= 0:
		is_low_health.emit()
