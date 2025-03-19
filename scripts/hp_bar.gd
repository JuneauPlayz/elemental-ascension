extends Control
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var hptext: Label = $HP
var max_hp = 0
var hp = 0
var shield = 0
@onready var current_element: RichTextLabel = $CurrentElement
@onready var shield_bar: ProgressBar = $ShieldBar
@onready var shield_spr: Sprite2D = $Shield
@onready var shield_label: Label = $ShieldLabel
@onready var status_bar: Control = $"Status Bar"


var element_dict = {"none": Color.WHITE, "fire": Color.CORAL, "water": Color.DARK_CYAN, "lightning": Color.PURPLE, "earth": Color.SADDLE_BROWN, "grass": Color.WEB_GREEN}

func _ready():
	update_statuses([])

func set_hp(newhp):
	hp = newhp
	progress_bar.value = hp
	update_text()

func set_maxhp(newhp):
	max_hp = newhp
	progress_bar.max_value = max_hp
	progress_bar.value = hp
	shield_bar.max_value = max_hp
	update_text()

func set_shield(newshield):
	shield = newshield
	shield_bar.value = shield
	update_text()
	
func update_text():
	hptext.text = str(hp) + " / " + str(max_hp)
	if (shield > 0):
		shield_bar.visible = true
		shield_spr.visible = true
		shield_label.visible = true
		shield_label.text = str(shield)
	else:
		shield_label.visible = false
		shield_bar.visible = false
		shield_spr.visible = false
		
		

func update_element(element):
	match element:
		"":
			current_element.text = " Element : None"
		"none":
			current_element.text = " Element : None"
		"fire":
			current_element.text = " Element : [color=coral]Fire[/color]"
		"water":
			current_element.text = " Element : [color=dark_cyan]Water[/color]"
		"lightning":
			current_element.text = " Element : [color=purple]Lightning[/color]"
		"earth":
			current_element.text = " Element : [color=saddle_brown]Earth[/color]"
		"grass":
			current_element.text = " Element : [color=web_green]Grass[/color]"
			
func update_statuses(statuses):
	status_bar.update_statuses(statuses)
