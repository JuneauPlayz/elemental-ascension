extends Unit
class_name Ally

@export var skill_1 : Skill
@export var skill_2: Skill
@export var skill_3: Skill
@export var skill_4: Skill

@export var ult_choice_1 : Skill
@export var ult_choice_2 : Skill

@export var keystone_choice_1 : Keystone
@export var keystone_choice_2 : Keystone
@export var keystone_choice_3 : Keystone
@export var keystone_choice_4 : Keystone

var skill_swap_1 : Skill
var skill_swap_1_spot : int
var skill_swap_2 : Skill

var ally_num : int

@onready var sprite_spot: Sprite2D = $SpriteSpot

@onready var spell_select_ui: Control = $SpellSelectUi
@onready var level_up_reward: Control = $LevelUpReward
@onready var swap_tutorial: Label = $LevelUpReward/SwapTutorial
@onready var confirm_swap: Button = $LevelUpReward/ConfirmSwap
@onready var item_handler: Control = $ItemHandler

var combat = true

var level_up_complete = false

var level
var level_up

var chosen_keystone

var run_starting
signal loaded

var using_skill = false
var spent_tokens = 0
var spent_tokens_type = ""
var spent_tokens_2 = 0
var spent_tokens_type_2 = ""
# special status checks
var sow_just_applied = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# loading
	run = get_tree().get_first_node_in_group("run")
	id = run.id
	run.id += 1
	await get_tree().create_timer(0.0001).timeout
	run = get_tree().get_first_node_in_group("run")
	# spell select ui first child, hp bar ui second child
	if run.combat == true and not run_starting:
		combat_manager = get_parent().get_parent().get_combat_manager()
		ReactionManager = combat_manager.ReactionManager
		spell_select_ui.new_select.connect(run.combat_manager._on_spell_select_ui_new_select)
		self.target_chosen.connect(run.combat_manager.target_signal)
		hp_bar.update_statuses(status)
	current_element = "neutral"
	hp_bar = $"HP Bar"
	targeting_area = $TargetingArea
	if run_starting:
		health = res.starting_health
		max_health = res.starting_health
		skill_1 = res.skill1
		if skill_1 != null:
			run.add_skill(skill_1)
		skill_2 = res.skill2
		if skill_2 != null:
			run.add_skill(skill_2)
		skill_3 = res.skill3
		if skill_3 != null:
			run.add_skill(skill_3)
		skill_4 = res.skill4
		if skill_4 != null:
			run.add_skill(skill_4)
		title = res.name
		
		if res.starting_item != null:
			match res.starting_item.type:
				"Weapon":
					change_weapon(res.starting_item)
				"Armor":
					change_armor(res.starting_item)
				"Accessory":
					change_accessory(res.starting_item)
		ult_choice_1 = res.ult_1
		if ult_choice_1 != null:
			ult_choice_1.update()

		ult_choice_2 = res.ult_2
		if ult_choice_2 != null:
			ult_choice_2.update()

		keystone_choice_1 = res.keystone_1
		if keystone_choice_1 != null:
			keystone_choice_1.update()

		keystone_choice_2 = res.keystone_2
		if keystone_choice_2 != null:
			keystone_choice_2.update()

		keystone_choice_3 = res.keystone_3
		if keystone_choice_3 != null:
			keystone_choice_3.update()

		keystone_choice_4 = res.keystone_4
		if keystone_choice_4 != null:
			keystone_choice_4.update()
		sprite_spot.texture = null
		sprite_spot.texture = load(res.sprite.resource_path)
		sprite_spot.scale = Vector2(res.sprite_scale,res.sprite_scale)
		run_starting = false
		update_skills()
	else:
		health = health
		max_health = max_health
	spell_select_ui.skill1 = skill_1
	spell_select_ui.skill2 = skill_2
	spell_select_ui.skill3 = skill_3
	spell_select_ui.skill4 = skill_4
	spell_select_ui.load_skills()
	hp_bar.set_hp(health)
	hp_bar.set_maxhp(max_health)

		
	
func update_vars():
	spell_select_ui.skill1 = skill_1
	spell_select_ui.skill2 = skill_2
	spell_select_ui.skill3 = skill_3
	spell_select_ui.skill4 = skill_4

func show_skills():
	spell_select_ui.visible = true
	
func hide_skills():
	spell_select_ui.visible = false
	
	
func update_skills():
	
	if skill_1 != null:
		update_skill_damage(skill_1)
		skill_1.update()
	if skill_2 != null:
		update_skill_damage(skill_2)
		skill_2.update()
	if skill_3 != null:
		update_skill_damage(skill_3)
		skill_3.update()
	if skill_4 != null:
		update_skill_damage(skill_4)
		skill_4.update()
	spell_select_ui.load_skills()
	
	
func show_level_up(level):
	level_up_reward.visible = true
	level_up_reward.reset()
	match level:
		1:
			level_up_reward.load_options(keystone_choice_1, keystone_choice_2)
		2:
			level_up_reward.load_skills(ult_choice_1, ult_choice_2)
		3:
			level_up_reward.load_options(keystone_choice_3, keystone_choice_4)
		_:
			level_up_reward.load_options(keystone_choice_3, keystone_choice_4)

func hide_level_up():
	level_up_reward.visible = false
	level_up_reward.reset()

func _on_spell_select_ui_new_select(ally) -> void:
	AudioPlayer.play_FX("click",-3)
	skill_swap_1_spot = spell_select_ui.selected
	if skill_swap_2 != null:
		confirm_swap.visible = true
	if run.shop == true:
		var shop = get_tree().get_first_node_in_group("shop")
		shop.new_skill_ally = self
	if run.choose_reward == true:
		var choose_reward = get_tree().get_first_node_in_group("choose_reward")
		choose_reward.new_skill_ally = self
		


func _on_level_up_reward_new_select(skill) -> void:
	if level_up_reward.choosing_skills:
		AudioPlayer.play_FX("new_click",-10)
		skill_swap_2 = skill
		swap_tutorial.visible = true
		if (skill_swap_1_spot > 0):
			confirm_swap.visible = true
	if level_up_reward.choosing_options:
		chosen_keystone = skill
		confirm_swap.visible = true

func get_spell_select():
	return spell_select_ui


func _on_targeting_area_pressed() -> void:
	if targetable == true:
		target_chosen.emit(self)


func _on_confirm_swap_pressed() -> void:
	AudioPlayer.play_FX("new_click",-10)
	match skill_swap_1_spot:
		1:
			skill_1 = skill_swap_2
		2:
			skill_2 = skill_swap_2
		3:
			skill_3 = skill_swap_2
		4:
			skill_4 = skill_swap_2
	run.add_skill(skill_swap_2)
	update_spell_select()
	update_skills()
	swap_tutorial.visible = false
	spell_select_ui.reset()

func update_spell_select():
	spell_select_ui.skill1 = skill_1
	spell_select_ui.skill2 = skill_2
	spell_select_ui.skill3 = skill_3
	spell_select_ui.skill4 = skill_4
	spell_select_ui.load_skills()
	

func _on_confirm_swap_level_pressed() -> void:
	AudioPlayer.play_FX("new_click",-10)
	if level_up_reward.choosing_skills:
		match skill_swap_1_spot:
			1:
				skill_1 = skill_swap_2
			2:
				skill_2 = skill_swap_2
			3:
				skill_3 = skill_swap_2
			4:
				skill_4 = skill_swap_2
		run.add_skill(skill_swap_2)
	elif level_up_reward.choosing_options:
		run.keystone_handler.purchase_keystone(chosen_keystone)
	level_up_reward.visible = false
	level_up_reward.choosing_skills = false
	level_up_reward.choosing_options = false
	update_spell_select()
	skill_swap_1_spot = 0
	swap_tutorial.visible = false
	level_up = false
	spell_select_ui.reset()

func attack_animation():
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		sprite_spot, "position:y", sprite_spot.position.y - 50, GC.GLOBAL_INTERVAL
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		sprite_spot, "rotation", sprite_spot.rotation - deg_to_rad(45), GC.GLOBAL_INTERVAL
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		sprite_spot, "rotation", sprite_spot.rotation + deg_to_rad(30), 0.05
	).set_ease(Tween.EASE_OUT).set_delay(GC.GLOBAL_INTERVAL)
	tween.tween_property(
		sprite_spot, "position:x", sprite_spot.position.x + 25, 0.05
	).set_ease(Tween.EASE_OUT).set_delay(GC.GLOBAL_INTERVAL)
	tween.tween_property(
		sprite_spot, "position:y", sprite_spot.position.y, 0.05
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(
		sprite_spot, "rotation", sprite_spot.rotation, 0.20
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(
		sprite_spot, "position:x", sprite_spot.position.x, 0.05
	).set_ease(Tween.EASE_OUT).set_delay(0.25)


func update_skill_damage(skill):
	if skill != null:
		skill.update()
		if skill.damaging:
			match skill.element:
				"fire":
					skill.damage = (skill.starting_damage + fire_skill_damage_bonus + all_skill_damage_bonus) * fire_skill_damage_mult * all_skill_damage_mult
				"water":
					skill.damage = (skill.starting_damage + water_skill_damage_bonus + all_skill_damage_bonus) * water_skill_damage_mult * all_skill_damage_mult
				"lightning":
					skill.damage = (skill.starting_damage + lightning_skill_damage_bonus + all_skill_damage_bonus) * lightning_skill_damage_mult  * all_skill_damage_mult
				"grass":
					skill.damage = (skill.starting_damage + grass_skill_damage_bonus + all_skill_damage_bonus) * grass_skill_damage_mult * all_skill_damage_mult
				"earth":
					skill.damage = (skill.starting_damage + earth_skill_damage_bonus + all_skill_damage_bonus) * earth_skill_damage_mult * all_skill_damage_mult
				"neutral":
					skill.damage = (skill.starting_damage + neutral_skill_damage_bonus + all_skill_damage_bonus) * neutral_skill_damage_mult * all_skill_damage_mult
		elif skill.healing:
			skill.damage = (skill.starting_damage + healing_skill_bonus) * healing_skill_mult
		elif skill.shielding:
			skill.damage = (skill.starting_damage + shielding_skill_bonus) * shielding_skill_mult
