extends Control
@onready var status_name: RichTextLabel = %StatusName
@onready var description: RichTextLabel = %Description
@onready var turns_remaining: RichTextLabel = %TurnsRemaining


func update(status):
	var run = get_tree().get_first_node_in_group("run")
	match status.name:
		"Burn":
			status_name.text = "Burn (Does not stack)"
			description.text = "This unit takes " + str(status.damage) + " " + status.element + " damage at the start of their turn"
			turns_remaining.text = " Turns Remaining : " + str(status.turns_remaining)
		"Nitro":
			var percent := int(run.nitro_mult * 100)
			status_name.text = "Nitro (Does not stack)"
			description.text = "-" + str(percent) + "% Damage Reduction"
			turns_remaining.text = " Turns Remaining : " + str(status.turns_remaining)
		"Muck":
			var percent := int(run.muck_mult * 100)
			status_name.text = "Muck (Does not stack)"
			description.text = "All Skill Damage Mult -" + str(percent) + "%"
			turns_remaining.text = " Turns Remaining : " + str(status.turns_remaining)
		"Sow":
			status_name.text = "Sow (Can stack)"
			description.text = "When a skill hits this unit, the caster of the skill heals " + str(run.sow_healing) + " and gains " + str(run.sow_shielding) + " shield"
		"Bubble":
			status_name.text = "Bubble (Does not stack)"
			description.text = "This unit takes " + str(run.bubble_mult) + "x damage"
		_:
			status_name.text = "Finish"
			description.text = "the rest of the statuses u bob"
			turns_remaining.text = "bob"
	
			
