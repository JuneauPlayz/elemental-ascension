extends Control


@onready var items: HBoxContainer = %Items
@onready var weapon_slot: PanelContainer = %WeaponSlot
@onready var weapon_ui: ItemUI = %WeaponUI
@onready var weapon_symbol: TextureRect = %WeaponSymbol
@onready var armor_slot: PanelContainer = %ArmorSlot
@onready var armor_ui: ItemUI = %ArmorUI
@onready var armor_symbol: TextureRect = %ArmorSymbol
@onready var accessory_slot: PanelContainer = %AccessorySlot
@onready var accessory_ui: ItemUI = %AccessoryUI
@onready var accessory_symbol: TextureRect = %AccessorySymbol

var has_weapon : bool = false
var has_armor : bool = false
var has_accessory: bool = false

func _ready() -> void:
	pass

func update_weapon_slot(item):
	weapon_ui.visible = true
	weapon_symbol.visible = false
	weapon_ui.set_item(item)

func update_armor_slot(item):
	armor_ui.visible = true
	armor_symbol.visible = false
	armor_ui.set_item(item)
	
func update_accessory_slot(item):
	accessory_ui.visible = true
	accessory_symbol.visible = false
	accessory_ui.set_item(item)
