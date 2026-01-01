class_name KeystoneHandler
extends Control

const KEYSTONE_UI := preload("res://scenes/keystone handler/keystone_ui.tscn")

@onready var keystones_container: HBoxContainer = %KeystonesContainer

@onready var fire_slot: ColorRect = %FireSlot
@onready var water_slot: ColorRect = %WaterSlot
@onready var lightning_slot: ColorRect = %LightningSlot
@onready var grass_slot: ColorRect = %GrassSlot
@onready var earth_slot: ColorRect = %EarthSlot


const BASIC_FIRE_KEYSTONE = preload("uid://c60xpmx3c7h44")


@onready var slot_map := {
	"Fire": fire_slot,
	"Water": water_slot,
	"Lightning": lightning_slot,
	"Grass": grass_slot,
	"Earth": earth_slot
}


var run

func _ready() -> void:
	run = get_tree().get_first_node_in_group("run")
	keystones_container.child_exiting_tree.connect(_on_keystone_removed)
	add_keystone(BASIC_FIRE_KEYSTONE)

func can_add_keystone(keystone: Keystone) -> bool:
	if keystone.element_slots.size() != 1:
		return false

	var slot_id = keystone.element_slots[0]

	if not slot_map.has(slot_id):
		return false

	if slot_map[slot_id].get_child_count() > 0:
		return false

	if run.occupied_element_slots.has(slot_id):
		return false

	return true

	
func add_keystone(keystone: Keystone) -> bool:
	if not can_add_keystone(keystone):
		return false

	var slot_id = keystone.element_slots[0]
	var slot_node: Control = slot_map[slot_id]

	var ui := KEYSTONE_UI.instantiate()
	slot_node.add_child(ui)

	ui.set_keystone(keystone)
	keystone.initialize_keystone(ui)

	run.keystones.append(keystone)
	run.occupied_element_slots.append(slot_id)

	return true

func remove_keystone_by_id(id: String) -> void:
	for slot in slot_map.values():
		for ui in slot.get_children():
			if ui.keystone and ui.keystone.id == id:
				ui.queue_free()
				return



func _on_keystone_removed(ui: KeystoneUI) -> void:
	if not ui or not ui.keystone:
		return

	var keystone := ui.keystone

	# Undo keystone effects
	keystone.deactivate_keystone(ui)

	# Update run state
	run.keystones.erase(keystone)
	for slot in keystone.element_slots:
		run.occupied_element_slots.erase(slot)


func initialize_keystone(_owner: KeystoneUI) -> void:
	pass


func deactivate_keystone(_owner: KeystoneUI) -> void:
	pass
