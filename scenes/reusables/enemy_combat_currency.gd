extends Control

@onready var fire_count: Label = $PanelContainer/MarginContainer/HBox/Control/FireCount
@onready var water_count: Label = $PanelContainer/MarginContainer/HBox/Control2/WaterCount
@onready var lightning_count: Label = $PanelContainer/MarginContainer/HBox/Control3/LightningCount
@onready var grass_count: Label = $PanelContainer/MarginContainer/HBox/Control5/GrassCount
@onready var earth_count: Label = $PanelContainer/MarginContainer/HBox/Control4/EarthCount



func update():
	var run = get_tree().get_first_node_in_group("run")
	fire_count.text = str(run.combat_manager.enemy_fire_tokens)
	water_count.text = str(run.combat_manager.enemy_water_tokens)
	lightning_count.text = str(run.combat_manager.enemy_lightning_tokens)
	grass_count.text = str(run.combat_manager.enemy_grass_tokens)
	earth_count.text = str(run.combat_manager.enemy_earth_tokens)
