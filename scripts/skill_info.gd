extends Control

@export var skill: Skill

@onready var skill_name: RichTextLabel = %SkillName
@onready var tags: RichTextLabel = %Tags
@onready var target_label: RichTextLabel = %Target
@onready var description: RichTextLabel = %Description
@onready var costs: HBoxContainer = %Costs
@onready var cost_label: Label = %CostLabel

const EARTH_SYMBOL = preload("uid://dgkpabaj1kl5r")
const FIRE_SYMBOL = preload("uid://ega8yf10nrw")
const GRASS_SYMBOL = preload("uid://6wem028prmhu")
const LIGHTNING_SYMBOL = preload("uid://c2a810t6sstxx")
const WATER_SYMBOL = preload("uid://b7ctbguy8vt4q")

func _ready() -> void:
	_clear_costs()
	description.text = ""

func update_skill_info() -> void:
	if skill == null:
		return

	_clear_costs()
	description.text = ""

	# Skill name
	skill_name.text = _color_element(skill.name, skill.element)

	# Target label
	target_label.text = _color_target(" " + _get_target_text(skill.target_type))

	_build_description()
	_build_costs()
	_build_tags()

# --------------------------------------------------
# Coloring helpers
# --------------------------------------------------

func _color_element(text: String, element: String) -> String:
	match element:
		"fire": return "[color=coral]%s[/color]" % text
		"water": return "[color=dark_cyan]%s[/color]" % text
		"lightning": return "[color=yellow]%s[/color]" % text
		"grass": return "[color=web_green]%s[/color]" % text
		"earth": return "[color=saddle_brown]%s[/color]" % text
		_: return text

func _color_target(text: String) -> String:
	return "[color=lavender]%s[/color]" % text

# --------------------------------------------------
# Target text
# --------------------------------------------------

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

# --------------------------------------------------
# Description
# --------------------------------------------------

func _build_description() -> void:
	var lines: Array[String] = []

	var raw_target := _get_target_text(skill.target_type)
	var target := _color_target(raw_target)
	var elem := _color_element(skill.element.capitalize(), skill.element)

	if skill.damaging:
		lines.append("Deal %d %s Damage to %s" % [skill.damage, elem, target])

	if skill.healing:
		lines.append("Heal %d health as %s to %s" % [skill.damage, elem, target])

	if skill.shielding:
		lines.append("Grant %d shield to %s" % [skill.damage, target])

	if skill.buff:
		lines.append("Apply buff (%d) to %s" % [skill.buff_value, target])

	if skill.summon != null:
		lines.append("Summon %s" % skill.summon.name)

	if skill.blast:
		lines.append("Blast for %d Damage" % skill.blast_damage)

	if skill.double_hit:
		var elem2 := _color_element(skill.element2.capitalize(), skill.element2)
		lines.append("Then deal %d %s Damage" % [skill.damage2, elem2])

	if skill.lifesteal:
		lines.append("Gain lifesteal")

	for s in skill.status_effects:
		lines.append("Apply " + s.name)

	description.text = " " + " \n".join(lines)

# --------------------------------------------------
# Costs
# --------------------------------------------------

func _clear_costs() -> void:
	for c in costs.get_children():
		if c != cost_label:
			c.queue_free()

func _build_costs() -> void:
	var has_cost := false

	if skill.cost > 0:
		has_cost = true
		_add_cost(skill.cost, skill.token_type)

	if skill.cost2 > 0:
		has_cost = true
		_add_cost(skill.cost2, skill.token_type2)

	costs.visible = has_cost

func _add_cost(amount: int, token: String) -> void:
	# Create label with outline
	var label := Label.new()
	label.text = str(amount)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("outline_size", 10)
	label.add_theme_color_override("font_outline_color", Color.BLACK)


	costs.add_child(label)

	# Add icon
	var icon := TextureRect.new()
	icon.texture = _get_token_texture(token)
	icon.custom_minimum_size = Vector2(25, 25)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	costs.add_child(icon)


func _get_token_texture(token: String) -> Texture2D:
	match token:
		"fire": return FIRE_SYMBOL
		"water": return WATER_SYMBOL
		"lightning": return LIGHTNING_SYMBOL
		"grass": return GRASS_SYMBOL
		"earth": return EARTH_SYMBOL
		_: return null

# --------------------------------------------------
# Tags
# --------------------------------------------------

func _build_tags() -> void:
	if skill.tags.is_empty():
		tags.visible = false
		return

	tags.visible = true
	var parts: Array[String] = []

	for tag in skill.tags:
		match tag:
			"Fire": parts.append("[color=coral]Fire[/color]")
			"Water": parts.append("[color=dark_cyan]Water[/color]")
			"Lightning": parts.append("[color=yellow]Lightning[/color]")
			"Grass": parts.append("[color=web_green]Grass[/color]")
			"Earth": parts.append("[color=saddle_brown]Earth[/color]")
			"": pass
			_: parts.append(tag)

	tags.text = " " + " / ".join(parts)
