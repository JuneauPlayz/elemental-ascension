extends Node
class_name Unit

# Common Variables
@export var health = 0
@export var max_health = 0
@export var shield = 0
@export var status : Array = []
@export var current_element : String = "none"
@export var bubble : bool = false
@export var muck : bool = false
@export var nitro : bool = false
@export var sow : bool = false
@export var res : UnitRes
@export var connected = false
@export var left : Unit
@export var right : Unit

var run

@export var defense : float
@export var status_resistance: float
@export var title : String

# Status Effect Constants
const BLEED = preload("res://resources/Status Effects/Bleed.tres")
const BUBBLE = preload("res://resources/Status Effects/Bubble.tres")
const BURN = preload("res://resources/Status Effects/Burn.tres")
const MUCK = preload("res://resources/Status Effects/Muck.tres")
const NITRO = preload("res://resources/Status Effects/Nitro.tres")
const SOW = preload("res://resources/Status Effects/Sow.tres")

# Nodes
@onready var damage_number_origin: Node2D = $DamageNumberOrigin
var hp_bar
var combat_manager
var targeting_area
var ReactionManager
var copy = false

# Signals
signal reaction_ended
signal target_chosen
signal died
# Common Methods


func receive_skill(skill, unit, value_multiplier):
	var rounded : int
	var reaction = ""
	var value = skill.final_damage * value_multiplier
	var value2 = skill.damage2 * value_multiplier
	if (!connected):
		ReactionManager.reaction_finished.connect(self.reaction_signal)
		connected = true
	var r = await ReactionManager.reaction(current_element, skill.element, self, value, skill.friendly, unit)
	if (r): 
		await reaction_ended 
		if skill.double_hit == true:
			await get_tree().create_timer(0.1).timeout
			var r2 = await ReactionManager.reaction(current_element, skill.element2, self, value2, skill.friendly, unit)
			if (r2):
				await reaction_ended 
			if (!r2):
				self.take_damage(value2, skill.element2, true)
	if (!r):
		self.take_damage(value, skill.element, true)
		if (skill.element != "none"):
			self.current_element = skill.element
		if skill.double_hit == true:
			await get_tree().create_timer(0.1).timeout
			var r2 = await ReactionManager.reaction(current_element, skill.element2, self, value2, skill.friendly, unit)
			if (r2):
				await reaction_ended 
			if (!r2):
				self.take_damage(value2, skill.element2, true)
	if sow:
		unit.receive_healing(roundi(run.sow_healing * run.sow_healing_mult), "grass", false)
		unit.receive_shielding(roundi(run.sow_shielding * run.sow_shielding_mult), "earth", false)
		sow = false
		for stati in status:
			if stati.name == "Sow":
				status.erase(stati)
				if not copy:
					hp_bar.update_statuses(status)
				if not copy:
					DamageNumbers.display_text(self.damage_number_origin.global_position, "none", "Harvest!", 32)
	if skill.status_effects != []:
		for x in skill.status_effects:
			if x.name == "Bleed":
				var new_bleed = BLEED.duplicate()
				status.append(new_bleed)
			if x.name == "Burn":
				for stati in status:
					if stati.name == "Burn":
						status.erase(stati)
				if not copy:
					hp_bar.update_statuses(status)
				var new_burn = BURN.duplicate()
				new_burn.damage = run.burn_damage
				new_burn.turns_remaining = run.burn_length
				status.append(new_burn)
			if x.name == "Bubble":
				var new_bubble = BUBBLE.duplicate()
				status.append(new_bubble)
			if x.name == "Muck":
				var new_muck = MUCK.duplicate()
				status.append(new_muck)
			if x.name == "Nitro":
				var new_nitro = NITRO.duplicate()
				status.append(new_nitro)
			if x.name == "Sow":
				var new_sow = SOW.duplicate()
				status.append(new_sow)
				sow = true
		if not copy:
			hp_bar.update_statuses(status)
	if not copy:
		hp_bar.update_element(current_element)

func receive_skill_friendly(skill, unit, value_multiplier):
	var rounded : int
	var reaction = ""
	var number = skill.damage * value_multiplier
	var value = skill.damage * value_multiplier
	var r = await ReactionManager.reaction(current_element, skill.element, self, value, skill.friendly, unit)
	if (!r):
		if skill.shielding == true:
			self.receive_shielding(value, skill.element, true)
		if skill.healing == true:
			if (health + number >= max_health):
				number = max_health - health
			self.receive_healing(value, skill.element, true)
	if skill.status_effects != []:
		for x in skill.status_effects:
			status.append(x)
	if not copy:
		hp_bar.update_element(current_element)
		hp_bar.update_statuses(status)

func take_damage(damage : int, element : String, change_element : bool):
	if not copy:
		match element:
			"fire":
				AudioPlayer.play_FX("fire_hit", -18)
			"water":
				AudioPlayer.play_FX("water_hit", -18)
			"lightning":
				AudioPlayer.play_FX("lightning_hit", -27)
			"earth":
				AudioPlayer.play_FX("earth_hit", -25)
			"grass":
				AudioPlayer.play_FX("grass_hit", -18)
			_:
				AudioPlayer.play_FX("fire_hit", -18)

	if change_element:
		self.current_element = element
	if not copy:
		hp_bar.update_element(current_element)
	var damage_left = roundi(damage)
	if self is Enemy:
		damage_left += run.all_damage_bonus
		match element:
			"fire":
				damage_left += run.fire_damage_bonus
				damage_left *= run.fire_damage_mult
			"water":
				damage_left += run.water_damage_bonus
				damage_left *= run.water_damage_mult
			"lightning":
				damage_left += run.lightning_damage_bonus
				damage_left *= run.lightning_damage_mult
			"grass":
				damage_left += run.grass_damage_bonus
				damage_left *= run.grass_damage_mult
			"earth":
				damage_left += run.earth_damage_bonus
				damage_left *= run.earth_damage_mult
			"none":
				damage_left += run.physical_damage_bonus
				damage_left += run.physical_damage_mult
		damage_left *= run.all_damage_mult
	var total_dmg = damage_left
	if bubble:
		damage_left = roundi(damage * run.bubble_mult)
		total_dmg = damage_left
		bubble = false
		if not copy:
			DamageNumbers.display_text(self.damage_number_origin.global_position, "none", "Pop!", 32)
		for stati in status:
			if stati.name == "Bubble":
				status.erase(stati)
				if not copy:
					hp_bar.update_statuses(status)
				self.receive_healing(run.ally_bloom_healing * run.bloom_mult, "grass", false)
	if nitro:
		nitro = false
		for stati in status:
			if stati.name == "Nitro":
				status.erase(stati)
				if not copy:
					hp_bar.update_statuses(status)
				damage_left = roundi(damage_left * run.nitro_mult)
				if not copy:
					DamageNumbers.display_text(self.damage_number_origin.global_position, "none", "Nitrate!", 32)
	if not copy:
		DamageNumbers.display_number(damage_left, damage_number_origin.global_position, element, "")
	total_dmg = damage_left
	if (shield > 0):
		if (shield <= damage_left):
			damage_left -= shield
			shield = 0
		elif (shield > damage_left):
			shield -= damage_left
			damage_left = 0
		if not copy:
			hp_bar.set_shield(shield)
	health -= damage_left
	health = roundi(health)
	check_if_dead()
	if not copy:
		hp_bar.set_hp(roundi(health))
	return total_dmg

func receive_healing(healing: int, element : String, change_element):
	var healing_reduction = 1
	for stati in status:
		if stati.name == "Burn":
			healing_reduction = 0.5
	if not copy:
		AudioPlayer.play_FX("healing",-21)
	var new_healing = healing
	if self is Ally:
		new_healing = ((healing + run.healing_bonus) * run.healing_mult * healing_reduction)
	if self is Enemy:
		new_healing = healing * healing_reduction
	if not copy:
		DamageNumbers.display_number_plus(new_healing, damage_number_origin.global_position, element, "")
	if change_element:
		self.current_element = element
	health += new_healing
	if health >= max_health:
		health = max_health
	health = roundi(health)
	if not copy:
		hp_bar.set_hp(roundi(health))
	return new_healing

func receive_shielding(shielding: int, element : String, change_element : bool):
	if not copy:
		AudioPlayer.play_FX("earth_hit",-25)
	var new_shielding =shielding
	if self is Ally:
		new_shielding = ((shielding + run.shielding_bonus) * run.shielding_mult)
	if not copy:
		DamageNumbers.display_number_plus(new_shielding, damage_number_origin.global_position, element, "")
	if change_element:
		self.current_element = element
	shield += new_shielding
	shield = roundi(shield)
	if not copy:
		hp_bar.set_shield(roundi(shield))
	return new_shielding

func check_if_dead():
	if health <= 0:
		die()

func die():
	print("ded")
	died.emit()
	self.visible = false
	if self is Ally:
		combat_manager.allies.erase(self)
	elif self is Enemy:
		combat_manager.enemies.erase(self)
	combat_manager.set_unit_pos()

func hasLeft():
	return left != null

func hasRight():
	return right != null

func enable_targeting_area():
	targeting_area.visible = true

func disable_targeting_area():
	targeting_area.visible = false
	
func reaction_signal():
	reaction_ended.emit()

func execute_status(status_effect):
	if status_effect.event_based == false:
		take_damage(status_effect.damage, status_effect.element, true)
		status_effect.turns_remaining -= 1
		hp_bar.update_statuses(status)
	else:
		if status_effect.name == "Bubble":
			bubble = true
		elif status_effect.name == "Muck":
			muck = true
		elif status_effect.name == "Nitro":
			nitro = true
		elif status_effect.name == "Sow":
			sow = true
		
func set_shield(shield):
	self.shield = shield
	hp_bar.set_shield(shield)
	
func increase_max_hp(count, changehp):
	max_health += count
	if max_health < 1:
		max_health = 1
	hp_bar.set_maxhp(max_health)
	if changehp:
		health = max_health
		hp_bar.set_hp(max_health)
