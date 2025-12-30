extends Resource
class_name UnitRes

@export var name: String
@export var starting_health: int

@export var sprite: Texture2D
@export var sprite_scale := 1.0
@export var cutin_portrait: Texture2D

@export var skill1: Skill
@export var skill2: Skill
@export var skill3: Skill
@export var skill4: Skill

@export var core_main_stat: CoreUpgrade
