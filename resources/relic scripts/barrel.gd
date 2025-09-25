extends Relic

var member_var = 0
@export var damage_amount : int
@export var element : String


	
func activate_relic(owner: RelicUI) -> void:
	var combat = owner.get_tree().get_first_node_in_group("combat")
	if combat:
		var rng = RandomNumberGenerator.new()
		var random_num = rng.randi_range(1,combat.combat_manager.enemies.size())
		match random_num:
			1:
				combat.combat_manager.enemies[0].receive_damage(damage_amount, element, combat.combat_manager.ally1)
			2:
				combat.combat_manager.enemies[1].receive_damage(damage_amount, element, combat.combat_manager.ally1)
			3:
				combat.combat_manager.enemies[2].receive_damage(damage_amount, element, combat.combat_manager.ally1)
			4:
				combat.combat_manager.enemies[3].receive_damage(damage_amount, element, combat.combat_manager.ally1)
			
	
func get_tooltip() -> String:
	return tooltip
