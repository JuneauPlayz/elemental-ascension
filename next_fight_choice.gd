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

var rewards = []

signal choice_ended
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
	if level == 1:
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
	else:
		easy_level.text = "Level: " + str(level-1)
		medium_level.text = "Level: " + str(level)
		hard_level.text = "Level: " + str(level+1)
		easy_fight = GC.get_random_fight(level-1)
		medium_fight = GC.get_random_fight(level)
		hard_fight = GC.get_random_fight(level+1)
		easy_reward = GC.get_random_reward(level-1)
		medium_reward = GC.get_random_reward(level)
		hard_reward = GC.get_random_reward(level+1)
		
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
	
	if easy_reward.gold != 0:
		easy_reward_text.text += str(easy_reward.gold) + " Gold, "
	if easy_reward.XP != 0:
		easy_reward_text.text += str(easy_reward.XP) + " XP, "
	if easy_reward.shop_type != "none":
		easy_reward_text.text += easy_reward.shop_type + " Shop"
		
	if medium_reward.gold != 0:
		medium_reward_text.text += str(medium_reward.gold) + " Gold, "
	if medium_reward.XP != 0:
		medium_reward_text.text += str(medium_reward.XP) + " XP, "
	if medium_reward.shop_type != "none":
		medium_reward_text.text += medium_reward.shop_type + " Shop"
		
	if hard_reward.gold != 0:
		hard_reward_text.text += str(hard_reward.gold) + " Gold, "
	if hard_reward.XP != 0:
		hard_reward_text.text += str(hard_reward.XP) + " XP, "
	if hard_reward.shop_type != "none":
		hard_reward_text.text += hard_reward.shop_type + " Shop, "
	easy_reward_text.text = easy_reward_text.text.substr(0,easy_reward_text.text.length()-2)
	medium_reward_text.text = medium_reward_text.text.substr(0,medium_reward_text.text.length()-2)
	hard_reward_text.text = hard_reward_text.text.substr(0,hard_reward_text.text.length()-2)


func _on_easy_fight_pressed() -> void:
	run = get_tree().get_first_node_in_group("run")
	run.current_fight = easy_fight
	run.current_reward = easy_reward
	choice_ended.emit("")

func _on_medium_fight_pressed() -> void:
	run = get_tree().get_first_node_in_group("run")
	run.current_fight = medium_fight
	run.current_reward = medium_reward
	choice_ended.emit("")

func _on_hard_fight_pressed() -> void:
	run = get_tree().get_first_node_in_group("run")
	run.current_fight = hard_fight
	run.current_reward = hard_reward
	choice_ended.emit("")
