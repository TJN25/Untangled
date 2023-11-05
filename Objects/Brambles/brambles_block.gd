extends Node2D

@export var ATTACK_DAMAGE: float = 25
@export var KNOCKBACK_DAMAGE: float = 2
@export var DAMAGE_COOLDOWN: int = 15

@onready var player = get_node("../../Links/Player")
@onready var ball = get_node("../../Links/Ball")
@onready var collision_shape: CollisionShape2D = $HitboxComponent/CollisionShape2D

signal brambles_destroyed

var is_attacked: bool = false
var damage_counter: int = 0


func _on_attack_component_area_entered(area):
	if area is HitboxComponent:
		if area.hitbox_category == "player":
			var attack = Attack.new()
			attack.knockback_damage = KNOCKBACK_DAMAGE
			attack.attack_position = global_position
			attack.attack_damage = ATTACK_DAMAGE
			area.damage(attack)


func do_damage():
	var distance_to_ball = (global_position.distance_to(ball.global_position) - collision_shape.shape.radius)
	var damage_done = ball.ball_light.energy * (ball.attack_area.shape.radius*ball.attack_area.scale.x - distance_to_ball)/(ball.attack_area.shape.radius*ball.attack_area.scale.x)
	damage_done = clamp(damage_done, 0, ball.ball_light.energy)
	if damage_counter > DAMAGE_COOLDOWN:
		$HealthComponent.health -= damage_done
		player.player_energy -= damage_done
		damage_counter = 0
	else:
		damage_counter += 1

func _ready():
	$HealthComponent.health = 1

func _physics_process(delta):
	if is_attacked:
		pass
		#do_damage()
	if $HealthComponent.health < 0:
		brambles_destroyed.emit()
		queue_free()


func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent:
		if area.hitbox_category == "ball":
			is_attacked = true



func _on_hitbox_component_area_exited(area):
	if area is HitboxComponent:
		if area.hitbox_category == "ball":
			is_attacked = false


func _on_recover_health_timeout():
	$HealthComponent.health += 1
	if $HealthComponent.health > $HealthComponent.MAX_HEALTH:
		$HealthComponent.health = $HealthComponent.MAX_HEALTH
	$RecoverHealth.start()
