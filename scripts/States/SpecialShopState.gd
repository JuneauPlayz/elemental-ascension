extends State
class_name SpecialShopState
@onready var run: Node = $"../.."

func Enter(rarity):
	run.loading_screen(0.35)
	run.shop = true
	for ally in run.allies:
		ally.spell_select_ui.reset()
func Exit():
	run.shop = false
	run.shop_scene.queue_free()
	
func Update(_delta: float):
	pass
	
