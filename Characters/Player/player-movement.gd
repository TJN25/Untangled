extends CharacterBody2D

class_name Player

signal ball_thrown_signal(is_thrown)
signal is_double_jumping(player_double_jumping)
signal slot_colour(slot_number, slot_colour)

@export_category("Movement")
@export var SPEED: float = 50
@export var DESIRED_HEIGHT: float = 192
@export var DESIRED_DISTANCE: float = 128
@export var DESIRED_HEIGHT_DOUBLE_JUMP: float = 96
@export var DRAG_FACTOR: float = 1.4
@export var MAX_SPEED: float = 300
@export var GRAVITY_DOWN_ADJUST: float = 1.4
@export var BALL_FORCE: float = 200
@export var COYETE_TIME: float = 0.2
@export var JUMP_BUFFER: float = 0.1
@export var CONTROL_LIMIT: float = 0.04
@export var DASH_DISTANCE: float = 320
@export var DASH_HEIGHT: float = 128
@export var AIR_HANG: float = 0.04

@export_category("Attack and Damage")
@export var ATTACK_DAMAGE: float = 4
@export var KNOCKBACK_DAMAGE: float = 5
@export var HEALTH_INCREMENT: float = 10
#@export var MAX_PLAYER_ENERGY: float = 1000

@export_category("Components to access")
@export var health_component: HealthComponent
@export var energy_component: EnergyComponent
@export var audio_landing: AudioStreamPlayer2D
@export var audio_footsteps: AudioStreamPlayer2D
@export var audio_jump: AudioStreamPlayer2D
@export var state_machine: PlayerStateMachine
@export var inventory: Inventory

@onready var torch: PointLight2D = $Torch
@onready var ball: Ball = get_node("../Ball")
@onready var jump_raycast: RayCast2D = $JumpRaycast
@onready var left_raycast: RayCast2D = $LeftWallRaycast
@onready var right_raycast: RayCast2D = $RightWallRaycast
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var sprite: Sprite2D = $Sprite2D
@onready var playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var foot_particles: CPUParticles2D = $ParticlesFeet
@onready var camera_tracker: RemoteTransform2D = get_node("RemoteTransform2D")
@onready var player_light: PointLight2D = $PlayerLight
@onready var wall_collider: CharacterBody2D = $WallCheckBody

var JUMP_VELOCITY: float
var DOUBLE_JUMP_VELOCITY: float
var has_double_jumped: bool = false
var current_speed: float = 0
var animation_locked: bool = false
var ball_thrown: bool = false
var ball_direction: Vector2 = Vector2.ZERO
var player_attack: bool = false
var scare_enemy: bool = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float
var torch_distance: float = 100
var previous_position: Vector2
var angle: float = 0
var previous_angle: float = 0
var ANGLE_INCREMENT: float = PI/16
var coyote_counter: float = 0
var coyote_dash: float = 1
var wall_counter: float = 0
var jump_buffer: float = 0
var can_jump: bool = true
var jump_button_pressed: bool = false
var direction_facing: int = 1
var max_player_energy: float = 500
var control_counter: float = 0
var throw_cooldown: float = 0.0
var increment_health: bool = false
var max_player_health: float = 200
var attack_dir: float = 0
var attack_buffer: float = 0.0
var attack_angle: float = 0
var player_facing: Vector2 = Vector2(1, 0)
var throw_counter: int = 1

var player_dashed: bool = false

var DASH_SPEED: float

var slot_selected: int = 0
var slot_selected_opacity: float = 1
var slot_not_selected_opacity: float = 0.5

var footsteps_counter: float = 0

var DESIRED_TIME_Y: float = 1

var max_dash_time: float =  0.25
var max_dash_speed: float = 100

var current_ball: InventoryBall

# Upgrade features 
# These all need to be reset each time inside set_ball_features()
var can_knockback_ball: bool = false
var do_large_knockback: bool = false
var can_double_jump: bool = false
var can_wall_jump: bool = false
var can_be_dragged: bool = false
var can_recall_ball: bool = false
var can_smash: bool = false
var can_blast: bool = false
var ball_can_stick: bool = false
var ball_can_move: bool = false
var ball_can_smash: bool = false
var ball_can_bounce: bool = false
var do_bright_light: bool = false

var ball_knockback_value: float = 700 #lower is better
var ball_throw_range: float = 200 #change to 200
var return_speed: float = 0
var max_ball_bounces: int = 1 #change to 1
var max_throw_counter: int = 1
var max_stick_time: float = 0
var max_move_time: float = 0
var smash_strength: float = 0
var bright_light_value: float = 1
var energy_cost: float = 0
#Inventory

@onready var ball_slots_list: Array = $Inventory.balls_in_use
@onready var powerups: Dictionary = $Inventory.powerups_in_use
#var ball_slots_dict: Dictionary = {'Ball' = ['blue'], 'Boost' = ['red', 'can_knockback_ball']}

@onready var changing_powerups: Dictionary = $Inventory.powerups_in_use_ui

func move_torch():
	var diff = position - previous_position
	angle = diff.angle() + PI/2
	
	if (angle - previous_angle) > PI/8:
		angle = previous_angle + ANGLE_INCREMENT
	elif (angle - previous_angle < -PI/8):
		angle = previous_angle - ANGLE_INCREMENT
	
	torch.position = Vector2(cos(angle - PI/2), sin(angle - PI/2)) * torch_distance
	torch.look_at(position)
	torch.rotate(PI)
	previous_position = position
	previous_angle = angle

func assign_powerups(_current_powerup):
	if _current_powerup.name == "do_knockback":
		can_knockback_ball = true
		do_large_knockback = true
		ball_knockback_value = _current_powerup.value
	if _current_powerup.name == "increase_knockback":
		if do_large_knockback:
			ball_knockback_value -= _current_powerup.value
			return
		if ball_knockback_value == DASH_SPEED  - JUMP_VELOCITY* 0.5:
			ball_knockback_value -=  - JUMP_VELOCITY* 0.25
			return
		ball_knockback_value = DASH_SPEED  - JUMP_VELOCITY* 0.5
		can_knockback_ball = true
	if _current_powerup.name == "do_double_jump":
		max_throw_counter += _current_powerup.value
	if _current_powerup.name == "increase_range":
		ball_throw_range += _current_powerup.value
	if _current_powerup.name == "return_faster":
		return_speed += _current_powerup.value
	if _current_powerup.name == "do_bounce":
		ball.speed = ball.speed * 0.75
		ball_throw_range = ball_throw_range * 2
		max_ball_bounces += _current_powerup.value
		ball_can_bounce = true
	if _current_powerup.name == "do_move":
		ball_can_move = true
		max_move_time += _current_powerup.value
	if _current_powerup.name == "do_smash":
		ball_can_smash = true
		smash_strength += _current_powerup.value
	if _current_powerup.name == "do_stick":
		ball_can_stick = true
		max_stick_time += _current_powerup.value
	if _current_powerup.name == "increase_light":
		bright_light_value += _current_powerup.value
		do_bright_light = true
	if _current_powerup.value:
		energy_cost += _current_powerup.cost
	
func set_ball_features():
	energy_cost = 0
	ball.speed = ball.MAX_SPEED
	max_stick_time = 0
	max_move_time = 0
	smash_strength = 0
	max_ball_bounces = 1
	max_throw_counter = 1
	bright_light_value = 1
	changing_powerups = $Inventory.powerups_in_use_ui
	do_bright_light = false
	ball_can_bounce = false
	ball_can_stick = false
	ball_can_move = false
	ball_can_smash = false
	can_knockback_ball = false
	do_large_knockback = false
	can_double_jump = false
	can_wall_jump = false
	can_be_dragged = false
	can_recall_ball = false
	can_smash = false
	can_blast = false
	return_speed = 0
	ball_throw_range = 200 # change to 200
	ball_knockback_value = 0
	if slot_selected > len(ball_slots_list) - 1:
		slot_selected = 0
	current_ball = ball_slots_list[slot_selected]
	var current_powerups: Array = powerups[current_ball.name]
	var current_changing_powerups: Array = changing_powerups[current_ball.name]
	for i in range(current_powerups.size()):
		assign_powerups(current_powerups[i])
	for i in range(current_changing_powerups.size()):
		assign_powerups(current_changing_powerups[i])
	ball.sprite_canvas_item.set_modulate(current_ball.colour)



func _ready():
	set_ball_features()
	DESIRED_TIME_Y = DESIRED_DISTANCE/MAX_SPEED
	JUMP_VELOCITY = -2*DESIRED_HEIGHT/DESIRED_TIME_Y
	DOUBLE_JUMP_VELOCITY = -2*DESIRED_HEIGHT_DOUBLE_JUMP/DESIRED_TIME_Y
	gravity = 2*DESIRED_HEIGHT/(DESIRED_TIME_Y*DESIRED_TIME_Y)
	
	DASH_SPEED = (2*DASH_HEIGHT/max_dash_time) + 600 + JUMP_VELOCITY
	
	max_dash_speed = DASH_DISTANCE/max_dash_time
	max_player_energy = 100
	energy_component.player_energy = 20
	health_component.health = health_component.MAX_HEALTH
	animation_tree.active = true
	$IncrementHealth.start()
	


func _process(delta):
	energy_component.player_energy = clamp(energy_component.player_energy, 0, max_player_energy)
	if Input.is_action_just_pressed("change_ball_slot"):
		ball_slots_list = $Inventory.balls_in_use
		slot_selected += 1
		if slot_selected > len(ball_slots_list) - 1:
			slot_selected = 0
		set_ball_features()
		
	if increment_health:
		health_component.health += HEALTH_INCREMENT * 5 * delta
	health_component.health = clamp(health_component.health, 0, max_player_health)
	player_light.energy = (health_component.health/max_player_health)/2
	if Input.get_axis("left", "right") or Input.get_axis("jump", "down"):
		player_facing.x = Input.get_axis("left", "right")
		player_facing.y = Input.get_axis("jump", "down")

		
func _physics_process(delta):
	move_and_slide()

func _on_test_level_enemy_killed_signal():
	max_player_energy += 50
	energy_component.player_energy += 40
	if max_player_energy > energy_component.MAX_PLAYER_ENERGY:
		max_player_energy = energy_component.MAX_PLAYER_ENERGY
	

func _on_attack_component_area_entered(area):
	if area is HitboxComponent:
		if player_attack and area.hitbox_category == "enemy":
			var attack = Attack.new()
			attack.knockback_damage = KNOCKBACK_DAMAGE
			attack.attack_position = global_position
			if ATTACK_DAMAGE * velocity.y / -JUMP_VELOCITY <= ATTACK_DAMAGE:
				attack.attack_damage = ATTACK_DAMAGE
			else:
				attack.attack_damage = ATTACK_DAMAGE * velocity.y / -JUMP_VELOCITY
			area.damage(attack)
		elif area.hitbox_category == "enemy" :
			scare_enemy = true
		elif area.hitbox_category == "firefly":
			var attack = Attack.new()
			attack.knockback_damage = KNOCKBACK_DAMAGE
			attack.attack_position = global_position
			attack.attack_damage = ATTACK_DAMAGE
			area.damage(attack)
			energy_component.player_energy += 10
			max_player_energy += 1
		elif player_attack and area.hitbox_category == "brambles":
			var attack = Attack.new()
			attack.knockback_damage = KNOCKBACK_DAMAGE
			attack.attack_position = global_position
			if ATTACK_DAMAGE * velocity.y / -JUMP_VELOCITY <= ATTACK_DAMAGE:
				attack.attack_damage = ATTACK_DAMAGE
			else:
				attack.attack_damage = ATTACK_DAMAGE * velocity.y / -JUMP_VELOCITY
			area.damage(attack)

func _on_attack_component_area_exited(area):
	scare_enemy = false


func _on_area_2d_2_area_entered(area):
	if area is HitboxComponent:
		increment_health = true


func _on_area_2d_2_area_exited(area):
	if area is HitboxComponent:
		increment_health = false

func _is_ball_thrown(is_thrown, thrown_direction):
	ball_thrown = is_thrown
	ball_direction = thrown_direction

func do_footstep_audio():
	audio_footsteps.pitch_scale = randf_range(0.6, 0.8)
	audio_footsteps.play()


