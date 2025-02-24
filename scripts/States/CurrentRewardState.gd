extends State
class_name CurrentRewardState
@onready var run: Node = $"../.."

func Enter(boss):
	run.loading_screen(0.5)
	run.load_choose_reward(boss)
	run.choose_reward = true
	await get_tree().create_timer(0.1).timeout
	for ally in run.allies:
		ally.spell_select_ui.reset()
		ally.spell_select_ui.enable_all()
		ally.spell_select_ui.visible = true
		
func Exit():
	run.choose_reward_scene.queue_free()
	run.choose_reward = false
