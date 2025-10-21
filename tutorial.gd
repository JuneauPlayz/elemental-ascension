extends Node2D

const RUN = preload("res://scenes/main scenes/run.tscn")

var game

var ally1 = preload("uid://btrtrqusgest0")

var enemy1 = preload("uid://crtmf4u70jof5")

var enemy2 : UnitRes
var enemy3 : UnitRes
var enemy4 : UnitRes

var combat_manager

func _ready() -> void:
	GC.load_run_combat_test(ally1, null, null, null, enemy1, null, null, null, [])
	new_scene(RUN)
	combat_manager = current_scene.combat_manager
	combat_manager.tutorial = true


var current_scene
# Called when the node enters the scene tree for the first time.


func new_scene(scene):
	if current_scene != null:
		current_scene.queue_free()
	current_scene = scene.instantiate()
	self.add_child(current_scene)
