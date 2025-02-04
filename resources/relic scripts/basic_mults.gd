extends Relic

var member_var = 0
@export var fire_damage_bonus : int
@export var fire_damage_mult : float
@export var water_damage_bonus : int
@export var water_damage_mult : float
@export var lightning_damage_bonus : int
@export var lightning_damage_mult : float
@export var earth_damage_bonus : int
@export var earth_damage_mult : float
@export var grass_damage_bonus : int
@export var grass_damage_mult : float
@export var healing_bonus : int
@export var healing_mult : float
@export var shielding_bonus : int
@export var shielding_mult : float


func initialize_relic(owner : RelicUI) -> void:
	# Elemental Damage Bonuses and Multipliers
	var run = owner.get_tree().get_first_node_in_group("run")
	run.fire_damage_bonus += self.fire_damage_bonus
	run.fire_damage_mult += self.fire_damage_mult
	run.water_damage_bonus += self.water_damage_bonus
	run.water_damage_mult += self.water_damage_mult
	run.lightning_damage_bonus += self.lightning_damage_bonus
	run.lightning_damage_mult += self.lightning_damage_mult
	run.earth_damage_bonus += self.earth_damage_bonus
	run.earth_damage_mult += self.earth_damage_mult
	run.grass_damage_bonus += self.grass_damage_bonus
	run.grass_damage_mult += self.grass_damage_mult

	# Healing and Shielding Bonuses and Multipliers
	run.healing_bonus += self.healing_bonus
	run.healing_mult += self.healing_mult
	run.shielding_bonus += self.shielding_bonus
	run.shielding_mult += self.shielding_mult
	
func activate_relic(owner: RelicUI) -> void:
	print("this happens at specific times based on the Relic.Type property")
	
func deactivate_relic(owner: RelicUI) -> void:
	print("this gets called when a RelicUI is exiting hte SceneTree")

func get_tooltip() -> String:
	return tooltip
