extends Area2D

class_name AttackComponent

signal is_attack_area_entered(attack_direction)

const REST_POSITION: Vector2 = Vector2(0,10)
const REST_SIZE: Vector2 = Vector2(1,1)
const ATTACK_TIME: float = 0.15

var attacking: bool = false
var attack_direction: Vector2 = Vector2.ZERO
var attack_timer: float = 0
var move_distance: float = 500

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(_on_area_entered)
	do_rest()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	attack_timer += delta
	if attacking and attack_timer < ATTACK_TIME:
		do_attack(delta)
	else:
		do_rest()

func _on_is_attack(_attack_direction):
	#print("Do attack")
	attack_direction = _attack_direction
	attack_timer = 0
	attacking = true

func do_attack(delta):
	position += attack_direction * delta * move_distance
	if attack_direction.y != 0:
		scale.x = 3
	if attack_direction.x != 0:
		scale.y = 3

func do_rest():
	position = REST_POSITION
	scale = REST_SIZE
	attacking = false

func _on_area_entered(area):
	if attacking:
		is_attack_area_entered.emit(attack_direction)
		if area is HitboxComponent:
			if area.hitbox_category == "brambles":
				var attack = Attack.new()
				attack.knockback_damage = 0
				attack.attack_position = global_position
				attack.attack_damage = 5
				area.damage(attack)
