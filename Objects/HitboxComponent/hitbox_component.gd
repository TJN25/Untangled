extends Area2D

class_name HitboxComponent

signal is_knocked_back(knockback_damage, attack_position)

@export var health_component: HealthComponent
@export var energy_component: EnergyComponent
@export var hitbox_category: String


func damage(attack: Attack):
	if health_component:
		health_component.damage(attack)
	is_knocked_back.emit(attack.knockback_damage, attack.attack_position)

func energy_hit(_energy: PlayerEnergy):
	if energy_component:
		energy_component.energy_hit(_energy)

