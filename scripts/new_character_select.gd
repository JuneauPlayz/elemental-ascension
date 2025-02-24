extends Node2D
@onready var charizard: Draggable = $GridContainer/Charizard
@onready var blastoise: Draggable = $GridContainer/Blastoise
@onready var venasaur: Draggable = $GridContainer/Venasaur
@onready var pikachu: Draggable = $GridContainer/Pikachu
@onready var golem: Draggable = $GridContainer/Golem

const CHARIZARD = preload("res://resources/units/allies/Charizard.tres")
const BLASTOISE = preload("res://resources/units/allies/Blastoise.tres")
const VENASAUR = preload("res://resources/units/allies/Venasaur.tres")
const PIKACHU = preload("res://resources/units/allies/Pikachu.tres")
const GOLEM = preload("res://resources/units/allies/Golem.tres")

var charizard_spot
var blastoise_spot
var venasaur_spot
var pikachu_spot
var golem_spot

var empty_team = true

const BAGUETTE = preload("res://resources/units/enemies/Baguette.tres")
const BURGER_ENEMY = preload("res://resources/units/enemies/Burger.tres")

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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	characters.append(charizard)
	characters.append(blastoise)
	characters.append(venasaur)
	characters.append(pikachu)
	characters.append(golem)
	
	character_res_list.append(CHARIZARD)
	character_res_list.append(BLASTOISE)
	character_res_list.append(VENASAUR)
	character_res_list.append(PIKACHU)
	character_res_list.append(GOLEM)
	
	update_positions()
	_on_charizard_drag_ended()
	_on_blastoise_drag_ended()
	_on_venasaur_drag_ended()
	_on_pikachu_drag_ended()
	_on_golem_drag_ended()

func update_positions():
	if charizard:
		charizard_spot = charizard.global_position
	if blastoise:
		blastoise_spot = blastoise.global_position
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
		get_tree().change_scene_to_file("res://scenes/main scenes/run.tscn")

func check_spot(char, og_spot):
	update_positions()
	for character in characters:
		if char != character:
			if char.global_position == character.global_position:
				char.global_position = og_spot
				update_positions()

func _on_charizard_drag_ended() -> void:
	check_spot(charizard, charizard_spot)


func _on_blastoise_drag_ended() -> void:
	check_spot(blastoise, blastoise_spot)


func _on_venasaur_drag_ended() -> void:
	check_spot(venasaur, venasaur_spot)


func _on_pikachu_drag_ended() -> void:
	check_spot(pikachu, pikachu_spot)


func _on_golem_drag_ended() -> void:
	check_spot(golem, golem_spot)

func display_character_info(character):
	character_info.visible = true
	character_info.text = character.name + "  " + str(character.starting_health) + "  HP"
	skill_info_1.skill = character.skill1
	skill_info_2.skill = character.skill2
	skill_info_1.update_skill_info()
	skill_info_2.update_skill_info()
	
func _on_charizard_mouse_entered() -> void:
	display_character_info(CHARIZARD)


func _on_blastoise_mouse_entered() -> void:
	display_character_info(BLASTOISE)


func _on_venasaur_mouse_entered() -> void:
	display_character_info(VENASAUR)


func _on_pikachu_mouse_entered() -> void:
	display_character_info(PIKACHU)


func _on_golem_mouse_entered() -> void:
	display_character_info(GOLEM)
