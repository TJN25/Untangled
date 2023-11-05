extends Area2D


@onready var light: PointLight2D =$PointLight2D

var animation_forwards: bool = true
var hitbox_counter: int = 0
var current_area: HitboxComponent = null
# Called when the node enters the scene tree for the first time.
func _ready():
	animation_forwards = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hitbox_counter == 0:
		light.energy = 0.2
		light.scale = Vector2(1, 1)
	if current_area:
		var attack = Attack.new()
		attack.knockback_damage = 0
		attack.attack_position = global_position
		attack.attack_damage = -50 * delta
		current_area.damage(attack)


func _on_animated_sprite_2d_animation_finished():
	if animation_forwards:
		animation_forwards = false
		$AnimatedSprite2D.play_backwards()
	else:
		animation_forwards = true
		$AnimatedSprite2D.play()


func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent:
		if area.hitbox_category == "ball" or area.hitbox_category == "player":
			if area.hitbox_category == "player":
				current_area = area
			light.energy = 0.4
			light.scale = Vector2(2, 2)
			hitbox_counter += 1


func _on_hitbox_component_area_exited(area):
	if area is HitboxComponent:
		if area.hitbox_category == "ball" or area.hitbox_category == "player":
			if area.hitbox_category == "player":
				current_area = null
			light.energy = 0.4
			light.scale = Vector2(2, 2)
			hitbox_counter -= 1
