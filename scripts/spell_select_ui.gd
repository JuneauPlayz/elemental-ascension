extends Control


var selected = 0
signal new_select
@export var char : int

@onready var ba_1: Button = $PanelContainer/MarginContainer/VBoxContainer/BA1Panel/ba_1
@onready var s_1: Button = $PanelContainer/MarginContainer/VBoxContainer/SP1Panel/S1
@onready var s_2: Button = $PanelContainer/MarginContainer/VBoxContainer/SP2Panel/S2
@onready var ult: Button = $PanelContainer/MarginContainer/VBoxContainer/ULTPanel/ULT


var element_dict = {"none": Color.WHITE, "fire": Color.CORAL, "water": Color.DARK_CYAN, "lightning": Color.PURPLE, "earth": Color.SADDLE_BROWN, "grass": Color.WEB_GREEN}

var run

var skill1 : Skill
var skill2 : Skill
var skill3 : Skill
var skill4 : Skill

var empty1 = false
var empty2 = false
var empty3 = false
var empty4 = false

var disabled_all = false

@onready var skill_info_1: Control = $SkillInfo
@onready var skill_info_2: Control = $SkillInfo2
@onready var skill_info_3: Control = $SkillInfo3
@onready var skill_info_4: Control = $SkillInfo4

var initial_load = false

var blue = Color("3f61a1")
var gray = Color("515461")

func load_skills():
	run = get_tree().get_first_node_in_group("run")
	if (skill1 != null):
		skill1.update()
		update_font_color(ba_1,element_dict.get(skill1.element))
		skill_info_1.skill = skill1
		skill_info_1.update_skill_info()
		ba_1.text = skill1.name
	else:
		empty(1)
	if (skill2 != null):
		skill2.update()
		update_font_color(s_1,element_dict.get(skill2.element))
		skill_info_2.skill = skill2
		skill_info_2.update_skill_info()
		s_1.text = skill2.name
	else:
		empty(2)
	if (skill3 != null):
		skill3.update()
		update_font_color(s_2,element_dict.get(skill3.element))
		skill_info_3.skill = skill3
		skill_info_3.update_skill_info()
		s_2.text = skill3.name
	else:
		empty(3)
	if (skill4 != null):
		skill4.update()
		update_font_color(ult,element_dict.get(skill4.element))
		skill_info_4.skill = skill4
		skill_info_4.update_skill_info()
		ult.text = skill4.name
	else:
		empty(4)
		
	if (run.shop):
		enable_all()
	if not initial_load and not run.shop:
		if skill1 and skill1.cost > 0:
			ba_1.disabled = true
		if skill2 and skill2.cost > 0:
			s_1.disabled = true
		if skill3 and skill3.cost > 0:
			s_2.disabled = true
		if skill4 and skill4.cost > 0:
			ult.disabled = true
		initial_load = true

func _on_button_pressed() -> void:
	if selected != 1:
		selected = 1
	else:
		selected = 0
	update()

func _on_s_1_pressed() -> void:
	if selected != 2:
		selected = 2
	else:
		selected = 0
	update()

func _on_s_2_pressed() -> void:
	if selected != 3:
		selected = 3
	else:
		selected = 0
	update()
	
func _on_ult_pressed() -> void:
	if selected != 4:
		selected = 4
	else:
		selected = 0
	update()
	
func update():
	new_select.emit(get_parent())
	match selected:
		0:
			update_color(ba_1, gray)
			update_color(s_1, gray)
			update_color(s_2, gray)
			update_color(ult, gray)
		1:
			update_color(ba_1, blue)
			update_color(s_1, gray)
			update_color(s_2, gray)
			update_color(ult, gray)
		2:
			update_color(ba_1, gray)
			update_color(s_1, blue)
			update_color(s_2, gray)
			update_color(ult, gray)
		3:
			update_color(ba_1, gray)
			update_color(s_1, gray)
			update_color(s_2, blue)
			update_color(ult, gray)
		4:
			update_color(ba_1, gray)
			update_color(s_1, gray)
			update_color(s_2, gray)
			update_color(ult, blue)
	
func update_color(button, color):
	var new_stylebox_normal = button.get_theme_stylebox("normal").duplicate()
	new_stylebox_normal.bg_color = color
	button.add_theme_stylebox_override("normal", new_stylebox_normal)
	
func update_color_disabled(button, color):
	var new_stylebox_disabled = button.get_theme_stylebox("disabled").duplicate()
	new_stylebox_disabled.bg_color = color
	button.add_theme_stylebox_override("disabled", new_stylebox_disabled)
	
	
func update_font_color(button, color):
	button.add_theme_color_override("font_color", color)
	button.add_theme_color_override("font_hover_color", color)


	
func reset():
	update_color(ba_1, gray)
	update_color(s_1, gray)
	update_color(s_2, gray)
	update_color(ult, gray)
	selected = 0
	disabled_all = false


func enable(num):
	match num:
		1:
			ba_1.disabled = false
			empty1 = false
		2:
			s_1.disabled = false
			empty2 = false
		3:
			s_2.disabled = false
			empty3 = false
		4:
			ult.disabled = false
			empty4 = false

func enable_all():
	ba_1.disabled = false
	s_1.disabled = false
	s_2.disabled = false
	ult.disabled = false
	empty1 = false
	empty2 = false
	empty3 = false
	empty4 = false

func disable(num):
	match num:
		1:
			ba_1.disabled = true
		2:
			s_1.disabled = true
		3:
			s_2.disabled = true
		4:
			ult.disabled = true

func disable_all():
	ba_1.disabled = true
	s_1.disabled = true
	s_2.disabled = true
	ult.disabled = true
	disabled_all = true

	
func empty(num):
	match num:
		1:
			ba_1.disabled = true
			update_color_disabled(ba_1, gray)
			empty1 = true
			ba_1.text = ""
		2:
			s_1.disabled = true
			update_color_disabled(s_1, gray)
			empty2 = true
			s_1.text = ""
		3:
			s_2.disabled = true
			update_color_disabled(s_2, gray)
			empty3 = true
			s_2.text = ""
		4:
			ult.disabled = true
			update_color_disabled(ult, gray)
			empty4 = true
			ult.text = ""
	
func _on_ba_1_mouse_entered() -> void:
	if (not empty1 and skill1):
		skill_info_1.visible = true


func _on_s_1_mouse_entered() -> void:
	if (not empty2 and skill2):
		skill_info_2.visible = true


func _on_s_2_mouse_entered() -> void:
	if (not empty3 and skill3):
		skill_info_3.visible = true


func _on_ult_mouse_entered() -> void:
	if (not empty4 and skill4):
		skill_info_4.visible = true


func _on_ba_1_mouse_exited() -> void:
	if (not empty1 and skill1):
		skill_info_1.visible = false


func _on_s_1_mouse_exited() -> void:
	if (not empty2 and skill2):
		skill_info_2.visible = false


func _on_s_2_mouse_exited() -> void:
	if (not empty3 and skill3):
		skill_info_3.visible = false


func _on_ult_mouse_exited() -> void:
	if (not empty4 and skill4):
		skill_info_4.visible = false
