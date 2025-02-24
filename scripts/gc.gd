extends Node

var is_dragging = false

const GLOBAL_INTERVAL = 0.15
# global currencies

#enemies
const ALLY = preload("res://resources/units/allies/ally.tscn")
const CHILL_GUY = preload("res://resources/units/enemies/ChillGuy.tres")
const PYROMANCER = preload("res://resources/units/enemies/pyromancer.tres")
const TEAM_MAGMA_GRUNT = preload("res://resources/units/enemies/TeamMagmaGrunt.tres")
const HYDROMANCER = preload("res://resources/units/enemies/hydromancer.tres")
const BAGUETTE = preload("res://resources/units/enemies/Baguette.tres")
const ORB_WIZARD = preload("res://resources/units/enemies/OrbWizard.tres")
const LIGHTNING_MASTER = preload("res://resources/units/enemies/LightningMaster.tres")
const THEFINALBOSS = preload("res://resources/units/enemies/THEFINALBOSS.tres")

const FIRE_SWORDSMAN = preload("res://resources/units/enemies/Fire Swordsman.tres")
const FIRE_ARCHER = preload("res://resources/units/enemies/FireArcher.tres")

const WATER_SWORDSMAN = preload("res://resources/units/enemies/WaterSwordsman.tres")
const WATER_ARCHER = preload("res://resources/units/enemies/WaterArcher.tres")

const LIGHTNING_SWORDSMAN = preload("res://resources/units/enemies/Lightning Swordsman.tres")
const LIGHTNING_ARCHER = preload("res://resources/units/enemies/Lightning Archer.tres")

const EARTH_SWORDSMAN = preload("res://resources/units/enemies/EarthSwordsman.tres")
const EARTH_ARCHER = preload("res://resources/units/enemies/EarthArcher.tres")

const GRASS_SWORDSMAN = preload("res://resources/units/enemies/GrassSwordsman.tres")
const GRASS_ARCHER = preload("res://resources/units/enemies/GrassArcher.tres")

const FIRE_BOMBER = preload("res://resources/units/enemies/FireBomber.tres")
const LIGHTNING_BOMBER = preload("res://resources/units/enemies/LightningBomber.tres")
const WATER_BOMBER = preload("res://resources/units/enemies/WaterBomber.tres")

# events
const REST_EVENT = preload("res://rest_event.tscn")
const SPECIAL_SHOP_EVENT = preload("res://SpecialShopEvent.tscn")
const SACRIFICE_EVENT = preload("res://sacrifice_event.tscn")

const L1R1 = preload("res://resources/rewards/level1/L1R1.tres")
const L1R2 = preload("res://resources/rewards/level1/L1R2.tres")
const L1R3 = preload("res://resources/rewards/level1/L1R3.tres")
const L1R4 = preload("res://resources/rewards/level1/L1R4.tres")
const L2R1 = preload("res://resources/rewards/level2/L2R1.tres")
const L2R2 = preload("res://resources/rewards/level2/L2R2.tres")
const M1R1 = preload("res://resources/rewards/miniboss_1/M1R1.tres")
const M1R2 = preload("res://resources/rewards/miniboss_1/M1R2.tres")
const M1R3 = preload("res://resources/rewards/miniboss_1/M1R3.tres")

# predetermined fights
var f1v1 = [FIRE_SWORDSMAN, FIRE_ARCHER, null, null]
var f1v2 = [WATER_SWORDSMAN, WATER_ARCHER, null, null]
var f1v3 = [LIGHTNING_SWORDSMAN, LIGHTNING_ARCHER, null, null]


var f2v1 = [WATER_SWORDSMAN, FIRE_SWORDSMAN, null, null]
var f2v2 = [GRASS_SWORDSMAN, LIGHTNING_ARCHER, LIGHTNING_ARCHER, null]
var f2v3 = [EARTH_SWORDSMAN, FIRE_ARCHER, GRASS_ARCHER, null]

var f3v1 = [EARTH_SWORDSMAN, GRASS_SWORDSMAN, EARTH_ARCHER, LIGHTNING_ARCHER]
var f3v2 = [FIRE_SWORDSMAN, LIGHTNING_SWORDSMAN, WATER_ARCHER, null]
var f3v3 = [WATER_SWORDSMAN, FIRE_SWORDSMAN, LIGHTNING_SWORDSMAN, null]

var m1v1 = [FIRE_BOMBER, LIGHTNING_BOMBER, WATER_BOMBER, null]
var m1v2 = [LIGHTNING_BOMBER, FIRE_BOMBER, WATER_BOMBER, null]
var m1v3 = [WATER_BOMBER, FIRE_BOMBER, LIGHTNING_BOMBER, null]

var fight_5 = [PYROMANCER, HYDROMANCER, LIGHTNING_MASTER, ORB_WIZARD]

var fight_6 = [null, null, THEFINALBOSS, null]

var level_1_fights = [f1v1, f1v2, f1v3]
var level_1_rewards = [L1R1,L1R2,L1R3,L1R4]

var level_2_fights = [f2v1,f2v2,f2v3]
var level_2_rewards = [L2R1]

var miniboss_1_fights = [m1v1, m1v2, m1v3]
var miniboss_1_rewards = [M1R1, M1R2, M1R3]

var level_3_fights = [f3v1,f3v2,f3v3]
var level_3_rewards = [L1R1,L1R2,L1R3]

var level_4_fights = [f3v1]
var level_4_rewards = [L2R1]

var level_5_fights = [f3v1]
var level_5_rewards = [L2R1]

var level_6_fights = [f3v1]
var level_6_rewards = [L2R1]

var level_7_fights = [f3v1]
var level_7_rewards = [L2R1]

var level_8_fights = [f3v1]
var level_8_rewards = [L2R1]
#transition to run:

var ally1 : UnitRes
var ally2 : UnitRes
var ally3 : UnitRes
var ally4 : UnitRes

var events = [REST_EVENT, SPECIAL_SHOP_EVENT, SACRIFICE_EVENT, REST_EVENT, SPECIAL_SHOP_EVENT,]

var common_events = [REST_EVENT]
var rare_events = [SPECIAL_SHOP_EVENT, SACRIFICE_EVENT]

func load_run(ally1, ally2, ally3, ally4):
	self.ally1 = ally1
	self.ally2 = ally2
	self.ally3 = ally3
	self.ally4 = ally4
	
func get_random_event(rarity):
	if events == []:
		return null
	var rng = RandomNumberGenerator.new()
	var random_num = 0
	var event = null
	match rarity:
		"common":
			random_num = rng.randi_range(0,common_events.size()-1)
			event = common_events[random_num]
		"rare":
			random_num = rng.randi_range(0,rare_events.size()-1)
			event = rare_events[random_num]
	
	return event
	
func get_random_fight(level):
	var rng = RandomNumberGenerator.new()
	var random_num = 0
	var fight = null
	match level:
		1:
			random_num = rng.randi_range(0,level_1_fights.size()-1)
			fight = level_1_fights[random_num]
		2:
			random_num = rng.randi_range(0,level_2_fights.size()-1)
			fight = level_2_fights[random_num]
		3:
			random_num = rng.randi_range(0,level_3_fights.size()-1)
			fight = level_3_fights[random_num]
		4:
			random_num = rng.randi_range(0,level_4_fights.size()-1)
			fight = level_4_fights[random_num]
		5:
			random_num = rng.randi_range(0,level_5_fights.size()-1)
			fight = level_5_fights[random_num]
		6:
			random_num = rng.randi_range(0,level_6_fights.size()-1)
			fight = level_6_fights[random_num]
		7:
			random_num = rng.randi_range(0,level_7_fights.size()-1)
			fight = level_7_fights[random_num]
		8:
			random_num = rng.randi_range(0,level_8_fights.size()-1)
			fight = level_8_fights[random_num]
	return fight

func get_random_boss(level):
	var rng = RandomNumberGenerator.new()
	var random_num = 0
	var fight = null
	match level:
		1:
			random_num = rng.randi_range(0,miniboss_1_fights.size()-1)
			fight = miniboss_1_fights[random_num]
	return fight
	
func get_random_boss_reward(level):
	var rng = RandomNumberGenerator.new()
	var random_num = 0
	var reward = null
	match level:
		1:
			random_num = rng.randi_range(0,miniboss_1_rewards.size()-1)
			reward = miniboss_1_rewards[random_num]
	return reward
func get_random_reward(level):
	var rng = RandomNumberGenerator.new()
	var random_num = 0
	var reward = null
	match level:
		1:
			random_num = rng.randi_range(0,level_1_rewards.size()-1)
			reward = level_1_rewards[random_num]
		2:
			random_num = rng.randi_range(0,level_2_rewards.size()-1)
			reward = level_2_rewards[random_num]
		3:
			random_num = rng.randi_range(0,level_3_rewards.size()-1)
			reward = level_3_rewards[random_num]
		4:
			random_num = rng.randi_range(0,level_4_rewards.size()-1)
			reward = level_4_rewards[random_num]
		5:
			random_num = rng.randi_range(0,level_5_rewards.size()-1)
			reward = level_5_rewards[random_num]
		6:
			random_num = rng.randi_range(0,level_6_rewards.size()-1)
			reward = level_6_rewards[random_num]
		7:
			random_num = rng.randi_range(0,level_7_rewards.size()-1)
			reward = level_7_rewards[random_num]
		8:
			random_num = rng.randi_range(0,level_8_rewards.size()-1)
			reward = level_8_rewards[random_num]
	return reward
