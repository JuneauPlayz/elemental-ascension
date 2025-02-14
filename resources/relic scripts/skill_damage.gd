extends Relic

var member_var = 0
@export var fire_skill_damage_bonus : int
@export var fire_skill_damage_mult : float
@export var water_skill_damage_bonus : int
@export var water_skill_damage_mult : float
@export var lightning_skill_damage_bonus : int
@export var lightning_skill_damage_mult : float
@export var earth_skill_damage_bonus : int
@export var earth_skill_damage_mult : float
@export var grass_skill_damage_bonus : int
@export var grass_skill_damage_mult : float
@export var physical_skill_damage_bonus : int
@export var physical_skill_damage_mult : float
@export var all_skill_damage_bonus : int
@export var all_skill_damage_mult : float
@export var healing_skill_bonus : int
@export var healing_skill_mult : float
@export var shielding_skill_bonus : int
@export var shielding_skill_mult : float


func initialize_relic(owner : RelicUI) -> void:
	# Elemental Damage Bonuses and Multipliers
	var run = owner.get_tree().get_first_node_in_group("run")
	run.fire_skill_damage_bonus += self.fire_skill_damage_bonus
	run.fire_skill_damage_mult += self.fire_skill_damage_mult
	run.water_skill_damage_bonus += self.water_skill_damage_bonus
	run.water_skill_damage_mult += self.water_skill_damage_mult
	run.lightning_skill_damage_bonus += self.lightning_skill_damage_bonus
	run.lightning_skill_damage_mult += self.lightning_skill_damage_mult
	run.earth_skill_damage_bonus += self.earth_skill_damage_bonus
	run.earth_skill_damage_mult += self.earth_skill_damage_mult
	run.grass_skill_damage_bonus += self.grass_skill_damage_bonus
	run.grass_skill_damage_mult += self.grass_skill_damage_mult
	run.physical_skill_damage_bonus += self.physical_skill_damage_bonus
	run.physical_skill_damage_mult += self.physical_skill_damage_mult
	run.all_skill_damage_bonus += self.all_skill_damage_bonus
	run.all_skill_damage_mult += self.all_skill_damage_mult
	# Healing and Shielding Bonuses and Multipliers
	run.healing_skill_bonus += self.healing_skill_bonus
	run.healing_skill_mult += self.healing_skill_mult
	run.shielding_skill_bonus += self.shielding_skill_bonus
	run.shielding_skill_mult += self.shielding_skill_mult
	
	run.update_skills()
func activate_relic(owner: RelicUI) -> void:
	print("this happens at specific times based on the Relic.Type property")
	
func deactivate_relic(owner: RelicUI) -> void:
	print("this gets called when a RelicUI is exiting hte SceneTree")

func get_tooltip() -> String:
	return tooltip
