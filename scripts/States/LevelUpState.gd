extends State
class_name LevelUpState
@onready var run: Node = $"../.."

func Enter(rarity):
	run.loading_screen(0.35)
	run.load_level_up()
	for ally in run.allies:
		ally.show_level_up(run.level)
		ally.spell_select_ui.reset()
		ally.spell_select_ui.enable_all()
	run.move_allies(425,-150)
	run.split_allies()

func Exit():
	run.level_up = false
	for ally in run.allies:
		ally.hide_level_up()
		ally.level_up_reward.reset_vars()
	run.level_up_scene.queue_free()
	run.reset_ally_positions()
	
func Update(_delta: float):
	pass
	
