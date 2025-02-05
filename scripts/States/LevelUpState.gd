extends State
class_name LevelUpState
@onready var run: Node = $"../.."

func Enter():
	run.load_level_up()
	for ally in run.allies:
		ally.show_level_up(run.level)
	run.move_allies(425,-150)
	run.split_allies()

func Exit():
	run.level_up = false
	for ally in run.allies:
		ally.hide_level_up()
	run.level_up_scene.queue_free()
	run.reset_ally_positions()
	
func Update(_delta: float):
	pass
	
