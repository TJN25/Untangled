extends CharacterBody2D

class_name Player

signal ball_thrown_signal(is_thrown)
signal is_double_jumping(player_double_jumping)

@export var SPEED: float = 10.0
@export var DESIRED_HEIGHT: float = 64
@export var DESIRED_DISTANCE: float = 120
@export var DESIRED_HEIGHT_DOUBLE_JUMP: float = 32
@export var DRAG_FACTOR: float = 1.4
@export var MAX_SPEED: float = 300
@export var BALL_FORCE: float = 0.5
@export var ATTACK_DAMAGE: float = 4
@export var KNOCKBACK_DAMAGE: float = 5
@export var GRAVITY_UP = 490
@export var GRAVITY_DOWN_ADJUST: float = 1.4
@export var HEALTH_INCREMENT: float = 5
@export var CAMERA_ZOOM_MAX: float = 1
@export var CAMERA_ZOOM_MIN: float = 0.35
@export var MAX_PLAYER_ENERGY: float = 1000
@export var COYETE_TIME: int = 10
@export var JUMP_BUFFER: int = 30

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2DMushroom
@onready var camera: Camera2D = get_node("../../Camera2D")
@onready var torch: PointLight2D = $Torch
@onready var ball: Ball = get_node("../Ball")
@onready var jump_raycast: RayCast2D = $JumpRaycast
@onready var left_raycast: RayCast2D = $LeftWallRaycast
@onready var right_raycast: RayCast2D = $RightWallRaycast

var JUMP_VELOCITY: float
var DOUBLE_JUMP_VELOCITY: float
var has_double_jumped: bool = false
var current_speed: float = 0
var animation_locked: bool = false
var ball_thrown: bool = false
var player_attack: bool = false
var scare_enemy: bool = false
var zoom_camera: bool = false 
var camera_zoom_increment: float 
var player_energy: float
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float
var torch_distance: float = 100
var previous_position: Vector2
var angle: float = 0
var previous_angle: float = 0
var ANGLE_INCREMENT: float = PI/16
var can_throw: bool = true
var coyote_counter: int = 0
var coyote_counter_wall: int = 0
var coyote_counter_enemy: int = 0
var jump_buffer: int = 0
var can_jump: bool = true
var jump_button_pressed: bool = false
var direction_facing: int = 1
var max_player_energy: float = 500


# Variables for the store
var can_wall_jump: bool = false
var can_smash: bool = false
var can_blast: bool = false

func move_relative_to_ball(delta):
	if player_energy <= 0:
		velocity.x = velocity.x/DRAG_FACTOR
		if is_on_floor():
			velocity.y = 0
		else:
			velocity.y += gravity * delta
	else:
		var diff = ball.global_position - position
		$RemoteTransform2D.position = diff
		var distance_to_ball = position.distance_to(ball.global_position)
		var angle_to_ball = diff.angle()
		if distance_to_ball > 30:
			velocity.y = (BALL_FORCE*distance_to_ball)*sin(angle_to_ball)
			velocity.x = ( BALL_FORCE*distance_to_ball)*sin(angle_to_ball + PI/2)

func floor_check(delta):
	#Add the gravity.
	if not jump_raycast.is_colliding():
		coyote_counter_enemy += 1
	else:
		coyote_counter_enemy = 0
	if not is_on_wall():
		coyote_counter_wall += 1
	else:
		coyote_counter_wall = 0
	if not is_on_floor():
		coyote_counter += 1
		if coyote_counter_wall == 0 or coyote_counter_wall > COYETE_TIME:
			if velocity.y < 0:		
				velocity.y += gravity * delta
			else:
				velocity.y += gravity * GRAVITY_DOWN_ADJUST * delta
	else:
		coyote_counter = 0
		can_jump = true
		can_throw = true
		player_attack = false
		has_double_jumped = false
		is_double_jumping.emit(has_double_jumped)

func do_jump():
	has_double_jumped = false
	velocity.y = JUMP_VELOCITY
	can_jump = false
	jump_button_pressed = false

func do_double_jump():
	has_double_jumped = true
	is_double_jumping.emit(has_double_jumped)
	can_jump = false
	jump_button_pressed = false
	if not is_on_wall() and can_wall_jump:
		velocity.y = JUMP_VELOCITY
	else:
		if velocity.y < 0:
			velocity.y += DOUBLE_JUMP_VELOCITY
		else:
			velocity.y = DOUBLE_JUMP_VELOCITY

func jump_pressed():
	jump_buffer += 1
	if jump_buffer > JUMP_BUFFER:
		jump_buffer = 0
		jump_button_pressed = false
	else:
		if is_on_floor():
			do_jump()
		elif coyote_counter_enemy < COYETE_TIME:
			do_jump()
		else:
			if can_jump and coyote_counter < COYETE_TIME:
				do_jump()
			elif not has_double_jumped and coyote_counter_wall < COYETE_TIME and can_wall_jump:
				do_jump()
				has_double_jumped = true
			elif (left_raycast.is_colliding() or right_raycast.is_colliding()) and not has_double_jumped and can_wall_jump:
				if velocity.x >= -5 and not right_raycast.is_colliding():
					do_double_jump()
				elif velocity.x <= 5 and not left_raycast.is_colliding():
					do_double_jump()
				else:
					do_jump()
			elif not has_double_jumped:
				do_double_jump()

func move_player(delta):
	change_camera_zoom()
	$RemoteTransform2D.position = Vector2(0, 0)
	floor_check(delta)
	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		jump_button_pressed = true
	
	if jump_button_pressed:
		jump_pressed()
		
	if Input.is_action_pressed("down"):
		if not is_on_floor() and can_smash:
			player_attack = true
			velocity.y += gravity * GRAVITY_DOWN_ADJUST * 1.5 * delta	


	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("left", "right")

	if direction:
		camera.offset.x += direction
		camera.offset.x = clamp(camera.offset.x, -100, 100)
		direction_facing = direction
		velocity.x = velocity.x + direction * SPEED
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	else:
		velocity.x = velocity.x/DRAG_FACTOR 

func change_camera_zoom():
	if ball_thrown:
		if camera.zoom < Vector2(CAMERA_ZOOM_MAX, CAMERA_ZOOM_MAX):
			camera.zoom += Vector2(camera_zoom_increment, camera_zoom_increment)
		elif camera.zoom >= Vector2(CAMERA_ZOOM_MAX, CAMERA_ZOOM_MAX):
			camera.zoom = Vector2(CAMERA_ZOOM_MAX, CAMERA_ZOOM_MAX)
	else:
		if camera.zoom > Vector2(CAMERA_ZOOM_MIN, CAMERA_ZOOM_MIN):
			camera.zoom -= Vector2(camera_zoom_increment, camera_zoom_increment)
			if camera.zoom <= Vector2(CAMERA_ZOOM_MIN, CAMERA_ZOOM_MIN):
				camera.zoom = Vector2(CAMERA_ZOOM_MIN, CAMERA_ZOOM_MIN)
		


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

func update_animation():
	if player_attack:
		animated_sprite.rotation = PI
	else:
		animated_sprite.rotation = 0
	if is_on_floor():
		if velocity.x < -5:
			animated_sprite.play("Right")
			animated_sprite.speed_scale = (velocity.x/MAX_SPEED)
		elif velocity.x > 5:
			animated_sprite.speed_scale = (velocity.x/MAX_SPEED)
			animated_sprite.play("Right")
		else:
			animated_sprite.play("Idle")
	else:
		if velocity.x < -5:
			#animated_sprite.rotation_degrees = current_speed/20
			animated_sprite.play("Right")
		elif velocity.x > 5:
			#animated_sprite.rotation_degrees = current_speed/20
			animated_sprite.play("Right")
		else:
			animated_sprite.rotation_degrees = 0
			animated_sprite.play("Idle")

func _ready():
	camera.zoom = Vector2(CAMERA_ZOOM_MIN, CAMERA_ZOOM_MIN)
	var DESIRED_TIME_Y = DESIRED_DISTANCE/MAX_SPEED
	JUMP_VELOCITY = -2*DESIRED_HEIGHT/DESIRED_TIME_Y
	DOUBLE_JUMP_VELOCITY = -2*DESIRED_HEIGHT_DOUBLE_JUMP/DESIRED_TIME_Y
	gravity = 2*DESIRED_HEIGHT/(DESIRED_TIME_Y*DESIRED_TIME_Y)
	camera_zoom_increment = (CAMERA_ZOOM_MAX - CAMERA_ZOOM_MIN)/50
	camera.zoom = Vector2(CAMERA_ZOOM_MAX, CAMERA_ZOOM_MAX)
	max_player_energy = MAX_PLAYER_ENERGY/2
	player_energy = max_player_energy/5
	$IncrementHealth.start()
	
func _physics_process(delta):
	if player_energy < 0:
		player_energy = 0
	if zoom_camera:
		change_camera_zoom()
	if Input.is_action_just_pressed("return_ball"):
		
		if can_throw and not ball_thrown:
			player_attack = false
			ball_thrown = true
			can_throw = false
			ball_thrown_signal.emit(ball_thrown)
		else:
			ball_thrown = false
			ball_thrown_signal.emit(ball_thrown)
		zoom_camera = true

	if ball_thrown:
		move_relative_to_ball(delta)
	else:
		move_player(delta)
	move_torch()
	move_and_slide()
	update_animation()

func _on_test_level_enemy_killed_signal():
	max_player_energy += 50
	if $HealthComponent.health + HEALTH_INCREMENT*2 >  $HealthComponent.MAX_HEALTH:
		$HealthComponent.health = $HealthComponent.MAX_HEALTH
		player_energy += 40
	else:
		$HealthComponent.health += HEALTH_INCREMENT*2
		player_energy += 40
	if player_energy > max_player_energy:
		player_energy = max_player_energy
	if max_player_energy > MAX_PLAYER_ENERGY:
		max_player_energy = MAX_PLAYER_ENERGY
	
func _on_increment_health_timeout():
	print(max_player_energy)
	if $HealthComponent.health + HEALTH_INCREMENT >  $HealthComponent.MAX_HEALTH:
		$HealthComponent.health = $HealthComponent.MAX_HEALTH
	else:
		$HealthComponent.health += HEALTH_INCREMENT
	$IncrementHealth.start()

func _on_attack_component_area_entered(area):
	if area is HitboxComponent:
		#print("hitbox entered player attack")	
		if player_attack and area.hitbox_category == "enemy":
			var attack = Attack.new()
			attack.knockback_damage = KNOCKBACK_DAMAGE
			attack.attack_position = global_position
			if ATTACK_DAMAGE * velocity.y / -JUMP_VELOCITY <= ATTACK_DAMAGE:
				attack.attack_damage = ATTACK_DAMAGE
				#print(ATTACK_DAMAGE)
			else:
				attack.attack_damage = ATTACK_DAMAGE * velocity.y / -JUMP_VELOCITY
				#print(ATTACK_DAMAGE * velocity.y / -JUMP_VELOCITY)
			area.damage(attack)
			#print($HealthComponent.health)
		elif area.hitbox_category == "enemy" :
			scare_enemy = true
		elif area.hitbox_category == "firefly":
			var attack = Attack.new()
			attack.knockback_damage = KNOCKBACK_DAMAGE
			attack.attack_position = global_position
			attack.attack_damage = ATTACK_DAMAGE
			area.damage(attack)
			player_energy += 20
			if player_energy > max_player_energy:
				player_energy = max_player_energy
		elif player_attack and area.hitbox_category == "brambles":
			var attack = Attack.new()
			attack.knockback_damage = KNOCKBACK_DAMAGE
			attack.attack_position = global_position
			if ATTACK_DAMAGE * velocity.y / -JUMP_VELOCITY <= ATTACK_DAMAGE:
				attack.attack_damage = ATTACK_DAMAGE
				#print(ATTACK_DAMAGE)
			else:
				attack.attack_damage = ATTACK_DAMAGE * velocity.y / -JUMP_VELOCITY
				#print(ATTACK_DAMAGE * velocity.y / -JUMP_VELOCITY)
			area.damage(attack)

func _on_attack_component_area_exited(area):
	scare_enemy = false

