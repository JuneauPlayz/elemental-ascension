extends Resource
class_name UnitRes

@export var starting_health : int
@export var skill1 : Skill
@export var skill2 : Skill
@export var skill3 : Skill
@export var skill4 : Skill

var ally_num : int
var level = 0
var level_up = false
@export_category("Level Up Reward 1")
@export var relic_1 : Relic
@export var relic_2 : Relic

@export_category("Level Up Reward 2")
@export var ult_1 : Skill
@export var ult_2 : Skill

@export_category("Level Up Reward 3")
@export var relic_3 : Relic
@export var relic_4 : Relic

@export var sprite : Texture
@export var sprite_scale = 1.0

@export var name : String

@export var fire_damage_block : int
