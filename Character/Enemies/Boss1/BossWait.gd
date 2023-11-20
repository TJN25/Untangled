extends State

class_name Boss1Wait

@export var boss: Boss1

var timer: float = 0

func Enter():
#	print("Wait")
	timer = 0
	
func Update(delta: float):
	timer += delta
	if timer > 3:
		Transitioned.emit(self, "Boss1Shoot", "boss1")


