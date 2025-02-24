extends Node

@onready var loading: Node2D = $Loading
@onready var ally_1_spot: Node2D = %"Ally 1 Spot"
@onready var ally_2_spot: Node2D = %"Ally 2 Spot"
@onready var ally_3_spot: Node2D = %"Ally 3 Spot"
@onready var ally_4_spot: Node2D = %"Ally 4 Spot"
@onready var relic_handler_spot: Node2D = $RelicHandlerSpot
@onready var reaction_panel: Control = $ReactionGuide/ReactionPanel
@onready var relic_info: Control = %RelicInfo
@onready var gold_text: RichTextLabel = $GoldText
@onready var xp_bar: ProgressBar = $XPBar
@onready var current_level: Label = $XPBar/CurrentLevel
@onready var next_level: Label = $XPBar/NextLevel
@onready var xp_number: Label = $XPBar/XPNumber
@onready var xp_gain_position: Node2D = $XPBar/XPGainPosition

const RELIC_HANDLER = preload("res://scenes/relic handler/relic_handler.tscn")
const COMBAT = preload("res://scenes/main scenes/combat.tscn")
const SHOP = preload("res://scenes/main scenes/shop.tscn")
const LEVEL_UP = preload("res://level_up_scene.tscn")
const END = preload("res://scenes/main scenes/ending_screen.tscn")
const NEXT_FIGHT_CHOICE = preload("res://next_fight_choice.tscn")
const BOSS_REWARD = preload("res://boss_reward.tscn")

@onready var S: Node = $StateMachine

var combat_manager
var combat = false
var combat_scene
var shop = false
var shop_scene
var event = false
var event_scene
var level_up = false
var level_up_scene
var choose_fight_scene
var choose_reward_scene
var choose_reward = false

var scene_reward = ""

signal scene_end
signal special_scene_end

var ally_1_spot_og_pos
var ally_2_spot_og_pos
var ally_3_spot_og_pos
var ally_4_spot_og_pos

var id = 0
var ally1 : Ally
var ally2 : Ally
var ally3 : Ally
var ally4 : Ally

var allies = []

var front_ally
var back_ally

var gold = 0
var bonus_gold = 0
var gold_mult = 1

var level = 0
var xp = 0
var xp_bonus = 0
var xp_mult = 1
var current_xp_goal = 100

var hard = false
#combat
var current_reward = 6
var fight_level = 1
var max_fight_level = 20
var boss_level = 0
#checks
var reaction_guide_open = false

var relics = []
var obtainable_relics = []

var relic_handler

var skills = []
var obtainable_skills = []

var fire_skills = []
var water_skills = []
var lightning_skills = []
var grass_skills = []
var earth_skills = []

var fire_skill_damage_bonus = 0
var fire_skill_damage_mult = 1
var water_skill_damage_bonus = 0
var water_skill_damage_mult = 1
var lightning_skill_damage_bonus = 0
var lightning_skill_damage_mult = 1
var grass_skill_damage_bonus = 0
var grass_skill_damage_mult = 1
var earth_skill_damage_bonus = 0
var earth_skill_damage_mult = 1
var physical_skill_damage_bonus = 0
var physical_skill_damage_mult = 1
var healing_skill_bonus = 0
var healing_skill_mult = 1
var shielding_skill_bonus = 0
var shielding_skill_mult = 1
var all_skill_damage_bonus = 0
var all_skill_damage_mult = 1

var fire_damage_bonus = 0
var fire_damage_mult = 1
var water_damage_bonus = 0
var water_damage_mult = 1
var lightning_damage_bonus = 0
var lightning_damage_mult = 1
var earth_damage_bonus = 0
var earth_damage_mult = 1
var grass_damage_bonus = 0
var grass_damage_mult = 1
var physical_damage_bonus = 0
var physical_damage_mult = 1
var all_damage_bonus = 0
var all_damage_mult = 1

var healing_bonus = 0
var healing_mult = 1

var shielding_bonus = 0
var shielding_mult = 1

#tokens
var fire_tokens = 0
var water_tokens = 0
var lightning_tokens = 0
var grass_tokens = 0
var earth_tokens = 0

var fire_token_multiplier = 1
var water_token_multiplier = 1
var lightning_token_multiplier = 1
var	grass_token_multiplier = 1
var earth_token_multiplier = 1

var fire_token_bonus = 0
var water_token_bonus = 0
var lightning_token_bonus = 0
var grass_token_bonus = 0
var earth_token_bonus = 0

#mults
var vaporize_mult = 2
var shock_mult = 0.25
var erupt_mult = 3
var detonate_main_mult = 1.5
var detonate_side_mult = 0.5
var nitro_mult = 1.5
var bubble_mult = 0.5
var burn_damage = 10
var burn_length = 2
var muck_mult = 0.75
var discharge_mult = 1.5
var sow_shielding = 5
var sow_healing = 5
var sow_healing_mult = 1
var sow_shielding_mult = 1

var bloom_mult = 1
var ally_bloom_healing = 5
var enemy_bloom_healing = 5

# token bonus and mults

# Vaporize (Fire + Water)
var vaporize_fire_token_base = 1
var vaporize_water_token_base = 1
var vaporize_fire_token_mult = 1
var vaporize_water_token_mult = 1
var vaporize_fire_token_bonus = 0
var vaporize_water_token_bonus = 0

# Detonate (Fire + Lightning)
var detonate_fire_token_base = 1
var detonate_lightning_token_base = 1
var detonate_fire_token_mult = 1
var detonate_lightning_token_mult = 1
var detonate_fire_token_bonus = 0
var detonate_lightning_token_bonus = 0

# Erupt (Fire + Earth)
var erupt_fire_token_base = 1
var erupt_earth_token_base = 1
var erupt_fire_token_mult = 1
var erupt_earth_token_mult = 1
var erupt_fire_token_bonus = 0
var erupt_earth_token_bonus = 0

# Burn (Fire + Grass)
var burn_fire_token_base = 1
var burn_grass_token_base = 1
var burn_fire_token_mult = 1
var burn_grass_token_mult = 1
var burn_fire_token_bonus = 0
var burn_grass_token_bonus = 0

# Shock (Water + Lightning)
var shock_water_token_base = 1
var shock_lightning_token_base = 1
var shock_water_token_mult = 1
var shock_lightning_token_mult = 1
var shock_water_token_bonus = 0
var shock_lightning_token_bonus = 0

# Bloom (Water + Grass)
var bloom_water_token_base = 1
var bloom_grass_token_base = 1
var bloom_water_token_mult = 1
var bloom_grass_token_mult = 1
var bloom_water_token_bonus = 0
var bloom_grass_token_bonus = 0

# Nitro (Lightning + Grass)
var nitro_lightning_token_base = 1
var nitro_grass_token_base = 1
var nitro_lightning_token_mult = 1
var nitro_grass_token_mult = 1
var nitro_lightning_token_bonus = 0
var nitro_grass_token_bonus = 0

# Muck (Water + Earth)
var muck_water_token_base = 1
var muck_earth_token_base = 1
var muck_water_token_mult = 1
var muck_earth_token_mult = 1
var muck_water_token_bonus = 0
var muck_earth_token_bonus = 0

# Discharge (Earth + Lightning)
var discharge_earth_token_base = 1
var discharge_lightning_token_base = 1
var discharge_earth_token_mult = 1
var discharge_lightning_token_mult = 1
var discharge_earth_token_bonus = 0
var discharge_lightning_token_bonus = 0

# Sow (Earth + Grass)
var sow_earth_token_base = 1
var sow_grass_token_base = 1
var sow_earth_token_mult = 1
var sow_grass_token_mult = 1
var sow_earth_token_bonus = 0
var sow_grass_token_bonus = 0

var current_fight = null
var end = false
var current_boss = null

# event based relics
var ghostfire = false
var flow = false
var lightning_strikes_twice = false
var burn_stack = false
var discharge_destruction = false
var steamer = false

func run_loop():
	var fight_count = 0
	while not end:
		# combat
		if (level_up):
				S.transition("levelup","")
				await scene_end
		if fight_count == 3:
			fight_count = 0
			boss_level += 1
			S.transition("choosefight","boss")
			await scene_end
			S.transition("combat","")
			await scene_end
			S.transition("choosereward",current_boss)
			await scene_end
			if boss_level == 2:
				end = true
		else:
			if (level_up):
				S.transition("levelup","")
				await scene_end
			S.transition("choosefight","")
			fight_level += 1
			await scene_end
			if (level_up):
				S.transition("levelup","")
				await scene_end
			S.transition("combat","")
			await scene_end
			fight_count += 1
		if (level_up):
			S.transition("levelup","")
			await scene_end
		if (end):
			break
	var end_scene = END.instantiate()
	self.add_child(end_scene)
	
	
func scene_ended(next_scene):
	if (xp >= current_xp_goal):
		level_up_allies()
	if next_scene != "":
		match next_scene:
			"fire_shop":
				load_shop("fire")
			"water_shop":
				load_shop("water")
			"lightning_shop":
				load_shop("lightning")
			"grass_shop":
				load_shop("grass")
			"earth_shop":
				load_shop("earth")
		S.transition("specialshop","")
		await special_scene_end
		scene_end.emit()
	elif scene_reward != "":
		match scene_reward:
			"common_event":
				S.transition("event","common")
				await special_scene_end
				scene_end.emit()
			"rare_event":
				S.transition("event","rare")
				await special_scene_end
			"normal_shop":
				load_shop("none")
				S.transition("specialshop","")
				await special_scene_end
				scene_end.emit()
			"fire_shop":
				load_shop("fire")
				S.transition("specialshop","")
				await special_scene_end
				scene_end.emit()
			"water_shop":
				load_shop("water")
				S.transition("specialshop","")
				await special_scene_end
				scene_end.emit()
			"lightning_shop":
				load_shop("lightning")
				S.transition("specialshop","")
				await special_scene_end
				scene_end.emit()
			"grass_shop":
				load_shop("grass")
				S.transition("specialshop","")
				await special_scene_end
				scene_end.emit()
			"earth_shop":
				load_shop("earth")
				S.transition("specialshop","")
				await special_scene_end
				scene_end.emit()
		scene_reward = ""
	else:
		scene_end.emit()

func special_scene_ended():
	special_scene_end.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GC.ally1 != null:
		var ally1s = GC.ALLY.instantiate()
		ally1 = ally1s
		ally1s.res = GC.ally1
		ally1.ally_num = 1
		ally_1_spot.add_child(ally1s)
		skills.append(GC.ally1.skill1)
		skills.append(GC.ally1.skill2)
		skills.append(GC.ally1.skill3)
		skills.append(GC.ally1.skill4)
		allies.append(ally1)
		ally_1_spot_og_pos = ally_1_spot.global_position
	if GC.ally2 != null:
		var ally2s = GC.ALLY.instantiate()
		ally2 = ally2s
		ally2s.res = GC.ally2
		ally2.ally_num = 2
		ally_2_spot.add_child(ally2s)
		skills.append(GC.ally2.skill1)
		skills.append(GC.ally2.skill2)
		skills.append(GC.ally2.skill3)
		skills.append(GC.ally2.skill4)
		allies.append(ally2)
		ally_2_spot_og_pos = ally_2_spot.global_position
	if GC.ally3 != null:
		var ally3s = GC.ALLY.instantiate()
		ally3 = ally3s
		ally3s.res = GC.ally3
		ally3.ally_num = 3
		ally_3_spot.add_child(ally3s)
		skills.append(GC.ally3.skill1)
		skills.append(GC.ally3.skill2)
		skills.append(GC.ally3.skill3)
		skills.append(GC.ally3.skill4)
		allies.append(ally3)
		ally_3_spot_og_pos = ally_3_spot.global_position
	if GC.ally4 != null:
		var ally4s = GC.ALLY.instantiate()
		ally4 = ally4s
		ally4s.res = GC.ally4
		ally4.ally_num = 4
		ally_4_spot.add_child(ally4s)
		skills.append(GC.ally4.skill1)
		skills.append(GC.ally4.skill2)
		skills.append(GC.ally4.skill3)
		skills.append(GC.ally4.skill4)
		allies.append(ally4)
		ally_4_spot_og_pos = ally_4_spot.global_position
	front_ally = allies[allies.size()-1]
	back_ally = allies[0]
	
	for ally in allies:
		ally.run_starting = true
	reaction_panel.visible = false
	var dir = DirAccess.open("res://resources/relics")
	var relics = []
	get_all_files_from_directory("res://resources/relics", "", relics)
	for filename in relics:
		var relic = load(filename)
		obtainable_relics.append(relic)
	var element = ""
	
	for i in range(1,6):
		match i:
			1:
				element = "fire"
			2:
				element = "water"
			3:
				element = "lightning"
			4:
				element = "grass"
			5:
				element = "earth"
			6:
				element = "physical"
		dir = DirAccess.open("res://resources/Skills/" + element)
		var skills = []
		get_all_files_from_directory("res://resources/Skills/" + element, "", skills)
		for filename in skills:
			var skill = load(filename)
			if skill.purchaseable == true:
				obtainable_skills.append(skill)
	relic_handler = RELIC_HANDLER.instantiate()
	relic_handler_spot.add_child(relic_handler)
	run_loop()
		
func get_all_files_from_directory(path : String, file_ext:= "", files := []):
	var resources = ResourceLoader.list_directory(path)
	for res in resources:
		print(str(path+res))
		if res.ends_with("/"): 
			get_all_files_from_directory(path+res, file_ext, files)
		files.append(path+"/"+res)
	return files

func load_combat(enemy1, enemy2, enemy3, enemy4):
	combat_scene = COMBAT.instantiate()
	self.add_child(combat_scene)
	combat_manager = combat_scene.get_child(0)
	combat_manager.xp_reward = 50
	combat_manager.ally1 = ally1
	combat_manager.ally2 = ally2
	combat_manager.ally3 = ally3
	combat_manager.ally4 = ally4
	for ally in allies:
		ally._ready()
	combat_scene.enemy1res = enemy1
	combat_scene.enemy2res = enemy2
	combat_scene.enemy3res = enemy3
	combat_scene.enemy4res = enemy4
	
func get_combat_manager():
	if combat:
		return combat_manager

func load_shop(type):
	shop_scene = SHOP.instantiate()
	if type != "none":
		match type:
			"fire":
				shop_scene.type = "Fire"
			"water":
				shop_scene.type = "Water"
			"lightning":
				shop_scene.type = "Lightning"
			"grass":
				shop_scene.type = "Grass"
			"earth":
				shop_scene.type = "Earth"
				
	for ally in allies:
		ally._ready()
	self.add_child(shop_scene) 
	
func load_level_up():
	level_up_scene = LEVEL_UP.instantiate()
	self.add_child(level_up_scene)

func load_event(event):
	event_scene = event.instantiate()
	self.add_child(event_scene)

func load_choose_fight(level, fight_type):
	choose_fight_scene = NEXT_FIGHT_CHOICE.instantiate()
	choose_fight_scene.level = level
	choose_fight_scene.type = fight_type
	self.add_child(choose_fight_scene)

func load_choose_reward(reward_type):
	choose_reward_scene = BOSS_REWARD.instantiate()
	choose_reward_scene.reward_type = reward_type
	self.add_child(choose_reward_scene)
func add_gold(count):
	gold += ((count + bonus_gold) * gold_mult)
	gold_text.text = "[color=yellow]Gold[/color] : " + str(gold)

func spend_gold(count):
	gold -= count
	gold_text.text = "[color=yellow]Gold[/color] : " + str(gold)

func add_reward(reward):
	add_gold(reward.gold)
	increase_xp(reward.XP)
	if reward.shop_type != "none":
		match reward.shop_type:
			"normal":
				scene_reward = "normal_shop"
			"fire":
				scene_reward = "fire_shop"
			"water":
				scene_reward = "water_shop"
			"lightning":
				scene_reward = "lightning_shop"
			"grass":
				scene_reward = "grass_shop"
			"earth":
				scene_reward = "earth_shop"
	if reward.event_type != "none":
		match reward.event_type:
			"common":
				scene_reward = "common_event"
			"rare":
				scene_reward = "rare_event"

func level_up_allies():
	level += 1
	level_up = true
	if ally1 != null:
		ally1.level += 1
		ally1.level_up = true
	if ally2 != null:
		ally2.level += 1
		ally2.level_up = true
	if ally3 != null:
		ally3.level += 1
		ally3.level_up = true
	if ally4 != null:
		ally4.level += 1
		ally4.level_up = true
	for ally in allies:
		ally.increase_max_hp(10,false)
	current_xp_goal += 100
	current_level.text = str(level)
	next_level.text = str(level+1)	
	xp_number.text = str(xp) + " / " + str(current_xp_goal) + " XP"
		
func get_random_relic():
	if obtainable_relics == []:
		return null
	var rng = RandomNumberGenerator.new()
	var random_num = rng.randi_range(0,obtainable_relics.size()-1)
	var relic = obtainable_relics[random_num]
	while relic in relics:
		random_num = rng.randi_range(0,obtainable_relics.size()-1)
		relic = obtainable_relics[random_num]
	return relic
	
func get_random_skill():
	var rng = RandomNumberGenerator.new()
	var random_num = rng.randi_range(0,obtainable_skills.size()-1)
	var skill = obtainable_skills[random_num]
	while skill in skills:
		random_num = rng.randi_range(0,obtainable_skills.size()-1)
		skill = obtainable_skills[random_num]
	return skill


func _on_reaction_guide_pressed() -> void:
	reaction_panel.update_mult_labels()
	if reaction_panel.visible:
		reaction_panel.visible = false
		reaction_guide_open = false
		#for enemy in enemies:
			#enemy.show_next_skill_info()
		#for ally in allies:
			#ally.spell_select_ui.visible = true
	elif not reaction_panel.visible:
		reaction_panel.visible = true
		reaction_guide_open = true
		#for enemy in enemies:
			#enemy.hide_next_skill_info()
		#for ally in allies:
			#ally.spell_select_ui.visible = false

func toggle_relic_tooltip():
	relic_info.visible = !relic_info.visible
	
func loading_screen(time):
	loading.visible = true
	await get_tree().create_timer(time).timeout
	loading.visible = false

func increase_xp(count):
	xp += ((count + xp_bonus) * xp_mult)
	xp_bar.value = xp
	xp_number.text = str(xp) + " / " + str(current_xp_goal) + " XP"
	DamageNumbers.display_number_plus(count, xp_gain_position.global_position, "none", " XP!")

func move_allies(x,y):
	if ally1 != null:
		ally_1_spot.global_position += Vector2(x,y)
	if ally2 != null:
		ally_2_spot.global_position += Vector2(x,y)
	if ally3 != null:
		ally_3_spot.global_position += Vector2(x,y)
	if ally4 != null:
		ally_4_spot.global_position += Vector2(x,y)
	
func reset_ally_positions():
	if ally1 != null:
		ally_1_spot.global_position = ally_1_spot_og_pos
	if ally2 != null:
		ally_2_spot.global_position = ally_2_spot_og_pos
	if ally3 != null:
		ally_3_spot.global_position = ally_3_spot_og_pos
	if ally4 != null:
		ally_4_spot.global_position = ally_4_spot_og_pos

func split_allies():
	if ally1 != null:
		ally_1_spot.global_position.x += -150
	if ally2 != null:
		ally_2_spot.global_position.x += -75
	if ally3 != null:
		ally_3_spot.global_position.x += 75
	if ally4 != null:
		ally_4_spot.global_position.x += 150
	

func reset() -> void:
		# Reset node references
		loading = $Loading
		ally_1_spot = %"Ally 1 Spot"
		ally_2_spot = %"Ally 2 Spot"
		ally_3_spot = %"Ally 3 Spot"
		ally_4_spot = %"Ally 4 Spot"
		relic_handler_spot = $RelicHandlerSpot
		reaction_panel = $ReactionGuide/ReactionPanel
		relic_info = %RelicInfo

		# Reset scenes
		combat_scene = null
		shop_scene = null
		event_scene = null
		level_up_scene = null

		# Reset state variables
		combat = false
		shop = false
		event = false
		level_up = false
		end = false

		# Reset ally positions
		ally_1_spot_og_pos = ally_1_spot.global_position
		ally_2_spot_og_pos = ally_2_spot.global_position
		ally_3_spot_og_pos = ally_3_spot.global_position
		ally_4_spot_og_pos = ally_4_spot.global_position

		# Reset allies
		ally1 = null
		ally2 = null
		ally3 = null
		ally4 = null
		allies = []
		front_ally = null
		back_ally = null

		# Reset resources
		gold = 0
		bonus_gold = 0
		gold_mult = 1

		level = 0
		xp = 0
		xp_bonus = 0
		xp_mult = 1
		current_xp_goal = 100

		# Reset combat rewards
		current_reward = 6

		# Reset checks
		reaction_guide_open = false

		# Reset relics and skills
		relics = []
		obtainable_relics = []
		skills = []
		obtainable_skills = []

		# Reset damage bonuses and multipliers
		fire_damage_bonus = 0
		fire_damage_mult = 1
		water_damage_bonus = 0
		water_damage_mult = 1
		lightning_damage_bonus = 0
		lightning_damage_mult = 1
		earth_damage_bonus = 0
		earth_damage_mult = 1
		grass_damage_bonus = 0
		grass_damage_mult = 1
		physical_damage_bonus = 0
		physical_damage_mult = 1
		all_damage_bonus = 0
		all_damage_mult = 1

		healing_bonus = 0
		healing_mult = 1
		shielding_bonus = 0
		shielding_mult = 1

		# Reset tokens
		fire_tokens = 0
		water_tokens = 0
		lightning_tokens = 0
		grass_tokens = 0
		earth_tokens = 0

		fire_token_multiplier = 1
		water_token_multiplier = 1
		lightning_token_multiplier = 1
		grass_token_multiplier = 1
		earth_token_multiplier = 1

		fire_token_bonus = 0
		water_token_bonus = 0
		lightning_token_bonus = 0
		grass_token_bonus = 0
		earth_token_bonus = 0

		# Reset reaction multipliers
		vaporize_mult = 2
		shock_mult = 0.25
		erupt_mult = 3
		detonate_main_mult = 1.5
		detonate_side_mult = 0.5
		nitro_mult = 1.5
		bubble_mult = 0.5
		burn_damage = 10
		burn_length = 2
		muck_mult = 0.75
		discharge_mult = 1.5
		sow_shielding = 5
		sow_healing = 5
		sow_healing_mult = 1
		sow_shielding_mult = 1

		bloom_mult = 1
		ally_bloom_healing = 5
		enemy_bloom_healing = 5

		# Reset token bonuses and multipliers for reactions
		vaporize_fire_token_base = 1
		vaporize_water_token_base = 1
		vaporize_fire_token_mult = 1
		vaporize_water_token_mult = 1
		vaporize_fire_token_bonus = 0
		vaporize_water_token_bonus = 0

		detonate_fire_token_base = 1
		detonate_lightning_token_base = 1
		detonate_fire_token_mult = 1
		detonate_lightning_token_mult = 1
		detonate_fire_token_bonus = 0
		detonate_lightning_token_bonus = 0

		erupt_fire_token_base = 1
		erupt_earth_token_base = 1
		erupt_fire_token_mult = 1
		erupt_earth_token_mult = 1
		erupt_fire_token_bonus = 0
		erupt_earth_token_bonus = 0

		burn_fire_token_base = 1
		burn_grass_token_base = 1
		burn_fire_token_mult = 1
		burn_grass_token_mult = 1
		burn_fire_token_bonus = 0
		burn_grass_token_bonus = 0

		shock_water_token_base = 1
		shock_lightning_token_base = 1
		shock_water_token_mult = 1
		shock_lightning_token_mult = 1
		shock_water_token_bonus = 0
		shock_lightning_token_bonus = 0

		bloom_water_token_base = 1
		bloom_grass_token_base = 1
		bloom_water_token_mult = 1
		bloom_grass_token_mult = 1
		bloom_water_token_bonus = 0
		bloom_grass_token_bonus = 0

		nitro_lightning_token_base = 1
		nitro_grass_token_base = 1
		nitro_lightning_token_mult = 1
		nitro_grass_token_mult = 1
		nitro_lightning_token_bonus = 0
		nitro_grass_token_bonus = 0

		muck_water_token_base = 1
		muck_earth_token_base = 1
		muck_water_token_mult = 1
		muck_earth_token_mult = 1
		muck_water_token_bonus = 0
		muck_earth_token_bonus = 0

		discharge_earth_token_base = 1
		discharge_lightning_token_base = 1
		discharge_earth_token_mult = 1
		discharge_lightning_token_mult = 1
		discharge_earth_token_bonus = 0
		discharge_lightning_token_bonus = 0

		sow_earth_token_base = 1
		sow_grass_token_base = 1
		sow_earth_token_mult = 1
		sow_grass_token_mult = 1
		sow_earth_token_bonus = 0
		sow_grass_token_bonus = 0

		# Reset event-based relics
		ghostfire = false
		flow = false
		lightning_strikes_twice = false
		burn_stack = false
		steamer = false

		# Reset relic handler
		if relic_handler:
			relic_handler.queue_free()
		relic_handler = RELIC_HANDLER.instantiate()
		relic_handler_spot.add_child(relic_handler)

		# Reset reaction panel visibility
		reaction_panel.visible = false
		reaction_guide_open = false

		# Reset relic info visibility
		relic_info.visible = false

		# Reset loading screen visibility
		loading.visible = false

		# Reset ally positions
		reset_ally_positions()

		# Reset allies' run_starting state
		for ally in allies:
			ally.run_starting = true

func update_damage(skill):
	if skill != null:
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
				"none":
					skill.damage = (skill.starting_damage + physical_skill_damage_bonus + all_skill_damage_bonus) * physical_skill_damage_mult * all_skill_damage_mult
		elif skill.healing:
			skill.damage = (skill.starting_damage + healing_skill_bonus) * healing_skill_mult
		elif skill.shielding:
			skill.damage = (skill.starting_damage + shielding_skill_bonus) * shielding_skill_mult

func add_skill(skill):
	skills.append(skill)
	match skill.element:
		"fire":
			fire_skills.append(skill)
		"water":
			water_skills.append(skill)
		"lightning":
			lightning_skills.append(skill)
		"grass":
			grass_skills.append(skill)
		"earth":
			earth_skills.append(skill)

func update_skills():
	for skill in skills:
		update_damage(skill)
