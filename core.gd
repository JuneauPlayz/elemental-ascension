extends Node2D

const CORE_INFO = preload("res://scenes/reusables/core_info.tscn")

var ally
var main_stat
var substats = []
var info
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ally = get_parent()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func change_main_stat(upgrade):
	main_stat = upgrade
	
func add_substat(upgrade):
	substats.append(upgrade)
			


func _on_icon_mouse_entered() -> void:
	info = CORE_INFO.instantiate()
	self.add_child(info)
	info.update(self)
	info.global_position = self.global_position + Vector2(48,-96)


func _on_icon_mouse_exited() -> void:
	info.queue_free()
