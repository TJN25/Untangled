extends CharacterBody2D

@export var MOVE_SPEED: float = 200
@export var MOVE_TIME: float = 2.5
@export var MOVE_VARIANCE: float = 0.2
@export var SPAWN_POINT: Marker2D
@export var SPAWN_WEIGHT: float = 0.5


var direction: Vector2 = Vector2.ZERO
var move_timer: float = 0
var speed: float = 200
var spawn_direction: Vector2 = Vector2.ZERO

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	move_timer += delta
	if move_timer > MOVE_TIME:
		direction.x = rng.randf_range(-1, 1)
		direction.y = rng.randf_range(-1, 1)
		speed = rng.randf_range(MOVE_SPEED * (1 - MOVE_VARIANCE), MOVE_SPEED * (1 + MOVE_VARIANCE))
		move_timer = 0
#		print("bat direction " + str(direction))
	do_move(delta)
	move_and_slide()

func do_move(delta):
	velocity = speed * direction
	
