extends Control

const RELIC_UI = preload("res://scenes/relic handler/relic_ui.tscn")

@onready var relic_info: Control = $PanelContainer/MarginContainer/VBoxContainer/RelicInfo
@onready var skill_info: Control = $PanelContainer/MarginContainer/VBoxContainer/SkillInfo

@onready var buy: Button = $PanelContainer/MarginContainer/VBoxContainer/Buy

@export var item : Resource
@export var price : int
var run
signal purchased
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	run = get_tree().get_first_node_in_group("run")
	relic_info.visible = false
	skill_info.visible = false
	var shop = get_tree().get_first_node_in_group("shop")
	self.purchased.connect(shop.item_bought)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_item():
	if item is Relic:
		relic_info.visible = true
		relic_info.update_relic_info(item)
		var new_relic_ui = RELIC_UI.instantiate()
		add_child(new_relic_ui)
	elif item is Skill:
		skill_info.visible = true
		skill_info.skill = item
		skill_info.update_skill_info()
	
	buy.text = "Buy (" + str(price) + " Gold)"


func _on_buy_pressed() -> void:
	if run.gold >= price:
		AudioPlayer.play_FX("click",-10)
		run.gold -= price
		purchased.emit(item, self)

func hide_buy():
	buy.visible = false
	
func show_buy():
	buy.visible = true
