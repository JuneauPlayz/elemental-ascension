extends State
class_name CombatState
@onready var run: Node = $"../.."

func Enter():
	run.loading_screen(0.5)
	run.combat = true
	for ally in run.allies:
		ally.spell_select_ui.show_position()
	run.load_combat(run.current_fight[0],run.current_fight[1],run.current_fight[2],run.current_fight[3])
	
func Exit():
	for ally in run.allies:
		ally.spell_select_ui.hide_position()
		ally.receive_healing(1000,"none",true)
		ally.visible = true
		ally.current_element = "none"
	run.combat = false
	run.combat_scene.queue_free()
	run.next_fight()
	
func Update(_delta: float):
	pass
	
