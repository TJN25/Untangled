extends CharacterBody2D

class_name Player

signal is_knocked_back

@onready var wall_collider: CharacterBody2D = $WallCheck
@onready var state_machine: PlayerStateMachine = $PlayerStateMachine
@onready var collision_box: CollisionShape2D = $CollisionShape2D
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var energy_component: EnergyComponent = $EnergyComponent
@onready var knockback_collisions: KnockbackCollisions = $KnockbackCollisions

var features_dict: Dictionary = {}

# Movement defaults set by the controller
var MAX_SPEED: float
var JUMP_VELOCITY: float
var DOUBLE_JUMP_VELOCITY: float
var gravity: float
var speed: float
var AIR_HANG: float
var GRAVITY_DOWN_ADJUST: float
var COYOETE_TIME: float
var JUMP_BUFFER: float
var CONTROL_LIMIT: float
var DRAG_FACTOR: float
var MAX_THROW_ANIMATION_TIME: float
var max_dash_time: float
var dash_speed: float
var KNOCKBACK_TIME: float = 0.4

var ATTACK_DAMAGE: float = 1

#timers needed for movement
var air_hang: float = 0
var coyote_time: float = 0
var coyote_wall_time: float = 0
var jump_buffer: float = 0
var control_counter: float = 0
var throw_animation_time: float = 0

#Bools for player
var has_double_jumped: bool = false
var can_double_jump: bool = false #set by controller
var can_wall_jump: bool = false #set by controller
var can_dash: bool = false #set by controller
var can_diagonal_dash: bool = false
var can_vertical_dash: bool = false
var knocked_back: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO

#player variables
var throw_direction: Vector2 = Vector2.ZERO
var player_facing: Vector2 = Vector2.ZERO

var max_jumps: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hitbox_component.is_knocked_back.connect(_on_is_knocked_back)
	$Attackbox.is_attack_area_entered.connect(_on_attackbox_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.get_axis("left", "right") or Input.get_axis("jump", "down"):
		player_facing.x = Input.get_axis("left", "right")
		player_facing.y = Input.get_axis("jump", "down")

func _physics_process(delta: float) -> void:
	move_and_slide()

func update_features():
	dash_speed = features_dict["dash_speed"]
	max_dash_time = features_dict["max_dash_time"]
	can_dash = features_dict["can_dash"]
	max_jumps = features_dict["max_jumps"]
	can_wall_jump = features_dict["can_wall_jump"]
	can_diagonal_dash = features_dict["can_diagonal_dash"]
	can_vertical_dash = features_dict["can_vertical_dash"]
	gravity = features_dict["gravity"]
	MAX_SPEED = features_dict["MAX_SPEED"]
	JUMP_VELOCITY = features_dict["JUMP_VELOCITY"]
	DOUBLE_JUMP_VELOCITY = features_dict["DOUBLE_JUMP_VELOCITY"]
	speed = features_dict["speed"]
	AIR_HANG = features_dict["AIR_HANG"]
	GRAVITY_DOWN_ADJUST = features_dict["GRAVITY_DOWN_ADJUST"]
	COYOETE_TIME = features_dict["COYOETE_TIME"]
	JUMP_BUFFER = features_dict["JUMP_BUFFER"]
	CONTROL_LIMIT = features_dict["CONTROL_LIMIT"]
	DRAG_FACTOR = features_dict["DRAG_FACTOR"]
	MAX_THROW_ANIMATION_TIME = features_dict["MAX_THROW_ANIMATION_TIME"]
	ATTACK_DAMAGE = features_dict["ATTACK_DAMAGE"]

func _on_is_knocked_back(knockback_damage, attack_position):
	knocked_back = true
	knockback_velocity = -velocity


func _on_attackbox_entered(attack_direction):
	pass
#	knocked_back = truef
#	is_knocked_back.emit()
#	if attack_direction.x == 0:
#		knockback_velocity = attack_direction * JUMP_VELOCITY * 1.5
#	else:
#		knockback_velocity = -attack_direction * MAX_SPEED * 1.5



