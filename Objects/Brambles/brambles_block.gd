extends Node2D

class_name BramblesBlock

@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var attack_component: Area2D = $AttackComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var tile_map: TileMap = $TileMap

var ATTACK_DAMAGE: float = 5
var KNOCKBACK_DAMAGE: float = 5
var brambles_counter = 1

func _on_attack_component_area_entered(area):
	if area is HitboxComponent:
		if area.hitbox_category == "player":
			var attack = Attack.new()
			attack.knockback_damage = KNOCKBACK_DAMAGE
			attack.attack_position = global_position
			attack.attack_damage = ATTACK_DAMAGE
			area.damage(attack)


func _process(delta: float) -> void:
	if health_component. health <= 0:
		brambles_counter = 0
		tile_map.hide()
		set_process(false)
