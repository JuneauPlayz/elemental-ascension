extends Node2D

const RUN = preload("res://scenes/main scenes/run.tscn")

var p_allies = []
var p_enemies = []
var p_relics = []

var game

var ally1 : UnitRes
var ally2 : UnitRes
var ally3 : UnitRes
var ally4 : UnitRes
var enemy1 : UnitRes
var enemy2 : UnitRes
var enemy3 : UnitRes
var enemy4 : UnitRes

var relics = []
var relic_name : String

var allies_dict : Dictionary
var enemies_dict : Dictionary
var skills_dict : Dictionary
var skills_id_dict : Dictionary
var relics_dict : Dictionary
var id = 0

@onready var relics_p: OptionButton = $Relics

@onready var ally_1_p: OptionButton = $Ally1
@onready var ally_2_p: OptionButton = $Ally2
@onready var ally_3_p: OptionButton = $Ally3
@onready var ally_4_p: OptionButton = $Ally4
@onready var enemy_1_p: OptionButton = $Enemy1
@onready var enemy_2_p: OptionButton = $Enemy2
@onready var enemy_3_p: OptionButton = $Enemy3
@onready var enemy_4_p: OptionButton = $Enemy4
@onready var ally1_skill_1: OptionButton = $Ally1/Skill1
@onready var ally1_skill_2: OptionButton = $Ally1/Skill2
@onready var ally1_skill_3: OptionButton = $Ally1/Skill3
@onready var ally1_skill_4: OptionButton = $Ally1/Skill4
@onready var ally2_skill_1: OptionButton = $Ally2/Skill1
@onready var ally2_skill_2: OptionButton = $Ally2/Skill2
@onready var ally2_skill_3: OptionButton = $Ally2/Skill3
@onready var ally2_skill_4: OptionButton = $Ally2/Skill4
@onready var ally3_skill_1: OptionButton = $Ally3/Skill1
@onready var ally3_skill_2: OptionButton = $Ally3/Skill2
@onready var ally3_skill_3: OptionButton = $Ally3/Skill3
@onready var ally3_skill_4: OptionButton = $Ally3/Skill4
@onready var ally4_skill_1: OptionButton = $Ally4/Skill1
@onready var ally4_skill_2: OptionButton = $Ally4/Skill2
@onready var ally4_skill_3: OptionButton = $Ally4/Skill3
@onready var ally4_skill_4: OptionButton = $Ally4/Skill4



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dir = DirAccess.open("res://resources/units/allies")
	var allies = []
	game = get_tree().get_first_node_in_group("game")
	get_all_files_from_directory("res://resources/units/allies", "", allies)
	for filename in allies:
		var ally = load(filename)
		p_allies.append(ally)
		if ally is not PackedScene:
			allies_dict[ally.name] = ally
	
	dir = DirAccess.open("res://resources/units/enemies")
	var enemies = []
	get_all_files_from_directory("res://resources/units/enemies", "", enemies)
	for filename in enemies:
		var enemy = load(filename)
		p_enemies.append(enemy)
		if enemy is not PackedScene:
			enemies_dict[enemy.name] = enemy
		
	var o_allies = [ally_1_p, ally_2_p, ally_3_p, ally_4_p]
	var o_enemies = [enemy_1_p, enemy_2_p, enemy_3_p, enemy_4_p]
	for o_ally in o_allies:
		o_ally.add_item("none")
	
	for o_enemy in o_enemies:
		o_enemy.add_item("none")
	
	var count = 0
	for ally in p_allies:
		if ally is not PackedScene:
			count += 1
		for o_ally in o_allies:
			o_ally.get_popup().add_theme_font_size_override("font_size",  24)
			if ally is not PackedScene:
				o_ally.add_icon_item(ally.sprite, ally.name)
				o_ally.get_popup().set_item_icon_max_width(count, 50)
	count = 0
	for enemy in p_enemies:
		if enemy is not PackedScene:
			count += 1
		for o_enemy in o_enemies:
			o_enemy.get_popup().add_theme_font_size_override("font_size",  15)
			if enemy is not PackedScene:
				o_enemy.add_icon_item(enemy.sprite, enemy.name)
				o_enemy.get_popup().set_item_icon_max_width(count, 25)
				
	var element = ""
	var p_skills = []
	var ally_skills = [ally1_skill_1, ally1_skill_2, ally1_skill_3, ally1_skill_4, ally2_skill_1, ally2_skill_2, ally2_skill_3, ally2_skill_4, ally3_skill_1, ally3_skill_2, ally3_skill_3, ally3_skill_4, ally4_skill_1, ally4_skill_2, ally4_skill_3, ally4_skill_4]
	for ally_skill in ally_skills:
		ally_skill.add_item("none")
	for i in range(1,7):
		match i:
			1:
				element = "fire"
			2:
				element = "water"
			3:
				element = "lightning"
			4:
				element = "grass"
			5:
				element = "earth"
			6:
				element = "physical"
			7:
				element = "boss_skills"
		dir = DirAccess.open("res://resources/Skills/" + element)
		var skills = []
		get_all_files_from_directory("res://resources/Skills/" + element, "", skills)
		for filename in skills:
			var skill = load(filename)
			p_skills.append(skill)
			skills_dict[skill.name] = skill
			id += 1
			skills_id_dict[skill.name] = id
	for skill in p_skills:
		for ally_skill in ally_skills:
			ally_skill.get_popup().add_theme_font_size_override("font_size",  24)
			ally_skill.add_item(skill.name, id)
	relics_p.add_item("none")
	relics_p.get_popup().add_theme_font_size_override("font_size",  20)
	
	var file_relics = []
	get_all_files_from_directory("res://resources/relics", "", file_relics)
	for filename in file_relics:
		var relic = load(filename)
		p_relics.append(relic)
		relics_p.add_icon_item(relic.icon, relic.relic_name)
		relics_dict[relic.relic_name] = relic
	
			
func get_all_files_from_directory(path : String, file_ext:= "", files := []):
	var resources = ResourceLoader.list_directory(path)
	for res in resources:
		print(str(path+res))
		if res.ends_with("/"): 
			get_all_files_from_directory(path+res, file_ext, files)
		files.append(path+"/"+res)
	return files


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_ally_1_item_selected(index: int) -> void:
	var ally = ally_1_p.get_item_text(index)
	ally1_skill_1.select(skills_id_dict.get_or_add(allies_dict.get_or_add(ally).skill1.name))
	ally1_skill_2.select(skills_id_dict.get_or_add(allies_dict.get_or_add(ally).skill2.name))
	ally1 = allies_dict[ally]

func _on_ally_2_item_selected(index: int) -> void:
	var ally = ally_2_p.get_item_text(index)
	ally2_skill_1.select(skills_id_dict.get_or_add(allies_dict.get_or_add(ally).skill1.name))
	ally2_skill_2.select(skills_id_dict.get_or_add(allies_dict.get_or_add(ally).skill2.name))
	ally2 = allies_dict[ally]

func _on_ally_3_item_selected(index: int) -> void:
	var ally = ally_3_p.get_item_text(index)
	ally3_skill_1.select(skills_id_dict.get_or_add(allies_dict.get_or_add(ally).skill1.name))
	ally3_skill_2.select(skills_id_dict.get_or_add(allies_dict.get_or_add(ally).skill2.name))
	ally3 = allies_dict[ally]

func _on_ally_4_item_selected(index: int) -> void:
	var ally = ally_4_p.get_item_text(index)
	ally4_skill_1.select(skills_id_dict.get_or_add(allies_dict.get_or_add(ally).skill1.name))
	ally4_skill_2.select(skills_id_dict.get_or_add(allies_dict.get_or_add(ally).skill2.name))
	ally4 = allies_dict[ally]

func _on_start_combat_pressed() -> void:
	GC.load_run_combat_test(ally1, ally2, ally3, ally4, enemy1, enemy2, enemy3, enemy4, relics)
	game.new_scene(RUN)
	

func _on_enemy_1_item_selected(index: int) -> void:
	enemy1 = enemies_dict[enemy_1_p.get_item_text(index)]


func _on_enemy_2_item_selected(index: int) -> void:
	enemy2 = enemies_dict[enemy_2_p.get_item_text(index)]


func _on_enemy_3_item_selected(index: int) -> void:
	enemy3 = enemies_dict[enemy_3_p.get_item_text(index)]


func _on_enemy_4_item_selected(index: int) -> void:
	enemy4 = enemies_dict[enemy_4_p.get_item_text(index)]


func _on_relics_item_selected(index: int) -> void:
	relic_name = relics_p.get_item_text(index)


func _on_add_relic_pressed() -> void:
	if relic_name != "":
		relics.append(relics_dict[relic_name])
	relic_name = ""
	relics_p.select(0)
	DamageNumbers.display_text(relics_p.global_position + Vector2(350,150), "none", "Added!", 32)
