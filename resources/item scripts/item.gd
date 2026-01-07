class_name Item
extends Resource


@export_category("Identity")
@export var item_name: String
@export_enum("Weapon", "Armor", "Accessory") var type : String
@export_enum("Common", "Rare", "Epic", "Legendary") var tier: String = "Common"
@export var triggers : Array[Trigger]

@export_category("Tags")
@export var tags: Array[String] = []

@export_category("Visual")
@export var icon: Texture
@export_multiline var tooltip: String

func initialize_item(ui):
	pass
