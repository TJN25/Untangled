extends Area2D

class_name BramblesBlock

signal is_low_health(brambles_id)

@onready var tilemap: TileMap = $TileMap
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var health_component: HealthComponent = $HealthComponent

var active_brambles: bool = true
var brambles_id: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	active_brambles = true
	tilemap.show()
	area_entered.connect(_on_area_enetered)
	health_component.is_low_health.connect(_on_is_low_health)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if health_component.health <= health_component.max_health/2:
		tilemap.modulate = Color(1, 0.5, 0.5, 1)
	if health_component.health > 20:
		health_component.health = health_component.max_health
func _on_is_low_health():
	if not active_brambles:
		return
	active_brambles = false
	is_low_health.emit(brambles_id)
	queue_free()


func _on_area_enetered(area):
	if not active_brambles:
		return
	if area is HitboxComponent:
#		print(area.hitbox_category + " in brambles")
		if area.hitbox_category == "player":
			var attack = Attack.new()
			attack.knockback_damage = 1000
			attack.attack_position = global_position
			attack.attack_damage = 0
			area.damage(attack)
		elif area.hitbox_category == "ball":
			var attack = Attack.new()
			attack.knockback_damage = 1000
			attack.attack_position = global_position
			attack.attack_damage = 0
			area.damage(attack)
			
func _on_boss_dead(boss):
	if not active_brambles:
		return
	active_brambles = false
	is_low_health.emit(brambles_id)
	queue_free()
