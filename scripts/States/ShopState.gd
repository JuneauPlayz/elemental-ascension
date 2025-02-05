extends State
class_name ShopState
@onready var run: Node = $"../.."

func Enter():
	run.loading_screen(0.35)
	run.shop = true
	run.load_shop()
	
func Exit():
	run.next_fight()
	run.shop = false
	run.shop_scene.queue_free()
	
func Update(_delta: float):
	pass
	
