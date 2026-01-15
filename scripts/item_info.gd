extends Control


@onready var item_name: Label = %ItemName
@onready var tags: RichTextLabel = %Tags
@onready var description: Label = %Description
 

func _ready() -> void:
	item_name.text = ""
	description.text = ""
	tags.text = " "

func update_item_info(item):
	tags.text = " "
	if item != null:
		item_name.text = item.name
		description.text = item.tooltip
		for tag in item.tags:
			var added_text = tag
			match tag:
				"Fire":
					added_text = " [color=coral]Fire[/color]"
				"Water":
					added_text = " [color=dark_cyan]Water[/color]"
				"Lightning":
					added_text = " [color=yellow]Lightning[/color]"
				"Grass":
					added_text = " [color=web_green]Grass[/color]"
				"Earth":
					added_text = " [color=saddle_brown]Earth[/color]"
			if tag != "" or null:
				tags.text += added_text + ",  "
		tags.text = tags.text.substr(0, tags.text.length()-3)
