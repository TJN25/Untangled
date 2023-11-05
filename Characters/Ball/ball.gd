extends CharacterBody2D

class_name Ball

signal ball_thrown_signal(is_thrown, thrown_direction)

@export var SPEED: float = 150
@export var DESIRED_HEIGHT: float = 256
@export var DESIRED_HEIGHT_DOUBLE_JUMP: float = 192
@export var DESIRED_DISTANCE: float = 300
@export var DRAG_FACTOR: float = 10
@export var MAX_SPEED: float = 400
@export var PLAYER_FORCE: float = 800
@export var MAX_LIGHT_INTENSITY: float = 0.9
@export var MAX_LIGHT_SCALE: float = 1
@export var ATTACK_DAMAGE: float = 2
@export var sprite_canvas_item: CanvasItem

@export var state_machine: BallStateMachine
@export var audio_collision_ball: AudioStreamPlayer2D
@export var audio_ball_throw: AudioStreamPlayer2D

@onready var player: Node2D = get_node("../Player")
@onready var navigation_agent:= $NavigationAgent2D as NavigationAgent2D
@onready var ball_light: PointLight2D = $PointLight2D
@onready var hitbox_area: CollisionShape2D = $HitboxComponent/CollisionShape2D
@onready var left_raycast: RayCast2D = $LeftWallRaycast
@onready var right_raycast: RayCast2D = $RightWallRaycast
@onready var vertical_raycast: RayCast2D = $VerticalRaycast
@onready var trajectory_line_1: Line2D = $TrajectoryLine1
@onready var attack_area: CollisionShape2D = $AttackComponent/CollisionShape2D

var prev_pos = position
var velocity_ball = Vector2()
var current_speed: float = 0

var player_position: Vector2 = Vector2(0.0, 0.0)
var distance_to_player: float = 0.0
var angle_to_player: float = 0.0
var player_force: Vector2 = Vector2(0.0, 0.0)

var player_energy: float
var player_max_energy: float
var player_health: float
var player_max_health: float
var can_blast_enemies: bool = true
var blast_enemies: bool = false
var current_trail: Trail
var switch_frame_counter: int = 0
var ball_attached: bool = true
var ball_thrown: bool = false
var coyote_counter: float = 0
var jump_button_pressed: bool = false
var jump_buffer: float = 0
var can_jump: bool = true
var ball_in_brambles: bool = false
var player_not_moving_y: bool = false
var player_not_moving_x: bool = false
var attack_brambles: bool = false
var mouse_dir: Vector2
var has_double_jumped: bool = false
var can_wall_jump: bool = true
var ball_connected: bool = true
var current_velocity: Vector2
var check_for_velocity: bool = true
var attack_scale: Vector2 = Vector2(1,1)
var max_points: int = 30
var ball_attack: bool = false
var throw_direction: Vector2 = Vector2.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float
var JUMP_VELOCITY: float
var DOUBLE_JUMP_VELOCITY: float

func _ready():
	var DESIRED_TIME_Y = DESIRED_DISTANCE/MAX_SPEED
	JUMP_VELOCITY = -2*DESIRED_HEIGHT/DESIRED_TIME_Y
	DOUBLE_JUMP_VELOCITY = -2*DESIRED_HEIGHT_DOUBLE_JUMP/DESIRED_TIME_Y
	gravity = 2*DESIRED_HEIGHT/(DESIRED_TIME_Y*DESIRED_TIME_Y)
	ball_thrown_signal.connect(player._is_ball_thrown)
	make_path()

func get_player_force(delta):
	if ball_attached:
		position = player.position + Vector2(-15, -15)
	else:
		player_position = player.global_position
		var dir = to_local(navigation_agent.get_next_path_position()).normalized()
		var diff = player_position - position
		distance_to_player = position.distance_to(player_position)
		angle_to_player = diff.angle()
		if distance_to_player > 40:
			velocity = dir * PLAYER_FORCE*distance_to_player
		else:
			ball_attached = true
			position = player.position + Vector2(-15, -15)
	return(player_force)
	

func adjust_lighting():

	player_energy = player.player_energy
	player_max_energy = player.MAX_PLAYER_ENERGY
	player_health = get_node("../Player/HealthComponent").health
	player_max_health = get_node("../Player/HealthComponent").MAX_HEALTH
	var energy_level = player_energy/player_max_energy
	ball_light.scale = Vector2(energy_level*MAX_LIGHT_SCALE, energy_level*MAX_LIGHT_SCALE)


func update_trajectory(delta, jump_height, speed):
	var vel: Vector2 = Vector2.ZERO
	trajectory_line_1.clear_points()
	mouse_dir = (get_global_mouse_position() - global_position).normalized()
	var mouse_angle = mouse_dir.angle()
	if mouse_angle > 0:
		vel = mouse_dir * speed
	elif speed * tan(mouse_angle) > jump_height or speed * tan(mouse_angle) < -jump_height:
		vel.x  = -jump_height/tan(mouse_angle)
		vel.y = -jump_height
	else:
		if mouse_angle + PI/2 > 0:
			vel.x  = speed
			vel.y = speed * tan(mouse_angle)
		else:
			vel.x  = -speed
			vel.y = -speed * tan(mouse_angle)
	var pos: Vector2 = Vector2.ZERO
	for i in max_points:
		var collision = $TrajectoryLine1/CollisionTest.move_and_collide(vel * delta)
		if not collision:
			trajectory_line_1.add_point(pos)
			vel.y += gravity * delta
			pos += vel * delta

func do_sideways_movement(jump_height):
	mouse_dir = (get_global_mouse_position() - global_position).normalized()
	if mouse_dir.y < 0:
		mouse_dir.y = 0
	velocity = mouse_dir * jump_height
	jump_button_pressed = false


func do_speed_limit(delta):
	if is_on_floor():
		if velocity.x < 0.5:
			velocity.x += DRAG_FACTOR * delta
		elif velocity.x > 0.5:
			velocity.x -= DRAG_FACTOR * delta
		else:
			velocity.x = velocity.x/DRAG_FACTOR
	else:
		if velocity.x < -MAX_SPEED:
			velocity.x += DRAG_FACTOR * delta
		elif velocity.x > MAX_SPEED:
			velocity.x -= DRAG_FACTOR * delta
		velocity.y = clamp(velocity.y, JUMP_VELOCITY, MAX_SPEED*2)
	


func _physics_process(delta):
	adjust_attack_hitbox()
	do_speed_limit(delta)
	adjust_lighting()
	move_and_slide()

func make_path():
	navigation_agent.target_position = player.global_position

func _on_nav_timer_timeout():
	make_path()
	$NavTimer.start()
	
func make_trail():
	if current_trail:
		current_trail.stop()
	current_trail = Trail.create()
	add_child(current_trail)

func _on_blast_timer_timeout():
	blast_enemies = false
	$blast_timer.stop()

func _on_blast_enemies_cooldown_timeout():
	can_blast_enemies = true
	$blast_enemies_cooldown.stop()

func _on_player_ball_thrown_signal(is_thrown):
	ball_thrown = is_thrown
	if ball_thrown:
		ball_connected = true
		can_jump = true
		coyote_counter = 0
		ball_attached = false
		switch_frame_counter = 0
		motion_mode = 0
		has_double_jumped = false
		if can_blast_enemies and player.can_blast:
			$blast_enemies_cooldown.start()	
			can_blast_enemies = false
			blast_enemies = true
			$blast_timer.start()
	else:
		can_jump = true
		coyote_counter = 0
		motion_mode = 1	

func _on_detection_zone_area_entered(area):
	if area is HitboxComponent :
		if area.hitbox_category == "brambles":
			ball_in_brambles = true
			can_jump = true
			
func adjust_attack_hitbox():
	player_position = player.global_position
	distance_to_player = position.distance_to(player_position)
	if distance_to_player > 100:
		$AttackComponent/Hitbox.shape.radius = 50 - distance_to_player/100
	else:
		$AttackComponent/Hitbox.shape.radius = 50 
	$AttackComponent/Hitbox.shape.radius = clamp($AttackComponent/Hitbox.shape.radius, 10, 50)
func _on_detection_zone_area_exited(area):
	if area is HitboxComponent:
		if area.hitbox_category == "brambles":
			ball_in_brambles = false
			can_jump = false

func _on_attack_component_area_entered(area):
	if state_machine.current_state.name != "BallFollow":
		if area is HitboxComponent:
			if area.hitbox_category == "enemy" or area.hitbox_category == "brambles" or area.hitbox_category == "grounded_enemy":
				var attack = Attack.new()
				attack.knockback_damage = 0
				attack.attack_position = global_position
				attack.attack_damage = ATTACK_DAMAGE 
				attack.attack_damage = clamp(attack.attack_damage, ATTACK_DAMAGE, ATTACK_DAMAGE*100)
				player.player_energy -= attack.attack_damage/2
				area.damage(attack)
				ball_attack = true
			elif area.hitbox_category == "firefly":
				var attack = Attack.new()
				attack.knockback_damage = 0
				attack.attack_position = global_position
				attack.attack_damage = ATTACK_DAMAGE
				area.damage(attack)
				player.player_energy += 10
				player.max_player_energy += 1
				ball_attack = true

			
