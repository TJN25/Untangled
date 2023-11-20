extends CharacterBody2D

class_name Boss1

signal is_boss_dead(boss)

@export var projectile: PackedScene
@export var player_ball_controller: PlayerBallController
@onready var health_component: HealthComponent = $HealthComponent

var timer: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_component.is_low_health.connect(_on_is_low_health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_is_low_health():
	is_boss_dead.emit("boss1")
	queue_free()
