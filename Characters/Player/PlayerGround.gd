extends State

class_name PlayerGround

@export var player: CharacterBody2D 

var direction: float = 0


func Enter():
	player.coyote_dash = player.COYETE_TIME + 1
	player.audio_landing.play()
	player.coyote_counter = 0
	player.has_double_jumped = false
	
func Update(delta: float):
	player.throw_counter = player.max_throw_counter
	if player.health_component.health < 1:
		Transitioned.emit(self, "PlayerDead", "player")
	if Input.is_action_just_pressed("regen_health") and player.is_on_floor():
		Transitioned.emit(self, "PlayerRegen", "player")
	if Input.is_action_just_pressed("jump"):
		player.jump_button_pressed = true
	if Input.is_action_just_pressed("return_ball"):
		Transitioned.emit(self, "PlayerDrag", "player")
	update_animation()
func Physics_Update(delta):
	move_player(delta)

func move_player(delta):
	do_coyote_check(delta)
	if player.jump_button_pressed:
		jump_pressed(delta)
	direction = Input.get_axis("left", "right")
	if direction and not Input.is_action_pressed("return_ball"):
		player.foot_particles.amount = 8
		player.velocity.x = player.velocity.x + direction * player.SPEED
	else:
		player.foot_particles.amount = 0
		player.velocity.x = player.velocity.x/player.DRAG_FACTOR
	player.velocity.x = clamp(player.velocity.x, -player.MAX_SPEED, player.MAX_SPEED)
	if player.velocity.x < 5 and player.velocity.x > -5 and player.is_on_floor():
		player.foot_particles.amount = 1
	if player.ball_thrown and player.ball_direction.y == 0:
		if player.can_knockback_ball:
			player.ball_thrown = false
			Transitioned.emit(self, "PlayerDash", "player")
		player.ball_thrown = false

func do_coyote_check(delta):
	if player.is_on_floor():
		player.coyote_counter = 0
	elif player.coyote_counter <= player.COYETE_TIME:
		player.velocity.y += player.gravity * 0.1 * delta
		player.coyote_counter += delta
	else:
		Transitioned.emit(self, "PlayerAir", "player")

func jump_pressed(delta):
	if player.coyote_counter < player.COYETE_TIME or player.jump_buffer < player.JUMP_BUFFER:
		do_jump(player.JUMP_VELOCITY)
		Transitioned.emit(self, "PlayerAir", "player")
		player.has_double_jumped = false

func do_jump(jump_height):
	player.foot_particles.amount = 20
	player.coyote_counter = player.COYETE_TIME + 1
	player.jump_buffer = player.JUMP_BUFFER + 1
	player.velocity.y = jump_height
	player.can_jump = false
	player.jump_button_pressed = false
	player.control_counter = player.CONTROL_LIMIT + 1
	player.playback.travel("jump")
	
func update_facing_direction():
	if direction > 0:
		player.sprite.flip_h = false
	elif direction < 0:
		player.sprite.flip_h = true

func update_animation():
	player.animation_tree.set("parameters/Move/blend_position", direction)
	update_facing_direction()
