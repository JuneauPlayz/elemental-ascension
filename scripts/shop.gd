extends Node2D

@onready var relic_handler_spot: Node2D = $RelicHandlerSpot
const RELIC_HANDLER = preload("res://scenes/relic handler/relic_handler.tscn")

const SHOP_ITEM = preload("res://scenes/reusables/shop_item.tscn")

var ally1 : Ally
var ally2 : Ally
var ally3 : Ally
var ally4 : Ally

var allies = []



@onready var relic_1_spot: Node2D = $Relic1Spot
@onready var relic_2_spot: Node2D = $Relic2Spot
@onready var relic_3_spot: Node2D = $Relic3Spot

@onready var spell_1_spot: Node2D = $Spell1Spot
@onready var spell_2_spot: Node2D = $Spell2Spot
@onready var spell_3_spot: Node2D = $Spell3Spot

@onready var refresh_button: Button = $NextCombat/Refresh

var relic_list = []
var spell_list = []

var shop_relics = []
var shop_skills = []

var type = "none"
var refresh_price = 1


@onready var confirm_swap: Button = $ConfirmSwap
@onready var next_combat: Button = $NextCombat

var run
var new_skill : Skill
var new_skill_ally : Ally

signal swap_done
signal shop_ended
signal special_shop_ended

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioPlayer.play_music("wii_shop", -30)
	run = get_tree().get_first_node_in_group("run")
	shop_ended.connect(run.scene_ended)
	special_shop_ended.connect(run.special_scene_ended)
	relic_list.append(relic_1_spot)
	relic_list.append(relic_2_spot)
	relic_list.append(relic_3_spot)
	
	spell_list.append(spell_1_spot)
	spell_list.append(spell_2_spot)
	spell_list.append(spell_3_spot)
	
	refresh_price = 1
	refresh_button.text = "Refresh Options (" + str(refresh_price) + " Gold)"
	
	if (run.ally1 != null):
		allies.append(run.ally1)
	if (run.ally2 != null):
		allies.append(run.ally2)
	if (run.ally3 != null):
		allies.append(run.ally3)
	if (run.ally4 != null):
		allies.append(run.ally4)
	for ally in allies:
		ally.spell_select_ui.enable_all()
		ally.spell_select_ui.hide_position()
		ally.spell_select_ui.visible = true
	await get_tree().create_timer(0.3).timeout
	load_items(type)
		
func load_items(type):
	if type == "none":
		for spot in relic_list:
			var reroll_count = 0
			if spot.get_child_count() == 1:
				spot.get_child(0).queue_free()
			var item = SHOP_ITEM.instantiate()
			spot.add_child(item)
			item.item = run.get_random_relic()
			item.price = get_price(item.item)
			if run.obtainable_relics.size() > 2 and run.gold >= 3:
				if item.price > run.gold or item.item in shop_relics:
					while (item.item in shop_relics or item.price > run.gold or item.item in run.relics) and reroll_count < 100:
						item.item = run.get_random_relic()
						item.price = get_price(item.item)
						reroll_count += 1
				item.update_item()
				shop_relics.append(item.item)
			if reroll_count > 100:
					shop_relics = []
			
		for spot in spell_list:
			var reroll_count = 0
			if spot.get_child_count() == 1:
				spot.get_child(0).queue_free()
			var item = SHOP_ITEM.instantiate()
			spot.add_child(item)
			item.item = run.get_random_skill()
			item.price = get_price(item.item)
			if run.obtainable_relics.size() > 2 and run.gold >= 3:
				if item.price > run.gold or item.item in shop_skills:
					while (item.item in shop_skills or item.price > run.gold or item.item in run.skills) and reroll_count < 100:
						item.item = run.get_random_skill()
						item.price = get_price(item.item)
						reroll_count += 1
				item.update_item()
				shop_skills.append(item.item)
			item.skill_info.z_index -= 1
			if reroll_count > 100:
				shop_skills = []
		refresh_button.visible = true
	else:
		for spot in relic_list:
			var reroll_count = 0
			if spot.get_child_count() == 1:
				spot.get_child(0).queue_free()
			var item = SHOP_ITEM.instantiate()
			spot.add_child(item)
			item.item = run.get_random_relic()
			item.price = get_price(item.item)
			if run.obtainable_relics.size() > 2 and run.gold >= 3:
				if item.price > run.gold or item.item in shop_relics or type not in item.item.tags:
					while (item.item in shop_relics or item.price > run.gold or type not in item.item.tags or item.item in run.relics) and reroll_count < 100:
						item.item = run.get_random_relic()
						item.price = get_price(item.item)
						item.item.update()
						reroll_count += 1
				item.update_item()
				shop_relics.append(item.item)
			if reroll_count > 100:
				shop_relics = []
			
		for spot in spell_list:
			var reroll_count = 0
			if spot.get_child_count() == 1:
				spot.get_child(0).queue_free()
			var item = SHOP_ITEM.instantiate()
			spot.add_child(item)
			item.item = run.get_random_skill()
			item.price = get_price(item.item)
			if run.obtainable_relics.size() > 2 and run.gold >= 3:
				if item.price > run.gold or item.item in shop_skills or type not in item.item.tags:
					while (item.item in shop_skills or item.price > run.gold or type not in item.item.tags or item.item in run.skills) and reroll_count < 100:
						item.item = run.get_random_skill()
						item.price = get_price(item.item)
						item.item.update()
						reroll_count += 1
				item.update_item()
				shop_skills.append(item.item)
			item.skill_info.z_index -= 1
			if reroll_count > 100:
				shop_skills	 = []
		refresh_button.visible = false

func get_price(resource):
	match resource.tier:
		"Common":
			return 3
		"Rare":
			return 6
		"Epic":
			return 9

func item_bought(item, shop_item) -> void:
	if item is Relic:
		run.relic_handler.purchase_relic(item)
		run.relics.append(item)
		shop_item.queue_free()
	elif item is Skill:
		new_skill = item
		buying_new_skill(shop_item)
		shop_item.queue_free()

	
func buying_new_skill(shop_item):
	new_skill_ally = null
	for ally in allies:
		ally.spell_select_ui.reset()
	for spot in relic_list:
		if (not spot.get_child(0) == shop_item):
			spot.visible = false
	for spot in spell_list:
		if (not spot.get_child(0) == shop_item):
			spot.visible = false
	shop_item.get_parent().visible = true
	shop_item.visible = true
	confirm_swap.visible = true
	shop_item.hide_buy()
	next_combat.visible = false
	await swap_done
	for spot in relic_list:
		spot.visible = true
	for spot in spell_list:
		spot.visible = true
	confirm_swap.visible = false
	if (not run.reaction_guide_open):
		next_combat.visible = true



func _on_next_combat_pressed() -> void:
	AudioPlayer.play_FX("click",-10)
	if type == "none":
		shop_ended.emit("")
	else:
		special_shop_ended.emit()
	
func _on_confirm_swap_pressed() -> void:
	AudioPlayer.play_FX("click",-10)
	if (new_skill_ally):
		new_skill_ally.skill_swap_2 = new_skill
		new_skill_ally._on_confirm_swap_pressed()
		swap_done.emit()


func _on_refresh_pressed() -> void:
	if (run.gold >= refresh_price):
		run.spend_gold(refresh_price)
		load_items(type)
		refresh_price += 1
		refresh_button.text = "Refresh Options (" + str(refresh_price) + " Gold)"
