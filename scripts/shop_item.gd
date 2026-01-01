extends Control

const KEYSTONE_UI = preload("res://scenes/keystone handler/keystone_ui.tscn")

@onready var skill_info: Control = $PanelContainer/MarginContainer/VBoxContainer/SkillInfo
@onready var keystone_sprite: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/KeystoneInfo/KeystoneSprite

@onready var buy: Button = $PanelContainer/MarginContainer/VBoxContainer/Buy

@export var item : Resource
@export var price : int
var run
signal purchased
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	run = get_tree().get_first_node_in_group("run")
	skill_info.visible = false
	var shop = get_tree().get_first_node_in_group("shop")
	self.purchased.connect(shop.item_bought)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_item():
	item.update()
	if item is Keystone:
		keystone_sprite.texture = item.icon
		#var new_keystone_ui = KEYSTONE_UI.instantiate()
		#add_child(new_keystone_ui)
	elif item is Skill:
		skill_info.visible = true
		skill_info.skill = item
		skill_info.update_skill_info()
	
	buy.text = "Buy (" + str(price) + " Gold)"


func _on_buy_pressed() -> void:
	if not run.UIManager.reaction_guide_open and run.gold >= price:
		AudioPlayer.play_FX("click",-5)
		run.spend_gold(price)
		purchased.emit(item, self)

func hide_buy():
	buy.visible = false
	
func show_buy():
	buy.visible = true
