extends Node2D

const CHOOSE_FIGHT_SCENE_SPRITE = preload("res://scenes/reusables/choose_fight_scene_sprite.tscn")

@onready var easy_reward_text: RichTextLabel = $VBoxContainer/Fight1/MarginContainer/VBoxContainer/HBoxContainer3/Reward2
@onready var medium_reward_text: RichTextLabel = $VBoxContainer/Fight2/MarginContainer/VBoxContainer/HBoxContainer3/Reward2
@onready var hard_reward_text: RichTextLabel = $VBoxContainer/Fight3/MarginContainer/VBoxContainer/HBoxContainer3/Reward2

@onready var easy_enemies: HBoxContainer = $VBoxContainer/Fight1/MarginContainer/VBoxContainer/HBoxContainer
@onready var medium_enemies: HBoxContainer = $VBoxContainer/Fight2/MarginContainer/VBoxContainer/HBoxContainer
@onready var hard_enemies: HBoxContainer = $VBoxContainer/Fight3/MarginContainer/VBoxContainer/HBoxContainer

@onready var easy_level: Label = $VBoxContainer/Fight1/MarginContainer/VBoxContainer/HBoxContainer2/Level
@onready var medium_level: Label = $VBoxContainer/Fight2/MarginContainer/VBoxContainer/HBoxContainer2/Level
@onready var hard_level: Label = $VBoxContainer/Fight3/MarginContainer/VBoxContainer/HBoxContainer2/Level

var level = 1
var run

var easy_fight = null
var medium_fight = null
var hard_fight = null

var easy_reward = null
var medium_reward = null
var hard_reward = null

@onready var fight_1: PanelContainer = $VBoxContainer/Fight1
@onready var fight_2: PanelContainer = $VBoxContainer/Fight2
@onready var fight_3: PanelContainer = $VBoxContainer/Fight3

@onready var difficulty_1: Label = $VBoxContainer/Fight1/MarginContainer/VBoxContainer/HBoxContainer2/Difficulty
@onready var difficulty_2: Label = $VBoxContainer/Fight2/MarginContainer/VBoxContainer/HBoxContainer2/Difficulty
@onready var difficulty_3: Label = $VBoxContainer/Fight3/MarginContainer/VBoxContainer/HBoxContainer2/Difficulty


var rewards = []
var fights = []
var type = ""
signal choice_ended
var easy_color = "86a18c"
var hard_color = "b0797b"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.0001).timeout
	var run = get_tree().get_first_node_in_group("run")
	choice_ended.connect(run.scene_ended)
	
	for child in easy_enemies.get_children():
		child.queue_free()
	for child in medium_enemies.get_children():
		child.queue_free()
	for child in hard_enemies.get_children():
		child.queue_free()
	if type == "":
		if level == 1:
			update_color(fight_2, easy_color)
			difficulty_2.text = "Easy"
			easy_level.text = "Level: " + str(level)
			medium_level.text = "Level: " + str(level)
			hard_level.text = "Level: " + str(level+1)
			fights = []
			easy_fight = GC.get_random_fight(level)
			while easy_fight in fights:
				easy_fight = GC.get_random_fight(level)
			fights.append(easy_fight)
			medium_fight = GC.get_random_fight(level)
			while medium_fight in fights:
				medium_fight = GC.get_random_fight(level)
			fights.append(medium_fight)
			hard_fight = GC.get_random_fight(level+1)
			while hard_fight in fights:
				hard_fight = GC.get_random_fight(level+1)
			fights.append(hard_fight)
			rewards = []
			easy_reward = GC.get_random_reward(level)
			while easy_reward in rewards:
				easy_reward = GC.get_random_reward(level)
			rewards.append(easy_reward)
			medium_reward = GC.get_random_reward(level)
			while medium_reward in rewards:
				medium_reward = GC.get_random_reward(level)
			rewards.append(medium_reward)
			hard_reward = GC.get_random_reward(level+1)
			while hard_reward in rewards:
				hard_reward = GC.get_random_reward(level+1)
			rewards.append(hard_reward)
		else:
			if level < run.max_fight_level:
				easy_level.text = "Level: " + str(level-1)
				medium_level.text = "Level: " + str(level)
				hard_level.text = "Level: " + str(level+1)
				easy_fight = GC.get_random_fight(level-1)
				medium_fight = GC.get_random_fight(level)
				hard_fight = GC.get_random_fight(level+1)
				easy_reward = GC.get_random_reward(level-1)
				medium_reward = GC.get_random_reward(level)
				hard_reward = GC.get_random_reward(level+1)
			else:
				easy_level.text = "Level: " + str(level)
				medium_level.text = "Level: " + str(level)
				hard_level.text = "Level: " + str(level)
				easy_fight = GC.get_random_fight(level)
				medium_fight = GC.get_random_fight(level)
				hard_fight = GC.get_random_fight(level)
				rewards = []
				easy_reward = GC.get_random_reward(level)
				while easy_reward in rewards:
					easy_reward = GC.get_random_reward(level)
				rewards.append(easy_reward)
				medium_reward = GC.get_random_reward(level)
				while medium_reward in rewards:
					medium_reward = GC.get_random_reward(level)
				rewards.append(medium_reward)
				hard_reward = GC.get_random_reward(level)
				while hard_reward in rewards:
					hard_reward = GC.get_random_reward(level)
				rewards.append(hard_reward)
	elif type == "boss":
		if run.boss_level % 2 == 1:
			update_color(fight_1, hard_color)
			update_color(fight_2, hard_color)
			difficulty_1.text = "Miniboss"
			difficulty_2.text = "Miniboss"
			difficulty_3.text = "Miniboss"
			easy_level.text = "Level: " + str(run.boss_level)
			medium_level.text = "Level: " + str(run.boss_level)
			hard_level.text = "Level: " + str(run.boss_level)
			fights = []
			easy_fight = GC.get_random_boss(run.boss_level)
			while easy_fight in fights:
				easy_fight = GC.get_random_boss(run.boss_level)
			fights.append(easy_fight)
			medium_fight = GC.get_random_boss(run.boss_level)
			while medium_fight in fights:
				medium_fight = GC.get_random_boss(run.boss_level)
			fights.append(medium_fight)
			hard_fight = GC.get_random_boss(run.boss_level)
			while hard_fight in fights:
				hard_fight = GC.get_random_boss(run.boss_level)
			fights.append(hard_fight)
			rewards = []
			easy_reward = GC.get_random_boss_reward(run.boss_level)
			while easy_reward in rewards:
				easy_reward = GC.get_random_boss_reward(run.boss_level)
			rewards.append(easy_reward)
			medium_reward = GC.get_random_boss_reward(run.boss_level)
			while medium_reward in rewards:
				medium_reward = GC.get_random_boss_reward(run.boss_level)
			rewards.append(medium_reward)
			hard_reward = GC.get_random_boss_reward(run.boss_level)
			while hard_reward in rewards:
				hard_reward = GC.get_random_boss_reward(run.boss_level)
			rewards.append(hard_reward)
		if run.boss_level % 2 == 0:
			update_color(fight_1, hard_color)
			update_color(fight_2, hard_color)
			difficulty_1.text = "Boss"
			difficulty_2.text = "Boss"
			difficulty_3.text = "Boss"
			easy_level.text = "Level: " + str(run.boss_level)
			medium_level.text = "Level: " + str(run.boss_level)
			hard_level.text = "Level: " + str(run.boss_level)
			fights = []
			easy_fight = GC.get_random_boss(run.boss_level)
			#while easy_fight in fights:
				#easy_fight = GC.get_random_boss(run.boss_level)
			fights.append(easy_fight)
			medium_fight = GC.get_random_boss(run.boss_level)
			#while medium_fight in fights:
				#medium_fight = GC.get_random_boss(run.boss_level)
			fights.append(medium_fight)
			hard_fight = GC.get_random_boss(run.boss_level)
			#while hard_fight in fights:
				#hard_fight = GC.get_random_boss(run.boss_level)
			fights.append(hard_fight)
			rewards = []
			easy_reward = GC.get_random_boss_reward(run.boss_level)
			#while easy_reward in rewards:
				#easy_reward = GC.get_random_boss_reward(run.boss_level)
			rewards.append(easy_reward)
			medium_reward = GC.get_random_boss_reward(run.boss_level)
			#while medium_reward in rewards:
				#medium_reward = GC.get_random_boss_reward(run.boss_level)
			rewards.append(medium_reward)
			hard_reward = GC.get_random_boss_reward(run.boss_level)
			#while hard_reward in rewards:
				#hard_reward = GC.get_random_boss_reward(run.boss_level)
			rewards.append(hard_reward)
	for enemy in easy_fight:
		if enemy != null:
			var new_sprite = CHOOSE_FIGHT_SCENE_SPRITE.instantiate()
			new_sprite.texture = load(enemy.sprite.resource_path)
			easy_enemies.add_child(new_sprite)
	for enemy in medium_fight:
		if enemy != null:
			var new_sprite = CHOOSE_FIGHT_SCENE_SPRITE.instantiate()
			new_sprite.texture = load(enemy.sprite.resource_path)
			medium_enemies.add_child(new_sprite)
	for enemy in hard_fight:
		if enemy != null:
			var new_sprite = CHOOSE_FIGHT_SCENE_SPRITE.instantiate()
			new_sprite.texture = load(enemy.sprite.resource_path)
			hard_enemies.add_child(new_sprite)
	easy_reward_text.text += " "
	if easy_reward.gold != 0:
		easy_reward_text.text += str(easy_reward.gold) + " Gold, "
	if easy_reward.XP != 0:
		easy_reward_text.text += str(easy_reward.XP) + " XP, "
	if easy_reward.shop_type != "none":
		easy_reward_text.text += easy_reward.shop_type + " Shop, "
	if easy_reward.event_type != "none":
		easy_reward_text.text += easy_reward.event_type + " Event, " 
	if easy_reward.boss == true:
		easy_reward_text.text += " Boss Reward, "
		
	medium_reward_text.text += " "
	if medium_reward.gold != 0:
		medium_reward_text.text += str(medium_reward.gold) + " Gold, "
	if medium_reward.XP != 0:
		medium_reward_text.text += str(medium_reward.XP) + " XP, "
	if medium_reward.shop_type != "none":
		medium_reward_text.text += medium_reward.shop_type + " Shop, "
	if medium_reward.event_type != "none":
		medium_reward_text.text += medium_reward.event_type + " Event, "
	if medium_reward.boss == true:
		medium_reward_text.text += " Boss Reward, "
	
	hard_reward_text.text += " "
	if hard_reward.gold != 0:
		hard_reward_text.text += str(hard_reward.gold) + " Gold, "
	if hard_reward.XP != 0:
		hard_reward_text.text += str(hard_reward.XP) + " XP, "
	if hard_reward.shop_type != "none":
		hard_reward_text.text += hard_reward.shop_type + " Shop, "
	if hard_reward.event_type != "none":
		hard_reward_text.text += hard_reward.event_type + " Event, "
	if hard_reward.boss == true:
		hard_reward_text.text += " Boss Reward, "
	easy_reward_text.text = easy_reward_text.text.substr(0,easy_reward_text.text.length()-2)
	medium_reward_text.text = medium_reward_text.text.substr(0,medium_reward_text.text.length()-2)
	hard_reward_text.text = hard_reward_text.text.substr(0,hard_reward_text.text.length()-2)


func _on_easy_fight_pressed() -> void:
	run = get_tree().get_first_node_in_group("run")
	run.current_fight = easy_fight
	run.current_reward = easy_reward
	check_boss(easy_fight)
	choice_ended.emit("")

func _on_medium_fight_pressed() -> void:
	run = get_tree().get_first_node_in_group("run")
	run.current_fight = medium_fight
	run.current_reward = medium_reward
	check_boss(medium_fight)
	choice_ended.emit("")

func _on_hard_fight_pressed() -> void:
	run = get_tree().get_first_node_in_group("run")
	run.current_fight = hard_fight
	run.current_reward = hard_reward
	check_boss(hard_fight)
	choice_ended.emit("")

func update_color(button, color):
	var new_stylebox_normal = button.get_theme_stylebox("panel").duplicate()
	new_stylebox_normal.bg_color = color
	button.add_theme_stylebox_override("panel", new_stylebox_normal)

func check_boss(fight):
	if GC.FIRE_BOMBER in fight:
		run.current_boss = "bombers"
