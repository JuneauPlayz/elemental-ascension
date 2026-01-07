class_name Trigger
extends Resource

@export_enum("Skill", "Turn") var action : String
@export_enum("Pre", "Post") var timing : String

@export var value : int = 0
@export_enum("Fire", "Water", "Lightning", "Grass", "Earth", "Neutral") var element : String
@export_enum("Damage", "Healing", "Shielding") var value_type : String
@export_enum("single_enemy", "single_ally", "all_enemies", "all_allies", "all_units", "front_enemy", "front_ally", "back_enemy", "back_ally", "front_2_allies", "back_2_allies", "front_2_enemies", "back_2_enemies", "random_middle_ally", "random_enemy", "random_ally") var target_type : String = ""
