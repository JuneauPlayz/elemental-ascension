extends State
class_name ChooseFightState
@onready var run: Node = $"../.."

func Enter(fight_type):
	run.loading_screen(0.5)
	run.load_choose_fight(run.fight_level, fight_type)
	await get_tree().create_timer(0.1).timeout
	for ally in run.allies:
		ally.spell_select_ui.reset()
		ally.spell_select_ui.enable_all()
		
func Exit():
	run.choose_fight_scene.queue_free()
