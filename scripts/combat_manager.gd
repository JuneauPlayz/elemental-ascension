extends Node

@onready var turn_text: Label = $TurnText
@onready var combat_currency: Control = $CombatCurrency

const COMBAT_SIM = preload("res://combat_sim.tscn")

@export var ally1 : Ally
@export var ally2 : Ally
@export var ally3 : Ally
@export var ally4 : Ally
@export var allies : Array = []
var front_ally : Ally
var back_ally : Ally

@export var enemy1 : Enemy
@export var enemy2 : Enemy
@export var enemy3 : Enemy
@export var enemy4 : Enemy
@export var enemies : Array = []
var front_enemy : Enemy
var back_enemy : Enemy

var ally_list = [ally1, ally2, ally3, ally4]
var enemy_list = [enemy1, enemy2]

@export var action_queue = []
var choosing_skills = false
# parallel array for targets
@export var target_queue = []
var targeting = false

var targeting_skill : Skill
# parallel array for allies
@export var ally_queue = []

@onready var end_turn: Button = $"../EndTurn"
@onready var reset_choices: Button = $"../ResetChoices"
@onready var targeting_label: Label = $TargetingLabel
@onready var targeting_skill_info: Control = $TargetingSkillInfo
@onready var relics : RelicHandler
@onready var victory_screen: Control = $"../VictoryScreen"
@onready var win: Button = $"../Win"

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

var p_fire_tokens = 0
var p_water_tokens =0
var p_lightning_tokens = 0
var p_grass_tokens = 0
var p_earth_tokens = 0

var sim_fire_tokens = 0
var sim_water_tokens = 0
var sim_lightning_tokens = 0
var sim_grass_tokens = 0
var sim_earth_tokens = 0

const TARGET_CURSOR = preload("res://assets/target cursor.png")
const DEFAULT_CURSOR = preload("res://assets/defaultcursor.png")



signal ally_turn_done
signal enemy_turn_done
signal new_spell_selected
signal target_selected
signal target_chosen

var combat_finished = false
var first_turn = true
var victorious = false
var xp_reward
signal combat_ended
signal hit
signal signal_received
signal reaction_finished

var run
var sim
var prev_sim
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
	# relic stuff
	run.relic_handler.relics_activated.connect(_on_relics_activated)
	run.relic_handler.activate_relics_by_type(Relic.Type.START_OF_COMBAT)
	combat_currency.update()


func start_combat():
	combat_currency.update()
	reset_skill_select()
	check_requirements()
	show_skills()
	while (!combat_finished):
		start_ally_turn()
		await ally_turn_done
		enemy_turn()
		await enemy_turn_done

func end_battle():
	pass
	
func start_ally_turn():
	set_unit_pos()
	show_ui()
	update_tokens()
	turn_text.text = "Ally Turn"
	ally_pre_status()
	lose_shields()
	show_skills()
	reset_skill_select()
	check_requirements()
	update_skill_positions()
	choosing_skills = true

	
func execute_ally_turn():
	# skill execution
	if ally_queue != []:
		ally_queue[0].attack_animation()
	await get_tree().create_timer(0.15).timeout
	for n in range(action_queue.size()):
		if (action_queue.size() == 0):
			continue
		var skill = action_queue[n]
		var target = target_queue[n]
		var ally = ally_queue[n]
		use_skill(skill,target,ally,true,true)
		update_tokens()
		combat_currency.update()
		# checks if target is dead, currently skips the rest of the loop (wont print landed)
		if (target == null or target.visible == false):
			await get_tree().create_timer(0.1).timeout
			continue
		await reaction_finished
		print(str(skill.name) + " landed!")
		hit.emit()
		if ally_queue.size() > n+1:
			ally_queue[n+1].attack_animation()
		await get_tree().create_timer(GC.GLOBAL_INTERVAL+0.05).timeout
		# for sow only
		for stati in target.status:
			if stati.unique_type == "sow":
				target.sow = true
	await get_tree().create_timer(1).timeout
	reset_sim()
	ally_post_status()
	if enemies.is_empty():
		victory()
	else:
		turn_text.text = "Enemy Turn"
		ally_turn_done.emit()

func enemy_turn():
	await get_tree().create_timer(0.25).timeout
	enemy_pre_status()
	await get_tree().create_timer(0.15).timeout
	enemy_lose_shields()
	if enemies != []:
		enemies[0].attack_animation()
	await get_tree().create_timer(0.15).timeout
	for i in range(enemies.size()):
		var enemy = enemies[i]
		print("using enemy skill")
		set_unit_pos()
		use_skill(enemy.current_skill,null,enemy,true,false)
		hit.emit()
		enemy.change_skills()
		if enemies.size() > i+1:
			enemies[i+1].attack_animation()
		await get_tree().create_timer(GC.GLOBAL_INTERVAL+0.05).timeout
	await get_tree().create_timer(0.1).timeout
	enemy_post_status()
	await get_tree().create_timer(0.3).timeout
	if allies.is_empty():
		defeat()
	if enemies.is_empty():
		victory()
	else:
		enemy_turn_done.emit()

func check_event_relics(skill,unit,value_multiplier,target):
	if (run.ghostfire and unit is Ally and skill.element == "fire"):
		if (skill.target_type == "single_enemy" or skill.target_type == "back_enemy" or skill.target_type == "front_enemy"):
			await get_tree().create_timer(0.1).timeout
			var rng = RandomNumberGenerator.new()
			var random_num = rng.randi_range(1,enemies.size())
			match random_num:
				1:
					enemies[0].receive_skill(skill,unit,value_multiplier)
				2:
					enemies[1].receive_skill(skill,unit,value_multiplier)
				3:
					enemies[2].receive_skill(skill,unit,value_multiplier)
				4:
					enemies[3].receive_skill(skill,unit,value_multiplier)
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
	victory_screen.continue_pressed.connect(self.finish_battle)

func defeat():
	win.visible = false
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
		run.add_gold(run.current_reward)
		if run.end:
			run.increase_xp(xp_reward)
			combat_ended.emit("")
		else:
			for ally in allies:
				ally.spell_select_ui.new_select.disconnect(run.combat_manager._on_spell_select_ui_new_select)
			run.increase_xp(xp_reward)
			combat_ended.emit("")
	if not victorious:
		run.reset()
		get_tree().change_scene_to_file("res://scenes/main scenes/main_scene.tscn")

func reset_combat():
	allies = []
	enemies = []
	reset_tokens()
	victory_screen.visible = false
	
func use_skill(skill,target,unit,event,spend_tokens):
	if allies == []:
		defeat()
	if enemies == []:
		victory()
	skill.update()
	var value_multiplier = 1
	# token spending
	if unit.muck == true:
		unit.muck = false
		value_multiplier = run.muck_mult
		for stati in unit.status:
			if stati.name == "Muck":
				unit.status.erase(stati)
				unit.hp_bar.update_statuses(unit.status)
				DamageNumbers.display_text(unit.damage_number_origin.global_position, "none", "wash", 32)
	if event:
		check_event_relics(skill,unit,value_multiplier,target)
	if (skill.cost > 0 or skill.cost2 > 0) and spend_tokens == true:
			spend_skill_cost(skill)
	if target != null and not skill.friendly:
		target.receive_skill(skill,unit,value_multiplier)
	else:
		if (skill.target_type == "front_ally" and front_ally != null):
			front_ally.receive_skill(skill,unit,value_multiplier)
		elif (skill.target_type == "front_enemy" and front_enemy != null):
			front_enemy.receive_skill(skill,unit,value_multiplier)
		elif (skill.target_type == "back_ally" and back_ally != null):
			back_ally.receive_skill(skill,unit,value_multiplier)
		elif (skill.target_type == "back_enemy" and back_enemy != null):
			back_enemy.receive_skill(skill,unit,value_multiplier)
		elif (skill.target_type == "single_ally" and skill.friendly and target != null):
			target.receive_skill_friendly(skill,unit,value_multiplier)
		elif (skill.target_type == "random_enemy" and enemies.size() > 0):
			var rng = RandomNumberGenerator.new()
			var random_num = rng.randi_range(1,enemies.size())
			match random_num:
				1:
					enemies[0].receive_skill(skill,unit,value_multiplier)
				2:
					enemies[1].receive_skill(skill,unit,value_multiplier)
				3:
					enemies[2].receive_skill(skill,unit,value_multiplier)
				4:
					enemies[3].receive_skill(skill,unit,value_multiplier)
		elif (skill.target_type == "random_ally"):
			var rng = RandomNumberGenerator.new()
			var random_num = rng.randi_range(1,allies.size())
			match random_num:
				1:
					allies[0].receive_skill(skill,unit,value_multiplier)
				2:
					allies[1].receive_skill(skill,unit,value_multiplier)
				3:
					allies[2].receive_skill(skill,unit,value_multiplier)
				4:
					allies[3].receive_skill(skill,unit,value_multiplier)
		elif (target == null):
			if (skill.target_type == "all_allies" and allies.size() > 0):
				if (skill.friendly == true):
					for ally in allies:
						ally.receive_skill_friendly(skill,unit,value_multiplier)
				else:
					for ally in allies:
						ally.receive_skill(skill,unit,value_multiplier)
						#print(ally.title + " taking " + str(skill.damage) + " damage from " + unit.title)
			elif (skill.target_type == "all_enemies" and allies.size() > 0):
				if (skill.friendly == true):
					for enemy in enemies:
						enemy.receive_skill_friendly(skill,unit,value_multiplier)
				else:
					for enemy in enemies:
						enemy.receive_skill(skill,unit,value_multiplier)
			elif (skill.target_type == "all_units" and allies.size() > 0 and enemies.size() > 0):
				if (skill.friendly == true):
					for enemy in enemies:
						enemy.receive_skill_friendly(skill,unit,value_multiplier)
					for ally in allies:
						ally.receive_skill_friendly(skill,unit,value_multiplier)
				else:
					for enemy in enemies:
						enemy.receive_skill(skill,unit,value_multiplier)
					for ally in allies:
						ally.receive_skill(skill,unit,value_multiplier)
	if (skill.lifesteal):
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
	combat_currency.update()

func p_spend_skill_cost(skill, ally):
	var tokens1 = 0
	var tokens2 = 0
	print("spending tokens")
	if skill.cost > 0:
		match skill.token_type:
			"fire":
				p_fire_tokens -= skill.cost
				ally.spent_tokens_type = "fire"
				ally.spent_tokens = skill.cost
			"water":
				p_water_tokens -= skill.cost
				ally.spent_tokens_type = "water"
				ally.spent_tokens = skill.cost
			"lightning":
				p_lightning_tokens -= skill.cost
				ally.spent_tokens_type = "lightning"
				ally.spent_tokens = skill.cost
			"grass":
				p_grass_tokens -= skill.cost
				ally.spent_tokens_type = "grass"
				ally.spent_tokens = skill.cost
			"earth":
				p_earth_tokens -= skill.cost
				ally.spent_tokens_type = "earth"
				ally.spent_tokens = skill.cost
	if skill.cost2 > 0:
		match skill.token_type2:
			"fire":
				p_fire_tokens -= skill.cost2
				ally.spent_tokens_type_2 = "fire"
				ally.spent_tokens_2 = skill.cost2
			"water":
				p_water_tokens -= skill.cost2
				ally.spent_tokens_type_2 = "water"
				ally.spent_tokens_2 = skill.cost2
			"lightning":
				p_lightning_tokens -= skill.cost2
				ally.spent_tokens_type_2 = "lightning"
				ally.spent_tokens_2 = skill.cost2
			"grass":
				p_grass_tokens -= skill.cost2
				ally.spent_tokens_type_2 = "grass"
				ally.spent_tokens_2 = skill.cost2
			"earth":
				p_earth_tokens -= skill.cost2
				ally.spent_tokens_type_2 = "earth"
				ally.spent_tokens_2 = skill.cost2
	combat_currency.update()

func update_tokens():
	p_fire_tokens = fire_tokens
	p_water_tokens = water_tokens
	p_lightning_tokens = lightning_tokens
	p_earth_tokens = earth_tokens
	p_grass_tokens = grass_tokens
	combat_currency.update()

func _on_relics_activated(type : Relic.Type) -> void:
	match type:
		Relic.Type.START_OF_COMBAT:
			start_combat()
		Relic.Type.END_OF_COMBAT:
			victory()
		Relic.Type.END_OF_TURN:
			execute_ally_turn()
		
			
func reaction_signal():
	print("reaction_signal")
	await get_tree().create_timer(0.01).timeout
	# update currency ui
	combat_currency.update()
	reaction_finished.emit()
	
func lose_shields():
	for ally in allies:
		ally.set_shield(0)
		
func enemy_lose_shields():
	for enemy in enemies:
		enemy.set_shield(0)
	
# char 1
func _on_spell_select_ui_new_select(ally) -> void:
	var spell_select_ui: Control = ally.get_spell_select()
	var change = false
	var ally_pos = 0
	var allyskill = 0
	match ally.position:
		1:
			allyskill = ally1skill
			ally_pos = ally1_pos
		2:
			allyskill = ally2skill
			ally_pos = ally2_pos
		3:
			allyskill = ally3skill
			ally_pos = ally3_pos
		4:
			allyskill = ally4skill
			ally_pos = ally4_pos

	# if selecting something when not already selected on that character
	if (spell_select_ui.selected != 0 and allyskill == -1):
		ally_pos = next_pos
		next_pos += 1
		spell_select_ui.update_pos(ally_pos + 1)
	# if changing selection and not unselecting
	if (allyskill != -1 and spell_select_ui.selected != 0):
		action_queue.remove_at(ally_pos)
		target_queue.remove_at(ally_pos)
		ally_queue.remove_at(ally_pos)
		spell_select_ui.update_pos(0)
		change = true
	allyskill = spell_select_ui.selected
	ally.unspend_tokens()
	match spell_select_ui.selected:
		# if unselecting
		0:
			next_pos -= 1
			action_queue.remove_at(ally_pos)
			target_queue.remove_at(ally_pos)
			ally_queue.remove_at(ally_pos)
			update_positions(ally_pos)
			ally_pos = -1
			update_skill_positions()
			spell_select_ui.update_pos(0)
			allyskill = -1
			ally.using_skill = false
			combat_currency.update()
		1:
			if change:
				action_queue.insert(ally_pos,ally.basic_atk)
				target_queue.insert(ally_pos,await choose_target(ally.basic_atk))
				ally_queue.insert(ally_pos,ally)
			else:
				action_queue.append(ally.basic_atk)
				target_queue.append(await choose_target(ally.basic_atk))
				ally_queue.append(ally)
			p_spend_skill_cost(ally.basic_atk, ally)
			ally.using_skill = true
		2:
			if change:
				action_queue.insert(ally_pos,ally.skill_1)
				target_queue.insert(ally_pos,await choose_target(ally.skill_1))
				ally_queue.insert(ally_pos,ally)
			else:
				action_queue.append(ally.skill_1)
				target_queue.append(await choose_target(ally.skill_1))
				ally_queue.append(ally)
			p_spend_skill_cost(ally.skill_1, ally)
			ally.using_skill = true
		3:
			if change:
				action_queue.insert(ally_pos,ally.skill_2)
				target_queue.insert(ally_pos,await choose_target(ally.skill_2))
				ally_queue.insert(ally_pos,ally)
			else:
				action_queue.append(ally.skill_2)
				target_queue.append(await choose_target(ally.skill_2))
				ally_queue.append(ally)
			p_spend_skill_cost(ally.skill_2, ally)
			ally.using_skill = true
		4:
			if change:
				action_queue.insert(ally_pos,ally.ult)
				target_queue.insert(ally_pos,await choose_target(ally.ult))
				ally_queue.insert(ally_pos,ally)
			else:
				action_queue.append(ally.ult)
				target_queue.append(await choose_target(ally.ult))
				ally_queue.append(ally)
			p_spend_skill_cost(ally.ult, ally)
			ally.using_skill = true
	match ally.position:
		1:
			ally1skill = allyskill
			ally1_pos = ally_pos
			spell_select_ui.update_pos(ally1_pos+1)
		2:
			ally2skill = allyskill
			ally2_pos = ally_pos
			spell_select_ui.update_pos(ally2_pos+1)
		3:
			ally3skill = allyskill
			ally3_pos = ally_pos
			spell_select_ui.update_pos(ally3_pos+1)
		4:
			ally4skill = allyskill
			ally4_pos = ally_pos
			spell_select_ui.update_pos(ally4_pos+1)
	await run_sim()
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
		spell_select_ui1.update_pos(ally1_pos + 1)
	if ally2 != null:
		var spell_select_ui2 = ally2.get_spell_select()
		spell_select_ui2.update_pos(ally2_pos + 1)
	if ally3 != null:
		var spell_select_ui3 = ally3.get_spell_select()
		spell_select_ui3.update_pos(ally3_pos + 1)
	if ally4 != null:
		var spell_select_ui4 = ally4.get_spell_select()
		spell_select_ui4.update_pos(ally4_pos + 1)

func reset_skill_select():
	set_unit_pos()
	if ally1 != null:
		var spell_select_ui1 = ally1.get_spell_select()
		spell_select_ui1.reset()
		spell_select_ui1.update_pos(ally1_pos + 1)
		ally1.using_skill = false
	if ally2 != null:
		var spell_select_ui2 = ally2.get_spell_select()
		spell_select_ui2.reset()
		spell_select_ui2.update_pos(ally2_pos + 1)
		ally2.using_skill = false
	if ally3 != null:
		var spell_select_ui3 = ally3.get_spell_select()
		spell_select_ui3.reset()
		spell_select_ui3.update_pos(ally3_pos + 1)
		ally3.using_skill = false
	if ally4 != null:
		var spell_select_ui4 = ally4.get_spell_select()
		spell_select_ui4.reset()
		spell_select_ui4.update_pos(ally4_pos + 1)
		ally4.using_skill = false
	action_queue = []
	target_queue = []
	ally_queue = []
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
	if (!targeting and choosing_skills):
		AudioPlayer.play_FX("click",0)
		# end of turn relics
		choosing_skills = false
		set_unit_pos()
		hide_skills()
		hide_ui()
		run.relic_handler.activate_relics_by_type(Relic.Type.END_OF_TURN)

func _on_reset_choices_pressed() -> void:
	AudioPlayer.play_FX("click",0)
	action_queue = []
	target_queue = []
	ally_queue = []
	next_pos = 0
	ally1_pos = -1
	ally2_pos = -1
	ally3_pos = -1
	ally4_pos = -1
	reset_sim()
	reset_skill_select()
	update_skill_positions()
	for ally in allies:
		ally.unspend_tokens()
	update_tokens()
	combat_currency.update()
	check_requirements()

func show_skills():
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
	reset_choices.visible = false
	
func show_ui():
	if (not run.reaction_guide_open):
		end_turn.visible = true
	reset_choices.visible = true
	
	
func choose_target(skill : Skill): 
	if (skill.target_type == "single_enemy" or skill.target_type == "single_ally"):
		var target
		targeting = true
		targeting_skill = skill
		toggle_targeting_ui(skill)
		hide_skills()
		hide_ui()
		Input.set_custom_mouse_cursor(TARGET_CURSOR, 0, Vector2(32,32))
		targeting_skill_info.visible = true
		targeting_label.visible = true
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
		toggle_targeting_ui(skill)
		AudioPlayer.play_FX("click",0)
		Input.set_custom_mouse_cursor(DEFAULT_CURSOR, 0)
		targeting = false
		return target
	else:
		return null
	
func target_signal(unit):
	target_chosen.emit(unit)

func _input(event):
	if event.is_action_pressed("1"):
		if (targeting):
			if (not targeting_skill.friendly):
				if enemies.size() >= 1:
					if (enemies[0] != null):
						target_chosen.emit(enemies[0])
			elif (targeting_skill.friendly and targeting):
				if allies.size() >= 1:
					if (allies[0] != null):
						target_chosen.emit(allies[0])
	if event.is_action_pressed("2"):
		if (targeting):
			if (not targeting_skill.friendly and targeting):
				if enemies.size() >= 2:
					if (enemies[1] != null):
						target_chosen.emit(enemies[1])
			elif (targeting_skill.friendly and targeting):
				if allies.size() >= 2:
					if (allies[1] != null):
						target_chosen.emit(allies[1])
	if event.is_action_pressed("3"):
		if (targeting):
			if (not targeting_skill.friendly and targeting):
				if enemies.size() >= 3:
					if (enemies[2] != null):
						target_chosen.emit(enemies[2])
			elif (targeting_skill.friendly and targeting):
				if allies.size() >= 3:
					if (allies[2] != null):
						target_chosen.emit(allies[2])
	if event.is_action_pressed("4"):
		if (targeting):
			if (not targeting_skill.friendly and targeting):
				if enemies.size() >= 4:
					if (enemies[3] != null):
						target_chosen.emit(enemies[3])
			elif (targeting_skill.friendly and targeting):
				if allies.size() >= 4:
					if (allies[3] != null):
						target_chosen.emit(allies[3])
	if event.is_action_pressed("end_turn"):
		_on_end_turn_pressed()
			
	
func toggle_targeting_ui(skill):
	targeting_skill_info.skill = skill
	targeting_skill_info.update_skill_info()
	targeting_skill_info.visible = !targeting_skill_info.visible
	targeting_label.visible = !targeting_label.visible
	

	
	
#activate statuses
func enemy_pre_status():
	for enemy in enemies:
		if enemy.status != []:
			for status in enemy.status:
				if status.pre_turn == true:
					enemy.execute_status(status)
		for i in range (len(enemy.status)): 
			if i < len(enemy.status):
				if enemy.status[i].turns_remaining <= 0:
					enemy.status.remove_at(i)
					i -= 1
		enemy.hp_bar.update_statuses(enemy.status)
	

func enemy_post_status():
	for enemy in enemies:
		if enemy.status != []:
			for status in enemy.status:
				if status.pre_turn == false:
					enemy.execute_status(status)
		#remove any statuses with duration 0
		for i in range (len(enemy.status)): 
			if i < len(enemy.status):
				if enemy.status[i].turns_remaining <= 0:
					enemy.status.remove_at(i)
					i -= 1
		enemy.hp_bar.update_statuses(enemy.status)
	
func ally_pre_status():
	for ally in allies:
		if ally.status != []:
			for status in ally.status:
				if status.pre_turn == true:
					ally.execute_status(status)
		for i in range (len(ally.status)): 
			if i < len(ally.status):
				if ally.status[i].turns_remaining <= 0:
					ally.status.remove_at(i)
					i -= 1
		ally.hp_bar.update_statuses(ally.status)
func ally_post_status():
	for ally in allies:
		if ally.status != []:
			for status in ally.status:
				if status.pre_turn == false:
					ally.execute_status(status)
		for i in range (len(ally.status)): 
			if i < len(ally.status):
				if ally.status[i].turns_remaining <= 0:
					ally.status.remove_at(i)
					i -= 1
		ally.hp_bar.update_statuses(ally.status)
					
func check_requirements():
	for ally in allies:
		if not ally.using_skill:
			var skill : Skill
			for i in range(1, 5):
				match i:
					1:
						skill = ally.basic_atk
					2:
						skill = ally.skill_1
					3:
						skill = ally.skill_2
					4:
						skill = ally.ult
				if (skill):
					var check = false
					var tokens1 = 0
					var tokens2 = 0
					if skill.cost != null:
						match skill.token_type:
							"fire":
								tokens1 = p_fire_tokens
							"water":
								tokens1 = p_water_tokens
							"lightning":
								tokens1 = p_lightning_tokens
							"grass":
								tokens1 = p_grass_tokens
							"earth":
								tokens1 = p_earth_tokens
					if skill.cost2 != null:
						match skill.token_type2:
							"fire":
								tokens2 = p_fire_tokens
							"water":
								tokens2 = p_water_tokens
							"lightning":
								tokens2 = p_lightning_tokens
							"grass":
								tokens2 = p_grass_tokens
							"earth":
								tokens2 = p_earth_tokens
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
		
func set_unit_pos():
	for n in range(enemies.size()):
		if n > 0:
			enemies[n].left = enemies[n-1]
		else:
			enemies[n].left = null
		if n < enemies.size()-1:
			enemies[n].right = enemies[n+1]
		else:
			enemies[n].right = null
	for n in range(allies.size()):
		if n > 0:
			allies[n].left = allies[n-1]
		else:
			allies[n].left = null
		if n < allies.size()-1:
			allies[n].right = allies[n+1]
		else:
			allies[n].right = null
	if enemies.size() > 0:
		front_enemy = enemies[0]
		back_enemy = enemies[enemies.size()-1]
	if allies.size() > 0:
		front_ally = allies[allies.size()-1]
		back_ally = allies[0]
		
func vaporize(unit, caster, element):
	add_token("fire", (run.vaporize_fire_token_base + run.vaporize_fire_token_bonus) * run.vaporize_fire_token_mult)
	add_token("water", (run.vaporize_water_token_base + run.vaporize_water_token_bonus) * run.vaporize_water_token_mult)
	if run.steamer == true:
		if element == "fire":
			unit.current_element = "water"
		elif element == "water":
			unit.current_element = "fire"

func shock(unit, caster):
	add_token("lightning", (run.shock_lightning_token_base + run.shock_lightning_token_bonus) * run.shock_lightning_token_mult)
	add_token("water", (run.shock_water_token_base + run.shock_water_token_bonus) * run.shock_water_token_mult)

func detonate(unit, caster):
	add_token("fire", (run.detonate_fire_token_base + run.detonate_fire_token_bonus) * run.detonate_fire_token_mult)
	add_token("lightning", (run.detonate_lightning_token_base + run.detonate_lightning_token_bonus) * run.detonate_lightning_token_mult)

func erupt(unit, caster):
	add_token("fire", (run.erupt_fire_token_base + run.erupt_fire_token_bonus) * run.erupt_fire_token_mult)
	add_token("earth", (run.erupt_earth_token_base + run.erupt_earth_token_bonus) * run.erupt_earth_token_mult)

func bloom(unit, caster):
	add_token("water", (run.bloom_water_token_base + run.bloom_water_token_bonus) * run.bloom_water_token_mult)
	add_token("grass", (run.bloom_grass_token_base + run.bloom_grass_token_bonus) * run.bloom_grass_token_mult)

func burn(unit, caster):
	add_token("fire", (run.burn_fire_token_base + run.burn_fire_token_bonus) * run.burn_fire_token_mult)
	add_token("grass", (run.burn_grass_token_base + run.burn_grass_token_bonus) * run.burn_grass_token_mult)

func nitro(unit, caster):
	add_token("grass", (run.nitro_grass_token_base + run.nitro_grass_token_bonus) * run.nitro_grass_token_mult)
	add_token("lightning", (run.nitro_lightning_token_base + run.nitro_lightning_token_bonus) * run.nitro_lightning_token_mult)
	
func muck(unit, caster):
	add_token("water", (run.muck_water_token_base + run.muck_water_token_bonus) * run.muck_water_token_mult)
	add_token("earth", (run.muck_earth_token_base + run.muck_earth_token_bonus) * run.muck_earth_token_mult)

func discharge(unit):
	add_token("earth", (run.discharge_earth_token_base + run.discharge_earth_token_bonus) * run.discharge_earth_token_mult)
	add_token("lightning", (run.discharge_lightning_token_base + run.discharge_lightning_token_bonus) * run.discharge_lightning_token_mult)
	if run.discharge_destruction == true:
		for enemy in enemies:
			enemy.take_damage(5*run.discharge_mult,"none","false")

func sow(unit):
	add_token("earth", (run.sow_earth_token_base + run.sow_earth_token_bonus) * run.sow_earth_token_mult)
	add_token("grass", (run.sow_grass_token_base + run.sow_grass_token_bonus) * run.sow_grass_token_mult)
	
func add_token(element, count):
	match element:
		"fire":
			fire_tokens += ((count + run.fire_token_bonus) * run.fire_token_multiplier)
		"water":
			water_tokens += ((count + run.water_token_bonus) * run.water_token_multiplier)
		"lightning":
			lightning_tokens += ((count + run.lightning_token_bonus) * run.lightning_token_multiplier)
		"grass":
			grass_tokens += ((count + run.grass_token_bonus) * run.grass_token_multiplier)
		"earth":
			earth_tokens += ((count + run.earth_token_bonus) * run.earth_token_multiplier)

func reset_tokens():
	fire_tokens = 0
	water_tokens = 0
	lightning_tokens = 0
	earth_tokens = 0
	grass_tokens = 0

func run_sim():
	if (prev_sim != null):
		prev_sim.queue_free()
	sim = COMBAT_SIM.instantiate()
	self.add_child(sim)
	prev_sim = sim
	var sim_enemy1
	var sim_enemy2
	var sim_enemy3
	var sim_enemy4
	var sim_ally1
	var sim_ally2
	var sim_ally3
	var sim_ally4
	if (enemy1 != null):
		sim_enemy1 = enemy1.duplicate()
	if (enemy2 != null):
		sim_enemy2 = enemy2.duplicate()
	if (enemy3 != null):
		sim_enemy3 = enemy3.duplicate()
	if (enemy4 != null):
		sim_enemy4 = enemy4.duplicate()
	if (ally1 != null and ally1.visible == true):
		sim_ally1 = ally1.duplicate()
	if (ally2 != null and ally2.visible == true):
		sim_ally2 = ally2.duplicate()
	if (ally3 != null and ally3.visible == true):
		sim_ally3 = ally3.duplicate()
	if (ally4 != null and ally4.visible == true):
		sim_ally4 = ally4.duplicate()
		
	var sim_action_queue = []
	sim_action_queue.resize(action_queue.size())
	for i in range(action_queue.size()):
		sim_action_queue[i] = action_queue[i].duplicate()
	
	var sim_target_queue = []
	sim_target_queue.resize(target_queue.size())
	for i in range(target_queue.size()):
		if target_queue != null:
			var make_duplicate = true
			var new_target = null
			for target in sim_target_queue:
				if target != null and target_queue[i] != null:
					if target.title == target_queue[i].title:
						make_duplicate = false
						new_target = target
			if make_duplicate and target_queue[i] != null:
				sim_target_queue[i] = target_queue[i].duplicate()
			else:
				sim_target_queue[i] = new_target
			if (ally1 != null and ally1.visible == true and target_queue[i] == ally1):
				sim_ally1 = sim_target_queue[i]
			elif (ally2 != null and ally1.visible == true and target_queue[i] == ally2):
				sim_ally2 = sim_target_queue[i]
			elif (ally3 != null and ally3.visible == true and target_queue[i] == ally3):
				sim_ally3 = sim_target_queue[i]
			elif (ally4 != null and ally4.visible == true and target_queue[i] == ally4):
				sim_ally4 = sim_target_queue[i]
			elif (enemy1 != null and target_queue[i] == enemy1):
				sim_enemy1 = sim_target_queue[i]
			elif (enemy2 != null and target_queue[i] == enemy2):
				sim_enemy2 = sim_target_queue[i]
			elif (enemy3 != null and target_queue[i] == enemy3):
				sim_enemy3 = sim_target_queue[i]
			elif (enemy4 != null and target_queue[i] == enemy4):
				sim_enemy4 = sim_target_queue[i]
		else:
			sim_target_queue[i] = null
			
	var sim_ally_queue = []
	sim_ally_queue.resize(ally_queue.size())
	for i in range(ally_queue.size()):
		if ally_queue != null:
			var make_duplicate = true
			var new_ally = null
			for ally in sim_ally_queue:
				if ally != null and ally_queue[i] != null:
					if ally.title == ally_queue[i].title:
						make_duplicate = false
						new_ally = ally
			for ally in sim_target_queue:
				if ally != null and ally_queue[i] != null:
					if ally.title == ally_queue[i].title:
						make_duplicate = false
						new_ally = ally
			if make_duplicate and ally_queue[i] != null:
				sim_ally_queue[i] = ally_queue[i].duplicate()
			else:
				sim_ally_queue[i] = new_ally
			if (ally1 != null and ally1.visible == true and ally_queue[i] == ally1):
				sim_ally1 = sim_ally_queue[i]
			elif (ally1 != null and ally1.visible == true and ally_queue[i] == ally2):
				sim_ally2 = sim_ally_queue[i]
			elif (ally3 != null and ally3.visible == true and ally_queue[i] == ally3):
				sim_ally3 = sim_ally_queue[i]
			elif (ally4 != null and ally4.visible == true and ally_queue[i] == ally4):
				sim_ally4 = sim_ally_queue[i]
		else:
			sim_ally_queue[i] = null
	if (sim_enemy1 != null):
		sim_enemy1.copy = true
	if (sim_enemy2 != null):
		sim_enemy2.copy = true
	if (sim_enemy3 != null):
		sim_enemy3.copy = true
	if (sim_enemy4 != null):
		sim_enemy4.copy = true
	if (sim_ally1 != null):
		sim_ally1.copy = true
	if (sim_ally2 != null):
		sim_ally2.copy = true
	if (sim_ally3 != null):
		sim_ally3.copy = true
	if (sim_ally4 != null):
		sim_ally4.copy = true	
	var sim_finished = await sim.run_simulation(sim_ally1, sim_ally2, sim_ally3, sim_ally4, sim_enemy1, sim_enemy2, sim_enemy3, sim_enemy4, sim_action_queue, sim_target_queue, sim_ally_queue)
	if sim_finished:
		p_fire_tokens += sim_fire_tokens
		p_water_tokens += sim_water_tokens
		p_lightning_tokens += sim_lightning_tokens
		p_grass_tokens += sim_grass_tokens
		p_earth_tokens += sim_earth_tokens
		combat_currency.update()
	
func reset_sim():
	sim_fire_tokens = 0
	sim_water_tokens = 0
	sim_lightning_tokens = 0
	sim_grass_tokens = 0
	sim_earth_tokens = 0
	if (sim != null):
		sim.queue_free()
	if (prev_sim != null):
		sim.queue_free()
	sim = null
	prev_sim = null
