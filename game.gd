extends Node2D
const MAIN_SCENE = preload("res://scenes/main scenes/main_scene.tscn")

var current_scene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_scene(MAIN_SCENE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func new_scene(scene):
	if current_scene != null:
		current_scene.queue_free()
	current_scene = scene.instantiate()
	self.add_child(current_scene)
