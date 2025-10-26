extends Node2D
@onready var fire_girl: Draggable = $GridContainer/FireGirl
@onready var water_girl: Draggable = $GridContainer/WaterGirl
@onready var venasaur: Draggable = $GridContainer/Venasaur
@onready var pikachu: Draggable = $GridContainer/Pikachu
@onready var golem: Draggable = $GridContainer/Golem


var game

const RUN = preload("res://scenes/main scenes/run.tscn")

const FIRE_GIRL = preload("res://resources/units/allies/FireGirl.tres")
const VENASAUR = preload("res://resources/units/allies/Venasaur.tres")
const PIKACHU = preload("res://resources/units/allies/Pikachu.tres")
const GOLEM = preload("res://resources/units/allies/Golem.tres")
const WATER_GIRL = preload("uid://ct8pg6i13eoib")

var fire_girl_spot
var water_girl_spot
var venasaur_spot
var pikachu_spot
var golem_spot

var empty_team = true



var characters = []
var character_res_list = []

@onready var ally_1_spot: ColorRect = $GridContainer/Ally1Spot
@onready var ally_2_spot: ColorRect = $GridContainer/Ally2Spot
@onready var ally_3_spot: ColorRect = $GridContainer/Ally3Spot
@onready var ally_4_spot: ColorRect = $GridContainer/Ally4Spot

var ally1
var ally2
var ally3
var ally4

@onready var character_info: Label = $CharacterInfo
@onready var skill_info_1: Control = $CharacterInfo/SkillInfo1
@onready var skill_info_2: Control = $CharacterInfo/SkillInfo2
@onready var base_hp: Label = $CharacterInfo/Base_HP


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game = get_tree().get_first_node_in_group("game")
	
	characters.append(fire_girl)
	characters.append(water_girl)
	characters.append(venasaur)
	characters.append(pikachu)
	characters.append(golem)
	
	character_res_list.append(FIRE_GIRL)
	character_res_list.append(WATER_GIRL)
	character_res_list.append(VENASAUR)
	character_res_list.append(PIKACHU)
	character_res_list.append(GOLEM)
	
	update_positions()
	_on_fire_girl_drag_ended()
	_on_water_girl_drag_ended()
	_on_venasaur_drag_ended()
	_on_pikachu_drag_ended()
	_on_golem_drag_ended()
	
	character_info.visible = false
	
func update_positions():
	if fire_girl:
		fire_girl_spot = fire_girl.global_position
	if water_girl:
		water_girl_spot = water_girl.global_position
	if venasaur:
		venasaur_spot = venasaur.global_position
	if pikachu:
		pikachu_spot = pikachu.global_position
	if golem:
		golem_spot = golem.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass





func _on_begin_run_pressed() -> void:
	for i in range(characters.size()):
		if characters[i].global_position == ally_1_spot.global_position:
			ally1 = character_res_list[i]
			empty_team = false
		elif characters[i].global_position == ally_2_spot.global_position:
			ally2 = character_res_list[i]
			empty_team = false
		elif characters[i].global_position == ally_3_spot.global_position:
			ally3 = character_res_list[i]
			empty_team = false
		elif characters[i].global_position == ally_4_spot.global_position:
			ally4 = character_res_list[i]
			empty_team = false
	if empty_team == false:
		GC.load_run(ally1,ally2,ally3,ally4)
		game.new_scene(RUN)

func check_spot(char, og_spot):
	update_positions()
	for character in characters:
		if char != character:
			if char.global_position == character.global_position:
				char.global_position = og_spot
				update_positions()

func _on_fire_girl_drag_ended() -> void:
	check_spot(fire_girl, fire_girl_spot)


func _on_water_girl_drag_ended() -> void:
	check_spot(water_girl, water_girl_spot)


func _on_venasaur_drag_ended() -> void:
	check_spot(venasaur, venasaur_spot)


func _on_pikachu_drag_ended() -> void:
	check_spot(pikachu, pikachu_spot)


func _on_golem_drag_ended() -> void:
	check_spot(golem, golem_spot)

func display_character_info(character):
	character_info.visible = true
	character_info.text = character.name
	base_hp.text = "Base HP: " + str(character.starting_health) + "  HP"
	skill_info_1.skill = character.skill1
	skill_info_2.skill = character.skill2
	skill_info_1.update_skill_info()
	skill_info_2.update_skill_info()
	
func _on_fire_girl_mouse_entered() -> void:
	display_character_info(FIRE_GIRL)	


func _on_water_girl_mouse_entered() -> void:
	display_character_info(WATER_GIRL)


func _on_venasaur_mouse_entered() -> void:
	display_character_info(VENASAUR)


func _on_pikachu_mouse_entered() -> void:
	display_character_info(PIKACHU)


func _on_golem_mouse_entered() -> void:
	display_character_info(GOLEM)
