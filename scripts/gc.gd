extends Node

var is_dragging = false

const GLOBAL_INTERVAL = 0.15
# global currencies

const ALLY = preload("res://resources/units/allies/ally.tscn")
const CHILL_GUY = preload("res://resources/units/enemies/ChillGuy.tres")
const PYROMANCER = preload("res://resources/units/enemies/pyromancer.tres")
const TEAM_MAGMA_GRUNT = preload("res://resources/units/enemies/TeamMagmaGrunt.tres")
const HYDROMANCER = preload("res://resources/units/enemies/hydromancer.tres")
const BAGUETTE = preload("res://resources/units/enemies/Baguette.tres")
const ORB_WIZARD = preload("res://resources/units/enemies/OrbWizard.tres")
const LIGHTNING_MASTER = preload("res://resources/units/enemies/LightningMaster.tres")
const THEFINALBOSS = preload("res://resources/units/enemies/THEFINALBOSS.tres")

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

#transition to run:

var ally1 : UnitRes
var ally2 : UnitRes
var ally3 : UnitRes
var ally4 : UnitRes


func load_run(ally1, ally2, ally3, ally4):
	self.ally1 = ally1
	self.ally2 = ally2
	self.ally3 = ally3
	self.ally4 = ally4
