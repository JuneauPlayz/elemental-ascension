extends Node2D

const CHOOSE_FIGHT_SCENE_SPRITE = preload("res://scenes/reusables/choose_fight_scene_sprite.tscn")

var level = 1
var run

var rewards = []
var fights = []
var type = ""
signal choice_ended
var element_dict = {"none": Color.WHITE, "fire": Color.CORAL, "water": Color.DARK_CYAN, "lightning": Color.YELLOW, "earth": Color.SADDLE_BROWN, "grass": Color.WEB_GREEN}
var easy_color = "86a18c"
var hard_color = "b0797b"

const FIRE_BOMB = preload("res://resources/Skills/boss_skills/Fire Bomb.tres")
const THUNDER_BOMB = preload("res://resources/Skills/boss_skills/Thunder Bomb.tres")
const WATER_BOMB = preload("res://resources/Skills/boss_skills/Water Bomb.tres")


@onready var rewards_box: VBoxContainer = $Rewards
@onready var confirm_swap: Button = $ConfirmSwap
@onready var choice_skill_info: Control = $ChoiceSkillInfo
@onready var keystone_info_1: Control = $Rewards/Reward1/MarginContainer/HBoxContainer/VBoxContainer/KeystoneInfo
@onready var skill_info_1: Control = $Rewards/Reward1/MarginContainer/HBoxContainer/VBoxContainer/SkillInfo
@onready var keystone_info_2: Control = $Rewards/Reward2/MarginContainer/HBoxContainer/VBoxContainer/KeystoneInfo
@onready var skill_info_2: Control = $Rewards/Reward2/MarginContainer/HBoxContainer/VBoxContainer/SkillInfo
@onready var keystone_info_3: Control = $Rewards/Reward3/MarginContainer/HBoxContainer/VBoxContainer/KeystoneInfo
@onready var skill_info_3: Control = $Rewards/Reward3/MarginContainer/HBoxContainer/VBoxContainer/SkillInfo
@onready var reward_1: PanelContainer = $Rewards/Reward1
@onready var reward_2: PanelContainer = $Rewards/Reward2
@onready var reward_3: PanelContainer = $Rewards/Reward3
@onready var skip_reward: Button = $SkipReward
@onready var continue_button: Button = $Continue

var reward_type = null
var new_skill = null
var reward_1_reward = null
var reward_2_reward = null
var reward_3_reward = null


signal swap_done
signal reward_chosen

var new_skill_ally
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.0001).timeout
	run = get_tree().get_first_node_in_group("run")
	continue_button.visible = false
	skip_reward.visible = true
	choice_ended.connect(run.scene_ended)
	match reward_type:
		"bombers":
			set_reward(1, FIRE_BOMB)
			update_color(reward_1,element_dict.get("fire"))
			set_reward(2, WATER_BOMB)
			update_color(reward_2,element_dict.get("water"))
			set_reward(3, THUNDER_BOMB)
			update_color(reward_3,element_dict.get("lightning"))

	
func update_color(button, color):
	var new_stylebox_normal = button.get_theme_stylebox("panel").duplicate()
	new_stylebox_normal.bg_color = color
	button.add_theme_stylebox_override("panel", new_stylebox_normal)

func choosing_skill():
	var new_skill_ally = null
	choice_skill_info.visible = true
	choice_skill_info.skill = new_skill
	skip_reward.visible = false
	choice_skill_info.update_skill_info()
	for ally in run.allies:
		ally.spell_select_ui.reset()
	confirm_swap.visible = true
	continue_button.visible = false
	await swap_done
	choice_skill_info.visible = false
	confirm_swap.visible = false
	continue_button.visible = true

func _on_confirm_swap_pressed() -> void:
	AudioPlayer.play_FX("deeper_new_click",-10)
	if (new_skill_ally):
		new_skill_ally.skill_swap_2 = new_skill
		new_skill_ally._on_confirm_swap_pressed()
		swap_done.emit()


func _on_choose1_pressed() -> void:
	if not run.UIManager.reaction_guide_open:
		if reward_1_reward is Skill:
			new_skill = reward_1_reward.duplicate()
			skill_reward_chosen()
		elif reward_1_reward is Keystone:
			run.keystone_handler.purchase_keystone(reward_1_reward)
			keystone_reward_chosen()

func _on_choose2_pressed() -> void:
	run = get_tree().get_first_node_in_group("run")
	if not run.UIManager.reaction_guide_open:
		if reward_2_reward is Skill:
			new_skill = reward_2_reward.duplicate()
			skill_reward_chosen()
		elif reward_2_reward is Keystone:
			run.keystone_handler.purchase_keystone(reward_2_reward)
			keystone_reward_chosen()
		
func _on_choose3_pressed() -> void:
	run = get_tree().get_first_node_in_group("run")
	if not run.UIManager.reaction_guide_open:
		if reward_3_reward is Skill:
			new_skill = reward_3_reward.duplicate()
			skill_reward_chosen()
		elif reward_3_reward is Keystone:
			run.keystone_handler.purchase_keystone(reward_3_reward)
			keystone_reward_chosen()

func skill_reward_chosen():
	rewards_box.visible = false
	choosing_skill()

func keystone_reward_chosen():
	rewards_box.visible = false
	continue_button.visible = true
	skip_reward.visible = false

func set_reward(num, reward):
	match num:
		1:
			reward_1_reward = reward
			if reward is Skill:
				skill_info_1.visible = true
				skill_info_1.skill = reward
				skill_info_1.update_skill_info()
			elif reward is Keystone:
				keystone_info_1.visible = true
				keystone_info_1.update_keystone_info(reward)
		2:
			reward_2_reward = reward
			if reward is Skill:
				skill_info_2.visible = true
				skill_info_2.skill = reward
				skill_info_2.update_skill_info()
			elif reward is Keystone:
				keystone_info_2.visible = true
				keystone_info_2.update_keystone_info(reward)
		3:
			reward_3_reward = reward
			if reward is Skill:
				skill_info_3.visible = true
				skill_info_3.skill = reward
				skill_info_3.update_skill_info()
			elif reward is Keystone: 
				keystone_info_3.visible = true
				keystone_info_3.update_keystone_info(reward)


func _on_continue_pressed() -> void:
	choice_ended.emit("")
