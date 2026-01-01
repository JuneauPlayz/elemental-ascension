extends Control


var selected = 0
signal new_select
@export var char : int

@onready var ba_1: Button = $PanelContainer/MarginContainer/VBoxContainer/BA1Panel/option1
@onready var s_1: Button = $PanelContainer/MarginContainer/VBoxContainer/SP1Panel/option2
@onready var confirm_swap: Button = $ConfirmSwap


var element_dict = {"none": Color.WHITE, "fire": Color.CORAL, "water": Color.DARK_CYAN, "lightning": Color.YELLOW, "earth": Color.SADDLE_BROWN, "grass": Color.WEB_GREEN}

var skill1 : Skill
var skill2 : Skill

var keystone1 : Keystone
var keystone2 : Keystone

var choosing_skills = false
var choosing_options = false

@onready var skill_info_1: Control = $SkillInfo
@onready var skill_info_2: Control = $SkillInfo2


var blue = Color("3f61a1")
var gray = Color("2e2e2e78")

func load_skills(s1,s2):
	choosing_skills = true
	confirm_swap.text = "Confirm Swap"
	skill1 = s1
	skill2 = s2
	skill1.update()
	update_font_color(ba_1,element_dict.get(skill1.element))
	skill2.update()
	update_font_color(s_1,element_dict.get(skill2.element))
	skill_info_1.skill = s1
	skill_info_1.update_skill_info()
	skill_info_2.skill = s2
	skill_info_2.update_skill_info()
	ba_1.text = skill1.name
	s_1.text = skill2.name

func load_options(o1,o2):
	choosing_options = true
	confirm_swap.text = "Add Keystone"
	
	

func _on_button_pressed() -> void:
	if selected != 1:
		selected = 1
	else:
		selected = 0
	if choosing_skills:
		update(skill1)
	if choosing_options:
		update(keystone1)

func _on_s_1_pressed() -> void:
	if selected != 2:
		selected = 2
	else:
		selected = 0
	if choosing_skills:
		update(skill2)
	if choosing_options:
		update(keystone2)


func update(skill):
	new_select.emit(skill)
	match selected:
		0:
			update_color(ba_1, gray)
			update_color(s_1, gray)

		1:
			update_color(ba_1, blue)
			update_color(s_1, gray)

		2:
			update_color(ba_1, gray)
			update_color(s_1, blue)

	
func update_color(button, color):
	var new_stylebox_normal = button.get_theme_stylebox("normal").duplicate()
	new_stylebox_normal.bg_color = color
	button.add_theme_stylebox_override("normal", new_stylebox_normal)
	
	
func update_font_color(button, color):
	button.add_theme_color_override("font_color", color)

	

	
func reset():
	update_color(ba_1, gray)
	update_color(s_1, gray)

	
func enable(num):
	match num:
		1:
			ba_1.disabled = false
		2:
			s_1.disabled = false

func disable(num):
	match num:
		1:
			ba_1.disabled = true
		2:
			s_1.disabled = true


func _on_ba_1_mouse_entered() -> void:
	if choosing_skills:
		skill_info_1.visible = true



func _on_s_1_mouse_entered() -> void:
	if choosing_skills:
		skill_info_2.visible = true




func _on_ba_1_mouse_exited() -> void:
	if choosing_skills:
		skill_info_1.visible = false



func _on_s_1_mouse_exited() -> void:
	if choosing_skills:
		skill_info_2.visible = false


func reset_vars():
	choosing_skills = false
	choosing_options = false
	confirm_swap.visible = false
	skill_info_1.visible = false
	skill_info_2.visible = false
