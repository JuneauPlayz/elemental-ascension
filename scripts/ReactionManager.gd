extends Node

signal reaction_finished

const BLEED = preload("res://resources/Status Effects/Bleed.tres")
const BUBBLE = preload("res://resources/Status Effects/Bubble.tres")
const BURN = preload("res://resources/Status Effects/Burn.tres")
const MUCK = preload("res://resources/Status Effects/Muck.tres")
const NITRO = preload("res://resources/Status Effects/Nitro.tres")
const SOW = preload("res://resources/Status Effects/Sow.tres")
@onready var combat: Node = %CombatManager
var run

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	run = get_tree().get_first_node_in_group("run")

func reaction(elem1: String, elem2: String, unit: Unit, value, friendly: bool, caster: Unit) -> bool:
	var res_value = value
	
	# if unit is dead
	if unit == null:
		return false
	
	if elem1 == "none" or elem2 == "none":
		reaction_finished.emit()
		return false
	
	if elem1 == elem2:
		reaction_finished.emit()
		return false
	
	match elem1:
		"fire":
			match elem2:
				"water":
					vaporize(elem1, elem2, unit, value, friendly)
					if caster is Ally:
						combat.vaporize()
				"lightning":
					detonate(elem1, elem2, unit, value, friendly)
					if caster is Ally:
						combat.detonate()
				"earth":
					erupt(elem1, elem2, unit, value, friendly)
					if caster is Ally:
						combat.erupt()
				"grass":
					burn(elem1, elem2, unit, value, friendly)
					if caster is Ally:
						combat.burn()
		"water":
			match elem2:
				"fire":
					vaporize(elem1, elem2, unit, value, friendly)
					if caster is Ally:
						combat.vaporize()
				"lightning":
					shock(elem1, elem2, unit, value, friendly)
					if caster is Ally:
						combat.shock()
				"earth":
					muck(elem1, elem2, unit, value, friendly)
					if caster is Ally:
						combat.muck()
				"grass":
					bloom(elem1, elem2, unit, value, friendly)
					if caster is Ally:
						combat.bloom()
		"lightning":
			match elem2:
				"fire":
					detonate(elem1, elem2, unit, value, friendly)
					if caster is Ally:
						combat.detonate()
				"water":
					shock(elem1, elem2, unit, value, friendly)
					if caster is Ally:
						combat.shock()
				"earth":
					discharge(elem1, elem2, unit, value, friendly)
					if caster is Ally:
						combat.discharge()
				"grass":
					nitro(elem1, elem2, unit, value, friendly)
					if caster is Ally:
						combat.nitro()
		"earth":
			match elem2:
				"fire":
					erupt(elem1, elem2, unit, value, friendly)
					if caster is Ally:
						combat.erupt()
				"water":
					muck(elem1, elem2, unit, value, friendly)
					if caster is Ally:
						combat.muck()
				"lightning":
					discharge(elem1, elem2, unit, value, friendly)
					if caster is Ally:
						combat.discharge()
				"grass":
					sow(elem1, elem2, unit, value, friendly)
					if caster is Ally:
						combat.sow()
		"grass":
			match elem2:
				"earth":
					sow(elem1, elem2, unit, value, friendly)
					if caster is Ally:
						combat.sow()
				"fire":
					burn(elem1, elem2, unit, value, friendly)
					if caster is Ally:
						combat.burn()
				"water":
					bloom(elem1, elem2, unit, value, friendly)
					if caster is Ally:
						combat.bloom()
				"lightning":
					nitro(elem1, elem2, unit, value, friendly)
					if caster is Ally:
						combat.nitro()
	return true

func vaporize(elem1: String, elem2: String, unit: Unit, value, friendly: bool) -> void:
	var reaction_name = " Vaporize!"
	var res_value = roundi(value * run.vaporize_mult)
	unit.current_element = "none"
	DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, reaction_name, 38)
	if not friendly:
		unit.take_damage(res_value, elem2, false)
	await get_tree().create_timer(0.01).timeout
	reaction_finished.emit()

func detonate(elem1: String, elem2: String, unit: Unit, value, friendly: bool) -> void:
	var reaction_name = " Detonate!"
	var res_value = roundi(value)
	unit.current_element = "none"
	if unit == null:
		return
	DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, reaction_name, 38)
	if unit.hasLeft():
		unit.left.take_damage(res_value * run.detonate_side_mult, elem2, true)
	if unit.hasRight():
		unit.right.take_damage(res_value * run.detonate_side_mult, elem2, true)
	if not friendly:
		unit.take_damage(res_value * run.detonate_main_mult, elem2, false)
	await get_tree().create_timer(0.01).timeout
	reaction_finished.emit()

func erupt(elem1: String, elem2: String, unit: Unit, value, friendly: bool) -> void:
	var reaction_name = " Erupted!"
	var res_value = roundi(value)
	unit.current_element = "none"
	DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, reaction_name, 38)
	if not friendly:
		if unit.shield > 0:
			var shield = unit.shield
			if (value * run.erupt_mult) < shield:
				unit.take_damage(value * run.erupt_mult, elem2, false)
				res_value = value * run.erupt_mult
			else:
				var shield_dmg = (shield + run.erupt_mult - 1) / run.erupt_mult
				value -= shield_dmg
				res_value = value + shield
				unit.take_damage(res_value, elem2, false)
				reaction_name = " Erupted!!"
		else:
			unit.take_damage(res_value, elem2, false)
	elif friendly:
		unit.receive_shielding(value, elem2, false)
	await get_tree().create_timer(0.01).timeout
	reaction_finished.emit()

func burn(elem1: String, elem2: String, unit: Unit, value, friendly: bool) -> void:
	var reaction_name = " Burn!"
	if not run.burn_stack:
		for stati in unit.status:
				if stati.name == "Burn":
					unit.status.erase(stati)
	var new_burn = BURN.duplicate()
	new_burn.turns_remaining = run.burn_length
	new_burn.damage = run.burn_damage
	unit.current_element = "none"
	unit.status.append(new_burn)
	unit.hp_bar.update_statuses(unit.status)
	DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, reaction_name, 38)
	if not friendly:
		unit.take_damage(roundi(value), elem2, false)
	elif friendly:
		unit.receive_healing(roundi(value), elem2, false)
	await get_tree().create_timer(0.01).timeout
	reaction_finished.emit()

func shock(elem1: String, elem2: String, unit: Unit, value, friendly: bool) -> void:
	var reaction_name = " Shock!"
	var res_value = roundi(value * run.shock_mult)
	unit.current_element = "none"
	DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, reaction_name, 38)
	if not friendly:
		unit.take_damage(roundi(value), elem2, false)
		await get_tree().create_timer(0.02).timeout
		if unit != null:
			unit.take_damage(res_value, "lightning", true)
			DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, reaction_name, 38)
		await get_tree().create_timer(0.02).timeout
		if unit != null:
			unit.take_damage(res_value, "lightning", true)
			DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, reaction_name, 38)
			await get_tree().create_timer(0.02).timeout
		if unit != null:
			unit.take_damage(res_value, "lightning", true)
		DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, reaction_name, 38)
	await get_tree().create_timer(0.01).timeout
	reaction_finished.emit()

func bloom(elem1: String, elem2: String, unit: Unit, value, friendly: bool) -> void:
	var reaction_name = " Bloom!"
	var bubble_effect = BUBBLE.duplicate()
	unit.status.append(bubble_effect)
	unit.hp_bar.update_statuses(unit.status)
	unit.current_element = "none"
	DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, reaction_name, 38)
	if not friendly:
		unit.take_damage(roundi(value), elem2, false)
	elif friendly:
		unit.receive_healing(roundi(value), elem2, false)
	await get_tree().create_timer(0.01).timeout
	reaction_finished.emit()

func nitro(elem1: String, elem2: String, unit: Unit, value, friendly: bool) -> void:
	var reaction_name = " Nitro!"
	var nitro_effect = NITRO.duplicate()
	unit.status.append(nitro_effect)
	unit.hp_bar.update_statuses(unit.status)
	unit.current_element = "none"
	DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, reaction_name, 38)
	if not friendly:
		unit.take_damage(roundi(value), elem2, false)
	elif friendly:
		unit.receive_healing(roundi(value), elem2, false)
	await get_tree().create_timer(0.01).timeout
	reaction_finished.emit()

func discharge(elem1: String, elem2: String, unit: Unit, value, friendly: bool) -> void:
	var reaction_name = " Discharge!"
	var split_damage = value
	if combat.enemies.size() > 0:
		split_damage = roundi((value * run.discharge_mult) / combat.enemies.size())
		unit.current_element = "none"
	DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, reaction_name, 38)
	if not friendly:
		unit.take_damage(roundi(split_damage), elem2, false)
	elif friendly:
		unit.receive_shielding(roundi(value), elem2, false)
	for enemy in combat.enemies:
		if enemy != null and enemy != unit:
			enemy.take_damage(roundi(split_damage), "none", true)
	reaction_finished.emit()

func sow(elem1: String, elem2: String, unit: Unit, value, friendly: bool) -> void:
	var reaction_name = " Sow!"
	var sow_effect = SOW.duplicate()
	unit.status.append(sow_effect)
	unit.hp_bar.update_statuses(unit.status)
	unit.current_element = "none"
	DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, reaction_name, 38)
	if not friendly:
		unit.take_damage(roundi(value), elem2, false)
	elif friendly and elem2 == "grass":
		unit.receive_healing(roundi(value), elem2, false)
	elif friendly and elem2 == "earth":
		unit.receive_shielding(roundi(value), elem2, false)
	await get_tree().create_timer(0.01).timeout
	reaction_finished.emit()

func muck(elem1: String, elem2: String, unit: Unit, value, friendly: bool) -> void:
	var reaction_name = " Muck!"
	var muck_effect = MUCK.duplicate()
	unit.status.append(muck_effect)
	unit.hp_bar.update_statuses(unit.status)
	unit.current_element = "none"
	DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, reaction_name, 38)
	if not friendly:
		unit.take_damage(roundi(value), elem2, false)
	elif friendly and elem2 == "earth":
		unit.receive_shielding(roundi(value), elem2, false)
	await get_tree().create_timer(0.01).timeout
	reaction_finished.emit()
