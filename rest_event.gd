extends Node2D

var run
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	run = owner.get_tree().get_first_node_in_group("run")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_next_combat_pressed() -> void:
	run.event_ended()


func _on_rest_pressed() -> void:
	pass # Replace with function body.


func _on_work_pressed() -> void:
	pass # Replace with function body.


func _on_continue_pressed() -> void:
	pass # Replace with function body.
