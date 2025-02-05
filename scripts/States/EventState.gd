extends State
class_name EventState
@onready var run: Node = $"../.."

func Enter():
	run.event = true
	
func Exit():
	run.event = false
	run.next_fight()
	
func Update(_delta: float):
	pass
	
