extends Control

@onready var result_title: Label = $PanelContainer/PanelContainer/MarginContainer/VBoxContainer/ResultTitle
@onready var result_text: Label = $PanelContainer/PanelContainer/MarginContainer/VBoxContainer/Result
@onready var xp_text: Label = $PanelContainer/PanelContainer/MarginContainer/VBoxContainer/XP
@onready var gold_text: Label = $PanelContainer/PanelContainer/MarginContainer/VBoxContainer/Gold
@onready var shop_text: Label = $PanelContainer/PanelContainer/MarginContainer/VBoxContainer/Shop


@export var combat_manager : Node
signal continue_pressed
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_text(result, reward):
	result_title.text = result
	if result == "Defeat!":
		result_text.text = "Better luck next time.."
		xp_text.visible = false
		gold_text.visible = false
		shop_text.visible = false
		
	else:
		if reward.gold > 0:
			gold_text.text = "+" + str(reward.gold) + "  Gold"
		else:
			gold_text.text = ""
		if reward.XP > 0:
			xp_text.text = "+" + str(reward.XP) + "  XP"
		else:
			xp_text.text = ""
		if reward.shop_type != "none":
			match reward.shop_type:
				"normal":
					shop_text.text = "+ Normal Shop"
				"fire":
					shop_text.text = "+ Fire Shop"
				"water":
					shop_text.text = "+ Water Shop"
				"lightning":
					shop_text.text = "+ Lightning Shop"
				"grass":
					shop_text.text = "+ Grass Shop"
				"earth":
					shop_text.text = "+ Earth Shop"
		else:
			shop_text.text = ""
		


func _on_continue_pressed() -> void:
	continue_pressed.emit()
