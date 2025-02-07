extends Node2D

@onready var combat_manager: Node = %CombatManager
@onready var enemy_1_spot: Node2D = %"Enemy 1 Spot"
@onready var enemy_2_spot: Node2D = %"Enemy 2 Spot"
@onready var enemy_3_spot: Node2D = %"Enemy 3 Spot"
@onready var enemy_4_spot: Node2D = %"Enemy 4 Spot"
@onready var combat_currency: Control = $CombatManager/CombatCurrency
@onready var end_turn: Button = $EndTurn

var ally1 : Ally
var ally2 : Ally
var ally3 : Ally
var ally4 : Ally
var enemy1 : Enemy
var enemy2 : Enemy
var enemy3 : Enemy
var enemy4 : Enemy

var enemy1res : UnitRes
var enemy2res : UnitRes
var enemy3res : UnitRes
var enemy4res : UnitRes

var enemies = []
var allies = []

const ALLY = preload("res://resources/units/allies/ally.tscn")
const ENEMY = preload("res://resources/units/enemies/enemy.tscn")

var run
var combat_sim

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# loading
	run = get_tree().get_first_node_in_group("run")
	# bg music
	var rng = RandomNumberGenerator.new()
	var random_num = rng.randi_range(1,4)
	match random_num:
		1:
			AudioPlayer.play_music("og", -32)
		2:
			AudioPlayer.play_music("zinnia", -32)
		3:
			AudioPlayer.play_music("crimson", -32)
		4:
			AudioPlayer.play_music("iris", -32)
	
	combat_manager = get_child(0)
	await get_tree().create_timer(0.15).timeout
	load_units()
	combat_manager.combat_ready()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_combat_manager():
	return combat_manager

func load_units():
	print("loading units")
	if enemy1res != null:
		var enemy1s = ENEMY.instantiate()
		enemy1 = enemy1s
		enemy1s.res = enemy1res.duplicate()
		enemy_1_spot.add_child(enemy1s)
		combat_manager.enemy1 = enemy1s
	if enemy2res != null:
		var enemy2s = ENEMY.instantiate()
		enemy2 = enemy2s
		enemy2s.res = enemy2res.duplicate()
		enemy_2_spot.add_child(enemy2s)
		combat_manager.enemy2 = enemy2s
	if enemy3res != null:
		var enemy3s = ENEMY.instantiate()
		enemy3 = enemy3s
		enemy3s.res = enemy3res.duplicate()
		enemy_3_spot.add_child(enemy3s)
		combat_manager.enemy3 = enemy3s
	if enemy4res != null:
		var enemy4s = ENEMY.instantiate()
		enemy4 = enemy4s
		enemy4s.res = enemy4res.duplicate()
		enemy_4_spot.add_child(enemy4s)
		combat_manager.enemy4 = enemy4s
	if (enemy1 != null):
		enemies.append(enemy1)
	if (enemy2 != null):
		enemies.append(enemy2)
	if (enemy3 != null):
		enemies.append(enemy3)
	if (enemy4 != null):
		enemies.append(enemy4)
	if (run.ally1 != null):
		allies.append(run.ally1)
	if (run.ally2 != null):
		allies.append(run.ally2)
	if (run.ally3 != null):
		allies.append(run.ally3)
	if (run.ally4 != null):
		allies.append(run.ally4)
	for ally in allies:
		ally.update_vars()


func _on_win_pressed() -> void:
	combat_manager.victory()
