extends State
class_name CombatState
@onready var run: Node = $"../.."

func Enter():
	run.loading_screen(0.5)
	run.combat = true
	run.load_combat(run.current_fight[0],run.current_fight[1],run.current_fight[2],run.current_fight[3])
	
func Exit():
	run.combat = false
	run.combat_scene.queue_free()
	
func Update(_delta: float):
	pass
	
