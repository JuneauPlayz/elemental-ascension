extends Control
@onready var grid_container: GridContainer = $GridContainer
const STATUS_EFFECT = preload("res://status_effect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_statuses(statuses):
	for child in grid_container.get_children():
		child.queue_free()
	for status in statuses:
		var new_status = STATUS_EFFECT.instantiate()
		grid_container.add_child(new_status)
		new_status.status = status
		
	
