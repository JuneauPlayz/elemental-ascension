class_name KeystoneUI
extends Control

@export var keystone : Keystone : set = set_keystone

@onready var icon : TextureRect = $Icon
@onready var animation_player : AnimationPlayer = $AnimationPlayer
var shop = false


func _ready() -> void:

	flash()

func set_keystone(new_keystone: Keystone) -> void:
	if not is_node_ready():
		await ready
	
	keystone = new_keystone
	icon.texture = keystone.icon



	
func flash() -> void:
	animation_player.play("flash")
	

func _on_icon_mouse_entered() -> void:
	var run = get_tree().get_first_node_in_group("run")
	if keystone in run.keystones:
		run.UIManager.display(keystone)


func _on_icon_mouse_exited() -> void:
	var run = get_tree().get_first_node_in_group("run")
	run.UIManager.hide_display()
