extends PointLight2D

@export var distance: float = 30

@onready var player : Player = get_parent()

var angle: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	look_at(player.position)
	position = player.position


func _physics_process(delta):
	var diff = player.position - Vector2(0,0)
	angle = PI
	position = player.position

	#print(position - player.position)
	#position = player.position + (position - player.position).rotated(angle)
	#look_at(player.position)
