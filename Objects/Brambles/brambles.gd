extends Node2D

signal brambles_destroyed

@export_category("Components")
@export var hitbox_component: HitboxComponent
@export var health_component: HealthComponent
@export var sprite: TileMap

@export_category("Varaibles")
@export var MAX_LIGHT: float = 0.2
@export var KNOCKBACK_DAMAGE: float = 20
@export var ATTACK_DAMAGE: float = 25

@onready var light: PointLight2D = $PointLight2D


# Called when the node enters the scene tree for the first time.
func _ready():
	light.energy = 0
	hitbox_component.area_entered.connect(_on_hitbox_component_area_entered)
	brambles_destroyed.connect(get_parent().get_parent()._on_brambles_destroyed)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	light.energy = -MAX_LIGHT * (health_component.health - health_component.MAX_HEALTH)/health_component.MAX_HEALTH
	light.energy = clamp(light.energy, 0, MAX_LIGHT)
	if health_component.health <= 0:
		light.energy = MAX_LIGHT
		brambles_destroyed.emit()
		sprite.queue_free()
		hitbox_component.queue_free()
		set_process(false)


func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent:
		if area.hitbox_category == "player":
			var attack = Attack.new()
			attack.knockback_damage = KNOCKBACK_DAMAGE
			attack.attack_position = global_position
			attack.attack_damage = ATTACK_DAMAGE
			area.damage(attack)
