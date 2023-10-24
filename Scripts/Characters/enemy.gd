extends CharacterBody2D

class_name Enemy

signal health_depleted(killed_by_player: bool)
signal player_attack


@export var ENEMY_SPEED: float = 50
@export var ATTACK_DAMAGE: float = 2
@export var KNOCKBACK_DAMAGE: float = 0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var navigation_agent:= $NavigationAgent2D as NavigationAgent2D
@onready var player: Node2D = get_node("../Links/Player")

var chase_player: bool = false
var angle_to_player: float = 0
var scare_enemy: bool = false
var scare_cooldown: bool = false
var can_attack: bool = false
var in_hitbox: bool = false
var rng = RandomNumberGenerator.new()
var player_attack_global: bool = false
var take_knockback: bool = false
var distance_to_player: float
var overheat_counter: int = 0
var enemy_overheating: bool = false
var start_overheating: bool = false
var blast_enemies: bool = false
var can_blast_enemies: bool = true
var player_double_jumping: bool = false

func _on_detection_area_body_entered(body):
	player = body
	chase_player = true
	

	
func _on_detection_area_body_exited(body):
	player = null
	chase_player = false

func attack_player():
	player_attack.emit()
	var area = get_node("../Links/Player/HitboxComponent")
	var attack = Attack.new()
	attack.attack_damage = ATTACK_DAMAGE
	attack.knockback_damage = KNOCKBACK_DAMAGE
	attack.attack_position = global_position
	area.damage(attack)
	$HealthComponent.health -= ATTACK_DAMAGE/2
	can_attack = false
	$attack_cooldown.start()
	take_knockback = true
	$knockback.start()

func move_enemy():
	var dir = to_local(navigation_agent.get_next_path_position()).normalized()
	var rnd_x = rng.randi_range(0.8, 1)
	var rnd_y = rng.randi_range(0.8, 1)
	if Input.is_action_pressed("return_ball") and can_blast_enemies and player.can_blast:
		$blast_enemies_cooldown.start()	
		can_blast_enemies = false
		blast_enemies = true
		$blast_timer.start()
	if blast_enemies:
		velocity.y = -ENEMY_SPEED/distance_to_player*300*sin(angle_to_player) 
		velocity.x  = -ENEMY_SPEED/distance_to_player*300*sin(angle_to_player + PI/2) 
	elif player_double_jumping:
		velocity.y = velocity.y/10
		velocity.x = velocity.x/2
	elif take_knockback:
		velocity.y = -ENEMY_SPEED*1.5*sin(angle_to_player) * rnd_y
		velocity.x  = -ENEMY_SPEED*1.5*sin(angle_to_player + PI/2) * rnd_x
	elif in_hitbox and player_attack_global:
		attack_player()
		velocity.y = ENEMY_SPEED*0.1*sin(angle_to_player) * rnd_y
		velocity.x  = ENEMY_SPEED*0.1*sin(angle_to_player + PI/2) * rnd_x
	elif can_attack and in_hitbox:
		attack_player()
		velocity.y = ENEMY_SPEED*0.1*sin(angle_to_player) * rnd_y
		velocity.x  = ENEMY_SPEED*0.1*sin(angle_to_player + PI/2) * rnd_x
	elif can_attack:
		velocity = dir * ENEMY_SPEED*1.5
		if player.has_double_jumped:
			velocity.y = velocity.y/3
	elif player_attack_global:
		velocity = dir * ENEMY_SPEED*1.5
		if player.has_double_jumped:
			velocity.y = velocity.y/3
	elif chase_player:
		velocity = dir * ENEMY_SPEED
	

func despawn_enemy(killed_by_player):
	health_depleted.emit(killed_by_player)
	queue_free()

func get_player_attack_info():
	player_attack_global = get_parent().player_attack_global
	player = get_node("../Links/Player")
	distance_to_player = position.distance_to(player.position)
	var diff = player.position - position
	angle_to_player = diff.angle()

func check_overheating():
	if overheat_counter > 6 and not start_overheating:
		start_overheating = true
		$overheat_timer.start()
	elif overheat_counter < 3 and start_overheating:
		start_overheating = false
		$overheat_timer.stop()
	if enemy_overheating:
		enemy_overheating = false
		start_overheating = false
		var area = $HitboxComponent
		var attack = Attack.new()
		attack.attack_damage = ATTACK_DAMAGE/2
		attack.knockback_damage = 0
		attack.attack_position = global_position
		area.damage(attack)

func _ready():
	make_path()

func _physics_process(delta):
	get_player_attack_info()
	if($HealthComponent.health <= 0):
			despawn_enemy(true)
	if distance_to_player > 1000:
		despawn_enemy(false)
	
	check_overheating()
	move_enemy()
	update_animation()
	move_and_slide()


func update_animation():
	if can_attack and in_hitbox:
		animated_sprite.rotation = PI# (angle_to_ball + PI/2)
		animated_sprite.play("Attack")
	else: 
		if player_attack_global:
			animated_sprite.rotation = 0
			animated_sprite.play("Angry")
		else:
			animated_sprite.play("Idle")

func enemy():
	pass


func _on_attack_component_area_entered(area):
	if area is HitboxComponent:
		if area.hitbox_category == "player":
			in_hitbox = true
			$attack_cooldown.start()

func _on_attack_component_area_exited(area):
	in_hitbox = false


func _on_attack_cooldown_timeout():
	can_attack = true


func _on_knockback_timeout():
	take_knockback = false


func _on_overheat_component_area_entered(area):
	if area is HitboxComponent:
		if area.hitbox_category == "enemy" and can_attack:
			overheat_counter += 1

func _on_overheat_component_area_exited(area):
	if area is HitboxComponent:
		if area.hitbox_category == "enemy" and can_attack:
			overheat_counter -= 1


func _on_overheat_timer_timeout():
	enemy_overheating = true


func _on_blast_enemies_cooldown_timeout():
	can_blast_enemies = true
	$blast_enemies_cooldown.stop()


func _on_blast_timer_timeout():
	blast_enemies = false
	$blast_timer.stop()

func make_path():
	if can_attack:
		navigation_agent.target_position = player.global_position
	else:
		navigation_agent.target_position = get_node("../Links/Ball").global_position

func _on_nav_timer_timeout(): 
	make_path()
	$NavTimer.start()

func _player_is_double_jumping(is_player_double_jumping):
	player_double_jumping = is_player_double_jumping
