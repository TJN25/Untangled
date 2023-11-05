extends CharacterBody2D

class_name Firefly

signal firefly_hit_signal

@export_category("Variables")
@export var SPEED: float = 100
@export var MAX_LIGHT: float = 0.7
@export var MIN_LIGHT: float = 0.05
@export var MAX_RANGE: float = 0.1
@export var MIN_RANGE: float = 1.5
@export var trail: Trail

@export_category("Components to access")
@export var light = PointLight2D


var new_position: Vector2
var player: CharacterBody2D
var distance_to_player: float
var current_trail: Trail

func get_player_attack_info():
	player = get_node("../Links/Player")
	distance_to_player = position.distance_to(player.position)


func choose_direction():
	var rng = RandomNumberGenerator.new()
	var rnd_x = rng.randi_range(-10, 10)
	var rnd_y = rng.randi_range(-10, 10)
	new_position = Vector2(rnd_x, rnd_y)
	
func choose_lighting():
	var rng = RandomNumberGenerator.new()
	var rnd_light = rng.randf_range(MIN_LIGHT, MAX_LIGHT)
	var rnd_range = rng.randf_range(MIN_RANGE, MAX_RANGE)
	light.scale = Vector2(rnd_range, rnd_range)
	light.energy = rnd_light
	
func move_firefly():
	var diff = new_position
	var angle_to_ball = diff.angle()
	velocity.y = SPEED*sin(angle_to_ball)
	velocity.x = SPEED*sin(angle_to_ball + PI/2)

func despawn_firefly():
	firefly_hit_signal.emit()
	queue_free()

func _ready():
	make_trail()
	get_player_attack_info()
	var rng = RandomNumberGenerator.new()
	var rnd_x = rng.randi_range(-800, 800)
	var rnd_y = rng.randi_range(-400, 400)
	new_position = Vector2(rnd_x, rnd_y)

func _physics_process(delta):
	if $HealthComponent.health < 0:
		despawn_firefly()
	get_player_attack_info()
	if distance_to_player > 5000:
		despawn_firefly() 
	move_firefly()
	move_and_slide()


func _on_direction_timer_timeout():
	choose_direction()
	choose_lighting()
	
func make_trail():
	pass
#	if current_trail:
#		current_trail.stop()
#	current_trail = Trail.create()
#	add_child(current_trail)
