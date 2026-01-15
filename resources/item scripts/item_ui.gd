class_name ItemUI
extends Control

@export var item : Item : set = set_item
@onready var panel_container: PanelContainer = $PanelContainer

@onready var icon : TextureRect = %Icon
@onready var animation_player : AnimationPlayer = %AnimationPlayer
var shop = false


func _ready() -> void:
	flash()
	

func set_item(new_item: Item) -> void:
	if not is_node_ready():
		await ready
	
	item = new_item
	icon.texture = item.icon



	
func flash() -> void:
	animation_player.play("flash")
	

func _on_icon_mouse_entered() -> void:
	var run = get_tree().get_first_node_in_group("run")
	run.UIManager.display(item)


func _on_icon_mouse_exited() -> void:
	var run = get_tree().get_first_node_in_group("run")
	run.UIManager.hide_display()
