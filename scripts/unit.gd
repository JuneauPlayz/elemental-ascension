extends Node
class_name Unit

# Common Variables
@export var health = 0
@export var max_health = 0
@export var shield = 0

@export var damage_reduction : float = 0.0

@export var fire_damage_block = 0
@export var status : Array = []
@export var current_element : String = "none"
@export var res : UnitRes
@export var connected = false
@export var left : Unit
@export var right : Unit
@export var id : int
var run

var position : int
@export var title : String

# Damage and stat-related variables
var fire_skill_damage_bonus: float = 0.0
var water_skill_damage_bonus: float = 0.0
var lightning_skill_damage_bonus: float = 0.0
var grass_skill_damage_bonus: float = 0.0
var earth_skill_damage_bonus: float = 0.0
var all_skill_damage_bonus: float = 0.0

var fire_skill_damage_mult: float = 1.0
var water_skill_damage_mult: float = 1.0
var lightning_skill_damage_mult: float = 1.0
var grass_skill_damage_mult: float = 1.0
var earth_skill_damage_mult: float = 1.0
var all_skill_damage_mult: float = 1.0

var physical_skill_damage_bonus: float = 0.0
var physical_skill_damage_mult: float = 1.0

var healing_skill_bonus: float = 0.0
var healing_skill_mult: float = 1.0

var shielding_skill_bonus: float = 0.0
var shielding_skill_mult: float = 1.0

var fire_token_bonus: float = 0.0
var water_token_bonus: float = 0.0
var lightning_token_bonus: float = 0.0
var grass_token_bonus: float = 0.0
var earth_token_bonus: float = 0.0

# Status Effect Constants (templates if you still use them anywhere else)
const BLOOM = preload("res://resources/Status Effects/Bloom.tres")
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

# =========================
# Core skill / damage logic
# =========================

func receive_skill(skill, unit, value_multiplier):
	if skill.friendly == true:
		receive_skill_friendly(skill, unit, value_multiplier)
		return

	var rounded : int
	var reaction = ""
	var value = skill.damage * value_multiplier
	var value2 = skill.damage2 * value_multiplier

	if not connected:
		ReactionManager.reaction_finished.connect(self.reaction_signal)
		connected = true

	var r = await ReactionManager.reaction(current_element, skill.element, self, value, skill.friendly, unit)
	if r:
		await reaction_ended
		if skill.double_hit == true:
			await get_tree().create_timer(0.1).timeout
			var r2 = await ReactionManager.reaction(current_element, skill.element2, self, value2, skill.friendly, unit)
			if r2:
				await reaction_ended
			if not r2:
				self.take_damage(value2, skill.element2, true)
	else:
		self.take_damage(value, skill.element, true)
		if skill.element != "none":
			self.current_element = skill.element
		if skill.double_hit == true:
			await get_tree().create_timer(0.1).timeout
			var r2b = await ReactionManager.reaction(current_element, skill.element2, self, value2, skill.friendly, unit)
			if r2b:
				await reaction_ended
			if not r2b:
				self.take_damage(value2, skill.element2, true)

	# Blast logic
	if skill.blast == true:
		if hasLeft():
			if left.current_element == "none":
				left.take_damage(skill.blast_damage, skill.element, true)
			else:
				await combat_manager.ReactionManager.reaction(left.current_element, skill.element, left, skill.blast_damage, false, unit)
		if hasRight():
			if right.current_element == "none":
				right.take_damage(skill.blast_damage, skill.element, true)
			else:
				await combat_manager.ReactionManager.reaction(right.current_element, skill.element, right, skill.blast_damage, false, unit)

	# Status effects application (generic with stacking/countdown)
	if skill.status_effects != []:
		for x in skill.status_effects:
			apply_status(x)
		if not copy:
			hp_bar.update_statuses(status)

	if not copy:
		hp_bar.update_element(current_element)


func receive_skill_friendly(skill, unit, value_multiplier):
	var rounded : int
	var reaction = ""
	var number = skill.damage * value_multiplier
	var value = skill.damage * value_multiplier

	if skill.buff == true:
		increase_skill_damage(skill.buff_value)
	else:
		var r = await ReactionManager.reaction(current_element, skill.element, self, value, skill.friendly, unit)
		if not r:
			if skill.shielding == true:
				self.receive_shielding(value, skill.element, true)
			if skill.healing == true:
				if (health + number >= max_health):
					number = max_health - health
				self.receive_healing(value, skill.element, true)

		if skill.status_effects != []:
			for x in skill.status_effects:
				apply_status(x)

		if not copy:
			hp_bar.update_element(current_element)
			hp_bar.update_statuses(status)


func receive_damage(damage: int, element: String, unit) -> void:
	var r = false
	if not connected:
		ReactionManager.reaction_finished.connect(self.reaction_signal)
		connected = true

	r = await ReactionManager.reaction(current_element, element, self, damage, false, unit)

	if r:
		await reaction_ended
	else:
		self.take_damage(damage, element, true)
		if element != "none":
			self.current_element = element

	if not copy:
		hp_bar.update_element(current_element)


func increase_skill_damage(value):
	if self.skill1 != null:
		self.skill1.damage += value
	if self.skill2 != null:
		self.skill2.damage += value
	if self.skill3 != null:
		self.skill3.damage += value
	if self.skill4 != null:
		self.skill4.damage += value
	if self is Enemy:
		self.skill_info.update_skill_info()


func take_damage(damage : int, element : String, change_element : bool):
	if not copy:
		match element:
			"fire":
				AudioPlayer.play_FX("fire_hit", -8)
			"water":
				AudioPlayer.play_FX("water_hit", -18)
			"lightning":
				AudioPlayer.play_FX("lightning_hit", -20)
			"earth":
				AudioPlayer.play_FX("earth_hit", -25)
			"grass":
				AudioPlayer.play_FX("grass_hit", -10)
			_:
				AudioPlayer.play_FX("fire_hit", -18)

	var damage_left = roundi(damage)

	# Enemy damage modifiers based on run + element
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

	# calc damage reduction
	damage_left *= (1 - damage_reduction)
	
	var total_dmg = damage_left


	# Fire damage block
	if element == "fire":
		damage_left -= self.fire_damage_block
	
	DamageNumbers.display_number(damage_left, damage_number_origin.global_position, element, "")


	# Shield interaction
	if shield > 0:
		if shield <= damage_left:
			damage_left -= shield
			shield = 0
		elif shield > damage_left:
			shield -= damage_left
			damage_left = 0
		if not copy:
			hp_bar.set_shield(shield)

	health -= damage_left
	health = roundi(health)
	check_if_dead()
	if not copy:
		hp_bar.set_hp(roundi(health))

	if change_element:
		change_element(element)

	return total_dmg


func change_element(element):
	await get_tree().create_timer(0.00001).timeout
	current_element = element
	if not copy:
		hp_bar.update_element(current_element)


func receive_healing(healing: int, element : String, change_element):
	var healing_reduction = 1.0
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

	var new_shielding = shielding
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
		match position:
			1:
				combat_manager.ally1 = null
			2:
				combat_manager.ally2 = null
			3:
				combat_manager.ally3 = null
			4:
				combat_manager.ally4 = null
		combat_manager.check_ally_turn_done()
	elif self is Enemy:
		combat_manager.enemies.erase(self)
		match position:
			1:
				combat_manager.enemy1 = null
			2:
				combat_manager.enemy2 = null
			3:
				combat_manager.enemy3 = null
			4:
				combat_manager.enemy4 = null

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


# Apply a status with stacking/countdown rules.
# - If stackable and already present: increase stacks (up to max_stacks) and refresh turns_remaining.
# - If not stackable and already present: overwrite duration (and damage).
# - If new: duplicate resource, set stacks to 1 if stackable.
func apply_status(incoming: Status) -> void:

	var new_s: Status = incoming.duplicate()

	# Example: Burn uses run-based damage and duration
	match new_s.name:
		"Burn":
			new_s.turns_remaining = run.burn_length
			new_s.damage = run.burn_damage

	# Ensure at least 1 stack if stackable and not set
	if new_s.stack and new_s.stacks <= 0:
		new_s.stacks = 1
	

	# Try to merge with existing
	for s in status:
		if s.name == new_s.name:
			if s.stack:
				s.stacks = min(s.stacks + 1, new_s.max_stacks)
				s.turns_remaining = new_s.turns_remaining
				s.damage = new_s.damage
			else:
				s.turns_remaining = new_s.turns_remaining
				s.damage = new_s.damage
			if not copy:
				hp_bar.update_statuses(status)
			return
	
				
	# No existing, append
	status.append(new_s)
	apply_status_buff(new_s)
	if not copy:
		hp_bar.update_statuses(status)

func remove_status(stati):
	status.erase(stati)
	
	remove_status_buff(stati)
	hp_bar.update_statuses(status)
	
func apply_status_buff(s: Status) -> void:
	match s.name:
		"Nitro":
			self.damage_reduction -= run.nitro_mult
		"Muck":
			set_all_skill_damage_mult(self.all_skill_damage_mult - run.muck_mult)
		"Thorn":
			self.damage_reduction += run.thorn_mult
			self.thorn_damage += run.thorn_damage

func remove_status_buff(s: Status) -> void:
	match s.name:
		"Nitro":
			self.damage_reduction += run.nitro_mult
		"Muck":
			set_all_skill_damage_mult(self.all_skill_damage_mult + run.muck_mult)
		"Thorn":
			self.damage_reduction -= run.thorn_mult
			self.thorn_damage -= run.thorn_damage


# Called by CombatManager pre-/post-turn wrappers:
# - pre_turn == true  → ally_pre_status / enemy_pre_status
# - pre_turn == false → ally_post_status / enemy_post_status
func tick_statuses(pre_turn_tick: bool) -> void:
	var to_remove: Array = []

	for s in status:
		if s.pre_turn != pre_turn_tick:
			continue

		# Execute effect every relevant turn (both countdown and event_based)
		execute_status(s)

		# Only countdown types lose duration
		if s.type == "countdown":
			s.turns_remaining -= 1
			if s.turns_remaining <= 0:
				to_remove.append(s)

	for r in to_remove:
		remove_status(r)

	hp_bar.update_statuses(status)


# Executes the logic of a single status.
# - event_based: sets flags like Bubble/Muck/Nitro/Sow.
# - countdown: deals damage or other per-turn effect.
func execute_status(s: Status) -> void:
	if s.type == "event_based":
		if s.name == "Bubble":
			pass
		elif s.name == "Muck":
			pass
		elif s.name == "Nitro":
			pass
		elif s.name == "Sow":
			pass
		return

	# countdown type
	var dmg = s.damage
	if s.stack:
		dmg *= max(1, s.stacks)

	if dmg > 0:
		take_damage(dmg, s.element, true)

		
func check_statuses():
	for s in status:
		if s.name == "Bloom":
			if s.stacks == s.max_stacks:
				if self is Enemy:
					combat_manager.ally_bloom_burst()
				elif self is Ally:
					combat_manager.enemy_bloom_burst()
				remove_status(s)

func set_shield(shield):
	self.shield = shield
	hp_bar.set_shield(shield)


func increase_max_hp(count, changehp):
	max_health += count
	if max_health < 1:
		max_health = 1
	hp_bar.set_maxhp(max_health)
	hp_bar.set_hp(health + count)
	if changehp:
		health = max_health
		hp_bar.set_hp(max_health)

func set_all_skill_damage_mult(num):
	all_skill_damage_mult = num
	update_skills()
	
func update_skills():
	pass
