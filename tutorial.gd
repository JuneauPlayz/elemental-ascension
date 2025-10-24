extends Node2D

const RUN = preload("res://scenes/main scenes/run.tscn")

var game

var ally1 = preload("uid://btrtrqusgest0")
var ally2 = preload("uid://ct8pg6i13eoib")

var enemy1 = preload("uid://crtmf4u70jof5")
var enemy2 = preload("uid://crtmf4u70jof5")


var combat_manager

func _ready() -> void:
	GC.load_run_combat_test(ally1, null, null, null, enemy1, null, null, null, [])
	new_scene(RUN)
	combat_manager = current_scene.combat_manager
	combat_manager.tutorial = true


func tutorial_2():
	current_scene.queue_free()
	await get_tree().create_timer(0.1).timeout
	GC.load_run_combat_test(ally1, ally2, null, null, enemy1, null, null, null, [])
	new_scene(RUN)
	combat_manager = current_scene.combat_manager
	combat_manager.tutorial2 = true
	
var current_scene
# Called when the node enters the scene tree for the first time.


func new_scene(scene):
	if current_scene != null:
		current_scene.queue_free()
	current_scene = scene.instantiate()
	self.add_child(current_scene)
