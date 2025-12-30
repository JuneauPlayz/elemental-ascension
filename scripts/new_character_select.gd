extends Node2D

@onready var fire_girl: Draggable = $GridContainer/FireGirl
@onready var water_girl: Draggable = $GridContainer/WaterGirl
@onready var grass_girl: Draggable = $GridContainer/GrassGirl
@onready var lightning_girl: Draggable = $GridContainer/LightningGirl
@onready var earth_girl: Draggable = $GridContainer/EarthGirl

var game

const RUN = preload("res://scenes/main scenes/run.tscn")

const FIRE_GIRL = preload("res://resources/units/allies/FireGirl.tres")
const GRASS_GIRL = preload("uid://rch61bky2ck8")
const EARTH_GIRL = preload("uid://brb2gubx0hm1h")
const LIGHTNING_GIRL = preload("res://resources/units/allies/LightningGirl.tres")
const WATER_GIRL = preload("uid://ct8pg6i13eoib")

var fire_girl_spot
var water_girl_spot
var grass_girl_spot
var lightning_girl_spot
var earth_girl_spot

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

var sound_allowed = false

@onready var character_info: Label = $CharacterInfo
@onready var skill_info_1: Control = $CharacterInfo/SkillInfo1
@onready var skill_info_2: Control = $CharacterInfo/SkillInfo2
@onready var base_hp: Label = $CharacterInfo/Base_HP


func _ready() -> void:
	game = get_tree().get_first_node_in_group("game")
	
	characters.append(fire_girl)
	characters.append(water_girl)
	characters.append(grass_girl)
	characters.append(lightning_girl)
	characters.append(earth_girl)
	
	character_res_list.append(FIRE_GIRL)
	character_res_list.append(WATER_GIRL)
	character_res_list.append(GRASS_GIRL)
	character_res_list.append(LIGHTNING_GIRL)
	character_res_list.append(EARTH_GIRL)
	
	update_positions()
	
	character_info.visible = false
	await get_tree().process_frame
	sound_allowed = true
	

func update_positions():
	if fire_girl:
		fire_girl_spot = fire_girl.global_position
	if water_girl:
		water_girl_spot = water_girl.global_position
	if grass_girl:
		grass_girl_spot = grass_girl.global_position
	if lightning_girl:
		lightning_girl_spot = lightning_girl.global_position
	if earth_girl:
		earth_girl_spot = earth_girl.global_position


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
	AudioPlayer.play_FX("deeper_new_click")
	if empty_team == false:
		GC.load_run(ally1, ally2, ally3, ally4)
		game.new_scene(RUN)


func check_spot(char, og_spot):
	update_positions()
	for character in characters:
		if char != character:
			if char.global_position == character.global_position:
				char.global_position = og_spot
				update_positions()


# Drag ended signals
func _on_fire_girl_drag_ended() -> void:
	check_spot(fire_girl, fire_girl_spot)
	if sound_allowed:
		AudioPlayer.play_FX("new_click")

func _on_water_girl_drag_ended() -> void:
	check_spot(water_girl, water_girl_spot)
	if sound_allowed:
		AudioPlayer.play_FX("new_click")

func _on_grass_girl_drag_ended() -> void:
	check_spot(grass_girl, grass_girl_spot)
	if sound_allowed:
		AudioPlayer.play_FX("new_click")

func _on_lightning_girl_drag_ended() -> void:
	check_spot(lightning_girl, lightning_girl_spot)
	if sound_allowed:
		AudioPlayer.play_FX("new_click")

func _on_earth_girl_drag_ended() -> void:
	check_spot(earth_girl, earth_girl_spot)
	if sound_allowed:
		AudioPlayer.play_FX("new_click")


# Drag started signals
func _on_fire_girl_drag_started() -> void:
	if sound_allowed:
		AudioPlayer.play_FX("click")

func _on_water_girl_drag_started() -> void:
	if sound_allowed:
		AudioPlayer.play_FX("click")

func _on_grass_girl_drag_started() -> void:
	if sound_allowed:
		AudioPlayer.play_FX("click")

func _on_lightning_girl_drag_started() -> void:
	if sound_allowed:
		AudioPlayer.play_FX("click")

func _on_earth_girl_drag_started() -> void:
	if sound_allowed:
		AudioPlayer.play_FX("click")


func display_character_info(character):
	character_info.visible = true
	character_info.text = character.name
	base_hp.text = "Base HP: " + str(character.starting_health) + "  HP"
	skill_info_1.skill = character.skill1
	skill_info_2.skill = character.skill2
	skill_info_1.update_skill_info()
	skill_info_2.update_skill_info()


# Mouse entered signals
func _on_fire_girl_mouse_entered() -> void:
	display_character_info(FIRE_GIRL)	

func _on_water_girl_mouse_entered() -> void:
	display_character_info(WATER_GIRL)

func _on_grass_girl_mouse_entered() -> void:
	display_character_info(GRASS_GIRL)

func _on_lightning_girl_mouse_entered() -> void:
	display_character_info(LIGHTNING_GIRL)

func _on_earth_girl_mouse_entered() -> void:
	display_character_info(EARTH_GIRL)
