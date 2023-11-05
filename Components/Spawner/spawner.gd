extends Area2D

class_name Spawner

#signal to the level script that a new enemy is spawned
signal new_enemy
signal new_firefly

@export var ENEMY_INSTANCE: PackedScene
@export var SPAWN_TYPE: String
@export var MAX_SPAWN_NUMBER: int = 50
@export var spawn_point: Marker2D


@onready var player: Player = get_node("../Links/Player")

var spawner_cooldown: bool = true
var can_spawn: bool
var spawn_counter: int = 0

func _ready():
	if SPAWN_TYPE == "enemy":
		can_spawn = get_parent().can_spawn
	if SPAWN_TYPE == "firefly":
		can_spawn = get_parent().can_spawn_firefly
	
	area_entered.connect(_on_area_entered)
	
func spawn_enemy():
	spawn_counter += 1
	var inst = ENEMY_INSTANCE.instantiate()
	owner.add_child(inst)
	inst.position = spawn_point.global_position 
	##This connects the signal from enemy script to enemy_killed()
	if SPAWN_TYPE == "enemy":
		inst.health_depleted.connect(get_parent().enemy_killed)
		inst.player_attack.connect(get_parent().attacking_player)
		inst.player.is_double_jumping.connect(inst._player_is_double_jumping)
	elif SPAWN_TYPE == "firefly":
		inst.firefly_hit_signal.connect(get_parent().firefly_hit)
	
func _physics_process(delta):
	if SPAWN_TYPE == "enemy":
		can_spawn = get_parent().can_spawn
	elif SPAWN_TYPE == "firefly":
		can_spawn = get_parent().can_spawn_firefly
	if can_spawn and not spawner_cooldown and spawn_counter < MAX_SPAWN_NUMBER: 
		spawn_enemy()
		if SPAWN_TYPE == "enemy":
			new_enemy.emit()
		if SPAWN_TYPE == "firefly":
			new_firefly.emit()
		spawner_cooldown = true
		$initial_wait_time.start()

func _on_area_entered(area):
	if area is HitboxComponent:
		if area.hitbox_category == "player":
			$spawn_cooldown.start()


func _on_spawn_cooldown_timeout():
	spawner_cooldown = false


func _on_initial_wait_time_timeout():
	spawner_cooldown = false


func _on_area_exited(area):
	if area is HitboxComponent:
		if area.hitbox_category == "player":
			$spawn_cooldown.stop()
