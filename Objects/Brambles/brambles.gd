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

var current_energy_area: HitboxComponent = null
var brambles_missing: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	brambles_missing = false
	light.energy = 0
	hitbox_component.area_entered.connect(_on_hitbox_component_area_entered)
	brambles_destroyed.connect(get_parent().get_parent()._on_brambles_destroyed)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not brambles_missing:
		
		light.energy = -MAX_LIGHT * (health_component.health - health_component.MAX_HEALTH)/health_component.MAX_HEALTH
		light.energy = clamp(light.energy, 0, MAX_LIGHT)
		if health_component.health <= 0:
			light.energy = MAX_LIGHT
			brambles_missing = true
			brambles_destroyed.emit()
			sprite.queue_free()
			hitbox_component.queue_free()
	else:
		if current_energy_area:
			var player_energy = PlayerEnergy.new()
			player_energy.energy_added = 10 * delta
			current_energy_area.energy_hit(player_energy)



func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent:
		if area.hitbox_category == "player":
			var attack = Attack.new()
			attack.knockback_damage = KNOCKBACK_DAMAGE
			attack.attack_position = global_position
			attack.attack_damage = ATTACK_DAMAGE
			area.damage(attack)




func _on_energy_range_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		if area.hitbox_category == "player":
			current_energy_area = area


func _on_energy_range_area_exited(area: Area2D) -> void:
	if area is HitboxComponent:
		if area.hitbox_category == "player":
			current_energy_area = null
