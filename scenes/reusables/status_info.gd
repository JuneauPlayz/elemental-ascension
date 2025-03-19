extends Control
@onready var status_name: RichTextLabel = %StatusName
@onready var description: RichTextLabel = %Description
@onready var turns_remaining: RichTextLabel = %TurnsRemaining


func update(status):
	match status.name:
		"Burn":
			status_name.text = "Burn (Does not stack)"
			description.text = "This unit takes " + str(status.damage) + " " + status.element + " damage at the start of their turn"
			turns_remaining.text = " Turns Remaining : " + str(status.turns_remaining)
		_:
			status_name.text = "Finish"
			description.text = "the rest of the statuses u bob"
			turns_remaining.text = "bob"
	
			
