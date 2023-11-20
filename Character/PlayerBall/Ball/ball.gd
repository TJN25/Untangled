extends CharacterBody2D

class_name Ball

signal is_knocked_back

@onready var wall_collider: CharacterBody2D = $WallCheck
@onready var state_machine: BallStateMachine = $BallStateMachine
@onready var sprite_canvas_item: CanvasItem = $Sprite2D
@onready var ball_light: PointLight2D = $PointLight2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var hitbox_component: HitboxComponent = $HitboxComponent

var ATTACK_DAMAGE: float = 5

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
var return_distance: float
var return_speed: float
#timers needed for movement
var air_hang: float = 0
var coyote_time: float = 0
var coyote_wall_time: float = 0
var jump_buffer: float = 0
var control_counter: float = 0
var throw_animation_time: float = 0
var KNOCKBACK_TIME: float = 0.2

#Bools for player
var has_double_jumped: bool = false
var can_double_jump: bool = false #set by controller
var can_wall_jump: bool = false #set by controller
var knocked_back: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO

#ball specific variables
var target_position: Vector2 = Vector2.ZERO
var global_target_position: Vector2 = Vector2.ZERO
var throw_direction: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hitbox_component.area_entered.connect(_on_hitbox_entered)
	hitbox_component.is_knocked_back.connect(_on_is_knocked_back)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	move_and_slide()

func update_features():
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
	return_speed = features_dict["return_speed"]
	return_distance = features_dict["return_distance"]
	ATTACK_DAMAGE = features_dict["ATTACK_DAMAGE"]

func make_path():
	navigation_agent.target_position = global_target_position

func _on_nav_timer_timeout():
	make_path()
	$NavTimer.start()

func _on_hitbox_entered(area):
	if area is HitboxComponent:
		if state_machine.current_state.name != "BallFollow":
			var attack = Attack.new()
			attack.knockback_damage = 0
			attack.attack_position = global_position
			attack.attack_damage = ATTACK_DAMAGE
			area.damage(attack)

func _on_is_knocked_back(knockback_damage, attack_position):
	knocked_back = true
	is_knocked_back.emit()
	knockback_velocity = (global_position - attack_position).normalized() * knockback_damage



