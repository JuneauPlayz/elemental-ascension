class_name KeystoneHandler
extends Control

const KEYSTONE_UI := preload("res://scenes/keystone handler/keystone_ui.tscn")
const BASIC_FIRE_KEYSTONE = preload("uid://c60xpmx3c7h44")

const SLOT_SIZE := Vector2(50, 50)
const MIN_OVERLAP_RATIO := 0.5

@onready var keystones_container: GridContainer = %KeystonesContainer

@onready var fire_slot: ColorRect = %FireSlot
@onready var water_slot: ColorRect = %WaterSlot
@onready var lightning_slot: ColorRect = %LightningSlot
@onready var grass_slot: ColorRect = %GrassSlot
@onready var earth_slot: ColorRect = %EarthSlot

@onready var fire_drag: Draggable = $PanelContainer/KeystonesControl/KeystonesContainer/FireDrag
@onready var water_drag: Draggable = $PanelContainer/KeystonesControl/KeystonesContainer/WaterDrag
@onready var lightning_drag: Draggable = $PanelContainer/KeystonesControl/KeystonesContainer/LightningDrag
@onready var grass_drag: Draggable = $PanelContainer/KeystonesControl/KeystonesContainer/GrassDrag
@onready var earth_drag: Draggable = $PanelContainer/KeystonesControl/KeystonesContainer/EarthDrag

@onready var slot_map := {
	"fire": fire_slot,
	"water": water_slot,
	"lightning": lightning_slot,
	"grass": grass_slot,
	"earth": earth_slot
}

var run

var draggables: Array[Draggable] = []
var drag_original_pos := {}

func _ready() -> void:
	run = get_tree().get_first_node_in_group("run")

	draggables = [
		fire_drag,
		water_drag,
		lightning_drag,
		grass_drag,
		earth_drag
	]

	for d in draggables:
		drag_original_pos[d] = d.global_position

	keystones_container.child_exiting_tree.connect(_on_keystone_removed)

	add_keystone(BASIC_FIRE_KEYSTONE)

func update_drag_positions() -> void:
	drag_original_pos.clear()
	for d in draggables:
		if is_instance_valid(d):
			drag_original_pos[d] = d.global_position


func resolve_drag(dragged: Draggable) -> void:
	if not drag_original_pos.has(dragged):
		update_drag_positions()
		if not drag_original_pos.has(dragged):
			return

	var dragged_rect := Rect2(
		dragged.global_position - SLOT_SIZE * 0.5,
		SLOT_SIZE
	)

	var og_pos: Vector2 = drag_original_pos[dragged]

	for other in draggables:
		if other == dragged:
			continue
		if not drag_original_pos.has(other):
			continue

		var other_rect := Rect2(
			other.global_position - SLOT_SIZE * 0.5,
			SLOT_SIZE
		)

		var intersection := dragged_rect.intersection(other_rect)
		if intersection.size.x <= 0 or intersection.size.y <= 0:
			continue

		var overlap_area := intersection.size.x * intersection.size.y
		var required_area := SLOT_SIZE.x * SLOT_SIZE.y * MIN_OVERLAP_RATIO

		if overlap_area >= required_area:
			var other_pos = drag_original_pos[other]
			other.global_position = og_pos
			dragged.global_position = other_pos
			update_drag_positions()
			return

	# no valid overlap target
	dragged.global_position = og_pos
	update_drag_positions()



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
	keystone.deactivate_keystone(ui)

	run.keystones.erase(keystone)
	for slot in keystone.element_slots:
		run.occupied_element_slots.erase(slot)

# Drag signals

func _on_fire_drag_drag_started() -> void:
	update_drag_positions()

func _on_fire_drag_drag_ended() -> void:
	resolve_drag(fire_drag)

func _on_water_drag_drag_started() -> void:
	update_drag_positions()

func _on_water_drag_drag_ended() -> void:
	resolve_drag(water_drag)

func _on_lightning_drag_drag_started() -> void:
	update_drag_positions()

func _on_lightning_drag_drag_ended() -> void:
	resolve_drag(lightning_drag)

func _on_grass_drag_drag_started() -> void:
	update_drag_positions()

func _on_grass_drag_drag_ended() -> void:
	resolve_drag(grass_drag)

func _on_earth_drag_drag_started() -> void:
	update_drag_positions()

func _on_earth_drag_drag_ended() -> void:
	resolve_drag(earth_drag)
