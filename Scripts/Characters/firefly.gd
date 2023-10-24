extends CharacterBody2D

signal firefly_hit_signal

@export var SPEED: float = 500

var rng = RandomNumberGenerator.new()
var new_position: Vector2
var player: CharacterBody2D
var distance_to_player: float
var current_trail: Trail

func get_player_attack_info():
	player = get_node("../Links/Player")
	distance_to_player = position.distance_to(player.position)


func choose_direction():
	var rnd_x = rng.randi_range(-10, 10)
	var rnd_y = rng.randi_range(-10, 10)
	new_position = Vector2(rnd_x, rnd_y)

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
	var rnd_x = rng.randi_range(-800, 800)
	var rnd_y = rng.randi_range(-400, 400)
	new_position = Vector2(rnd_x, rnd_y)

func _physics_process(delta):
	if $HealthComponent.health < 0:
		despawn_firefly()
	get_player_attack_info()
	if distance_to_player > 500:
		despawn_firefly() 
	move_firefly()
	move_and_slide()


func _on_direction_timer_timeout():
	choose_direction()
	
func make_trail():
	if current_trail:
		current_trail.stop()
	current_trail = Trail.create()
	add_child(current_trail)
