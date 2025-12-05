extends Relic

var member_var = 0
@export var vaporize_mult : float
@export var shock_mult : float
@export var erupt_mult : float
@export var detonate_main_mult : float
@export var detonate_side_mult : float
@export var nitro_mult : float
@export var burn_damage : float
@export var burn_length : float
@export var muck_mult : float
@export var discharge_mult : float
@export var sow_shielding : float
@export var sow_healing : float
@export var sow_healing_mult : float
@export var sow_shielding_mult : float
@export var ally_bloom_shielding : float
@export var enemy_bloom_shielding : float
@export var ally_bloom_healing : float
@export var enemy_bloom_healing : float

func initialize_relic(owner : RelicUI) -> void:
	var run = owner.get_tree().get_first_node_in_group("run")
	run.vaporize_mult += self.vaporize_mult
	run.shock_mult += self.shock_mult
	run.erupt_mult += self.erupt_mult
	run.detonate_main_mult += self.detonate_main_mult
	run.detonate_side_mult += self.detonate_side_mult
	run.nitro_mult += self.nitro_mult
	run.burn_damage += self.burn_damage
	run.burn_length += self.burn_length
	run.muck_mult += self.muck_mult
	run.discharge_mult += self.discharge_mult
	run.sow_shielding += self.sow_shielding
	run.sow_healing += self.sow_healing
	run.sow_healing_mult += self.sow_healing_mult
	run.sow_shielding_mult += self.sow_shielding_mult
	run.ally_bloom_healing += self.ally_bloom_healing
	run.ally_bloom_shielding += self.ally_bloom_shielding
	run.enemy_bloom_healing = self.enemy_bloom_healing
	run.enemy_bloom_shielding = self.enemy_bloom_shielding

	
func activate_relic(owner: RelicUI) -> void:
	print("this happens at specific times based on the Relic.Type property")
	
func deactivate_relic(owner: RelicUI) -> void:
	print("this gets called when a RelicUI is exiting hte SceneTree")

func get_tooltip() -> String:
	return tooltip
