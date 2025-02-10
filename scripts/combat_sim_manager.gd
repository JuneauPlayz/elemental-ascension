extends Node

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


@onready var relics : RelicHandler


var ally1skill : int
var ally2skill : int
var ally3skill : int
var ally4skill : int

var next_pos : int

var ally1_pos : int
var ally2_pos : int
var ally3_pos : int
var ally4_pos : int

var fire_tokens_change = 0
var water_tokens_change = 0
var lightning_tokens_change = 0
var grass_tokens_change = 0
var earth_tokens_change = 0

@export var action_queue = []
@export var target_queue = []
@export var ally_queue = []

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
@onready var reaction_manager: Node = $ReactionManager

func run_simulation(ally1, ally2, ally3, ally4, enemy1, enemy2, enemy3, enemy4, action_queue, target_queue, ally_queue):
	run = get_tree().get_first_node_in_group("run")
	fire_tokens_change = 0
	water_tokens_change = 0
	lightning_tokens_change = 0
	grass_tokens_change = 0
	earth_tokens_change = 0
	allies = []
	enemies = []
	self.action_queue = action_queue
	self.target_queue = target_queue
	self.ally_queue = ally_queue
	if (enemy1 != null):
		self.enemy1 = enemy1
		enemies.append(self.enemy1)
	if (enemy2 != null):
		self.enemy2 = enemy2
		enemies.append(self.enemy2)
	if (enemy3 != null):
		self.enemy3 = enemy3
		enemies.append(self.enemy3)
	if (enemy4 != null):
		self.enemy4 = enemy4
		enemies.append(self.enemy4)
	if (ally1 != null):
		self.ally1 = ally1
		allies.append(self.ally1)
	if (ally2 != null):
		self.ally2 = ally2
		allies.append(self.ally2)
	if (ally3 != null):
		self.ally3 = ally3
		allies.append(self.ally3)
	if (ally4 != null):
		self.ally4 = ally4
		allies.append(self.ally4)
	for i in range(len(allies)):
		allies[i].position = i+1
	for ally in allies:
		ally.ReactionManager = reaction_manager
		ally.combat_manager = self
		ally.run = self.run
	for enemy in enemies:
		enemy.ReactionManager = reaction_manager
		enemy.combat_manager = self
		enemy.run = self.run
	set_unit_pos()
	execute_ally_turn(action_queue, target_queue, ally_queue)
	await ally_turn_done
	run.combat_manager.p_fire_tokens -= run.combat_manager.sim_fire_tokens
	run.combat_manager.p_water_tokens -= run.combat_manager.sim_water_tokens
	run.combat_manager.p_lightning_tokens -= run.combat_manager.sim_lightning_tokens
	run.combat_manager.p_grass_tokens -= run.combat_manager.sim_grass_tokens
	run.combat_manager.p_earth_tokens -= run.combat_manager.sim_earth_tokens
	run.combat_manager.sim_fire_tokens = fire_tokens_change
	run.combat_manager.sim_water_tokens = water_tokens_change
	run.combat_manager.sim_lightning_tokens = lightning_tokens_change
	run.combat_manager.sim_grass_tokens = grass_tokens_change
	run.combat_manager.sim_earth_tokens = earth_tokens_change
	return true
func _ready():
	run = get_tree().get_first_node_in_group("run")




	
func execute_ally_turn(action_queue, target_queue, ally_queue):
	# skill execution
	for n in range(action_queue.size()):
		if (action_queue.size() == 0):
			continue
		var skill = action_queue[n]
		var target = target_queue[n]
		var ally = ally_queue[n]
		use_skill(skill,target,ally,true,true)
		# checks if target is dead, currently skips the rest of the loop (wont print landed)
		if (target == null or target.visible == false):
			await get_tree().create_timer(0.01).timeout
			continue
		await reaction_finished
		# can be source of bugs
		await get_tree().create_timer(0.005).timeout
		# for sow only
		for stati in target.status:
			if stati.unique_type == "sow":
				target.sow = true
	await get_tree().create_timer(0.001).timeout
	ally_turn_done.emit()


func check_event_relics(skill,unit,value_multiplier,target):
	if (run.ghostfire and unit is Ally and skill.element == "fire"):
		if (skill.target_type == "single_enemy" or skill.target_type == "back_enemy" or skill.target_type == "front_enemy"):
			await get_tree().create_timer(0.002).timeout
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
		await get_tree().create_timer(0.002).timeout
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
		await get_tree().create_timer(0.002).timeout
		use_skill(skill, target, unit, false, false)
		
	
func use_skill(skill,target,unit,event,spend_tokens):
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



	


		
			
func reaction_signal():
	print("reaction_signal")
	await get_tree().create_timer(0.01).timeout
	# update currency ui
	reaction_finished.emit()
	


	
	
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
			fire_tokens_change += ((count + run.fire_token_bonus) * run.fire_token_multiplier)
		"water":
			water_tokens_change += ((count + run.water_token_bonus) * run.water_token_multiplier)
		"lightning":
			lightning_tokens_change += ((count + run.lightning_token_bonus) * run.lightning_token_multiplier)
		"grass":
			grass_tokens_change += ((count + run.grass_token_bonus) * run.grass_token_multiplier)
		"earth":
			earth_tokens_change += ((count + run.earth_token_bonus) * run.earth_token_multiplier)
