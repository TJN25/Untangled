extends Area2D

class_name HitboxComponent

@export var health_component: HealthComponent
@export var energy_component: EnergyComponent
@export var hitbox_category: String


func damage(attack: Attack):
	if health_component:
		health_component.damage(attack)

func energy_hit(_energy: PlayerEnergy):
	if energy_component:
		energy_component.energy_hit(_energy)
