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
@onready var element_symbol: TextureRect = $ElementSymbol

const EARTH_SYMBOL = preload("uid://dgkpabaj1kl5r")
const FIRE_SYMBOL = preload("uid://ega8yf10nrw")
const GRASS_SYMBOL = preload("uid://6wem028prmhu")
const LIGHTNING_SYMBOL = preload("uid://c2a810t6sstxx")
const WATER_SYMBOL = preload("uid://b7ctbguy8vt4q")
const WHITE_CIRCLE = preload("uid://dkf53etd24pjd")


var element_dict = {"none": Color.WHITE, "fire": Color.CORAL, "water": Color.DARK_CYAN, "lightning": Color.YELLOW, "earth": Color.SADDLE_BROWN, "grass": Color.WEB_GREEN}

func _ready():
	update_statuses([])
	update_element("neutral")

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
			element_symbol.texture = WHITE_CIRCLE
		"neutral":
			current_element.text = " Element : "
			element_symbol.texture = WHITE_CIRCLE
		"fire":
			current_element.text = " [color=coral]Element[/color] :"
			element_symbol.texture = FIRE_SYMBOL
		"water":
			current_element.text = " [color=dark_cyan]Element[/color] :"
			element_symbol.texture = WATER_SYMBOL
		"lightning":
			current_element.text = " [color=yellow]Element[/color] :"
			element_symbol.texture = LIGHTNING_SYMBOL
		"earth":
			current_element.text = " [color=saddle_brown]Element[/color] :"
			element_symbol.texture = EARTH_SYMBOL
		"grass":
			current_element.text = " [color=web_green]Element[/color] :"
			element_symbol.texture = GRASS_SYMBOL
		
func update_statuses(statuses):
	status_bar.update_statuses(statuses)
