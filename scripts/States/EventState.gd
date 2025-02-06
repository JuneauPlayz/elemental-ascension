extends State
class_name EventState
@onready var run: Node = $"../.."

func Enter():
	run.loading_screen(0.35)
	for ally in run.allies:
		ally.spell_select_ui.visible = true
		ally.spell_select_ui.enable_all()
	run.event = true
	run.load_event(GC.get_random_event())
	
func Exit():
	run.event = false
	run.event_scene.queue_free()
	
func Update(_delta: float):
	pass
	
