extends CharacterBody2D

class_name Projectile1

@onready var health_component: HealthComponent = $HealthComponent

var ATTACK_DAMAGE: int = 10
var direction: Vector2 = Vector2.ZERO
var speed: float = 200
var timer: float = 0
var knocked_back: bool = false

func _ready() -> void:
	health_component.is_low_health.connect(_on_is_low_health)
	timer = 0
	knocked_back = false

func _process(delta: float) -> void:
	if knocked_back:
		timer += delta
		if timer > 3:
			timer = 0
			knocked_back = false
func _physics_process(delta: float) -> void:
	velocity = speed * direction
	move_and_slide()

func _on_attack_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		if area.hitbox_category == "player":
			knocked_back = true
			var attack = Attack.new()
			attack.knockback_damage = 0
			attack.attack_position = global_position
			attack.attack_damage = ATTACK_DAMAGE
			area.damage(attack)

func _on_is_low_health():
	queue_free()
