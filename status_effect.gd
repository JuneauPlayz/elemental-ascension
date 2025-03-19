extends Control

const STATUS_INFO = preload("res://scenes/reusables/status_info.tscn")

var status
var info
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_texture_rect_mouse_entered() -> void:
	info = STATUS_INFO.instantiate()
	self.add_child(info)
	info.update(status)
	info.global_position = self.global_position + Vector2(0,-96)


func _on_texture_rect_mouse_exited() -> void:
	info.queue_free()
