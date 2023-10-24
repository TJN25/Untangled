extends Area2D

class_name HitboxComponent

@export var health_component: HealthComponent
@export var hitbox_category: String


func damage(attack: Attack):
	if health_component:
		health_component.damage(attack)
