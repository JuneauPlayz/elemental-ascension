extends Control

signal button_pressed

func _on_button_pressed() -> void:
	var run = get_tree().get_first_node_in_group("run")
	if run and run.combat_manager:
		connect("button_pressed", Callable(run.combat_manager, "pop_up_button_pressed"))
	button_pressed.emit()
	queue_free()
	
