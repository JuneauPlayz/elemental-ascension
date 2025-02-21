extends Node

signal reaction_finished

const BLEED = preload("res://resources/Status Effects/Bleed.tres")
const BUBBLE = preload("res://resources/Status Effects/Bubble.tres")
const BURN = preload("res://resources/Status Effects/Burn.tres")
const MUCK = preload("res://resources/Status Effects/Muck.tres")
const NITRO = preload("res://resources/Status Effects/Nitro.tres")
const SOW = preload("res://resources/Status Effects/Sow.tres")

@onready var combat: Node = $".."

var run

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	run = get_tree().get_first_node_in_group("run")
	self.reaction_finished.connect(combat.reaction_signal)

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
					vaporize(elem1, elem2, unit, value, friendly, caster)
					if caster is Ally:
						combat.vaporize(unit, caster, elem2)
				"lightning":
					detonate(elem1, elem2, unit, value, friendly, caster)
					if caster is Ally:
						combat.detonate(unit, caster)
				"earth":
					erupt(elem1, elem2, unit, value, friendly, caster)
					if caster is Ally:
						combat.erupt(unit, caster)
				"grass":
					burn(elem1, elem2, unit, value, friendly, caster)
					if caster is Ally:
						combat.burn(unit, caster)
		"water":
			match elem2:
				"fire":
					vaporize(elem1, elem2, unit, value, friendly, caster)
					if caster is Ally:
						combat.vaporize(unit, caster, elem2)
				"lightning":
					shock(elem1, elem2, unit, value, friendly, caster)
					if caster is Ally:
						combat.shock(unit, caster)
				"earth":
					muck(elem1, elem2, unit, value, friendly, caster)
					if caster is Ally:
						combat.muck(unit, caster)
				"grass":
					bloom(elem1, elem2, unit, value, friendly, caster)
					if caster is Ally:
						combat.bloom(unit, caster)
		"lightning":
			match elem2:
				"fire":
					detonate(elem1, elem2, unit, value, friendly, caster)
					if caster is Ally:
						combat.detonate(unit, caster)
				"water":
					shock(elem1, elem2, unit, value, friendly, caster)
					if caster is Ally:
						combat.shock(unit, caster)
				"earth":
					discharge(elem1, elem2, unit, value, friendly, caster)
					if caster is Ally:
						combat.discharge(unit, caster)
				"grass":
					nitro(elem1, elem2, unit, value, friendly, caster)
					if caster is Ally:
						combat.nitro(unit, caster)
		"earth":
			match elem2:
				"fire":
					erupt(elem1, elem2, unit, value, friendly, caster)
					if caster is Ally:
						combat.erupt(unit, caster)
				"water":
					muck(elem1, elem2, unit, value, friendly, caster)
					if caster is Ally:
						combat.muck(unit, caster)
				"lightning":
					discharge(elem1, elem2, unit, value, friendly, caster)
					if caster is Ally:
						combat.discharge(unit, caster)
				"grass":
					sow(elem1, elem2, unit, value, friendly, caster)
					if caster is Ally:
						combat.sow(unit, caster)
		"grass":
			match elem2:
				"earth":
					sow(elem1, elem2, unit, value, friendly, caster)
					if caster is Ally:
						combat.sow(unit, caster)
				"fire":
					burn(elem1, elem2, unit, value, friendly, caster)
					if caster is Ally:
						combat.burn(unit, caster)
				"water":
					bloom(elem1, elem2, unit, value, friendly, caster)
					if caster is Ally:
						combat.bloom(unit, caster)
				"lightning":
					nitro(elem1, elem2, unit, value, friendly, caster)
					if caster is Ally:
						combat.nitro(unit, caster)
	return true

func vaporize(elem1: String, elem2: String, unit: Unit, value, friendly: bool, caster : Unit) -> void:
	var reaction_name = " Vaporize!"
	var res_value = roundi(value * run.vaporize_mult)
	unit.current_element = "none"
	if not friendly:
		unit.take_damage(res_value, elem2, false)
	await get_tree().create_timer(0.001).timeout
	reaction_finished.emit()

func detonate(elem1: String, elem2: String, unit: Unit, value, friendly: bool, caster : Unit) -> void:
	var reaction_name = " Detonate!"
	var res_value = roundi(value)
	unit.current_element = "none"
	if unit == null:
		return
	if unit.hasLeft():
		if unit.left.current_element == "none":
			unit.left.take_damage(res_value * run.detonate_side_mult, elem2, true)
		else:
			print("Left detonate")
			await reaction(unit.left.current_element, elem2, unit.left, res_value * run.detonate_side_mult, false, caster)
	if unit.hasRight():
		if unit.right.current_element == "none":
			unit.right.take_damage(res_value * run.detonate_side_mult, elem2, true)
		else:
			await reaction(unit.right.current_element, elem2, unit.right, res_value * run.detonate_side_mult, false, caster)
	if not friendly:
		unit.take_damage(res_value * run.detonate_main_mult, elem2, false)
	await get_tree().create_timer(0.001).timeout
	reaction_finished.emit()

func erupt(elem1: String, elem2: String, unit: Unit, value, friendly: bool, caster : Unit) -> void:
	var reaction_name = " Erupted!"
	var res_value = roundi(value)
	unit.current_element = "none"
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
	await get_tree().create_timer(0.001).timeout
	reaction_finished.emit()

func burn(elem1: String, elem2: String, unit: Unit, value, friendly: bool, caster : Unit) -> void:
	var reaction_name = " Burn!"
	if not run.burn_stack:
		for stati in unit.status:
				if stati.name == "Burn":
					unit.status.erase(stati)
	var new_burn = BURN.duplicate()
	new_burn.turns_remaining = run.burn_length
	if unit is Enemy:
		new_burn.damage = run.burn_damage
	unit.current_element = "none"
	unit.status.append(new_burn)
	if not friendly:
		unit.take_damage(roundi(value), elem2, false)
	elif friendly:
		unit.receive_healing(roundi(value), elem2, false)
	await get_tree().create_timer(0.001).timeout
	reaction_finished.emit()

func shock(elem1: String, elem2: String, unit: Unit, value, friendly: bool, caster : Unit) -> void:
	var reaction_name = " Shock!"
	var res_value = roundi(value * run.shock_mult)
	unit.current_element = "none"
	if not friendly:
		unit.take_damage(roundi(value), elem2, false)
		if unit != null:
			unit.take_damage(res_value, "lightning", true)
		if unit != null:
			unit.take_damage(res_value, "lightning", true)
		if unit != null:
			unit.take_damage(res_value, "lightning", true)
	await get_tree().create_timer(0.001).timeout
	reaction_finished.emit()

func bloom(elem1: String, elem2: String, unit: Unit, value, friendly: bool, caster : Unit) -> void:
	var reaction_name = " Bloom!"
	var bubble_effect = BUBBLE.duplicate()
	unit.status.append(bubble_effect)
	unit.current_element = "none"
	if not friendly:
		unit.take_damage(roundi(value), elem2, false)
	elif friendly:
		unit.receive_healing(roundi(value), elem2, false)
	await get_tree().create_timer(0.001).timeout
	reaction_finished.emit()

func nitro(elem1: String, elem2: String, unit: Unit, value, friendly: bool, caster : Unit) -> void:
	var reaction_name = " Nitro!"
	var nitro_effect = NITRO.duplicate()
	unit.status.append(nitro_effect)
	unit.current_element = "none"
	if not friendly:
		unit.take_damage(roundi(value), elem2, false)
	elif friendly:
		unit.receive_healing(roundi(value), elem2, false)
	await get_tree().create_timer(0.001).timeout
	reaction_finished.emit()

func discharge(elem1: String, elem2: String, unit: Unit, value, friendly: bool, caster : Unit) -> void:
	var reaction_name = " Discharge!"
	var split_damage = value
	if combat.enemies.size() > 0:
		split_damage = roundi((value * run.discharge_mult) / combat.enemies.size())
	if not friendly:
		unit.take_damage(roundi(split_damage), elem2, false)
		unit.current_element = "none"
		if not unit.copy:
			unit.hp_bar.update_element(unit.current_element)
	elif friendly:
		unit.receive_shielding(roundi(value), elem2, false)
	for enemy in combat.enemies:
		if enemy != null and enemy != unit:
			enemy.take_damage(roundi(split_damage), "none", true)
	reaction_finished.emit()

func sow(elem1: String, elem2: String, unit: Unit, value, friendly: bool, caster : Unit) -> void:
	var reaction_name = " Sow!"
	var sow_effect = SOW.duplicate()
	unit.status.append(sow_effect)
	unit.current_element = "none"
	if not friendly:
		unit.take_damage(roundi(value), elem2, false)
	elif friendly and elem2 == "grass":
		unit.receive_healing(roundi(value), elem2, false)
	elif friendly and elem2 == "earth":
		unit.receive_shielding(roundi(value), elem2, false)
	await get_tree().create_timer(0.001).timeout
	reaction_finished.emit()

func muck(elem1: String, elem2: String, unit: Unit, value, friendly: bool, caster : Unit) -> void:
	var reaction_name = " Muck!"
	var muck_effect = MUCK.duplicate()
	unit.status.append(muck_effect)
	unit.current_element = "none"
	if not friendly:
		unit.take_damage(roundi(value), elem2, false)
	elif friendly and elem2 == "earth":
		unit.receive_shielding(roundi(value), elem2, false)
	await get_tree().create_timer(0.001).timeout
	reaction_finished.emit()
