class_name Relic
extends Resource

enum Type {START_OF_TURN, START_OF_COMBAT, END_OF_TURN, END_OF_COMBAT, EVENT_BASED}

@export var relic_name : String
@export_enum("Common","Rare","Epic", "Legendary") var tier : String = "Common"
@export var type : Type
@export_category("Tags")
@export_enum("Fire","Water","Lightning","Grass","Earth","Single Target","AOE","Healing","Shielding","All") var tag1 : String
@export_enum("Fire","Water","Lightning","Grass","Earth","Single Target","AOE","Healing","Shielding","All") var tag2 : String
@export_enum("Fire","Water","Lightning","Grass","Earth","Single Target","AOE","Healing","Shielding","All") var tag3 : String
@export var tags = []
@export_category("Visual")
@export var icon : Texture
@export_multiline var tooltip : String

func _ready():
	pass

func update():
	if tags == []:
		if tag1 != null:
			tags.append(tag1)
		if tag2 != null:
			tags.append(tag2)
		if tag3 != null:
			tags.append(tag3)

func initialize_relic(_owner : RelicUI) -> void:
	pass
	
# Should be implemented by event-based rleics which connect to the EventBus to make sure that they are disconnected when a relic gets removed
func deactivate_relic(_owner : RelicUI) -> void:
	pass
	
func get_tooltip() -> String:
	return tooltip
