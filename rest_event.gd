extends Node2D
@onready var next_combat: Button = $NextCombat
@onready var rest: Button = $EventPopup/MarginContainer/HBoxContainer/VBoxContainer/Rest
@onready var work: Button = $EventPopup/MarginContainer/HBoxContainer/VBoxContainer/Work
@onready var continue_button: Button = $EventPopup/MarginContainer/HBoxContainer/VBoxContainer/Continue
@onready var event_popup: PanelContainer = $EventPopup

var run
signal event_ended
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	run = get_tree().get_first_node_in_group("run")
	event_ended.connect(run.special_scene_ended)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_next_combat_pressed() -> void:
	event_ended.emit()
	


func _on_rest_pressed() -> void:
	for ally in run.allies:
		ally.increase_max_hp(10,true)
	next_combat.visible = true
	event_popup.visible = false


func _on_work_pressed() -> void:
	run.add_gold(3)
	next_combat.visible = true
	event_popup.visible = false
	


func _on_continue_pressed() -> void:
	for ally in run.allies:
		ally.take_damage(30,"none",true)
	run.increase_xp(50)
	next_combat.visible = true
	event_popup.visible = false
