extends Control

@export var skill : Skill
@onready var skill_name: RichTextLabel = %SkillName
@onready var element: RichTextLabel = %Element
@onready var description: Label = %Description
@onready var target_label: Label = %Target
@onready var cost_label: Label = %Cost
@onready var tags: RichTextLabel = %Tags


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	description.text = ""

func update_skill_info():
	description.text = ""
	var target = ""
	skill_name.text = skill.name
	var element_text = ""
	tags.text = " Tags : "
	cost_label.text = ""
	match skill.element:
		"fire":
			element_text = " [color=coral]Fire[/color]"
		"water":
			element_text = " [color=dark_cyan]Water[/color]"
		"lightning":
			element_text = " [color=purple]Lightning[/color]"
		"grass":
			element_text = " [color=web_green]Grass[/color]"
		"earth":
			element_text = " [color=saddle_brown]Earth[/color]"
		
	element.text = "[center]" + element_text + "[/center]"
	match skill.target_type:
		"single_enemy":
			target = "Any Enemy"
		"single_ally":
			target = "Any Ally"
		"all_allies":
			target = "All Allies"
		"all_enemies":
			target = "All Enemies"
		"all_units":
			target = "All Units"
		"front_ally":
			target = "Front Ally"
		"front_2_allies":
			target = "Two Closest Allies"
		"front_enemy":
			target = "Front Enemy"
		"front_2_enemies":
			target = "Two Closest Enemies"
		"back_ally":
			target = "Back Ally"
		"back_2_allies":
			target = "Two Farthest Allies"
		"back_enemy":
			target = "Back Enemy"
		"back_2_enemies":
			target = "Back 2 Enemies"
		"random_enemy":
			target = "Random Enemy"
		"random_ally":
			target = "Random Ally"
		"random_middle_ally":
			target = "Random Middle Ally"
	target_label.text = " " + target
	if skill.damaging == true:
		description.text += "Damage " + str(skill.damage) 
	if skill.shielding == true:
		description.text += "Shield " + str(skill.damage)
	if skill.healing == true:
		description.text += "Heal " + str(skill.damage)
	if skill.buff == true:
		description.text += "Buff " + str(skill.damage)
	if skill.summon != null:
		description.text += "Summon " + skill.summon.name
	if description.text == "" and skill.element != "none" and not skill.buff:
		description.text = "Apply " + skill.element
	if skill.blast == true:
		description.text += "\nBlast " + str(skill.blast_damage)
	if skill.double_hit == true:
		description.text += "\nDouble Hit " + str(skill.damage2) + " " + str(skill.element2)
	if skill.lifesteal == true:
		description.text += "\nLifesteal"
	if skill.status_effects != []:
		for x in skill.status_effects:
			if x.name == "Bleed":
				description.text += "\nBleed"
			if x.name == "Burn":
				description.text += "\nBurn"
			if x.name == "Bubble":
				description.text += "\nBubble"
			if x.name == "Muck":
				description.text += "\nMuck"
			if x.name == "Nitro":
				description.text += "\nNitro"
			if x.name == "Sow":
				description.text += "\nSow"
	if skill.cost > 0:
		cost_label.visible = true
		cost_label.text += "Cost: " +  str(skill.cost) + " " + skill.token_type + " tokens"
		if skill.cost2 > 0:
			cost_label.text += "\n    " + str(skill.cost2) + " " + skill.token_type2 + " tokens"
	else:
		cost_label.visible = false
	
	if skill.tags == []:
		tags.visible = false
	else:
		tags.visible = true
		for tag in skill.tags:
			var added_text = tag
			match tag:
				"Fire":
					added_text = " [color=coral]Fire[/color]"
				"Water":
					added_text = " [color=dark_cyan]Water[/color]"
				"Lightning":
					added_text = " [color=purple]Lightning[/color]"
				"Grass":
					added_text = " [color=web_green]Grass[/color]"
				"Earth":
					added_text = " [color=saddle_brown]Earth[/color]"
			if tag != "" or null:
				tags.text += added_text + ",  "
		tags.text = tags.text.substr(0, tags.text.length()-3)
