# meta-name Keystone
# meta-description: Create a Relio which can be acquired by the player.

extends Keystone

var member_var = 0

func initialize_keystone(owner : KeystoneUI) -> void:
	var run = owner.get_tree().get_first_node_in_group("run")
	
func activate_keystone(owner: KeystoneUI) -> void:
	print("this happens at specific times based on the Keystone.Type property")
	
func deactivate_keystone(owner: KeystoneUI) -> void:
	print("this gets called when a KeystoneUI is exiting hte SceneTree")

func get_tooltip() -> String:
	return tooltip
