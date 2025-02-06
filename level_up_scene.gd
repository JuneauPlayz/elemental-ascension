extends Node2D

var run
signal level_up_ended
@onready var continue_button: Button = $Continue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	run = get_tree().get_first_node_in_group("run")
	for ally in run.allies:
		ally.spell_select_ui.visible = true
		ally.spell_select_ui.enable_all()
		ally.confirm_swap.visible = false
		ally.swap_tutorial.visible = false
	continue_button.text = "Skip Rewards"
	level_up_ended.connect(run.scene_ended)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for ally in run.allies:
		if ally.level_up == true:
			return
	continue_button.text = "Continue"


func _on_continue_pressed() -> void:
	level_up_ended.emit("")
