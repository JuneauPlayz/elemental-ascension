extends PanelContainer

const EARTH_SYMBOL = preload("uid://dgkpabaj1kl5r")
const FIRE_SYMBOL = preload("uid://ega8yf10nrw")
const GRASS_SYMBOL = preload("uid://6wem028prmhu")
const LIGHTNING_SYMBOL = preload("uid://c2a810t6sstxx")
const WATER_SYMBOL = preload("uid://b7ctbguy8vt4q")

@onready var countdown_label: Label = %Countdown
@onready var target: RichTextLabel = %Target
@onready var action: Label = %Action
@onready var element_symbol: TextureRect = %ElementSymbol

var skill: Skill
var run

func _ready() -> void:
	run = get_tree().get_first_node_in_group("run")

func update_skill_info(countdown: int) -> void:
	if skill == null:
		return

	if countdown >= 0:
		countdown_label.text = str(countdown)
	else:
		visible = false
		return

	var action_type := "Effect"
	var value := 0

	if skill.damaging:
		action_type = "Damage"
		value = skill.damage
	elif skill.healing:
		action_type = "Healing"
		value = skill.damage
	elif skill.shielding:
		action_type = "Shielding"
		value = skill.damage

	if value > 0:
		action.text = str(value) + " " + action_type
	else:
		action.text = action_type

	target.text = _color_target(_get_target_text(skill.target_type))

	match skill.element:
		"fire": element_symbol.texture = FIRE_SYMBOL
		"water": element_symbol.texture = WATER_SYMBOL
		"lightning": element_symbol.texture = LIGHTNING_SYMBOL
		"earth": element_symbol.texture = EARTH_SYMBOL
		"grass": element_symbol.texture = GRASS_SYMBOL
		_: element_symbol.texture = null

func _color_target(text: String) -> String:
	return "[color=lavender]%s[/color]" % text

func _get_target_text(t: String) -> String:
	match t:
		"single_enemy": return "Any Enemy"
		"single_ally": return "Any Ally"
		"all_allies": return "All Allies"
		"all_enemies": return "All Enemies"
		"all_units": return "All Units"
		"front_ally": return "Front Ally"
		"front_2_allies": return "Two Closest Allies"
		"front_enemy": return "Front Enemy"
		"front_2_enemies": return "Two Closest Enemies"
		"back_ally": return "Back Ally"
		"back_2_allies": return "Two Farthest Allies"
		"back_enemy": return "Back Enemy"
		"back_2_enemies": return "Back Two Enemies"
		"random_enemy": return "Random Enemy"
		"random_ally": return "Random Ally"
		"random_middle_ally": return "Random Middle Ally"
		_: return ""

func _on_mouse_entered() -> void:
	run.UIManager.display(skill)

func _on_mouse_exited() -> void:
	run.UIManager.hide_display()
