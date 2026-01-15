class_name Keystone
extends Resource


@export_category("Identity")
@export var name: String
@export_enum("Common", "Rare", "Epic", "Legendary") var tier: String = "Common"

@export_category("Element Slots")
# Which elemental slots this keystone occupies.
# Examples:
#   Fire keystone        -> ["fire"]
#   Vaporize keystone   -> ["fire", "water"]
@export var element_slots: Array[String] = []
@export var triggers : Array[Trigger]

@export_category("Tags")
@export var tags: Array[String] = []

@export_category("Visual")
@export var icon: Texture
@export_multiline var tooltip: String

func initialize_keystone(ui):
	pass
