extends Node

@onready var turn_text: Label = $TurnText
@onready var combat_currency: Control = $CombatCurrency
@onready var enemy_combat_currency: Control = $EnemyCombatCurrency

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

var targeting_skill : Skill


@onready var end_turn: Button = $"../EndTurn"
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

var tutorial = false

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
		allies[i].update_core()
	# setting left and right for units
	set_unit_pos()
	# relic stuff
	run.update_skills()
	run.relic_handler.relics_activated.connect(_on_relics_activated)
	run.relic_handler.activate_relics_by_type(Relic.Type.START_OF_COMBAT)
	combat_currency.update()
	run.hide_gold()
	run.hide_xp()



func start_combat():
	combat_currency.update()
	reset_skill_select()
	check_requirements()
	show_skills()
	while (!combat_finished):
		start_ally_turn()
		if tutorial == true:
			start_tutorial()
			tutorial = false
		await ally_turn_done

func end_battle():
	pass
	
func start_ally_turn():
	set_unit_pos()
	show_ui()
	run.relic_handler.activate_relics_by_type(Relic.Type.START_OF_TURN)
	turn_text.text = "Ally Turn"
	ally_pre_status()
	lose_shields()
	show_skills()
	reset_skill_select()
	check_requirements()
	update_skill_positions()
	choosing_skills = true

# rework
func ally_skill_use(skill, target, ally):
	var new_target = use_skill(skill,target,ally,true,true)
	check_post_skill(skill)
	combat_currency.update()
	# checks if target is dead, currently skips the rest of the loop (wont print landed)
	await reaction_finished
	print(str(skill.name) + " landed!")
	hit.emit()
	# for sow only
	enemy_status_check()
	ally.spell_select_ui.disable_all()
	for enemy in enemies:
		enemy.decrease_countdown(1)
	check_ally_turn_done()
	run.relic_handler.activate_relics_by_type(Relic.Type.POST_ALLY_SKILL)
	await get_tree().create_timer(0.1).timeout
	if enemy_skill_queue != []:
		await check_enemy_skills()
	
	show_ui()
	ally_post_status()
	if enemies.is_empty():
		victory()
	
	
	

func enemy_skill_use(enemy):
	
	run.relic_handler.activate_relics_by_type(Relic.Type.PRE_ENEMY_SKILL)
	match enemy.position:
		1:
			enemy_skill_queue.append(enemy1)
		2:
			enemy_skill_queue.append(enemy2)
		3:
			enemy_skill_queue.append(enemy3)
		4:
			enemy_skill_queue.append(enemy4)

func check_enemy_skills():
	for enemy in enemy_skill_queue:
		use_skill(enemy.current_skill,null,enemy,true,false)
		await get_tree().create_timer(0.1).timeout
	enemy_skill_queue = []

# rework
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
		check_post_skill(enemy.current_skill)
		hit.emit()
		if enemies.size() > i+1:
			if not enemies[i+1].animation:
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

func enemy_status_check():
	for enemy in enemies:
		for stati in enemy.status:
			if stati.unique_type == "sow":
				enemy.sow = true

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
	_on_end_turn_pressed()

func check_event_relics(skill,unit,value_multiplier,target):
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
	
func use_skill(skill,target,unit,event,spend_tokens):
	if allies == []:
		defeat()
	if enemies == []:
		victory()
	skill.update()
	if skill.summon != null:
		var new_summon = ENEMY.instantiate()
		new_summon.res = skill.summon.duplicate()
		if enemy3 == null:
			get_parent().enemy_3_spot.add_child(new_summon)
			enemy3 = new_summon
			enemies.push_front(enemy3)
		elif enemy2 == null:
			get_parent().enemy_2_spot.add_child(new_summon)
			enemy2 = new_summon
			enemies.push_front(enemy2)
		elif enemy1 == null:
			get_parent().enemy_1_spot.add_child(new_summon)
			enemy1 = new_summon
			enemies.push_front(enemy1)
		else:
			return
		return
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
		elif (skill.target_type == "front_2_allies" and front_ally != null):
			front_ally.receive_skill(skill,unit,value_multiplier)
			if front_ally_2 != null:
				front_ally_2.receive_skill(skill,unit,value_multiplier)
		elif (skill.target_type == "front_enemy" and front_enemy != null):
			front_enemy.receive_skill(skill,unit,value_multiplier)
		elif (skill.target_type == "front_2_enemies" and front_enemy != null):
			front_enemy.receive_skill(skill,unit,value_multiplier)
			if front_enemy_2 != null:
				front_enemy_2.receive_skill(skill,unit,value_multiplier)
		elif (skill.target_type == "back_ally" and back_ally != null):
			back_ally.receive_skill(skill,unit,value_multiplier)
		elif (skill.target_type == "back_2_allies" and back_ally != null):
			back_ally.receive_skill(skill,unit,value_multiplier)
			if back_ally_2 != null:
				back_ally_2.receive_skill(skill,unit,value_multiplier)
		elif (skill.target_type == "back_enemy" and back_enemy != null):
			back_enemy.receive_skill(skill,unit,value_multiplier)
		elif (skill.target_type == "back_2_enemies" and back_enemy != null):
			back_enemy.receive_skill(skill,unit,value_multiplier)
			if back_enemy_2 != null:
				back_enemy_2.receive_skill(skill,unit,value_multiplier)
		elif (skill.target_type == "random_middle_ally" and middle_allies != []):
			var rng = RandomNumberGenerator.new()
			var random_num = rng.randi_range(1,middle_allies.size())
			match random_num:
				1:
					middle_allies[0].receive_skill(skill,unit,value_multiplier)
				2:
					middle_allies[1].receive_skill(skill,unit,value_multiplier)
		elif (skill.target_type == "single_ally" and target != null):
			target.receive_skill(skill,unit,value_multiplier)
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
			if allies == []:
				return
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
				var temp_allies = allies.duplicate()
				for ally in temp_allies:
					if ally in allies:
						ally.receive_skill(skill,unit,value_multiplier)
						set_unit_pos()
						#print(ally.title + " taking " + str(skill.damage) + " damage from " + unit.title)
			elif (skill.target_type == "all_enemies" and allies.size() > 0):
				var temp_enemies = enemies.duplicate()
				for enemy in temp_enemies:
					if enemy in enemies:
						enemy.receive_skill(skill,unit,value_multiplier)
						set_unit_pos()
			elif (skill.target_type == "all_units" and allies.size() > 0 and enemies.size() > 0):
				var temp_enemies = enemies.duplicate()
				for enemy in temp_enemies:
					if enemy in enemies:
						enemy.receive_skill(skill,unit,value_multiplier)
						set_unit_pos()
				var temp_allies = allies.duplicate()
				for ally in temp_allies:
					if ally in allies:
						ally.receive_skill(skill,unit,value_multiplier)
						set_unit_pos()
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


func _on_relics_activated(type : Relic.Type) -> void:
	match type:
		Relic.Type.START_OF_COMBAT:
			start_combat()
		Relic.Type.END_OF_COMBAT:
			victory()
		
			
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
	
func _on_spell_select_ui_new_select(ally) -> void:
	var spell_select_ui: Control = ally.get_spell_select()
	var selected_index = spell_select_ui.selected
	
	hide_ui()
	# If unselecting
	if selected_index == 0:
		ally.using_skill = false
		spell_select_ui.update_pos(0)
		combat_currency.update()
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
		await ally_skill_use(skill, null, ally)
	else:
		var target = await choose_target(skill)
		if target:
			ally.using_skill = true
			await ally_skill_use(skill, target, ally)
	
	combat_currency.update()
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
	if (!targeting and choosing_skills):
		hide_ui()
		AudioPlayer.play_FX("click",0)
		await get_tree().create_timer(0.5).timeout
		for enemy in enemies:
			if enemy.skill_used == false:
				enemy_skill_use(enemy)
	
		check_enemy_skills()
		# end of turn relics
		choosing_skills = false
		set_unit_pos()
		hide_skills()
		await get_tree().create_timer(0.5).timeout
		ally_turn_done.emit()
		for enemy in enemies:
			enemy.change_skills()

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
	
func show_ui():
	if (not run.UIManager.reaction_guide_open):
		end_turn.visible = true
	
	
func choose_target(skill : Skill): 
	if (skill.target_type == "single_enemy" or skill.target_type == "single_ally"):
		var target
		targeting = true
		targeting_skill = skill
		toggle_targeting_ui(skill)
		hide_skills()
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
		combat_currency.update()
		check_requirements()
	else:
		combat_currency.update()
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

		
func vaporize(unit, caster, element):
	add_token("fire", (run.vaporize_fire_token_base + run.vaporize_fire_token_bonus + caster.fire_token_bonus) * run.vaporize_fire_token_mult)
	add_token("water", (run.vaporize_water_token_base + run.vaporize_water_token_bonus + caster.water_token_bonus) * run.vaporize_water_token_mult)
	if run.steamer == true:
		if element == "fire":
			unit.current_element = "water"
		elif element == "water":
			unit.current_element = "fire"

func shock(unit, caster):
	add_token("lightning", (run.shock_lightning_token_base + run.shock_lightning_token_bonus + caster.lightning_token_bonus) * run.shock_lightning_token_mult)
	add_token("water", (run.shock_water_token_base + run.shock_water_token_bonus + caster.water_token_bonus) * run.shock_water_token_mult)

func detonate(unit, caster):
	add_token("fire", (run.detonate_fire_token_base + run.detonate_fire_token_bonus + caster.fire_token_bonus) * run.detonate_fire_token_mult)
	add_token("lightning", (run.detonate_lightning_token_base + run.detonate_lightning_token_bonus + caster.lightning_token_bonus) * run.detonate_lightning_token_mult)

func erupt(unit, caster):
	add_token("fire", (run.erupt_fire_token_base + run.erupt_fire_token_bonus + caster.fire_token_bonus) * run.erupt_fire_token_mult)
	add_token("earth", (run.erupt_earth_token_base + run.erupt_earth_token_bonus + caster.earth_token_bonus) * run.erupt_earth_token_mult)

func bloom(unit, caster):
	add_token("water", (run.bloom_water_token_base + run.bloom_water_token_bonus + caster.water_token_bonus) * run.bloom_water_token_mult)
	add_token("grass", (run.bloom_grass_token_base + run.bloom_grass_token_bonus + caster.grass_token_bonus) * run.bloom_grass_token_mult)

func burn(unit, caster):
	add_token("fire", (run.burn_fire_token_base + run.burn_fire_token_bonus + caster.fire_token_bonus) * run.burn_fire_token_mult)
	add_token("grass", (run.burn_grass_token_base + run.burn_grass_token_bonus + caster.grass_token_bonus) * run.burn_grass_token_mult)

func nitro(unit, caster):
	add_token("grass", (run.nitro_grass_token_base + run.nitro_grass_token_bonus + caster.grass_token_bonus) * run.nitro_grass_token_mult)
	add_token("lightning", (run.nitro_lightning_token_base + run.nitro_lightning_token_bonus + caster.lightning_token_bonus) * run.nitro_lightning_token_mult)
	
func muck(unit, caster):
	add_token("water", (run.muck_water_token_base + run.muck_water_token_bonus + caster.water_token_bonus) * run.muck_water_token_mult)
	add_token("earth", (run.muck_earth_token_base + run.muck_earth_token_bonus + caster.earth_token_bonus) * run.muck_earth_token_mult)

func discharge(unit, caster):
	add_token("earth", (run.discharge_earth_token_base + run.discharge_earth_token_bonus + caster.earth_token_bonus) * run.discharge_earth_token_mult)
	add_token("lightning", (run.discharge_lightning_token_base + run.discharge_lightning_token_bonus + caster.lightning_token_bonus) * run.discharge_lightning_token_mult)
	if run.discharge_destruction == true:
		for enemy in enemies:
			enemy.take_damage(5 * run.discharge_mult, "none", false)

func sow(unit, caster):
	add_token("earth", (run.sow_earth_token_base + run.sow_earth_token_bonus + caster.earth_token_bonus) * run.sow_earth_token_mult)
	add_token("grass", (run.sow_grass_token_base + run.sow_grass_token_bonus + caster.grass_token_bonus) * run.sow_grass_token_mult)

	
func add_token(element, count):
	match element:
		"fire":
			fire_tokens += int((count + run.fire_token_bonus) * run.fire_token_multiplier)
		"water":
			water_tokens += int((count + run.water_token_bonus) * run.water_token_multiplier)
		"lightning":
			lightning_tokens += int((count + run.lightning_token_bonus) * run.lightning_token_multiplier)
		"grass":
			grass_tokens += int((count + run.grass_token_bonus) * run.grass_token_multiplier)
		"earth":
			earth_tokens += int((count + run.earth_token_bonus) * run.earth_token_multiplier)


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

#tutorial
func start_tutorial():
	run = get_tree().get_first_node_in_group("run")
	hide_tokens()
	hide_end_turn()
	hide_reaction_guide_button()
	hide_win()
	
