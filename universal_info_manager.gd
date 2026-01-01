extends Control

var main_display

@onready var displays: HBoxContainer = %Displays

const UNIVERSAL_SKILL_INFO = preload("uid://ddskj68e5o6q7")
const KEYSTONE_INFO = preload("uid://ppg1wk60cwxc")

func new_display(display):
	for child in displays.get_children():
		child.queue_free()
	if display is Skill:
		main_display = UNIVERSAL_SKILL_INFO.instantiate()
		displays.add_child(main_display)
		main_display.skill = display
		main_display.update_skill_info()
	elif display is Keystone:
		main_display = KEYSTONE_INFO.instantiate()
		displays.add_child(main_display)
		main_display.update_keystone_info(display)

func hide_display():
	for child in displays.get_children():
		child.queue_free()
