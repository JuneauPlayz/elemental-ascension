extends Control

const KEYSTONE_UI = preload("res://scenes/keystone handler/keystone_ui.tscn")


@onready var icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/TextureRectContainer/PanelContainer/TextureRect
@onready var item_name: RichTextLabel = %ItemName

@onready var buy: Button = %Buy

@export var item : Resource
@export var price : int

var run
signal purchased

const EARTH_SYMBOL = preload("uid://dgkpabaj1kl5r")
const FIRE_SYMBOL = preload("uid://ega8yf10nrw")
const GRASS_SYMBOL = preload("uid://6wem028prmhu")
const LIGHTNING_SYMBOL = preload("uid://c2a810t6sstxx")
const WATER_SYMBOL = preload("uid://b7ctbguy8vt4q")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	run = get_tree().get_first_node_in_group("run")
	var shop = get_tree().get_first_node_in_group("shop")
	position.x = 0
	position.y = 0
	self.purchased.connect(shop.item_bought)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_item():
	item_name.text = item.name
	if item is Keystone or item is Item:
		icon.texture = item.icon
	elif item is Skill:
		match item.element:
			"fire":
				icon.texture = FIRE_SYMBOL
			"water":
				icon.texture = WATER_SYMBOL
			"lightning":
				icon.texture = LIGHTNING_SYMBOL
			"grass":
				icon.texture = GRASS_SYMBOL
			"earth":
				icon.texture = EARTH_SYMBOL
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


func _on_texture_rect_mouse_entered() -> void:
	run.UIManager.display(item)


func _on_texture_rect_mouse_exited() -> void:
	run.UIManager.hide_display()
