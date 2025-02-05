extends Node

@onready var loading: Node2D = $Loading
@onready var ally_1_spot: Node2D = %"Ally 1 Spot"
@onready var ally_2_spot: Node2D = %"Ally 2 Spot"
@onready var ally_3_spot: Node2D = %"Ally 3 Spot"
@onready var ally_4_spot: Node2D = %"Ally 4 Spot"
@onready var relic_handler_spot: Node2D = $RelicHandlerSpot
@onready var reaction_panel: Control = $ReactionGuide/ReactionPanel
@onready var relic_info: Control = %RelicInfo

const RELIC_HANDLER = preload("res://scenes/relic handler/relic_handler.tscn")
const COMBAT = preload("res://scenes/main scenes/combat.tscn")
const SHOP = preload("res://scenes/main scenes/shop.tscn")

var combat_manager
var combat = false
var combat_scene
var shop = false
var shop_scene

var ally1 : Ally
var ally2 : Ally
var ally3 : Ally
var ally4 : Ally

var allies = []

var gold = 0
var bonus_gold = 0
var gold_mult = 1
#combat
var current_reward = 6
#checks
var reaction_guide_open = false

var relics = []
var obtainable_relics = []

var relic_handler

var skills = []
var obtainable_skills = []

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

var current_fight = GC.fight_1
var disable_level_up = false
var end = false

# event based relics
var ghostfire = false
var flow = false
var lightning_strikes_twice = false
var burn_stack = false
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
	combat = true
	load_combat(current_fight[0],current_fight[1],current_fight[2],current_fight[3])
		
func get_all_files_from_directory(path : String, file_ext:= "", files := []):
	var resources = ResourceLoader.list_directory(path)
	for res in resources:
		print(str(path+res))
		if res.ends_with("/"): 
			get_all_files_from_directory(path+res, file_ext, files)
		files.append(path+"/"+res)
	return files

func load_combat(enemy1, enemy2, enemy3, enemy4):
	loading_screen(0.5)
	next_fight()
	combat = true
	combat_scene = COMBAT.instantiate()
	self.add_child(combat_scene)
	combat_manager = combat_scene.get_child(1)
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
	
func load_shop():
	shop = true
	shop_scene = SHOP.instantiate()
	for ally in allies:
		ally._ready()
	self.add_child(shop_scene) 
			
func add_gold(count):
	gold += ((count + bonus_gold) * gold_mult)
	
func next_fight():
	match current_fight:
		GC.fight_1:
			current_fight = GC.fight_2
			current_reward = GC.fight_2_reward
		GC.fight_2:
			current_fight = GC.fight_3
			current_reward = GC.fight_3_reward
			level_up_allies()
		GC.fight_3:
			current_fight = GC.fight_4
			current_reward = GC.fight_4_reward
			disable_level_ups()
		GC.fight_4:
			current_fight = GC.fight_5
			current_reward = GC.fight_5_reward
			level_up_allies()
		GC.fight_5:
			current_fight = GC.fight_6
			current_reward = GC.fight_6_reward
			end = true
		GC.fight_6:
			end_game()
			
func level_up_allies():
	disable_level_up = false
	print("hiaaaaaaaaaaaaaaaaaaaaaaa")
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
		
func disable_level_ups():
	if ally1 != null:
		ally1.level_up = false
	if ally2 != null:
		ally2.level_up = false
	if ally3 != null:
		ally3.level_up = false
	if ally4 != null:
		ally4.level_up = false
		
func end_game():
	get_tree().change_scene_to_file("res://scenes/main scenes/ending_screen.tscn")

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
	
func combat_ended():
	combat_scene.queue_free()
	combat = false
	load_shop()
	
func shop_ended():
	shop_scene.queue_free()
	shop = false
	load_combat(current_fight[0],current_fight[1],current_fight[2],current_fight[3])
	
func loading_screen(time):
	loading.visible = true
	await get_tree().create_timer(time).timeout
	loading.visible = false
