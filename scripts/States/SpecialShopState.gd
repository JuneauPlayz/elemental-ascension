extends State
class_name SpecialShopState
@onready var run: Node = $"../.."

func Enter():
	run.loading_screen(0.35)
	run.shop = true
	
func Exit():
	run.shop = false
	run.shop_scene.queue_free()
	
func Update(_delta: float):
	pass
	
