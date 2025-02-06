extends Resource
class_name Skill
@export var name: String
@export_category("Necessary")
@export var damage : int = 5
@export_enum("none", "water", "fire", "lightning", "earth", "grass") var element : String
@export var damaging = false
@export var healing = false
@export var shielding = false
@export_enum("single_enemy", "single_ally", "all_enemies", "all_allies", "all_units", "front_enemy", "front_ally", "back_enemy", "back_ally", "random_enemy", "random_ally") var target_type : String
@export var purchaseable = true
@export_enum("Common","Rare","Epic", "Legendary") var tier : String = "Common"

@export_category("Extras")
@export var friendly = false
@export var lifesteal = false
@export var lifesteal_rate : float = 1.0

@export_category("Cost")
@export var cost = 0
@export_enum("water", "fire", "lightning", "earth", "grass") var token_type : String
@export var cost2 = 0
@export_enum("water", "fire", "lightning", "earth", "grass") var token_type2 : String

@export var status_effects : Array = []


@export_category("Double Hit")
@export var double_hit = false
@export var damage2 : int = 0
@export_enum("none", "water", "fire", "lightning", "earth", "grass") var element2 : String

@export_category("Tags")
@export_enum("Fire","Water","Lightning","Grass","Earth","Single Target","AOE","Healing","Shielding","Damage") var tag1 : String
@export_enum("Fire","Water","Lightning","Grass","Earth","Single Target","AOE","Healing","Shielding","Damage") var tag2 : String
@export_enum("Single Target","AOE","Blast") var target_tag : String
@export var tags = []

var final_damage : int

func _ready():
	final_damage = damage

func update():
	final_damage = damage
	if tags == []:
		if tag1 != null:
			tags.append(tag1)
		if tag2 != null:
			tags.append(tag2)
		if target_tag != null:
			tags.append(target_tag)

	
