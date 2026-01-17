class_name TriggerCondition
extends Resource

@export_enum("Pre", "Post") var timing : String
@export_enum("Skill", "Damage", "Reaction", "Turn") var condition_type : String
@export_enum("fire", "water", "lightning", "grass", "earth") var element : String
@export_enum("vaporize", "detonate", "burn", "erupt", "shock", "bloom", "muck", "nitro", "discharge", "sow") var reaction : String

func matches(event: Dictionary) -> bool:
	if event.type != condition_type:
		return false
	if event.timing != timing:
		return false

	match condition_type:
		"Skill":
			return event.element == element
		"Reaction":
			return event.reaction == reaction
		_:
			return true
