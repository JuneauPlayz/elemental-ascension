extends Node

@onready var turn_text: Label = $TurnText
@onready var combat_currency: Control = $CombatCurrency
@onready var enemy_combat_currency: Control = $EnemyCombatCurrency
@onready var trigger_manager: TriggerManager = %TriggerManager


const AFTER_SKILL_DELAY = 0.35
const END_TURN_DELAY = 0.5

@onready var text_popups: Node = $"../Tutorial/Tutorial1"


const ENEMY = preload("res://resources/units/enemies/enemy.tscn")



@export var ally1 : Ally
@export var ally2 : Ally
@export var ally3 : Ally
@export var ally4 : Ally
@export var allies : Array = []
var front_ally : Ally
var front_ally_2 : Ally
var back_ally : Ally
var back_ally_2 : Ally
var middle_allies = []
@export var enemy1 : Enemy
@export var enemy2 : Enemy
@export var enemy3 : Enemy
@export var enemy4 : Enemy
@export var enemies : Array = []
var front_enemy : Enemy
var front_enemy_2 : Enemy
var back_enemy : Enemy
var back_enemy_2 : Enemy

var ally_list = [ally1, ally2, ally3, ally4]
var enemy_list = [enemy1, enemy2]

var enemy_skill_queue = []
var choosing_skills = false
# parallel array for targets
var targeting = false
var input_allowed = false

var targeting_skill : Skill

var auto_end_turn = true
var tutorial_no_end_turn = false
var tutorial_no_ally_skill = false
var skills_castable = true

@onready var end_turn: Button = $"../EndTurn"
@onready var keystones : KeystoneHandler
@onready var victory_screen: Control = $"../VictoryScreen"
@onready var win: Button = $"../Win"
@onready var character_ult_animation: Control = %CharacterUltAnimation


var ally1skill : int
var ally2skill : int
var ally3skill : int
var ally4skill : int

var next_pos : int

var ally1_pos : int
var ally2_pos : int
var ally3_pos : int
var ally4_pos : int

var fire_tokens = 0
var water_tokens = 0
var lightning_tokens = 0
var grass_tokens = 0
var earth_tokens = 0

var enemy_fire_tokens = 0
var enemy_water_tokens = 0
var enemy_lightning_tokens = 0
var enemy_grass_tokens = 0
var enemy_earth_tokens = 0

var tutorial = false
var tutorial2 = false

const TARGET_CURSOR = preload("res://assets/target cursor.png")
const DEFAULT_CURSOR = preload("res://assets/defaultcursor.png")

signal ally_turn_done
signal enemy_skills_done
signal new_spell_selected
signal target_selected
signal target_chosen
signal skill_selected
signal end_turn_pressed
signal ult_anim_done


var combat_finished = false
var first_turn = true
var victorious = false
var xp_reward

signal combat_ended
signal hit
signal signal_received
signal reaction_finished

signal skill_used(caster : Unit, skill : Skill, target : Array[Unit])
signal damage_dealt(value : int, element : String)
signal reaction_triggered(value : int, reaction : String)
signal turn_started
signal turn_ended

var run

@onready var ReactionManager: Node = $"../ReactionManager"


func combat_ready():
	run = get_tree().get_first_node_in_group("run")
	combat_ended.connect(run.scene_ended)
	await get_tree().create_timer(0.1).timeout
	reset_combat()
	if (enemy1 != null):
		enemies.append(enemy1)
	if (enemy2 != null):
		enemies.append(enemy2)
	if (enemy3 != null):
		enemies.append(enemy3)
	if (enemy4 != null):
		enemies.append(enemy4)
	if (ally1 != null):
		allies.append(ally1)
	if (ally2 != null):
		allies.append(ally2)
	if (ally3 != null):
		allies.append(ally3)
	if (ally4 != null):
		allies.append(ally4)
	for i in range(len(allies)):
		allies[i].position = i+1
	# setting left and right for units
	set_unit_pos()
	# keystone stuff
	run.update_skills()
	combat_currency.update()
	run.hide_gold()
	run.hide_xp()
	load_triggers()
	start_combat()
	



func start_combat():
	combat_currency.update()
	enemy_combat_currency.update()
	reset_skill_select()
	check_requirements()
	show_skills()
	for popup in text_popups.get_children():
		popup.visible = false
	for enemy in enemies:
		enemy.change_skills()
		enemy.change_element("neutral")
	for ally in allies:
		ally.change_element("neutral")
	while (!combat_finished):
		start_ally_turn()
		if tutorial == true:
			start_tutorial()
			tutorial = false
		elif tutorial2 == true:
			start_tutorial2()
			tutorial2 = false
		await ally_turn_done

func end_battle():
	pass
	
func start_ally_turn():
	set_unit_pos()
	show_ui()
	turn_text.text = "Ally Turn"
	input_allowed = true
	turn_started.emit()
	ally_pre_status()
	enemy_pre_status()
	lose_shields()
	show_skills()
	reset_skill_select()
	check_requirements()
	update_skill_positions()
	choosing_skills = true


func ally_skill_use_wrapper(skill, target, ally):
	hide_ui()
	hide_skills()
	ally.spell_select_ui.disable_all()

	await ally_skill_use(skill, target, ally)
	await get_tree().create_timer(AFTER_SKILL_DELAY).timeout
	
	if enemy_skill_queue.size() > 0:
		await check_enemy_skills()

	show_ui()
	show_skills()

	if enemies.is_empty():
		victory()


	check_ally_turn_done()

func ally_skill_use(skill, target, ally):
	input_allowed = false
	var targets = []
	if target == null:
		targets = resolve_targets(skill.target_type)
	else:
		targets = [target]
	use_skill(skill, target, ally, true, true)
	check_post_skill(skill)
	combat_currency.update()

	await reaction_finished
	
	skill_used.emit(ally, skill, targets)
	emit_signal("skill_used", ally, skill, targets)
	print(str(skill.name) + " landed!")
	hit.emit()
	await get_tree().create_timer(0.1).timeout
	for enemy in enemies:
		enemy.decrease_countdown(1)
	input_allowed = true


	

func enemy_skill_use(enemy):
	enemy_skill_queue.append(enemy)

func check_enemy_skills():
	input_allowed = false
	for enemy in enemy_skill_queue:
		await enemy_skill_use_wrapper(enemy)
		await get_tree().create_timer(AFTER_SKILL_DELAY).timeout
	enemy_skill_queue.clear()
	enemy_skills_done.emit()
	input_allowed = true
	combat_currency.update()


func enemy_skill_use_wrapper(enemy):
	use_skill(enemy.current_skill, null, enemy, true, false)
	await reaction_finished
	skill_used.emit(enemy, enemy.current_skill, resolve_targets(enemy.current_skill.target_type))


func check_post_skill(skill):
	if skill.decay == true:
		skill.damage -= skill.decay_value
		if skill.damage < 0:
			skill.damage = 0
		if skill.blast == true:
			skill.blast_damage -= skill.decay_value
			if skill.blast_damage < 0:
				skill.blast_damage = 0
		skill.update()

func check_ally_turn_done():
	for ally in allies:
		if ally.spell_select_ui.disabled_all == false:
			return
	if auto_end_turn:
		end_turn_process()

func check_event_keystones(skill,unit,value_multiplier,target):
	if (run.ghostfire and unit is Ally and skill.element == "fire"):
		if (skill.target_type == "single_enemy" or skill.target_type == "back_enemy" or skill.target_type == "front_enemy"):
			await get_tree().create_timer(0.1).timeout
			front_enemy.receive_skill(skill, unit, value_multiplier)
	if (run.flow and unit is Ally and skill.element == "water"):
		await get_tree().create_timer(0.1).timeout
		var new_target = target
		if skill.target_type == "back_enemy":
			new_target = back_enemy
		if skill.target_type == "front_enemy":
			new_target = front_enemy
		if (skill.target_type == "single_enemy"):
			if new_target != null:
				if new_target.left != null:
					new_target.left.receive_skill(skill,unit,value_multiplier*0.5)
				if new_target.right != null:
					new_target.right.receive_skill(skill,unit,value_multiplier*0.5)
	if (run.lightning_strikes_twice and unit is Ally and skill.element == "lightning"):
		await get_tree().create_timer(0.10).timeout
		use_skill(skill, target, unit, false, false)
		
func victory():
	victorious = true
	victory_screen.visible = true
	victory_screen.update_text("Victory!", run.current_reward)
	hide_skills()
	hide_ui()
	run.show_gold()
	run.show_xp()
	# already connected !
	victory_screen.continue_pressed.connect(self.finish_battle)

func defeat():
	win.visible = false
	run.show_gold()
	run.show_xp()
	run.reset()
	victorious = false
	victory_screen.visible = true
	victory_screen.update_text("Defeat!", 0)
	run.add_gold(0)
	hide_skills()
	hide_ui()
	for enemy in enemies:
		enemy.visible = false
	victory_screen.continue_pressed.connect(self.finish_battle)
	
func finish_battle():
	if victorious:
		run.add_reward(run.current_reward)
		if run.end:
			combat_ended.emit("")
		else:
			for ally in allies:
				ally.spell_select_ui.new_select.disconnect(run.combat_manager._on_spell_select_ui_new_select)
			combat_ended.emit("")
	if not victorious:
		run.reset()
		get_tree().change_scene_to_file("res://scenes/main scenes/main_scene.tscn")

func reset_combat():
	allies = []
	enemies = []
	reset_tokens()
	victory_screen.visible = false
	
func use_skill(skill, target, unit, event, spend_tokens):
	skill.update()

	if skill.ultimate:
		character_ult_animation.play_ultimate(unit.sprite_spot.texture, skill.name)
		await ult_anim_done

	var value_multiplier := 1

	if event:
		check_event_keystones(skill, unit, value_multiplier, target)

	if (skill.cost > 0 or skill.cost2 > 0) and spend_tokens:
		spend_skill_cost(skill)

	var targets: Array

	# Explicit target always wins
	if target != null:
		targets = [target]
	else:
		targets = resolve_targets(skill.target_type)

	for t in targets:
		if t != null:
			t.receive_skill(skill, unit, value_multiplier)

	if skill.lifesteal:
		unit.receive_healing(roundi(skill.damage * skill.lifesteal_rate), "grass", false)

	
func spend_skill_cost(skill):
	var tokens1 = 0
	var tokens2 = 0
	print("spending tokens")
	if skill.cost > 0:
		match skill.token_type:
			"fire":
				fire_tokens -= skill.cost
			"water":
				water_tokens -= skill.cost
			"lightning":
				lightning_tokens -= skill.cost
			"grass":
				grass_tokens -= skill.cost
			"earth":
				earth_tokens -= skill.cost
	if skill.cost2 > 0:
		match skill.token_type2:
			"fire":
				fire_tokens -= skill.cost2
			"water":
				water_tokens -= skill.cost2
			"lightning":
				lightning_tokens -= skill.cost2
			"grass":
				grass_tokens -= skill.cost2
			"earth":
				earth_tokens -= skill.cost2

		
			
func reaction_signal():
	combat_currency.update()
	enemy_combat_currency.update()
	reaction_finished.emit()
	
func lose_shields():
	for ally in allies:
		ally.set_shield(0)
		
func enemy_lose_shields():
	for enemy in enemies:
		enemy.set_shield(0)
	
func _on_spell_select_ui_new_select(ally) -> void:
	var spell_select_ui: Control = ally.get_spell_select()
	var selected_index = spell_select_ui.selected
	# for tutorial
	skill_selected.emit()
		
	hide_ui()
	# If unselecting
	if selected_index == 0:
		ally.using_skill = false
		return
	
	# Pick the correct skill
	var skill = null
	match selected_index:
		1: skill = ally.skill_1
		2: skill = ally.skill_2
		3: skill = ally.skill_3
		4: skill = ally.skill_4
	
	if skill == null:
		return
	if skill.target_type != "single_enemy" and skill.target_type != "single_ally":
		await ally_skill_use_wrapper(skill, null, ally)
	else:
		run.UIManager.freeze_info()
		var target = await choose_target(skill)
		if target:
			target_selected.emit()
			run.UIManager.unfreeze_info()
			run.UIManager.hide_display()
			ally.using_skill = true
			await ally_skill_use_wrapper(skill, target, ally)
	
	check_requirements()
	


func update_positions(cpos):
	if ally1_pos > cpos:
		ally1_pos -= 1
	if ally2_pos > cpos:
		ally2_pos -= 1
	if ally3_pos > cpos:
		ally3_pos -= 1
	if ally4_pos > cpos:
		ally4_pos -= 1

func update_skill_positions():
	if ally1 != null:
		var spell_select_ui1 = ally1.get_spell_select()
	if ally2 != null:
		var spell_select_ui2 = ally2.get_spell_select()
	if ally3 != null:
		var spell_select_ui3 = ally3.get_spell_select()
	if ally4 != null:
		var spell_select_ui4 = ally4.get_spell_select()


func reset_skill_select():
	set_unit_pos()
	if ally1 != null:
		var spell_select_ui1 = ally1.get_spell_select()
		spell_select_ui1.reset()
		ally1.using_skill = false
	if ally2 != null:
		var spell_select_ui2 = ally2.get_spell_select()
		spell_select_ui2.reset()
		ally2.using_skill = false
	if ally3 != null:
		var spell_select_ui3 = ally3.get_spell_select()
		spell_select_ui3.reset()
		ally3.using_skill = false
	if ally4 != null:
		var spell_select_ui4 = ally4.get_spell_select()
		spell_select_ui4.reset()
		ally4.using_skill = false
	next_pos = 0
	ally1_pos = -1
	ally2_pos = -1
	ally3_pos = -1
	ally4_pos = -1
	ally1skill = -1
	ally2skill = -1
	ally3skill = -1
	ally4skill = -1
	for ally in allies:
		ally.update_skills()

	update_skill_positions()
	
func _on_end_turn_pressed() -> void:
	AudioPlayer.play_FX("deeper_new_click",0)
	end_turn_process()

func end_turn_process():
	if (!targeting and choosing_skills):
		input_allowed = false
		hide_ui()
		hide_skills()
		end_turn_pressed.emit()
		await get_tree().create_timer(END_TURN_DELAY).timeout
		for enemy in enemies:
			if enemy.skill_used == false and enemy.can_attack:
				enemy_skill_use(enemy)
	
		await check_enemy_skills()
		# end of turn keystones
		choosing_skills = false
		set_unit_pos()
		ally_post_status()
		enemy_post_status()
		turn_ended.emit()
		input_allowed = true
		ally_turn_done.emit()
		for enemy in enemies:
			enemy.change_skills()

func show_skills():
	if not tutorial_no_ally_skill:
		if ally1 != null:
			ally1.show_skills()
		if ally2 != null:
			ally2.show_skills()
		if ally3 != null:
			ally3.show_skills()
		if ally4 != null:
			ally4.show_skills()
	
func hide_skills():
	if ally1 != null:
		ally1.hide_skills()
	if ally2 != null:
		ally2.hide_skills()
	if ally3 != null:
		ally3.hide_skills()
	if ally4 != null:
		ally4.hide_skills()
	
func hide_ui():
	end_turn.visible = false
	
func show_ui():
	if (not run.UIManager.reaction_guide_open and not tutorial_no_end_turn):
		end_turn.visible = true
	
	
func choose_target(skill : Skill): 
	if (skill.target_type == "single_enemy" or skill.target_type == "single_ally"):
		var target
		targeting = true
		targeting_skill = skill
		hide_skills()
		Input.set_custom_mouse_cursor(TARGET_CURSOR, 0, Vector2(32,32))
		if (not skill.friendly):
			for enemy in enemies:
				enemy.enable_targeting_area()
			new_spell_selected.emit()
			target = await target_chosen
			for enemy in enemies:
				enemy.disable_targeting_area()
		elif (skill.friendly):
			for ally in allies:
				ally.enable_targeting_area()
			new_spell_selected.emit()
			target = await target_chosen
			for ally in allies:
				ally.disable_targeting_area()
		show_skills()
		show_ui()
		Input.set_custom_mouse_cursor(DEFAULT_CURSOR, 0)
		targeting = false
		return target
		check_requirements()
	else:
		check_requirements()
		return null
	
func target_signal(unit):
	target_chosen.emit(unit)

func _input(event):
	if event.is_action_pressed("1"):
		if (targeting):
			if (not targeting_skill.friendly):
				if enemies.size() >= 1:
					if (enemies[0] != null):
						if enemies[0].targetable == true:
							target_chosen.emit(enemies[0])
			elif (targeting_skill.friendly and targeting):
				if allies.size() >= 1:
					if (allies[0] != null):
						if allies[0].targetable == true:
							target_chosen.emit(allies[0])
	if event.is_action_pressed("2"):
		if (targeting):
			if (not targeting_skill.friendly and targeting):
				if enemies.size() >= 2:
					if (enemies[1] != null):
						if enemies[1].targetable == true:
							target_chosen.emit(enemies[1])
			elif (targeting_skill.friendly and targeting):
				if allies.size() >= 2:
					if (allies[1] != null):
						if allies[1].targetable == true:
							target_chosen.emit(allies[1])
	if event.is_action_pressed("3"):
		if (targeting):
			if (not targeting_skill.friendly and targeting):
				if enemies.size() >= 3:
					if (enemies[2] != null):
						if enemies[2].targetable == true:
							target_chosen.emit(enemies[2])
			elif (targeting_skill.friendly and targeting):
				if allies.size() >= 3:
					if (allies[2] != null):
						if allies[2].targetable == true:
							target_chosen.emit(allies[2])
	if event.is_action_pressed("4"):
		if (targeting):
			if (not targeting_skill.friendly and targeting):
				if enemies.size() >= 4:
					if (enemies[3] != null):
						if enemies[3].targetable == true:
							target_chosen.emit(enemies[3])
			elif (targeting_skill.friendly and targeting):
				if allies.size() >= 4:
					if (allies[3] != null):
						if allies[3].targetable == true:
							target_chosen.emit(allies[3])
	if event.is_action_pressed("end_turn"):
		if (input_allowed):
			_on_end_turn_pressed()
			

	
	
#activate statuses


func enemy_pre_status():
	for enemy in enemies:
		enemy.tick_statuses(true)

func enemy_post_status():
	for enemy in enemies:
		enemy.tick_statuses(false)

func ally_pre_status():
	for ally in allies:
		ally.tick_statuses(true)

func ally_post_status():
	for ally in allies:
		ally.tick_statuses(false)

					
func check_requirements():
	var check = false
	var tokens1 = 0
	var tokens2 = 0

	var run = get_tree().get_first_node_in_group("run")
	for ally in allies:
		if not ally.using_skill and ally.spell_select_ui.disabled_all == false:
			var skill : Skill
			for i in range(1, 5):
				match i:
					1:
						skill = ally.skill_1
					2:
						skill = ally.skill_2
					3:
						skill = ally.skill_3
					4:
						skill = ally.skill_4
				if (skill):
					# Check first cost
					if skill.cost != null:
						match skill.token_type:
							"fire":
								tokens1 = fire_tokens
							"water":
								tokens1 = water_tokens
							"lightning":
								tokens1 = lightning_tokens
							"grass":
								tokens1 = grass_tokens
							"earth":
								tokens1 = earth_tokens

					# Check second cost
					if skill.cost2 != null:
						match skill.token_type2:
							"fire":
								tokens2 = fire_tokens
							"water":
								tokens2 = water_tokens
							"lightning":
								tokens2 = lightning_tokens
							"grass":
								tokens2 = grass_tokens
							"earth":
								tokens2 = earth_tokens

					# Final check for first cost
					if skill.cost != null:
						if skill.cost <= tokens1:
							check = true
						else:
							check = false
							
					if skill.cost2 != null:
						if skill.cost <= tokens1 and skill.cost2 <= tokens2:
							check = true
						else:
							check = false
					if skill.cost > 0 or skill.cost2 > 0:
						if check:
							ally.spell_select_ui.enable(i)
						else:
							ally.spell_select_ui.disable(i)
					else:
						ally.spell_select_ui.enable(i)


#had deepseek help improve my code, might be buggy
func set_unit_pos():
	# Clear previous data
	middle_allies.clear()
	enemies.clear()
	allies.clear()

	# Add enemies and assign positions
	for i in range(1, 5):
		var enemy = get("enemy" + str(i))
		if enemy != null:
			enemies.append(enemy)
			enemy.position = i

	# Add allies and assign positions
	for i in range(1, 5):
		var ally = get("ally" + str(i))
		if ally != null:
			allies.append(ally)
			ally.position = i

	# Link enemies and allies (left and right)
	link_units(enemies)
	link_units(allies)

	# Determine front and back units
	front_enemy = enemies[0] if enemies.size() > 0 else null
	back_enemy = enemies[enemies.size() - 1] if enemies.size() > 0 else null
	front_enemy_2 = enemies[1] if enemies.size() > 1 else null
	back_enemy_2 = enemies[enemies.size() - 2] if enemies.size() > 1 else null

	front_ally = allies[allies.size() - 1] if allies.size() > 0 else null
	back_ally = allies[0] if allies.size() > 0 else null

	# Assign Front Ally 2 and Back Ally 2
	front_ally_2 = null
	back_ally_2 = null

	if allies.size() > 1:
		front_ally_2 = allies[allies.size() - 2]  # Ally directly behind Front Ally
		back_ally_2 = allies[1]  # Ally directly in front of Back Ally

	# Handle special case for 2 allies
	if allies.size() == 2:
		front_ally_2 = back_ally  # Back Ally is also Front Ally 2
		back_ally_2 = front_ally  # Front Ally is also Back Ally 2

	# Determine middle allies based on the number of allies
	match allies.size():
		1:
			middle_allies.append(allies[0])  # Only ally is added to middle_allies
		2:
			middle_allies.append(allies[0])
			middle_allies.append(allies[1])
		3:
			middle_allies.append(allies[1])
		4:
			middle_allies.append(allies[1])
			middle_allies.append(allies[2])

# Helper function to link units (left and right)
func link_units(units):
	for i in range(units.size()):
		if i > 0:
			units[i].left = units[i - 1]
		else:
			units[i].left = null

		if i < units.size() - 1:
			units[i].right = units[i + 1]
		else:
			units[i].right = null

func compute_token_amount(base, bonus, caster_bonus, mult, caster):
	if caster is Enemy:
		return 1 + caster_bonus
	return (base + bonus + caster_bonus) * mult


func vaporize(unit, caster, element):
	add_token("fire",
		compute_token_amount(
			run.vaporize_fire_token_base,
			run.vaporize_fire_token_bonus,
			caster.fire_token_bonus,
			run.vaporize_fire_token_mult,
			caster
		),
		caster
	)
	reaction_triggered.emit(1, "vaporize")

	add_token("water",
		compute_token_amount(
			run.vaporize_water_token_base,
			run.vaporize_water_token_bonus,
			caster.water_token_bonus,
			run.vaporize_water_token_mult,
			caster
		),
		caster
	)

	if run.steamer:
		if element == "fire":
			unit.current_element = "water"
		elif element == "water":
			unit.current_element = "fire"


func shock(unit, caster):
	add_token("lightning",
		compute_token_amount(
			run.shock_lightning_token_base,
			run.shock_lightning_token_bonus,
			caster.lightning_token_bonus,
			run.shock_lightning_token_mult,
			caster
		),
		caster
	)

	add_token("water",
		compute_token_amount(
			run.shock_water_token_base,
			run.shock_water_token_bonus,
			caster.water_token_bonus,
			run.shock_water_token_mult,
			caster
		),
		caster
	)


func detonate(unit, caster):
	add_token("fire",
		compute_token_amount(
			run.detonate_fire_token_base,
			run.detonate_fire_token_bonus,
			caster.fire_token_bonus,
			run.detonate_fire_token_mult,
			caster
		),
		caster
	)

	add_token("lightning",
		compute_token_amount(
			run.detonate_lightning_token_base,
			run.detonate_lightning_token_bonus,
			caster.lightning_token_bonus,
			run.detonate_lightning_token_mult,
			caster
		),
		caster
	)


func erupt(unit, caster):
	add_token("fire",
		compute_token_amount(
			run.erupt_fire_token_base,
			run.erupt_fire_token_bonus,
			caster.fire_token_bonus,
			run.erupt_fire_token_mult,
			caster
		),
		caster
	)

	add_token("earth",
		compute_token_amount(
			run.erupt_earth_token_base,
			run.erupt_earth_token_bonus,
			caster.earth_token_bonus,
			run.erupt_earth_token_mult,
			caster
		),
		caster
	)


func bloom(unit, caster):
	add_token("water",
		compute_token_amount(
			run.bloom_water_token_base,
			run.bloom_water_token_bonus,
			caster.water_token_bonus,
			run.bloom_water_token_mult,
			caster
		),
		caster
	)

	add_token("grass",
		compute_token_amount(
			run.bloom_grass_token_base,
			run.bloom_grass_token_bonus,
			caster.grass_token_bonus,
			run.bloom_grass_token_mult,
			caster
		),
		caster
	)


func burn(unit, caster):
	add_token("fire",
		compute_token_amount(
			run.burn_fire_token_base,
			run.burn_fire_token_bonus,
			caster.fire_token_bonus,
			run.burn_fire_token_mult,
			caster
		),
		caster
	)

	add_token("grass",
		compute_token_amount(
			run.burn_grass_token_base,
			run.burn_grass_token_bonus,
			caster.grass_token_bonus,
			run.burn_grass_token_mult,
			caster
		),
		caster
	)


func nitro(unit, caster):
	add_token("grass",
		compute_token_amount(
			run.nitro_grass_token_base,
			run.nitro_grass_token_bonus,
			caster.grass_token_bonus,
			run.nitro_grass_token_mult,
			caster
		),
		caster
	)

	add_token("lightning",
		compute_token_amount(
			run.nitro_lightning_token_base,
			run.nitro_lightning_token_bonus,
			caster.lightning_token_bonus,
			run.nitro_lightning_token_mult,
			caster
		),
		caster
	)


func muck(unit, caster):
	add_token("water",
		compute_token_amount(
			run.muck_water_token_base,
			run.muck_water_token_bonus,
			caster.water_token_bonus,
			run.muck_water_token_mult,
			caster
		),
		caster
	)

	add_token("earth",
		compute_token_amount(
			run.muck_earth_token_base,
			run.muck_earth_token_bonus,
			caster.earth_token_bonus,
			run.muck_earth_token_mult,
			caster
		),
		caster
	)


func discharge(unit, caster):
	add_token("earth",
		compute_token_amount(
			run.discharge_earth_token_base,
			run.discharge_earth_token_bonus,
			caster.earth_token_bonus,
			run.discharge_earth_token_mult,
			caster
		),
		caster
	)

	add_token("lightning",
		compute_token_amount(
			run.discharge_lightning_token_base,
			run.discharge_lightning_token_bonus,
			caster.lightning_token_bonus,
			run.discharge_lightning_token_mult,
			caster
		),
		caster
	)

	if run.discharge_destruction:
		for enemy in enemies:
			enemy.take_damage(5 * run.discharge_mult, "neutral", false)


func sow(unit, caster):
	add_token("earth",
		compute_token_amount(
			run.sow_earth_token_base,
			run.sow_earth_token_bonus,
			caster.earth_token_bonus,
			run.sow_earth_token_mult,
			caster
		),
		caster
	)

	add_token("grass",
		compute_token_amount(
			run.sow_grass_token_base,
			run.sow_grass_token_bonus,
			caster.grass_token_bonus,
			run.sow_grass_token_mult,
			caster
		),
		caster
	)


func ally_bloom_burst():
	for ally in allies:
		ally.receive_healing(run.ally_bloom_healing, "grass", false)

func enemy_bloom_burst():
	for enemy in enemies:
		enemy.receive_healing(run.enemy_bloom_healing, "grass", false)
	
func add_token(element, count, caster):
	var is_enemy = caster is Enemy
	var tokens_gained = 0
	var offset = Vector2(-30, 80)
	AudioPlayer.play_FX("coin", -8)
	match element:

		"fire":
			tokens_gained = (count + run.fire_token_bonus) * run.fire_token_multiplier
			if is_enemy:
				enemy_fire_tokens += int(tokens_gained)
				DamageNumbers.display_text(
					enemy_combat_currency.fire_count.global_position + offset,
					"fire",
					"+" + str(int(tokens_gained)),
					24,
					false
				)
			else:
				fire_tokens += int(tokens_gained)
				print(str(combat_currency.fire_count.global_position + offset))
				DamageNumbers.display_text(
					combat_currency.fire_count.global_position + offset,
					"fire",
					"+" + str(int(tokens_gained)),
					24,
					false
				)

		"water":
			tokens_gained = (count + run.water_token_bonus) * run.water_token_multiplier
			if is_enemy:
				enemy_water_tokens += int(tokens_gained)
				DamageNumbers.display_text(
					enemy_combat_currency.water_count.global_position + offset,
					"water",
					"+" + str(int(tokens_gained)),
					24,
					false
				)
			else:
				water_tokens += int(tokens_gained)
				print(str(combat_currency.water_count.global_position + offset) )
				DamageNumbers.display_text(
					combat_currency.water_count.global_position + offset,
					"water",
					"+" + str(int(tokens_gained)),
					24,
					false
				)

		"lightning":
			tokens_gained = (count + run.lightning_token_bonus) * run.lightning_token_multiplier
			if is_enemy:
				enemy_lightning_tokens += int(tokens_gained)
				DamageNumbers.display_text(
					enemy_combat_currency.lightning_count.global_position + offset,
					"lightning",
					"+" + str(int(tokens_gained)),
					24,
					false
				)
			else:
				lightning_tokens += int(tokens_gained)
				DamageNumbers.display_text(
					combat_currency.lightning_count.global_position + offset,
					"lightning",
					"+" + str(int(tokens_gained)),
					24,
					false
				)

		"grass":
			tokens_gained = (count + run.grass_token_bonus) * run.grass_token_multiplier
			if is_enemy:
				enemy_grass_tokens += int(tokens_gained)
				DamageNumbers.display_text(
					enemy_combat_currency.grass_count.global_position + offset,
					"grass",
					"+" + str(int(tokens_gained)),
					24,
					false
				)
			else:
				grass_tokens += int(tokens_gained)
				DamageNumbers.display_text(
					combat_currency.grass_count.global_position + offset,
					"grass",
					"+" + str(int(tokens_gained)),
					24,
					false
				)

		"earth":
			tokens_gained = (count + run.earth_token_bonus) * run.earth_token_multiplier
			if is_enemy:
				enemy_earth_tokens += int(tokens_gained)
				DamageNumbers.display_text(
					enemy_combat_currency.earth_count.global_position + offset,
					"earth",
					"+" + str(int(tokens_gained)),
					24,
					false
				)
			else:
				earth_tokens += int(tokens_gained)
				DamageNumbers.display_text(
					combat_currency.earth_count.global_position + offset,
					"earth",
					"+" + str(int(tokens_gained)),
					24,
					false
				)




func reset_tokens():
	fire_tokens = 0
	water_tokens = 0
	lightning_tokens = 0
	earth_tokens = 0
	grass_tokens = 0

func hide_tokens():
	combat_currency.visible = false
	enemy_combat_currency.visible = false
	
func hide_end_turn():
	end_turn.visible = false
	
func hide_reaction_guide_button():
	run.reaction_guide_button.visible = false
	
func hide_win():
	win.visible = false

func show_end_turn():
	end_turn.visible = true

#tutorial
signal next_popup
signal reaction_guide_button_pressed
@onready var tutorial_highlight: CanvasLayer = $"../Tutorial/TutorialHighlight"
@onready var tutorial_highlight_dim: ColorRect = $"../Tutorial/TutorialHighlight/ColorRect"

@onready var popup_1: Control = $"../Tutorial/Tutorial1/Popup1"
@onready var popup_2: Control = $"../Tutorial/Tutorial1/Popup2"
@onready var popup_3: Control = $"../Tutorial/Tutorial1/Popup3"
@onready var popup_3_2_5: Control = $"../Tutorial/Tutorial1/Popup3_2_5"
@onready var popup_3_2_6: Control = $"../Tutorial/Tutorial1/Popup3_2_6"
@onready var popup_3_5: Control = $"../Tutorial/Tutorial1/Popup3_5"
@onready var popup_4: Control = $"../Tutorial/Tutorial1/Popup4"
@onready var popup_5: Control = $"../Tutorial/Tutorial1/Popup5"
@onready var popup_6: Control = $"../Tutorial/Tutorial1/Popup6"
@onready var popup_7: Control = $"../Tutorial/Tutorial1/Popup7"
@onready var popup_8: Control = $"../Tutorial/Tutorial1/Popup8"

@onready var popup_9: Control = $"../Tutorial/Tutorial2/Popup9"
@onready var popup_10: Control = $"../Tutorial/Tutorial2/Popup10"
@onready var popup_11: Control = $"../Tutorial/Tutorial2/Popup11"
@onready var popup_13: Control = $"../Tutorial/Tutorial2/Popup13"
@onready var popup_14: Control = $"../Tutorial/Tutorial2/Popup14"
@onready var popup_15: Control = $"../Tutorial/Tutorial2/Popup15"
@onready var popup_16: Control = $"../Tutorial/Tutorial2/Popup16"
@onready var popup_17: Control = $"../Tutorial/Tutorial2/Popup17"
@onready var popup_18: Control = $"../Tutorial/Tutorial2/Popup18"
@onready var popup_19: Control = $"../Tutorial/Tutorial2/Popup19"
@onready var popup_20: Control = $"../Tutorial/Tutorial2/Popup20"
@onready var popup_21: Control = $"../Tutorial/Tutorial2/Popup21"
@onready var popup_22: Control = $"../Tutorial/Tutorial2/Popup22"
@onready var popup_23: Control = $"../Tutorial/Tutorial2/Popup23"
@onready var popup_24: Control = $"../Tutorial/Tutorial2/Popup24"



func start_tutorial():
	run = get_tree().get_first_node_in_group("run")
	hide_tokens()
	hide_end_turn()
	hide_reaction_guide_button()
	hide_win()
	tutorial_no_end_turn = true
	auto_end_turn = false
	enemy1.can_attack = false
	enemy1.update_countdown_label()
	ally1.hide_skills()
	popup_1.visible = true
	await next_popup
	ally1.show_skills()
	await get_tree().create_timer(0.1).timeout
	popup_2.visible = true
	tutorial_highlight.visible = true
	tutorial_highlight_dim.highlight_nodes([ally1.spell_select_ui.ba_1, popup_2.get_child(0)], 1.0)
	await skill_selected
	popup_2.visible = false
	tutorial_highlight.visible = false
	await get_tree().create_timer(0.1).timeout
	popup_3.visible = true
	tutorial_highlight.visible = true
	
	tutorial_highlight_dim.highlight_nodes([enemy1.sprite_spot, popup_3.get_child(0)], 1.0)
	await target_selected
	tutorial_highlight.visible = false
	popup_3.visible = false
	popup_3_2_5.visible = true
	await next_popup
	popup_3_2_5.visible = false
	popup_3_2_6.visible = true
	await next_popup
	popup_3_5.visible = true
	tutorial_highlight.visible = true
	show_end_turn()
	tutorial_highlight_dim.highlight_nodes([popup_3_5.get_child(0), end_turn], 1.0)
	tutorial_no_ally_skill = true
	await end_turn_pressed
	popup_3_5.visible = false
	tutorial_highlight.visible = false
	popup_4.visible = true
	ally1.hide_skills()
	await next_popup
	popup_5.visible = true
	enemy1.can_attack = true
	enemy1.set_countdown()
	tutorial_highlight.visible = true
	tutorial_highlight_dim.highlight_nodes([enemy1.countdown_label, enemy1.skill_info.get_child(0), enemy1.next_skill_label, popup_5.get_child(0)], 1.0)
	await next_popup
	ally1.show_skills()
	tutorial_no_ally_skill = false
	popup_6.visible = true
	tutorial_highlight_dim.highlight_nodes([ally1.spell_select_ui.ba_1, popup_6.get_child(0)], 1.0)
	await skill_selected
	tutorial_highlight_dim.highlight_nodes([popup_6.get_child(0), enemy1.sprite_spot], 1.0)
	await target_selected
	popup_6.visible = false
	popup_7.visible = true
	tutorial_highlight_dim.highlight_nodes([popup_7.get_child(0)], 1.0)
	await next_popup
	popup_7.visible = false
	popup_8.visible = true
	tutorial_highlight_dim.highlight_nodes([popup_8.get_child(0)], 1.0)
	await next_popup
	var tutorial_node = get_tree().get_first_node_in_group("tutorial")
	tutorial_node.tutorial_2()
	
	
func start_tutorial2():
	run = get_tree().get_first_node_in_group("run")
	tutorial_no_end_turn = true
	tutorial_highlight.visible = true
	popup_9.visible = true
	tutorial_highlight_dim.highlight_nodes([popup_9.get_child(0), ally1.spell_select_ui.ba_1], 1.0)
	ally2.spell_select_ui.disable(1)
	enemy2.targetable = false
	await skill_selected
	tutorial_highlight_dim.highlight_nodes([popup_9.get_child(0), enemy1.sprite_spot], 1.0)
	await target_selected
	skills_castable = false
	ally2.spell_select_ui.disable(1)
	popup_9.visible = false
	popup_10.visible = true
	tutorial_highlight_dim.highlight_nodes([popup_10.get_child(0), enemy1.hp_bar.current_element], 1.0)
	await next_popup
	ally2.spell_select_ui.disable(1)
	popup_10.visible = false
	popup_11.visible = true
	tutorial_highlight_dim.highlight_nodes([popup_11.get_child(0), run.reaction_guide_button], 1.0)
	await reaction_guide_button_pressed
	await get_tree().create_timer(0.05).timeout
	popup_11.visible = false
	popup_13.visible = true
	tutorial_highlight_dim.highlight_nodes([popup_13.get_child(0), run.reaction_panel.vaporize_row], 1.0)
	await next_popup
	popup_13.visible = false
	popup_14.visible = true
	tutorial_highlight_dim.highlight_nodes([popup_14.get_child(0), run.reaction_panel.fire_vaporize_tokens], 1.0)
	await next_popup
	popup_14.visible = false
	popup_15.visible = true
	tutorial_highlight_dim.highlight_nodes([popup_15.get_child(0), run.reaction_guide_button], 1.0)
	await reaction_guide_button_pressed
	skills_castable = true
	ally2.spell_select_ui.enable(1)
	enemy2.targetable = true
	popup_15.visible = false
	popup_16.visible = true
	tutorial_highlight_dim.highlight_nodes([popup_16.get_child(0), ally2.spell_select_ui.ba_1], 1.0)
	await skill_selected
	tutorial_highlight_dim.highlight_nodes([popup_16.get_child(0), enemy1.sprite_spot], 1.0)
	await target_selected
	skills_castable = false
	popup_16.visible = false
	popup_17.visible = true
	tutorial_highlight_dim.highlight_nodes([popup_17.get_child(0)], 1.0)
	await next_popup
	popup_17.visible = false
	popup_18.visible = true
	tutorial_highlight_dim.highlight_nodes([popup_18.get_child(0), combat_currency], 1.0)
	await next_popup
	popup_18.visible = false
	popup_19.visible = true
	tutorial_highlight_dim.highlight_nodes([popup_19.get_child(0), ally1.spell_select_ui.s_1], 1.0)
	await next_popup
	popup_19.visible = false
	popup_20.visible = true
	tutorial_highlight_dim.highlight_nodes([popup_20.get_child(0), ally1.spell_select_ui.s_1], 1.0)
	await next_popup
	popup_20.visible = false
	popup_21.visible = true
	skills_castable = true
	ally1.spell_select_ui.disable(1)
	ally1.spell_select_ui.disable(2)
	enemy1.targetable = false
	tutorial_highlight_dim.highlight_nodes([popup_21.get_child(0), ally2.spell_select_ui.ba_1], 1.0)
	await skill_selected
	tutorial_highlight_dim.highlight_nodes([popup_21.get_child(0), enemy2.sprite_spot], 1.0)
	await target_selected
	popup_21.visible = false
	popup_22.visible = true
	ally1.spell_select_ui.reset()
	ally1.spell_select_ui.disable(1)
	ally1.spell_select_ui.enable(2)
	tutorial_highlight_dim.highlight_nodes([popup_22.get_child(0), ally1.spell_select_ui.s_1], 1.0)
	await skill_selected
	popup_22.visible = false
	popup_23.visible = true
	tutorial_highlight_dim.highlight_nodes([popup_23.get_child(0)], 1.0)
	await next_popup
	popup_23.visible = false
	popup_24.visible = true
	tutorial_highlight_dim.highlight_nodes([popup_24.get_child(0)], 1.0)
	await next_popup
	var tutorial_node = get_tree().get_first_node_in_group("tutorial")
	tutorial_node.game.new_scene(tutorial_node.game.MAIN_SCENE)
	

func reaction_guide_opened():
	reaction_guide_button_pressed.emit()

func pop_up_button_pressed():
	next_popup.emit()


func _on_character_ult_animation_ult_anim_done() -> void:
	ult_anim_done.emit()

func resolve_targets(target_type: String) -> Array:
	var result: Array = []

	match target_type:
		"single_enemy", "front_enemy":
			if front_enemy != null:
				result.append(front_enemy)

		"single_ally", "front_ally":
			if front_ally != null:
				result.append(front_ally)

		"all_enemies":
			result = enemies.duplicate()

		"all_allies":
			result = allies.duplicate()

		"all_units":
			result = allies.duplicate()
			result.append_array(enemies)

		"front_2_enemies":
			if front_enemy != null:
				result.append(front_enemy)
			if front_enemy_2 != null:
				result.append(front_enemy_2)

		"back_enemy":
			if back_enemy != null:
				result.append(back_enemy)

		"back_2_enemies":
			if back_enemy != null:
				result.append(back_enemy)
			if back_enemy_2 != null:
				result.append(back_enemy_2)

		"front_2_allies":
			if front_ally != null:
				result.append(front_ally)
			if front_ally_2 != null:
				result.append(front_ally_2)

		"back_ally":
			if back_ally != null:
				result.append(back_ally)

		"back_2_allies":
			if back_ally != null:
				result.append(back_ally)
			if back_ally_2 != null:
				result.append(back_ally_2)

		"random_enemy":
			if enemies.size() > 0:
				result.append(enemies.pick_random())

		"random_ally":
			if allies.size() > 0:
				result.append(allies.pick_random())

		"random_middle_ally":
			if middle_allies.size() > 0:
				result.append(middle_allies.pick_random())

	return result.filter(func(u): return u != null)

func load_triggers() -> void:
	var trigger_manager := %TriggerManager
	
	for keystone in run.keystones:
		for trigger in keystone.triggers:
				if trigger == null or trigger.conditions == null:
					continue

				trigger_manager.triggers.append(trigger)
				
	for ally in allies:
		if ally == null:
			continue

		for item in ally.items:
			if item == null:
				continue

			for trigger in item.triggers:
				if trigger == null or trigger.conditions == null:
					continue

				trigger.caster = ally
				trigger_manager.triggers.append(trigger)
