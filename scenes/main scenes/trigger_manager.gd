extends Node

class_name TriggerManager

var run
var triggers: Array = [] # all registered triggers
var trigger_queue: Array = [] # triggers queued for execution

signal triggers_done

@onready var combat_manager: Node = %CombatManager

func _ready() -> void:
	run = get_tree().get_first_node_in_group("run")


func register_trigger(trigger: Trigger) -> void:
	if trigger == null:
		return
	triggers.append(trigger)

# --- Signal handlers ---
func _on_skill_used(caster: Unit, skill: Skill, target: Array[Unit]) -> void:
	print("hi")
	handle_event("skill_used", [caster, skill, target])

func _on_damage_dealt(value: int, element: String) -> void:
	handle_event("damage_dealt", [value, element])

func _on_reaction_triggered(value: int, reaction: String) -> void:
	handle_event("reaction_triggered", [value, reaction])

func _on_turn_started() -> void:
	handle_event("turn_started")

func _on_turn_ended() -> void:
	handle_event("turn_ended")

# --- Core event handling ---
func handle_event(event_name: String, event_args = null) -> void:
	for trigger in triggers:
		if trigger == null or trigger.conditions.is_empty():
			continue

		for condition in trigger.conditions:
			if _check_condition(condition, event_name, event_args, trigger.caster):
				trigger_queue.append(trigger)
				break # Only need one condition to queue

	execute_triggers()

func _check_condition(condition, event_name: String, event_args, caster) -> bool:
	# Check timing first
	if condition.timing == "Pre" and event_name in ["skill_used", "damage_dealt", "reaction_triggered"]:
		return false
	if condition.timing == "Post" and event_name in ["turn_started", "turn_ended"]:
		return false

	# Match event to condition type
	match condition.condition_type:
		"Skill":
			if event_name != "skill_used":
				return false
			var skill = event_args[1] if event_args != null else null
			if skill == null:
				return false
			if condition.element != null and skill.element != condition.element:
				return false

		"Damage":
			if event_name != "damage_dealt":
				return false
			if condition.element != null and event_args[1] != condition.element:
				return false

		"Reaction":
			if event_name != "reaction_triggered":
				return false
			if condition.reaction != null and event_args[1] != condition.reaction:
				return false

		"Turn":
			if event_name != condition.condition_type.lower(): # turn_started / turn_ended
				return false

	# Optional: check caster matches
	if caster != null:
		return false

	return true

func execute_triggers() -> void:
	while trigger_queue.size() > 0:
		var trigger = trigger_queue.pop_front()
		_execute_trigger(trigger)
		await get_tree().create_timer(GC.GLOBAL_INTERVAL).timeout

	emit_signal("triggers_done")

func _execute_trigger(trigger: Trigger) -> void:
	if trigger == null:
		return

	for effect in trigger.effects:
		if effect == null:
			continue
		var targets = _resolve_trigger_targets(effect.target_type)
		for unit in targets:
			if unit == null:
				continue
			match effect.value_type:
				"Damage":
					unit.take_damage(effect.value, effect.element, false)
				"Healing":
					unit.receive_healing(effect.value, effect.element, false)
				"Shielding":
					unit.receive_shielding(effect.value, effect.element, false)
				"Status":
					if effect.statuses != null:
						for status in effect.statuses:
							for i in range(effect.value):
								unit.apply_status(status.duplicate())
							unit.hp_bar.update_statuses(unit.status)

func _resolve_trigger_targets(target_type: String) -> Array:
	var cm = combat_manager
	var result: Array = []

	match target_type:
		"single_enemy":
			if cm.front_enemy != null:
				result.append(cm.front_enemy)
		"single_ally":
			if cm.front_ally != null:
				result.append(cm.front_ally)
		"all_enemies":
			result = cm.enemies.duplicate()
		"all_allies":
			result = cm.allies.duplicate()
		"all_units":
			result = cm.allies.duplicate()
			result.append_array(cm.enemies)
		"front_enemy":
			if cm.front_enemy != null:
				result.append(cm.front_enemy)
		"front_2_enemies":
			if cm.front_enemy != null:
				result.append(cm.front_enemy)
			if cm.front_enemy_2 != null:
				result.append(cm.front_enemy_2)
		"back_enemy":
			if cm.back_enemy != null:
				result.append(cm.back_enemy)
		"back_2_enemies":
			if cm.back_enemy != null:
				result.append(cm.back_enemy)
			if cm.back_enemy_2 != null:
				result.append(cm.back_enemy_2)
		"front_ally":
			if cm.front_ally != null:
				result.append(cm.front_ally)
		"front_2_allies":
			if cm.front_ally != null:
				result.append(cm.front_ally)
			if cm.front_ally_2 != null:
				result.append(cm.front_ally_2)
		"back_ally":
			if cm.back_ally != null:
				result.append(cm.back_ally)
		"back_2_allies":
			if cm.back_ally != null:
				result.append(cm.back_ally)
			if cm.back_ally_2 != null:
				result.append(cm.back_ally_2)
		"random_enemy":
			if cm.enemies.size() > 0:
				result.append(cm.enemies.pick_random())
		"random_ally":
			if cm.allies.size() > 0:
				result.append(cm.allies.pick_random())
		"random_middle_ally":
			if cm.middle_allies.size() > 0:
				result.append(cm.middle_allies.pick_random())

	return result
