extends CharacterBody2D

class_name Ball

@export var SPEED: float = 150
@export var DESIRED_HEIGHT: float = 128
@export var DESIRED_DISTANCE: float = 240
@export var DRAG_FACTOR: float = 1.1
@export var MAX_SPEED: float = 300
@export var PLAYER_FORCE: float = 2
@export var MAX_LIGHT_INTENSITY: float = 0.9
@export var MAX_LIGHT_SCALE: float = 1
@export var ATTACK_DAMAGE: float = 1

@onready var player: Node2D = get_node("../Player")
@onready var navigation_agent:= $NavigationAgent2D as NavigationAgent2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2DMushroom
@onready var ball_light: PointLight2D = $PointLight2D
@onready var attack_area: CollisionShape2D = $HitboxComponent/CollisionShape2D
@onready var left_raycast: RayCast2D = $LeftWallRaycast
@onready var right_raycast: RayCast2D = $RightWallRaycast

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
var coyote_counter: int = 0
var jump_button_pressed: bool = false
var jump_buffer: int = 0
var can_jump: bool = true
var ball_in_brambles: bool = false
var player_not_moving_y: bool = false
var player_not_moving_x: bool = false
var attack_brambles: bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float
var JUMP_VELOCITY: float

func _ready():
	var DESIRED_TIME_Y = DESIRED_DISTANCE/MAX_SPEED
	JUMP_VELOCITY = -2*DESIRED_HEIGHT/DESIRED_TIME_Y
	gravity = 2*DESIRED_HEIGHT/(DESIRED_TIME_Y*DESIRED_TIME_Y)
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
		elif switch_frame_counter > 9:
			ball_attached = true
			position = player.position + Vector2(-15, -15)
		else:
			pass
	return(player_force)
	

func floor_check(delta):
	#Add the gravity.
	if not is_on_floor():
		coyote_counter += 1
		if not is_on_wall() and not is_on_ceiling():
			if velocity.y < 0:
				if ball_in_brambles and not Input.is_action_pressed("jump"):
					velocity.y += gravity * 5 * delta
				else:
					velocity.y += gravity * delta
			else:
				if ball_in_brambles and not Input.is_action_pressed("jump"):
					velocity.y += gravity/5 * delta
					velocity.y = clamp(velocity.y, 0, MAX_SPEED/10)
				else:
					velocity.y += gravity * player.GRAVITY_DOWN_ADJUST * delta
		if is_on_wall() or is_on_ceiling():
			velocity.y = 0
	else:
		coyote_counter = 0
		can_jump = true

func do_jump():
	if not ball_in_brambles:
		can_jump = false
		velocity.y = JUMP_VELOCITY
		jump_button_pressed = false
	elif  Input.is_action_pressed("jump"):
		velocity.y = JUMP_VELOCITY/5
	else:
		jump_button_pressed = false

	
func jump_pressed():
	jump_buffer += 1
	if jump_buffer > player.JUMP_BUFFER:
		jump_buffer = 0
		jump_button_pressed = false
	else:
		if is_on_floor() or is_on_wall() or ball_in_brambles:
			do_jump()
			if is_on_wall():
				if left_raycast.is_colliding():
					velocity.x = MAX_SPEED/2
				elif right_raycast.is_colliding():
					velocity.x = -MAX_SPEED/2
		else:
			if can_jump and coyote_counter < player.COYETE_TIME:
				do_jump()
	
func move_ball(delta):
	if switch_frame_counter < 10:
		if switch_frame_counter == 0:
			player_not_moving_x = false
			player_not_moving_y = false
			if player.velocity.y > -10:
				player_not_moving_y = true
			if player.velocity.x > -10 and player.velocity.x < 10:
				player_not_moving_x = true
			velocity = Vector2(0.0, 0.0)
		
		if player_not_moving_x or player_not_moving_y:
			velocity.y = JUMP_VELOCITY/1.8
			velocity.x += player.direction_facing * SPEED
		else:
			var dir = (player.position - player.previous_position).normalized()
			velocity += dir * SPEED
				
		velocity.y = clamp(velocity.y, -MAX_SPEED*1.5, MAX_SPEED*1.5)
		velocity.x = clamp(velocity.x, -MAX_SPEED*1.5, MAX_SPEED*1.5)
		switch_frame_counter += 1

	
	floor_check(delta)
	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		jump_button_pressed = true
	elif Input.is_action_pressed("jump") and ball_in_brambles:
		jump_pressed()
	if jump_button_pressed:
		jump_pressed()
		
	if Input.is_action_pressed("down"):
		if not is_on_floor():
			velocity.y += gravity * player.GRAVITY_DOWN_ADJUST * delta


	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = velocity.x + direction * SPEED
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	else:
		velocity.x = velocity.x/DRAG_FACTOR 

func move_relative_to_player(delta):
	player_force = get_player_force(delta)

func adjust_lighting():
	if blast_enemies:
		ball_light.scale += Vector2(MAX_LIGHT_SCALE/30,MAX_LIGHT_SCALE/30)
		ball_light.energy += MAX_LIGHT_INTENSITY/50
	elif not ball_thrown and ball_light.energy > MAX_LIGHT_INTENSITY:
			ball_light.scale -= Vector2(MAX_LIGHT_SCALE/10,MAX_LIGHT_SCALE/10)
			ball_light.energy -= MAX_LIGHT_INTENSITY/10
	elif ball_thrown and ball_light.energy > MAX_LIGHT_INTENSITY*1.5:
			ball_light.scale -= Vector2(MAX_LIGHT_SCALE/10,MAX_LIGHT_SCALE/10)
			ball_light.energy -= MAX_LIGHT_INTENSITY/10	
	elif ball_thrown:
		player_energy = player.player_energy
		player_max_energy = player.MAX_PLAYER_ENERGY
		player_health = get_node("../Player/HealthComponent").health
		player_max_health = get_node("../Player/HealthComponent").MAX_HEALTH
		var health_level = player_health/player_max_health
		var energy_level = player_energy/player_max_energy
		ball_light.scale = Vector2(energy_level*MAX_LIGHT_SCALE*1.5, energy_level*MAX_LIGHT_SCALE*1.5)
		ball_light.energy = health_level*MAX_LIGHT_INTENSITY*1.2
	else:
		player_energy = player.player_energy
		player_max_energy = player.MAX_PLAYER_ENERGY
		player_health = get_node("../Player/HealthComponent").health
		player_max_health = get_node("../Player/HealthComponent").MAX_HEALTH
		var health_level = player_health/player_max_health
		var energy_level = player_energy/player_max_energy
		ball_light.scale = Vector2(energy_level*MAX_LIGHT_SCALE, energy_level*MAX_LIGHT_SCALE)
		ball_light.energy = health_level*MAX_LIGHT_INTENSITY
	attack_area.scale = ball_light.scale*10


func _physics_process(delta):
	if player.ball_thrown:
		move_ball(delta)
	else:
		move_relative_to_player(delta)
	if ball_in_brambles:
		velocity.x = velocity.x/10
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
		ball_attached = false
		switch_frame_counter = 0
		motion_mode = 0
		if can_blast_enemies and player.can_blast:
			$blast_enemies_cooldown.start()	
			can_blast_enemies = false
			blast_enemies = true
			$blast_timer.start()
			#velocity.y = clamp(velocity.y, 0, MAX_SPEED*3)
			#velocity.x = clamp(velocity.x, -MAX_SPEED*3, MAX_SPEED*3)
	else:
		motion_mode = 1	

func _on_detection_zone_area_entered(area):
	if area is HitboxComponent :
		if area.hitbox_category == "brambles":
			ball_in_brambles = true
			can_jump = true

func _on_detection_zone_area_exited(area):
	if area is HitboxComponent:
		if area.hitbox_category == "brambles":
			ball_in_brambles = false
			can_jump = false



