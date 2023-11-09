extends Node2D



##signal to player to increase health after enemy kill
signal enemy_killed_signal

@export var MAX_ENEMIES: int = 5
@export var MAX_FIREFLIES: int = 20

@export var background_tiles: CanvasItem

@export_category("ball slots")
@export var ball_slot_1: CanvasItem
@export var ball_slot_2: CanvasItem
@export var ball_slot_3: CanvasItem
@export var ball_slot_4: CanvasItem
@export var ball_slot_5: CanvasItem

@onready var main_menu = get_parent()
@onready var player: Player = $Links/Player


var can_spawn: bool = false

var enemy_count: int = 0
var counter: int = 0
var player_attack_global: bool = false
var firefly_counter: int = 0
var can_spawn_firefly: int = true
 
func set_health_bar():
	$CanvasLayer/health_bar.value = $Links/Player/HealthComponent.health
	$CanvasLayer/health_bar.max_value = $Links/Player.max_player_health
func set_energy_bar():
	$CanvasLayer/energy_bar.value = $Links/Player.energy_component.player_energy
	$CanvasLayer/energy_bar.max_value = $Links/Player.max_player_energy
	$CanvasLayer/energy_bar.size.x = 10 + $Links/Player.max_player_energy/100
	
func set_enemy_bar():
	$CanvasLayer/enemy_bar.value = counter

func _ready():
	#background_tiles.set_modulate(Color(0.16,0.42,0.76,1))
	#$AudioStreamPlayer2D.play(0.0)
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
		#print("y")
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

func _on_brambles_destroyed():
	player._on_test_level_enemy_killed_signal()

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


#func _on_audio_stream_player_2d_finished():
#	$AudioStreamPlayer2D.play(0.0)


#func _on_player_slot_colour(slot_number, slot_colour):
#	if slot_number == 0:
#		ball_slot_1.show()
#		ball_slot_1.set_modulate(slot_colour)
#	if slot_number == 1:
#		ball_slot_2.show()
#		ball_slot_2.set_modulate(slot_colour)
#	if slot_number == 2:
#		ball_slot_3.show()
#		ball_slot_3.set_modulate(slot_colour)
#	if slot_number == 3:
#		ball_slot_4.show()
#		ball_slot_4.set_modulate(slot_colour)
#	if slot_number == 4:
#		ball_slot_5.show()
#		ball_slot_5.set_modulate(slot_colour)

