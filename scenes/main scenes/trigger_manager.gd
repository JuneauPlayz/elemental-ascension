extends Node

var run

@onready var combat_manager: Node = %CombatManager

var post_fire_skill_triggers : Array[Trigger]

func _ready() -> void:
	var run = get_tree().get_first_node_in_group("run")
	
func execute_trigger(trigger: Trigger) -> void:
	if trigger == null:
		return

	var targets: Array = _resolve_trigger_targets(trigger.target_type)
	if targets.is_empty():
		return

	for unit in targets:
		if unit == null:
			continue

		match trigger.value_type:
			"Damage":
				unit.take_damage(trigger.value, trigger.element, false)
			"Healing":
				unit.receive_healing(trigger.value, trigger.element, false)
			"Shielding":
				unit.receive_shielding(trigger.value, trigger.element, false)


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

func _on_combat_manager_ally_fire_skill_used() -> void:
	for trigger in post_fire_skill_triggers:
		execute_trigger(trigger)


func _on_combat_manager_ally_water_skill_used() -> void:
	pass # Replace with function body.


func _on_combat_manager_ally_lightning_skill_used() -> void:
	pass # Replace with function body.


func _on_combat_manager_ally_grass_skill_used() -> void:
	pass # Replace with function body.


func _on_combat_manager_ally_earth_skill_used() -> void:
	pass # Replace with function body.
