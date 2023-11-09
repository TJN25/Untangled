extends State

class_name PlayerRegen

@export var player: CharacterBody2D 

var max_time: float = 2.0


	
func Update(delta: float):
	if player.health_component.health < 1:
		Transitioned.emit(self, "PlayerDead", "player")
	if Input.is_action_just_released("regen_health"):
		Transitioned.emit(self, "PlayerGround", "player")
	if player.energy_component.player_energy < 50 * delta:
		Transitioned.emit(self, "PlayerGround", "player")
		
	player.energy_component.player_energy -= 25 * delta
	player.health_component.health += 25 * delta
	if player.health_component.health > player.health_component.MAX_HEALTH:
		player.health_component.health = player.health_component.MAX_HEALTH
		Transitioned.emit(self, "PlayerGround", "player")
