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

signal new_select

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


func update_color(panel, color):
	var new_stylebox_normal = panel.get_theme_stylebox("panel").duplicate()
	new_stylebox_normal.bg_color = color
	panel.add_theme_stylebox_override("panel", new_stylebox_normal)

func reset_colors():
	update_color(weapon_slot, "#18191e6e")
	update_color(armor_slot, "#18191e6e")
	update_color(accessory_slot, "#18191e6e")
	update_color(weapon_ui.panel_container, "#18191e")
	update_color(armor_ui.panel_container, "#18191e")
	update_color(accessory_ui.panel_container, "#18191e")

func _on_select_accessory_pressed() -> void:
	new_select.emit("Accessory")


func _on_select_armor_pressed() -> void:
	new_select.emit("Armor")


func _on_select_weapon_pressed() -> void:
	new_select.emit("Weapon")


func _on_select_armor_mouse_entered() -> void:
	if armor_ui.item != null:
		armor_ui._on_icon_mouse_entered()


func _on_select_armor_mouse_exited() -> void:
	if armor_ui.item != null:
		armor_ui._on_icon_mouse_exited()


func _on_select_accessory_mouse_entered() -> void:
	if accessory_ui.item != null:
		accessory_ui._on_icon_mouse_entered()

func _on_select_accessory_mouse_exited() -> void:
	if accessory_ui.item != null:
		accessory_ui._on_icon_mouse_exited()


func _on_select_weapon_mouse_entered() -> void:
	if weapon_ui.item != null:
		weapon_ui._on_icon_mouse_entered()


func _on_select_weapon_mouse_exited() -> void:
	if weapon_ui.item != null:
		weapon_ui._on_icon_mouse_exited()
