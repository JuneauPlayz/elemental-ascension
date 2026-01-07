extends State
class_name CombatState
@onready var run: Node = $"../.."

func Enter(rarity):
	run.loading_screen(0.5)
	run.combat = true
	run.load_combat(run.current_fight[0],run.current_fight[1],run.current_fight[2],run.current_fight[3])
	
func Exit():
	for ally in run.allies:
		ally.receive_healing(1000,"neutral",true)
		ally.visible = true
		ally.current_element = "neutral"
		ally.hp_bar.update_element(ally.current_element)
		ally.status = []
		ally.hp_bar.update_statuses(ally.status)
	run.combat = false
	run.combat_scene.queue_free()
	
func Update(_delta: float):
	pass
	
