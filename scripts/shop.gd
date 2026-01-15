extends Node2D


const SHOP_ITEM = preload("res://scenes/reusables/shop_sellable.tscn")

var ally1 : Ally
var ally2 : Ally
var ally3 : Ally
var ally4 : Ally

var allies = []

@onready var items_label: Label = $ItemsLabel
@onready var skills_label: Label = $SkillsLabel


@onready var item_1_spot: Node2D = %Item1Spot
@onready var item_2_spot: Node2D = %Item2Spot
@onready var item_3_spot: Node2D = %Item3Spot

@onready var skill_1_spot: Node2D = %Skill1Spot
@onready var skill_2_spot: Node2D = %Skill2Spot
@onready var skill_3_spot: Node2D = %Skill3Spot

@onready var refresh_button: Button = $NextCombat/Refresh
@onready var swap_tutorial: Label = $ConfirmSwap/SwapTutorial

var item_list = []
var skill_list = []

var shop_items = []
var shop_skills = []

var type = "none"
var refresh_price = 1


@onready var confirm_swap: Button = $ConfirmSwap
@onready var next_combat: Button = $NextCombat

var run
var new_skill : Skill
var new_skill_ally : Ally
var picking_new_skill : bool = false

var new_item : Item
var new_item_ally : Ally
var picking_new_item : bool = false

signal swap_done
signal shop_ended
signal special_shop_ended

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	run = get_tree().get_first_node_in_group("run")
	shop_ended.connect(run.special_scene_ended)
	special_shop_ended.connect(run.special_scene_ended) 
	item_list.append(item_1_spot)
	item_list.append(item_2_spot)
	item_list.append(item_3_spot)
	
	skill_list.append(skill_1_spot)
	skill_list.append(skill_2_spot)
	skill_list.append(skill_3_spot)
	
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
		ally.spell_select_ui.visible = true
	await get_tree().create_timer(0.3).timeout
	load_items(type)
		
func load_items(type):
	if type == "none":
		for spot in item_list:
			var reroll_count = 0
			if spot.get_child_count() == 1:
				spot.get_child(0).queue_free()
			var item = SHOP_ITEM.instantiate()
			spot.add_child(item)
			item.item = run.get_random_item()
			item.price = get_price(item.item)
			if run.obtainable_items.size() > 2 and run.gold >= 3:
				if item.price > run.gold or item.item in shop_items:
					while (item.item in shop_items or item.price > run.gold or item.item in run.items) and reroll_count < 100:
						item.item = run.get_random_item()
						item.price = get_price(item.item)
						reroll_count += 1
				item.update_item()
				shop_items.append(item.item)
			if reroll_count > 100:
					shop_items = []
			
		for spot in skill_list:
			var reroll_count = 0
			if spot.get_child_count() == 1:
				spot.get_child(0).queue_free()
			var item = SHOP_ITEM.instantiate()
			spot.add_child(item)
			item.item = run.get_random_skill()
			item.price = get_price(item.item)
			if run.obtainable_items.size() > 2 and run.gold >= 3:
				if item.price > run.gold or item.item in shop_skills:
					while (item.item in shop_skills or item.price > run.gold or item.item in run.skills) and reroll_count < 100:
						item.item = run.get_random_skill()
						item.price = get_price(item.item)
						reroll_count += 1
				item.update_item()
				shop_skills.append(item.item)
			if reroll_count > 100:
				shop_skills = []
		refresh_button.visible = true
	else:
		for spot in item_list:
			var reroll_count = 0
			if spot.get_child_count() == 1:
				spot.get_child(0).queue_free()
			var item = SHOP_ITEM.instantiate()
			spot.add_child(item)
			item.item = run.get_random_item()
			item.price = get_price(item.item)
			if run.obtainable_items.size() > 2 and run.gold >= 3:
				if item.price > run.gold or item.item in shop_items or type not in item.item.tags:
					while (item.item in shop_items or item.price > run.gold or type not in item.item.tags or item.item in run.items) and reroll_count < 100:
						item.item = run.get_random_item()
						item.price = get_price(item.item)
						reroll_count += 1
				item.update_item()
				shop_items.append(item.item)
			if reroll_count > 100:
				shop_items = []
			
		for spot in skill_list:
			var reroll_count = 0
			if spot.get_child_count() == 1:
				spot.get_child(0).queue_free()
			var item = SHOP_ITEM.instantiate()
			spot.add_child(item)
			item.item = run.get_random_skill()
			item.price = get_price(item.item)
			if run.obtainable_items.size() > 2 and run.gold >= 3:
				if item.price > run.gold or item.item in shop_skills or type not in item.item.tags:
					while (item.item in shop_skills or item.price > run.gold or type not in item.item.tags or item.item in run.skills) and reroll_count < 100:
						item.item = run.get_random_skill()
						item.price = get_price(item.item)
						reroll_count += 1
				item.update_item()
				shop_skills.append(item.item)
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
	if item is Item:
		run.items.append(item)
		buying_new_item(shop_item)
		shop_item.queue_free()
	elif item is Skill:
		new_skill = item
		buying_new_skill(shop_item)
		shop_item.queue_free()

func buying_new_skill(shop_item):
	swap_tutorial.text = "Click on an empty slot or 
current spell to replace"
	hide_shop_UI()
	new_skill_ally = null
	for ally in allies:
		ally.spell_select_ui.reset()
	for spot in item_list:
		if (spot.get_child_count() > 0 and not spot.get_child(0) == shop_item):
			spot.visible = false
	for spot in skill_list:
		if (spot.get_child_count() > 0 and not spot.get_child(0) == shop_item):
			spot.visible = false
	shop_item.get_parent().visible = true
	shop_item.visible = true
	confirm_swap.visible = true
	shop_item.hide_buy()
	next_combat.visible = false
	picking_new_skill = true
	await swap_done
	for spot in skill_list:
		spot.visible = true
	for spot in skill_list:
		spot.visible = true
	confirm_swap.visible = false
	new_skill = null
	new_skill_ally = null
	picking_new_skill = false
	if (not run.UIManager.reaction_guide_open):
		next_combat.visible = true

func buying_new_item(shop_item):
	new_item = shop_item.item
	swap_tutorial.text = "Click on an ally that will
	receive the new item."
	hide_shop_UI()
	var new_item_ally = null
	for spot in item_list:
		if (spot.get_child_count() > 0 and not spot.get_child(0) == shop_item):
			spot.visible = false
	for spot in skill_list:
		if (spot.get_child_count() > 0 and not spot.get_child(0) == shop_item):
			spot.visible = false
	shop_item.get_parent().visible = true
	shop_item.visible = true
	confirm_swap.visible = true
	shop_item.hide_buy()
	next_combat.visible = false
	for ally in run.allies:
		ally.enable_targeting_area()
	picking_new_item = true
	await swap_done
	for spot in skill_list:
		spot.visible = true
	for spot in skill_list:
		spot.visible = true
	confirm_swap.visible = false
	for ally in run.allies:
		ally.disable_targeting_area()
		ally.reset_item_handler_colors()
	new_item_ally = null
	new_item = null
	picking_new_item = false

	if (not run.UIManager.reaction_guide_open):
		next_combat.visible = true

func hide_shop_UI():
	items_label.visible = false
	skills_label.visible = false

func show_shop_UI():
	items_label.visible = true
	skills_label.visible = true

func _on_next_combat_pressed() -> void:
	AudioPlayer.play_FX("click",-10)
	if type == "none":
		shop_ended.emit()
	else:
		special_shop_ended.emit()
	
func _on_confirm_swap_pressed() -> void:
	AudioPlayer.play_FX("click",-10)
	if (new_skill_ally and picking_new_skill):
		new_skill_ally.skill_swap_2 = new_skill
		new_skill_ally._on_confirm_swap_pressed()
		swap_done.emit()
	elif (new_item_ally and picking_new_item):
		match new_item.type:
			"Weapon":
				new_item_ally.change_weapon(new_item)
			"Armor":
				new_item_ally.change_armor(new_item)
			"Accessory":
				new_item_ally.change_accessory(new_item)
		swap_done.emit()
	for ally in allies:
		ally.spell_select_ui.reset()
	for spot in item_list:
		spot.visible = true
	for spot in skill_list:
		spot.visible = true

func _on_refresh_pressed() -> void:
	if (run.gold >= refresh_price):
		run.spend_gold(refresh_price)
		load_items(type)
		refresh_price += 1
		refresh_button.text = "Refresh Options (" + str(refresh_price) + " Gold)"
