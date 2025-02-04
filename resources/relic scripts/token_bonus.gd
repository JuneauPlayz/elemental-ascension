extends Relic

var member_var = 0
@export var fire_token_count : int
@export var water_token_count : int
@export var lightning_token_count : int
@export var earth_token_count : int
@export var grass_token_count : int

func initialize_relic(owner : RelicUI) -> void:
	print("this happens once we gain a new relic")
	
func activate_relic(owner: RelicUI) -> void:
	var run = owner.get_tree().get_first_node_in_group("run")
	run.fire_tokens += fire_token_count
	run.water_tokens += water_token_count
	run.lightning_tokens += lightning_token_count
	run.earth_tokens += earth_token_count
	run.grass_tokens += grass_token_count
	
func deactivate_relic(owner: RelicUI) -> void:
	print("this gets called when a RelicUI is exiting hte SceneTree")

func get_tooltip() -> String:
	return tooltip
