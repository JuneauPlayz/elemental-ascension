extends Node
@onready var keystone_handler_spot: Node2D = $"../KeystoneHandlerSpot"
@onready var gold_text: RichTextLabel = $"../GoldText"
@onready var xp_bar: ProgressBar = $"../XPBar"
@onready var current_level: Label = $"../XPBar/CurrentLevel"
@onready var next_level: Label = $"../XPBar/NextLevel"
@onready var xp_number: Label = $"../XPBar/XPNumber"
@onready var xp_gain_position: Node2D = $"../XPBar/XPGainPosition"
@onready var reaction_guide: Button = $"../ReactionGuide"
@onready var reaction_panel: Control = $"../ReactionGuide/ReactionPanel"
@onready var loading: Node2D = $"../Loading"
@onready var universal_info_manager: Control = $"../UniversalInfoManager"

var freeze = false
var reaction_guide_open = false

signal reaction_guide_button_pressed

func set_gold(gold):
	gold_text.text = "[color=yellow]Gold[/color] : " + str(gold)
	
func set_xp(xp, current_xp_goal):
	xp_bar.value = xp
	xp_number.text = str(xp) + " / " + str(current_xp_goal) + " XP"

func set_current_level(level):
	current_level.text = str(level)
	next_level.text = str(level+1)

func toggle_reaction_panel():
	reaction_guide_button_pressed.emit()
	reaction_panel.update_mult_labels()
	if reaction_panel.visible:
		reaction_panel.visible = false
		reaction_guide_open = false
		#for enemy in enemies:
			#enemy.show_next_skill_info()
		#for ally in allies:
			#ally.spell_select_ui.visible = true
	elif not reaction_panel.visible:
		reaction_panel.visible = true
		reaction_guide_open = true
		#for enemy in enemies:
			#enemy.hide_next_skill_info()
		#for ally in allies:
			#ally.spell_select_ui.visible = false


func loading_screen(time):
	loading.visible = true
	await get_tree().create_timer(time).timeout
	loading.visible = false

func reset():
	reaction_guide_open = false

func display(object):
	universal_info_manager.new_display(object)
	
func hide_display():
	if not freeze:
		universal_info_manager.hide_display()

func freeze_info():
	freeze = true

func unfreeze_info():
	freeze = false

func _on_reaction_guide_pressed() -> void:
	toggle_reaction_panel()
