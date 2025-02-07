extends Control

@onready var fire_count: Label = $PanelContainer/MarginContainer/VBoxContainer/Control/FireCount
@onready var water_count: Label = $PanelContainer/MarginContainer/VBoxContainer/Control2/WaterCount
@onready var lightning_count: Label = $PanelContainer/MarginContainer/VBoxContainer/Control3/LightningCount
@onready var grass_count: Label = $PanelContainer/MarginContainer/VBoxContainer/Control4/GrassCount
@onready var earth_count: Label = $PanelContainer/MarginContainer/VBoxContainer/Control5/EarthCount

@onready var fire_count_2: Label = $PanelContainer/MarginContainer/VBoxContainer/Control/FireCount2
@onready var water_count_2: Label = $PanelContainer/MarginContainer/VBoxContainer/Control2/WaterCount2
@onready var lightning_count_2: Label = $PanelContainer/MarginContainer/VBoxContainer/Control3/LightningCount2
@onready var earth_count_2: Label = $PanelContainer/MarginContainer/VBoxContainer/Control5/EarthCount2
@onready var grass_count_2: Label = $PanelContainer/MarginContainer/VBoxContainer/Control4/GrassCount2


func update():
	var run = get_tree().get_first_node_in_group("run")
	fire_count.text = str(run.combat_manager.fire_tokens)
	water_count.text = str(run.combat_manager.water_tokens)
	lightning_count.text = str(run.combat_manager.lightning_tokens)
	grass_count.text = str(run.combat_manager.grass_tokens)
	earth_count.text = str(run.combat_manager.earth_tokens)
	
	fire_count_2.visible = true
	water_count_2.visible = true
	lightning_count_2.visible = true
	grass_count_2.visible = true
	earth_count_2.visible = true
	
	if run.combat_manager.p_fire_tokens == run.combat_manager.fire_tokens:
		fire_count_2.visible = false
	elif run.combat_manager.p_fire_tokens > run.combat_manager.fire_tokens:
		fire_count_2.text = " (+" + str(run.combat_manager.p_fire_tokens-run.combat_manager.fire_tokens) + ")"
	elif run.combat_manager.p_fire_tokens < run.combat_manager.fire_tokens:
		fire_count_2.text = " (" + str(run.combat_manager.p_fire_tokens-run.combat_manager.fire_tokens) + ")"
		
	if run.combat_manager.p_water_tokens == run.combat_manager.water_tokens:
		water_count_2.visible = false
	elif run.combat_manager.p_water_tokens > run.combat_manager.water_tokens:
		water_count_2.text = " (+" + str(run.combat_manager.p_water_tokens-run.combat_manager.water_tokens) + ")"
	elif run.combat_manager.p_water_tokens < run.combat_manager.water_tokens:
		water_count_2.text = " (" + str(run.combat_manager.p_water_tokens-run.combat_manager.water_tokens) + ")"
		
	if run.combat_manager.p_lightning_tokens == run.combat_manager.lightning_tokens:
		lightning_count_2.visible = false
	elif run.combat_manager.p_lightning_tokens > run.combat_manager.lightning_tokens:
		lightning_count_2.text = " (+" + str(run.combat_manager.p_lightning_tokens-run.combat_manager.lightning_tokens) + ")"
	elif run.combat_manager.p_lightning_tokens < run.combat_manager.lightning_tokens:
		lightning_count_2.text = " (" + str(run.combat_manager.p_lightning_tokens-run.combat_manager.lightning_tokens) + ")"
		
	if run.combat_manager.p_grass_tokens == run.combat_manager.grass_tokens:
		grass_count_2.visible = false
	elif run.combat_manager.p_grass_tokens > run.combat_manager.grass_tokens:
		grass_count_2.text = " (+" + str(run.combat_manager.p_grass_tokens-run.combat_manager.grass_tokens) + ")"
	elif run.combat_manager.p_fire_tokens < run.combat_manager.fire_tokens:
		grass_count_2.text = " (" + str(run.combat_manager.p_grass_tokens-run.combat_manager.grass_tokens) + ")"
		
	if run.combat_manager.p_earth_tokens == run.combat_manager.earth_tokens:
		earth_count_2.visible = false
	elif run.combat_manager.p_earth_tokens > run.combat_manager.earth_tokens:
		earth_count_2.text = " (+" + str(run.combat_manager.p_earth_tokens-run.combat_manager.earth_tokens) + ")"
	elif run.combat_manager.p_earth_tokens < run.combat_manager.earth_tokens:
		earth_count_2.text = " (" + str(run.combat_manager.p_earth_tokens-run.combat_manager.earth_tokens) + ")"
