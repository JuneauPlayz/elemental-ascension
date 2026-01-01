extends Control


@onready var keystone_name: Label = %KeystoneName
@onready var tags: RichTextLabel = %Tags
@onready var description: Label = %Description


#@export var keystone : Keystone
func _ready() -> void:
	keystone_name.text = ""
	description.text = ""
	tags.text = " "

func update_keystone_info(keystone):
	tags.text = " "
	if keystone != null:
		keystone_name.text = keystone.keystone_name
		description.text = keystone.tooltip
		for tag in keystone.tags:
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
