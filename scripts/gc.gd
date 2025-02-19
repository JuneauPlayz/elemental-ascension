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

# events
const REST_EVENT = preload("res://rest_event.tscn")
const SPECIAL_SHOP_EVENT = preload("res://SpecialShopEvent.tscn")
const SACRIFICE_EVENT = preload("res://sacrifice_event.tscn")

const L1R1 = preload("res://resources/rewards/level1/L1R1.tres")
const L1R2 = preload("res://resources/rewards/level1/L1R2.tres")
const L1R3 = preload("res://resources/rewards/level1/L1R3.tres")

# predetermined fights
var fight_1 = [TEAM_MAGMA_GRUNT, CHILL_GUY, null, null]
var fight_1_reward = 6

var fight_2 = [CHILL_GUY, TEAM_MAGMA_GRUNT, BAGUETTE, null]
var fight_2_reward = 6

var fight_3 = [PYROMANCER, HYDROMANCER, null, null]
var fight_3_reward = 9

var fight_4 = [CHILL_GUY, LIGHTNING_MASTER, BAGUETTE, ORB_WIZARD]
var fight_4_reward = 12

var fight_5 = [PYROMANCER, HYDROMANCER, LIGHTNING_MASTER, ORB_WIZARD]
var fight_5_reward = 15

var fight_6 = [null, null, THEFINALBOSS, null]
var fight_6_reward = 18

var level_1_fights = [fight_1]
var level_1_rewards = [L1R1,L1R2,L1R3]
var level_2_fights = [fight_2]
var level_2_rewards = [L1R1,L1R2,L1R3]
var level_3_fights = [fight_3]
var level_3_rewards = [L1R1,L1R2,L1R3]

#transition to run:

var ally1 : UnitRes
var ally2 : UnitRes
var ally3 : UnitRes
var ally4 : UnitRes

var events = [REST_EVENT, SPECIAL_SHOP_EVENT, SACRIFICE_EVENT, REST_EVENT, SPECIAL_SHOP_EVENT,]

func load_run(ally1, ally2, ally3, ally4):
	self.ally1 = ally1
	self.ally2 = ally2
	self.ally3 = ally3
	self.ally4 = ally4
	
func get_random_event():
	if events == []:
		return null
	var rng = RandomNumberGenerator.new()
	var random_num = rng.randi_range(0,events.size()-1)
	var event = events[random_num]
	
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
	return fight
	
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
	return reward
