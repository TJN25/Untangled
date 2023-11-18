extends CharacterBody2D

class_name KnockbackCollisions

signal is_attack_collision(collision_direction)

@onready var left_ray: RayCast2D = $RayCast2D4
@onready var right_ray: RayCast2D = $RayCast2D2
@onready var down_ray: RayCast2D = $RayCast2D
@onready var up_ray: RayCast2D = $RayCast2D3

var collision_direction: Vector2 = Vector2.ZERO



func _physics_process(delta: float) -> void:
	if right_ray.is_colliding():
		collision_direction = Vector2(1, 0)
	elif left_ray.is_colliding():
		collision_direction = Vector2(-1, 0)
	elif up_ray.is_colliding():
		collision_direction = Vector2(0, -1)
	elif down_ray.is_colliding():
		collision_direction = Vector2(0, 1)
	else:
		collision_direction = Vector2(0, 0)
