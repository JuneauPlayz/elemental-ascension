extends Control

@onready var relic_name: Label = $PanelContainer/PanelContainer/MarginContainer/VBoxContainer/RelicName
@onready var description: Label = $PanelContainer/PanelContainer/MarginContainer/VBoxContainer/Description
@onready var tags: RichTextLabel = $PanelContainer/PanelContainer/MarginContainer/VBoxContainer/Tags

#@export var relic : Relic
func _ready() -> void:
	relic_name.text = ""
	description.text = ""
	tags.text = " Tags : "

func update_relic_info(relic):
	tags.text = " Tags : "
	if relic != null:
		relic_name.text = relic.relic_name
		description.text = relic.tooltip
		for tag in relic.tags:
			var added_text = tag
			match tag:
				"Fire":
					added_text = " [color=coral]Fire[/color]"
				"Water":
					added_text = " [color=dark_cyan]Water[/color]"
				"Lightning":
					added_text = " [color=purple]Lightning[/color]"
				"Grass":
					added_text = " [color=web_green]Grass[/color]"
				"Earth":
					added_text = " [color=saddle_brown]Earth[/color]"
			if tag != "" or null:
				tags.text += added_text + ",  "
		tags.text = tags.text.substr(0, tags.text.length()-3)
