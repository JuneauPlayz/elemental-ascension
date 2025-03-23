extends Control

@onready var core_name: RichTextLabel = %CoreName
@onready var main_stat_label: RichTextLabel = %MainStat
@onready var stat_container: HBoxContainer = $Panel/PanelContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer
@onready var v_box_container: VBoxContainer = $Panel/PanelContainer/PanelContainer/MarginContainer/VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update(core):
	var main_stat = core.main_stat
	var name = main_stat.element + "_" + main_stat.type
	var display_name = main_stat.element + " " + main_stat.type
	var run = get_tree().get_first_node_in_group("run")
	main_stat_label.text = " M: + " + str(main_stat.amount) + " " + display_name
	for stat in core.substats:
		var new_substat = main_stat_label.duplicate()
		v_box_container.add_child(new_substat)
		name = stat.element + "_" + stat.type
		display_name = stat.element + " " + stat.type
		new_substat.text = " S: + " + str(stat.amount) + " " + display_name
