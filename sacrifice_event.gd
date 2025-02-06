extends Node2D

var run
signal event_ended
@onready var next_combat: Button = $NextCombat
@onready var event_popup: PanelContainer = $EventPopup

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	run = get_tree().get_first_node_in_group("run")
	event_ended.connect(run.scene_ended)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_sacrifice_gold_pressed() -> void:
	var total_gold = run.gold
	var sacrifices = run.gold / 3
	for i in range(sacrifices):
		for ally in run.allies:
			ally.increase_max_hp(10,true)
		run.all_damage_bonus += 1
	run.spend_gold(run.gold)
	next_combat.visible = true
	event_popup.visible = false

func _on_sacrifice_health_pressed() -> void:
	for ally in run.allies:
		ally.increase_max_hp(-30,true)
	run.add_gold(15)
	next_combat.visible = true
	event_popup.visible = false
	
func _on_sacrifice_damage_pressed() -> void:
	run.all_damage_mult = run.all_damage_mult / 2.0
	for ally in run.allies:
		ally.increase_max_hp(ally.max_health,true)
	run.healing_mult += 1
	run.shielding_mult += 1
	next_combat.visible = true
	event_popup.visible = false


func _on_next_combat_pressed() -> void:
	event_ended.emit("")
