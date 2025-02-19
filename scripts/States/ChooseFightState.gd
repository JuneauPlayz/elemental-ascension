extends State
class_name ChooseFightState
@onready var run: Node = $"../.."

func Enter():
	run.loading_screen(0.5)
	run.load_choose_fight(run.fight_level)

func Exit():
	run.choose_fight_scene.queue_free()
