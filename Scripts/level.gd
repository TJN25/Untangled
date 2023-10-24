extends Node2D



##signal to player to increase health after enemy kill
signal enemy_killed_signal

@export var MAX_ENEMIES: int = 5
@export var MAX_FIREFLIES: int = 5
@onready var main_menu = get_parent()
@onready var player: Player = $Links/Player


var can_spawn: bool = false

var enemy_count: int = 0
var counter: int = 0
var player_attack_global: bool = false
var firefly_counter: int = 0
var can_spawn_firefly: int = true
 
func set_health_bar():
	if $Links/Player/HealthComponent.health <= 0:
		$Links/Player/HealthComponent.health = $Links/Player/HealthComponent.MAX_HEALTH
	$CanvasLayer/health_bar.value = $Links/Player/HealthComponent.health

func set_energy_bar():
	$CanvasLayer/energy_bar.value = $Links/Player.player_energy

func set_enemy_bar():
	$CanvasLayer/enemy_bar.value = counter

func _ready():
	player.player_energy = player.MAX_PLAYER_ENERGY/2
	main_menu.quit_level.connect(_on_quit_level)
	$CanvasLayer/enemy_bar.max_value = MAX_ENEMIES + 5
	$CanvasLayer/health_bar.max_value = $Links/Player/HealthComponent.MAX_HEALTH
	set_enemy_bar()
	set_health_bar()
	set_energy_bar()

func _physics_process(delta): 
	set_enemy_bar()
	set_health_bar()
	set_energy_bar()
	if firefly_counter >= MAX_FIREFLIES:
		can_spawn_firefly = false
	else:
		can_spawn_firefly = true
	
	if counter >= MAX_ENEMIES:
		can_spawn = false
	elif counter < MAX_ENEMIES/2 and not player_attack_global:
		can_spawn = true

 
#Runs when health_depleted is emitted. 
func enemy_killed(killed_by_player):
	if killed_by_player:
		enemy_killed_signal.emit()
	counter -= 1

#Runs when player_attack is emmited
func attacking_player():
	$player_attack_global_timer.start()
	can_spawn = false
	player_attack_global = true

func _on_spawner_new_enemy():
	counter += 1


func _on_spawner_2_new_enemy():
	counter += 1


func _on_spawner_3_new_enemy():
	counter += 1


func _on_spawner_4_new_enemy():
	counter += 1


func _on_spawner_5_new_enemy():
	counter += 1


func _on_player_attack_global_timer_timeout():
	player_attack_global = false

func firefly_hit():
	firefly_counter -= 1

func _on_spawner_6_new_firefly():
	firefly_counter += 1


	
func _on_quit_level():
	queue_free()
