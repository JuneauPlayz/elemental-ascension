extends Node2D

var run
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	run = get_tree().get_first_node_in_group("run")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_new_run_pressed() -> void:
	run.reset()
	get_tree().change_scene_to_file("res://scenes/main scenes/main_scene.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
