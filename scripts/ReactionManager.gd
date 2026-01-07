extends Node

signal reaction_finished


const BLOOM = preload("res://resources/Status Effects/Bloom.tres")
const BURN = preload("res://resources/Status Effects/Burn.tres")
const MUCK = preload("res://resources/Status Effects/Muck.tres")
const NITRO = preload("res://resources/Status Effects/Nitro.tres")
const SOW = preload("res://resources/Status Effects/Sow.tres")

@onready var combat: Node = %CombatManager
var run

var vaporize_mult = 2
var shock_mult = 0.25
var erupt_mult = 3
var detonate_main_mult = 1.5
var detonate_side_mult = 0.5
var nitro_mult = 1.5
var bubble_mult = 0.5
var burn_damage = 10
var burn_length = 2
var muck_mult = 0.75
var discharge_mult = 1.5
var sow_shielding = 5
var sow_healing = 5
var sow_healing_mult = 1
var sow_shielding_mult = 1
var bloom_mult = 1
var ally_bloom_healing = 5
var enemy_bloom_healing = 5

var active_reactions = 0

func _ready():
	await get_tree().create_timer(0.15).timeout
	run = get_tree().get_first_node_in_group("run")
	if run.combat_manager == null:
		return
	self.reaction_finished.connect(run.combat_manager.reaction_signal)

func reaction(elem1, elem2, unit, value, friendly, caster):
	if unit == null:
		reaction_finished_signal()
		return false
	if elem1 == "neutral" or elem2 == "neutral" or elem1 == elem2:
		reaction_finished_signal()
		return false

	active_reactions += 1
	await _run_reaction(elem1, elem2, unit, value, friendly, caster)
	active_reactions -= 1

	if active_reactions == 0:
		reaction_finished_signal()

	return true

func _run_reaction(elem1, elem2, unit, value, friendly, caster):
	match elem1:
		"fire":
			match elem2:
				"water": await vaporize(elem1,elem2,unit,value,friendly,caster); combat.vaporize(unit,caster,elem2)
				"lightning": await detonate(elem1,elem2,unit,value,friendly,caster); combat.detonate(unit,caster)
				"earth": await erupt(elem1,elem2,unit,value,friendly,caster); combat.erupt(unit,caster)
				"grass": await burn(elem1,elem2,unit,value,friendly,caster); combat.burn(unit,caster)

		"water":
			match elem2:
				"fire": await vaporize(elem1,elem2,unit,value,friendly,caster); combat.vaporize(unit,caster,elem2)
				"lightning": await shock(elem1,elem2,unit,value,friendly,caster); combat.shock(unit,caster)
				"earth": await muck(elem1,elem2,unit,value,friendly,caster); combat.muck(unit,caster)
				"grass": await bloom(elem1,elem2,unit,value,friendly,caster); combat.bloom(unit,caster)

		"lightning":
			match elem2:
				"fire": await detonate(elem1,elem2,unit,value,friendly,caster); combat.detonate(unit,caster)
				"water": await shock(elem1,elem2,unit,value,friendly,caster); combat.shock(unit,caster)
				"earth": await discharge(elem1,elem2,unit,value,friendly,caster); combat.discharge(unit,caster)
				"grass": await nitro(elem1,elem2,unit,value,friendly,caster); combat.nitro(unit,caster)

		"earth":
			match elem2:
				"fire": await erupt(elem1,elem2,unit,value,friendly,caster); combat.erupt(unit,caster)
				"water": await muck(elem1,elem2,unit,value,friendly,caster); combat.muck(unit,caster)
				"lightning": await discharge(elem1,elem2,unit,value,friendly,caster); combat.discharge(unit,caster)
				"grass": await sow(elem1,elem2,unit,value,friendly,caster); combat.sow(unit,caster)

		"grass":
			match elem2:
				"earth": await sow(elem1,elem2,unit,value,friendly,caster); combat.sow(unit,caster)
				"fire": await burn(elem1,elem2,unit,value,friendly,caster); combat.burn(unit,caster)
				"water": await bloom(elem1,elem2,unit,value,friendly,caster); combat.bloom(unit,caster)
				"lightning": await nitro(elem1,elem2,unit,value,friendly,caster); combat.nitro(unit,caster)


func vaporize(elem1,elem2,unit,value,friendly,caster):
	var res_value = roundi(value)
	if caster is Ally:
		res_value = roundi(value * run.vaporize_mult)
	elif caster is Enemy:
		res_value = roundi(value * vaporize_mult)
	unit.current_element = "neutral"
	DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, " Vaporize!", 38)
	if not friendly:
		unit.take_damage(res_value, elem2, false)
	await get_tree().process_frame

func detonate(elem1,elem2,unit,value,friendly,caster):
	var res_value = roundi(value)
	var side_value = roundi(value)
	if caster is Ally:
		res_value = roundi(value * run.detonate_main_mult)
		side_value = roundi(value * run.detonate_side_mult)
	elif caster is Enemy:
		res_value = roundi(value * detonate_main_mult)
		side_value = roundi(value * detonate_side_mult)

	unit.current_element = "neutral"
	DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, " Detonate!", 38)

	if unit.hasLeft():
		if unit.left.current_element == "neutral":
			unit.left.take_damage(side_value, elem2, true)
		else:
			await reaction(unit.left.current_element, elem2, unit.left, side_value, false, caster)

	if unit.hasRight():
		if unit.right.current_element == "neutral":
			unit.right.take_damage(side_value, elem2, true)
		else:
			await reaction(unit.right.current_element, elem2, unit.right, side_value, false, caster)

	if not friendly:
		unit.take_damage(res_value, elem2, false)
	await get_tree().process_frame

func erupt(elem1,elem2,unit,value,friendly,caster):
	var res_value = roundi(value)
	if caster is Ally:
		res_value = roundi(value * run.erupt_mult)
	elif caster is Enemy:
		res_value = roundi(value * erupt_mult)
	unit.current_element = "neutral"
	DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, " Erupted!", 38)
	if not friendly:
		unit.take_damage(res_value, elem2, false)
	else:
		unit.receive_shielding(value, elem2, false)
	await get_tree().process_frame

func burn(elem1,elem2,unit,value,friendly,caster):
	var new_burn = BURN.duplicate()
	new_burn.turns_remaining = run.burn_length
	if unit is Enemy:
		new_burn.damage = run.burn_damage
	unit.current_element = "neutral"
	unit.apply_status(new_burn)
	unit.hp_bar.update_statuses(unit.status)
	DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, " Burn!", 38)
	if not friendly:
		unit.take_damage(roundi(value), elem2, false)
	else:
		unit.receive_healing(roundi(value), elem2, false)
	unit.check_statuses()
	await get_tree().process_frame

func shock(elem1,elem2,unit,value,friendly,caster):
	var res_value = roundi(value)
	if caster is Ally:
		res_value = roundi(value * run.shock_mult)
	elif caster is Enemy:
		res_value = roundi(value * shock_mult)
	unit.current_element = "neutral"
	DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, " Shock!", 38)
	if not friendly:
		unit.take_damage(roundi(value), elem2, false)
		await get_tree().process_frame
		if unit != null:
			unit.take_damage(res_value, "lightning", true)
		await get_tree().process_frame
		if unit != null:
			unit.take_damage(res_value, "lightning", true)
		await get_tree().process_frame
		if unit != null:
			unit.take_damage(res_value, "lightning", true)
	await get_tree().process_frame

func bloom(elem1,elem2,unit,value,friendly,caster):
	var bloom_stack = BLOOM.duplicate()
	unit.apply_status(bloom_stack)
	unit.hp_bar.update_statuses(unit.status)
	unit.current_element = "neutral"
	DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, " Bloom!", 38)
	if not friendly:
		unit.take_damage(roundi(value), elem2, false)
	else:
		unit.receive_healing(roundi(value), elem2, false)
	unit.check_statuses()
	await get_tree().process_frame

func nitro(elem1,elem2,unit,value,friendly,caster):
	var nitro_effect = NITRO.duplicate()
	unit.apply_status(nitro_effect)
	unit.check_statuses()
	unit.hp_bar.update_statuses(unit.status)
	unit.current_element = "neutral"
	DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, " Nitro!", 38)
	if not friendly:
		unit.take_damage(roundi(value), elem2, false)
	else:
		unit.receive_healing(roundi(value), elem2, false)
	unit.check_statuses()
	await get_tree().process_frame

func discharge(elem1,elem2,unit,value,friendly,caster):
	var split = value
	if caster is Ally:
		split = roundi((value * run.discharge_mult) / combat.enemies.size())
	elif caster is Enemy:
		split = roundi((value * discharge_mult) / combat.enemies.size())
	DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, " Discharge!", 38)
	if not friendly:
		unit.take_damage(split, elem2, false)
		unit.current_element = "neutral"
	else:
		unit.receive_shielding(roundi(value), elem2, false)
	for enemy in combat.enemies:
		if enemy != null and enemy != unit:
			enemy.take_damage(split, "neutral", true)
	await get_tree().process_frame

func sow(elem1,elem2,unit,value,friendly,caster):
	var sow_effect = SOW.duplicate()
	unit.apply_status(sow_effect)
	unit.hp_bar.update_statuses(unit.status)
	unit.current_element = "neutral"
	DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, " Sow!", 38)
	if not friendly:
		unit.take_damage(roundi(value), elem2, false)
	elif friendly and elem2 == "grass":
		unit.receive_healing(roundi(value), elem2, false)
	elif friendly and elem2 == "earth":
		unit.receive_shielding(roundi(value), elem2, false)
	unit.check_statuses()
	await get_tree().process_frame

func muck(elem1,elem2,unit,value,friendly,caster):
	var muck_effect = MUCK.duplicate()
	unit.apply_status(muck_effect)
	unit.hp_bar.update_statuses(unit.status)
	unit.current_element = "neutral"
	DamageNumbers.display_text(unit.damage_number_origin.global_position, elem2, " Muck!", 38)
	if not friendly:
		unit.take_damage(roundi(value), elem2, false)
	elif friendly and elem2 == "earth":
		unit.receive_shielding(roundi(value), elem2, false)
	unit.check_statuses()
	await get_tree().process_frame

func reaction_finished_signal():
	await get_tree().process_frame
	reaction_finished.emit()
