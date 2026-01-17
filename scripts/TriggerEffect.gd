class_name TriggerEffect
extends Resource

@export_enum("Damage", "Healing", "Shielding", "Status") var value_type : String
@export var value : int
@export_enum("fire","water","lightning","grass","earth", "neutral") var element : String
@export_enum("single_enemy", "single_ally", "all_enemies", "all_allies", "all_units", "front_enemy", "front_ally", "back_enemy", "back_ally", "front_2_allies", "back_2_allies", "front_2_enemies", "back_2_enemies", "random_middle_ally", "random_enemy", "random_ally") var target_type : String 
@export var statuses : Array[Status] 
