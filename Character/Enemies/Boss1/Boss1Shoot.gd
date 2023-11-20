extends State

class_name Boss1Shoot

@export var boss: Boss1

var counter: int = 0
var max_count: int = 4

func Enter():
	counter = 0
	
func Update(delta: float):
	boss.timer += delta
	if boss.timer > 1:
		boss.timer = 0
		do_shoot()
	if counter > max_count:
#		print("Transition")
		Transitioned.emit(self, "Boss1Wait", "boss1")

func Physics_Update(delta):
	pass

func do_shoot():
	var inst = boss.projectile.instantiate()
	add_child(inst)
	inst.direction = Vector2(1,0)
	if (boss.player_ball_controller.player.global_position.x - boss.global_position.x) < 0:
		inst.direction = Vector2(-1, 0)
	inst.position = boss.global_position + Vector2(0, 64)
	counter += 1
