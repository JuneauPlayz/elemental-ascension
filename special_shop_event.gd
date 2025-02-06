extends Node2D


# Called when the node enters the scene tree for the first time.
var run
signal event_ended
var shop = ""
@onready var event_popup: PanelContainer = $EventPopup
@onready var next_shop: Button = $NextShop

func _ready() -> void:
	run = get_tree().get_first_node_in_group("run")
	event_ended.connect(run.scene_ended)
	next_shop.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_next_combat_pressed() -> void:
	event_ended.emit(shop)


func _on_fire_pressed() -> void:
	shop = "fire_shop"
	event_popup.visible = false
	next_shop.visible = true

func _on_water_pressed() -> void:
	shop = "water_shop"
	event_popup.visible = false
	next_shop.visible = true


func _on_lightning_pressed() -> void:
	shop = "lightning_shop"
	event_popup.visible = false
	next_shop.visible = true


func _on_grass_pressed() -> void:
	shop = "grass_shop"
	event_popup.visible = false
	next_shop.visible = true


func _on_earth_pressed() -> void:
	shop = "earth_shop"
	event_popup.visible = false
	next_shop.visible = true
