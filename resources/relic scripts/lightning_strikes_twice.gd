extends Relic

var member_var = 0

func initialize_relic(owner : RelicUI) -> void:
	var run = owner.get_tree().get_first_node_in_group("run")
	run.lightning_strikes_twice = true
	pass
func activate_relic(owner: RelicUI) -> void:
	print("this happens at specific times based on the Relic.Type property")
	
func deactivate_relic(owner: RelicUI) -> void:
	print("this gets called when a RelicUI is exiting hte SceneTree")

func get_tooltip() -> String:
	return tooltip
