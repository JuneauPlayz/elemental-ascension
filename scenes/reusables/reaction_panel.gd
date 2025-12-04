extends Control

@onready var fire_vaporize_mult: Label = $PanelContainer/MarginContainer/FirePage/Vaporize/FireVaporizeMult
@onready var fire_vaporize_tokens: RichTextLabel = $PanelContainer/MarginContainer/FirePage/FireVaporizeTokens
@onready var fire_detonate_mult: Label = $PanelContainer/MarginContainer/FirePage/Detonate/FireDetonateMult
@onready var fire_detonate_tokens: RichTextLabel = $PanelContainer/MarginContainer/FirePage/FireDetonateTokens
@onready var fire_burn_damage: Label = $PanelContainer/MarginContainer/FirePage/Burn/FireBurnDamage
@onready var fire_burn_tokens: RichTextLabel = $PanelContainer/MarginContainer/FirePage/FireBurnTokens
@onready var fire_erupt_mult: Label = $PanelContainer/MarginContainer/FirePage/Erupt/FireEruptMult
@onready var fire_erupt_tokens: RichTextLabel = $PanelContainer/MarginContainer/FirePage/FireEruptTokens
@onready var water_vaporize_mult: Label = $PanelContainer/MarginContainer/WaterPage/Vaporize2/WaterVaporizeMult
@onready var water_vaporize_tokens: RichTextLabel = $PanelContainer/MarginContainer/WaterPage/WaterVaporizeTokens
@onready var water_shock_mult: Label = $PanelContainer/MarginContainer/WaterPage/Shock/WaterShockMult
@onready var water_shock_tokens: RichTextLabel = $PanelContainer/MarginContainer/WaterPage/WaterShockTokens
@onready var water_bloom_healing: Label = $PanelContainer/MarginContainer/WaterPage/Bloom/WaterBloomHealing
@onready var water_bloom_tokens: RichTextLabel = $PanelContainer/MarginContainer/WaterPage/WaterBloomTokens
@onready var water_muck_mult: Label = $PanelContainer/MarginContainer/WaterPage/Muck/WaterMuckMult
@onready var water_muck_tokens: RichTextLabel = $PanelContainer/MarginContainer/WaterPage/WaterMuckTokens
@onready var lightning_detonate_mult: Label = $PanelContainer/MarginContainer/LightningPage/Detonate2/LightningDetonateMult
@onready var lightning_detonate_tokens: RichTextLabel = $PanelContainer/MarginContainer/LightningPage/LightningDetonateTokens2
@onready var lightning_shock_mult: Label = $PanelContainer/MarginContainer/LightningPage/Shock/LightningShockMult
@onready var lightning_shock_tokens: RichTextLabel = $PanelContainer/MarginContainer/LightningPage/LightningShockTokens
@onready var lightning_nitro_mult: Label = $PanelContainer/MarginContainer/LightningPage/Nitro/LightningNitroMult
@onready var lightning_nitro_tokens: RichTextLabel = $PanelContainer/MarginContainer/LightningPage/LightningNitroTokens
@onready var lightning_discharge_mult: Label = $PanelContainer/MarginContainer/LightningPage/Discharge/LightningDischargeMult
@onready var lightning_discharge_tokens: RichTextLabel = $PanelContainer/MarginContainer/LightningPage/LightningDischargeTokens
@onready var grass_burn_damage: Label = $PanelContainer/MarginContainer/GrassPage/Burn2/GrassBurnDamage
@onready var grass_burn_tokens: RichTextLabel = $PanelContainer/MarginContainer/GrassPage/GrassBurnTokens
@onready var grass_bloom_healing: Label = $PanelContainer/MarginContainer/GrassPage/Bloom2/GrassBloomHealing
@onready var grass_bloom_tokens: RichTextLabel = $PanelContainer/MarginContainer/GrassPage/GrassBloomTokens2
@onready var grass_nitro_mult: Label = $PanelContainer/MarginContainer/GrassPage/Nitro/GrassNitroMult
@onready var grass_nitro_tokens: RichTextLabel = $PanelContainer/MarginContainer/GrassPage/GrassNitroTokens
@onready var grass_sow_shielding: Label = $PanelContainer/MarginContainer/GrassPage/Sow/GrassSowShielding
@onready var grass_sow_tokens: RichTextLabel = $PanelContainer/MarginContainer/GrassPage/GrassSowTokens
@onready var earth_erupt_mult: Label = $PanelContainer/MarginContainer/EarthPage/Erupt2/EarthEruptMult
@onready var earth_erupt_tokens: RichTextLabel = $PanelContainer/MarginContainer/EarthPage/EarthEruptTokens2
@onready var earth_muck_mult: Label = $PanelContainer/MarginContainer/EarthPage/Muck/EarthMuckMult
@onready var earth_muck_tokens: RichTextLabel = $PanelContainer/MarginContainer/EarthPage/EarthMuckTokens
@onready var earth_discharge_mult: Label = $PanelContainer/MarginContainer/EarthPage/Discharge/EarthDischargeMult
@onready var earth_discharge_tokens: RichTextLabel = $PanelContainer/MarginContainer/EarthPage/EarthDischargeTokens
@onready var earth_sow_shielding: Label = $PanelContainer/MarginContainer/EarthPage/Sow/EarthSowShielding
@onready var earth_sow_tokens: RichTextLabel = $PanelContainer/MarginContainer/EarthPage/EarthSowTokens



@onready var fire_damage_bonus_2: RichTextLabel = $PanelContainer/MarginContainer/FirePage/FireDamageBonus2
@onready var fire_damage_mult_2: RichTextLabel = $PanelContainer/MarginContainer/FirePage/FireDamageMult2
@onready var water_damage_bonus_2: RichTextLabel = $PanelContainer/MarginContainer/WaterPage/WaterDamageBonus2
@onready var water_damage_mult_2: RichTextLabel = $PanelContainer/MarginContainer/WaterPage/WaterDamageMult2
@onready var lightning_damage_bonus_2: RichTextLabel = $PanelContainer/MarginContainer/LightningPage/LightningDamageBonus2
@onready var lightning_damage_mult_2: RichTextLabel = $PanelContainer/MarginContainer/LightningPage/LightningDamageMult2
@onready var grass_damage_bonus_2: RichTextLabel = $PanelContainer/MarginContainer/GrassPage/HBoxContainer/VBoxContainer/GrassDamageBonus2
@onready var grass_damage_mult_2: RichTextLabel = $PanelContainer/MarginContainer/GrassPage/HBoxContainer/VBoxContainer/GrassDamageMult2
@onready var healing_bonus_2: RichTextLabel = $PanelContainer/MarginContainer/GrassPage/HBoxContainer/VBoxContainer2/HealingBonus2
@onready var healing_mult_2: RichTextLabel = $PanelContainer/MarginContainer/GrassPage/HBoxContainer/VBoxContainer2/HealingMult2
@onready var earth_damage_bonus_2: RichTextLabel = $PanelContainer/MarginContainer/EarthPage/HBoxContainer/VBoxContainer/EarthDamageBonus2
@onready var earth_damage_mult_2: RichTextLabel = $PanelContainer/MarginContainer/EarthPage/HBoxContainer/VBoxContainer/EarthDamageMult2
@onready var shielding_bonus_2: RichTextLabel = $PanelContainer/MarginContainer/EarthPage/HBoxContainer/VBoxContainer2/ShieldingBonus2
@onready var shielding_mult_2: RichTextLabel = $PanelContainer/MarginContainer/EarthPage/HBoxContainer/VBoxContainer2/ShieldingMult2
@onready var fire_damage_bonus: RichTextLabel = $PanelContainer/MarginContainer/StatsPage/PanelContainer/MarginContainer/HBOX/Column1/FireDamageBonus
@onready var fire_damage_mult: RichTextLabel = $PanelContainer/MarginContainer/StatsPage/PanelContainer/MarginContainer/HBOX/Column1/FireDamageMult
@onready var water_damage_bonus: RichTextLabel = $PanelContainer/MarginContainer/StatsPage/PanelContainer/MarginContainer/HBOX/Column1/WaterDamageBonus
@onready var water_damage_mult: RichTextLabel = $PanelContainer/MarginContainer/StatsPage/PanelContainer/MarginContainer/HBOX/Column1/WaterDamageMult
@onready var lightning_damage_bonus: RichTextLabel = $PanelContainer/MarginContainer/StatsPage/PanelContainer/MarginContainer/HBOX/Column1/LightningDamageBonus
@onready var lightning_damage_mult: RichTextLabel = $PanelContainer/MarginContainer/StatsPage/PanelContainer/MarginContainer/HBOX/Column1/LightningDamageMult
@onready var grass_damage_bonus: RichTextLabel = $PanelContainer/MarginContainer/StatsPage/PanelContainer/MarginContainer/HBOX/Column1/GrassDamageBonus
@onready var grass_damage_mult: RichTextLabel = $PanelContainer/MarginContainer/StatsPage/PanelContainer/MarginContainer/HBOX/Column1/GrassDamageMult
@onready var earth_damage_bonus: RichTextLabel = $PanelContainer/MarginContainer/StatsPage/PanelContainer/MarginContainer/HBOX/Column1/EarthDamageBonus
@onready var earth_damage_mult: RichTextLabel = $PanelContainer/MarginContainer/StatsPage/PanelContainer/MarginContainer/HBOX/Column1/EarthDamageMult
@onready var healing_bonus: RichTextLabel = $PanelContainer/MarginContainer/StatsPage/PanelContainer/MarginContainer/HBOX/Column2/HealingBonus
@onready var healing_mult: RichTextLabel = $PanelContainer/MarginContainer/StatsPage/PanelContainer/MarginContainer/HBOX/Column2/HealingMult
@onready var shielding_bonus: RichTextLabel = $PanelContainer/MarginContainer/StatsPage/PanelContainer/MarginContainer/HBOX/Column2/ShieldingBonus
@onready var shielding_mult: RichTextLabel = $PanelContainer/MarginContainer/StatsPage/PanelContainer/MarginContainer/HBOX/Column2/ShieldingMult
@onready var physical_damage_bonus: RichTextLabel = $PanelContainer/MarginContainer/StatsPage/PanelContainer/MarginContainer/HBOX/Column2/PhysicalDamageBonus
@onready var physical_damage_mult: RichTextLabel = $PanelContainer/MarginContainer/StatsPage/PanelContainer/MarginContainer/HBOX/Column2/PhysicalDamageMult
@onready var all_damage_bonus: RichTextLabel = $PanelContainer/MarginContainer/StatsPage/PanelContainer/MarginContainer/HBOX/Column2/AllDamageBonus
@onready var all_damage_mult: RichTextLabel = $PanelContainer/MarginContainer/StatsPage/PanelContainer/MarginContainer/HBOX/Column2/AllDamageMult
@onready var bonus_gold: RichTextLabel = $PanelContainer/MarginContainer/StatsPage/PanelContainer/MarginContainer/HBOX/Column2/BonusGold
@onready var gold_mult: RichTextLabel = $PanelContainer/MarginContainer/StatsPage/PanelContainer/MarginContainer/HBOX/Column2/GoldMult

@onready var stats_disclaimer: Label = $StatsDisclaimer

var current_page = "fire"

@onready var fire_page: VBoxContainer = $PanelContainer/MarginContainer/FirePage
@onready var water_page: VBoxContainer = $PanelContainer/MarginContainer/WaterPage
@onready var lightning_page: VBoxContainer = $PanelContainer/MarginContainer/LightningPage
@onready var grass_page: VBoxContainer = $PanelContainer/MarginContainer/GrassPage
@onready var earth_page: VBoxContainer = $PanelContainer/MarginContainer/EarthPage
@onready var stats_page: VBoxContainer = $PanelContainer/MarginContainer/StatsPage
var run
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	run = get_tree().get_first_node_in_group("run")
	change_page("fire")
	update_mult_labels()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_hide_pressed() -> void:
	get_parent().pressed.emit()


func change_page(page):
	update_mult_labels()
	fire_page.visible = false
	water_page.visible = false
	lightning_page.visible = false
	grass_page.visible = false
	earth_page.visible = false
	stats_page.visible = false
	stats_disclaimer.visible = false
	match page:
		"fire":
			fire_page.visible = true
		"water":
			water_page.visible = true
		"lightning":
			lightning_page.visible = true
		"grass":
			grass_page.visible = true
		"earth":
			earth_page.visible = true
		"stats":
			stats_page.visible = true
			stats_disclaimer.visible = true

func update_mult_labels() -> void:
	# Update vaporize labels
	run = get_tree().get_first_node_in_group("run")
	var vaporize_text = "Vaporize Multiplier: " + str(run.vaporize_mult) + "x"
	fire_vaporize_mult.text = vaporize_text
	water_vaporize_mult.text = vaporize_text

	var fire_tokens = (run.vaporize_fire_token_base + run.vaporize_fire_token_bonus) * run.vaporize_fire_token_mult
	var water_tokens = (run.vaporize_water_token_base + run.vaporize_water_token_bonus) * run.vaporize_water_token_mult
	var vaporize_tokens_text = "        +" + str(fire_tokens) + " [color=coral] Fire[/color]" + (" Tokens" if fire_tokens >= 2 else " Token") + "  +" + str(water_tokens) + " [color=darkcyan] Water[/color]" + (" Tokens" if water_tokens >= 2 else " Token")
	fire_vaporize_tokens.text = vaporize_tokens_text
	water_vaporize_tokens.text = vaporize_tokens_text

	# Update shock labels
	var shock_text = "Shock Multiplier: " + str(run.shock_mult) + "x"
	water_shock_mult.text = shock_text
	lightning_shock_mult.text = shock_text

	var shock_water_tokens = (run.shock_water_token_base + run.shock_water_token_bonus) * run.shock_water_token_mult
	var shock_lightning_tokens = (run.shock_lightning_token_base + run.shock_lightning_token_bonus) * run.shock_lightning_token_mult
	var shock_tokens_text = "        +" + str(shock_water_tokens) + " [color=darkcyan] Water[/color]" + (" Tokens" if shock_water_tokens >= 2 else " Token") + "  +" + str(shock_lightning_tokens) + " [color=purple] Lightning[/color]" + (" Tokens" if shock_lightning_tokens >= 2 else " Token")
	water_shock_tokens.text = shock_tokens_text
	lightning_shock_tokens.text = shock_tokens_text

	# Update detonate labels
	var detonate_text = "Detonate Multiplier: " + str(run.detonate_main_mult) + "x\nSide Multiplier: " + str(run.detonate_side_mult) + "x"
	fire_detonate_mult.text = detonate_text
	lightning_detonate_mult.text = detonate_text

	var detonate_fire_tokens = (run.detonate_fire_token_base + run.detonate_fire_token_bonus) * run.detonate_fire_token_mult
	var detonate_lightning_tokens = (run.detonate_lightning_token_base + run.detonate_lightning_token_bonus) * run.detonate_lightning_token_mult
	var detonate_tokens_text = "        +" + str(detonate_fire_tokens) + " [color=coral] Fire[/color]" + (" Tokens" if detonate_fire_tokens >= 2 else " Token") + "  +" + str(detonate_lightning_tokens) + " [color=purple] Lightning[/color]" + (" Tokens" if detonate_lightning_tokens >= 2 else " Token")
	fire_detonate_tokens.text = detonate_tokens_text
	lightning_detonate_tokens.text = detonate_tokens_text

	# Update erupt labels
	var erupt_text = "Erupt Multiplier: " + str(run.erupt_mult) + "x"
	fire_erupt_mult.text = erupt_text
	earth_erupt_mult.text = erupt_text

	var erupt_fire_tokens = (run.erupt_fire_token_base + run.erupt_fire_token_bonus) * run.erupt_fire_token_mult
	var erupt_earth_tokens = (run.erupt_earth_token_base + run.erupt_earth_token_bonus) * run.erupt_earth_token_mult
	var erupt_tokens_text = "        +" + str(erupt_fire_tokens) + " [color=coral] Fire[/color]" + (" Tokens" if erupt_fire_tokens >= 2 else " Token") + "  +" + str(erupt_earth_tokens) + " [color=saddlebrown] Earth[/color]" + (" Tokens" if erupt_earth_tokens >= 2 else " Token")
	fire_erupt_tokens.text = erupt_tokens_text
	earth_erupt_tokens.text = erupt_tokens_text

	# Update bloom labels
	var bloom_healing_text = "Bloom Healing: " + str(run.ally_bloom_healing)
	water_bloom_healing.text = bloom_healing_text
	grass_bloom_healing.text = bloom_healing_text

	var bloom_water_tokens = (run.bloom_water_token_base + run.bloom_water_token_bonus) * run.bloom_water_token_mult
	var bloom_grass_tokens = (run.bloom_grass_token_base + run.bloom_grass_token_bonus) * run.bloom_grass_token_mult
	var bloom_tokens_text = "        +" + str(bloom_water_tokens) + " [color=darkcyan] Water[/color]" + (" Tokens" if bloom_water_tokens >= 2 else " Token") + "  +" + str(bloom_grass_tokens) + " [color=webgreen] Grass[/color]" + (" Tokens" if bloom_grass_tokens >= 2 else " Token")
	water_bloom_tokens.text = bloom_tokens_text
	grass_bloom_tokens.text = bloom_tokens_text

	# Update nitro labels
	var nitro_text = "Nitro Multiplier: " + str(run.nitro_mult) + "x"
	lightning_nitro_mult.text = nitro_text
	grass_nitro_mult.text = nitro_text

	var nitro_lightning_tokens = (run.nitro_lightning_token_base + run.nitro_lightning_token_bonus) * run.nitro_lightning_token_mult
	var nitro_grass_tokens = (run.nitro_grass_token_base + run.nitro_grass_token_bonus) * run.nitro_grass_token_mult
	var nitro_tokens_text = "        +" + str(nitro_lightning_tokens) + " [color=purple] Lightning[/color]" + (" Tokens" if nitro_lightning_tokens >= 2 else " Token") + "  +" + str(nitro_grass_tokens) + " [color=webgreen] Grass[/color]" + (" Tokens" if nitro_grass_tokens >= 2 else " Token")
	lightning_nitro_tokens.text = nitro_tokens_text
	grass_nitro_tokens.text = nitro_tokens_text

	# Update burn labels
	var burn_damage_text = "Burn Damage: " + str(run.burn_damage) + "\nBurn Length: " + str(run.burn_length) + " turns"
	fire_burn_damage.text = burn_damage_text
	grass_burn_damage.text = burn_damage_text

	var burn_fire_tokens = (run.burn_fire_token_base + run.burn_fire_token_bonus) * run.burn_fire_token_mult
	var burn_grass_tokens = (run.burn_grass_token_base + run.burn_grass_token_bonus) * run.burn_grass_token_mult
	var burn_tokens_text = "        +" + str(burn_fire_tokens) + " [color=coral] Fire[/color]" + (" Tokens" if burn_fire_tokens >= 2 else " Token") + "  +" + str(burn_grass_tokens) + " [color=webgreen] Grass[/color]" + (" Tokens" if burn_grass_tokens >= 2 else " Token")
	fire_burn_tokens.text = burn_tokens_text
	grass_burn_tokens.text = burn_tokens_text

	# Update muck labels
	var muck_text = "Muck Multiplier: " + str(run.muck_mult) + "x"
	water_muck_mult.text = muck_text
	earth_muck_mult.text = muck_text

	var muck_water_tokens = (run.muck_water_token_base + run.muck_water_token_bonus) * run.muck_water_token_mult
	var muck_earth_tokens = (run.muck_earth_token_base + run.muck_earth_token_bonus) * run.muck_earth_token_mult
	var muck_tokens_text = "        +" + str(muck_water_tokens) + " [color=darkcyan] Water[/color]" + (" Tokens" if muck_water_tokens >= 2 else " Token") + "  +" + str(muck_earth_tokens) + " [color=saddlebrown] Earth[/color]" + (" Tokens" if muck_earth_tokens >= 2 else " Token")
	water_muck_tokens.text = muck_tokens_text
	earth_muck_tokens.text = muck_tokens_text

	# Update discharge labels
	var discharge_text = "Discharge Multiplier: " + str(run.discharge_mult) + "x"
	lightning_discharge_mult.text = discharge_text
	earth_discharge_mult.text = discharge_text

	var discharge_earth_tokens = (run.discharge_earth_token_base + run.discharge_earth_token_bonus) * run.discharge_earth_token_mult
	var discharge_lightning_tokens = (run.discharge_lightning_token_base + run.discharge_lightning_token_bonus) * run.discharge_lightning_token_mult
	var discharge_tokens_text = "        +" + str(discharge_earth_tokens) + " [color=saddlebrown] Earth[/color]" + (" Tokens" if discharge_earth_tokens >= 2 else " Token") + "  +" + str(discharge_lightning_tokens) + " [color=purple] Lightning[/color]" + (" Tokens" if discharge_lightning_tokens >= 2 else " Token")
	lightning_discharge_tokens.text = discharge_tokens_text
	earth_discharge_tokens.text = discharge_tokens_text

	# Update sow labels
	var sow_shielding_text = "Sow Shielding: " + str(run.sow_shielding) + "\nSow Healing: " + str(run.sow_healing)
	earth_sow_shielding.text = sow_shielding_text
	grass_sow_shielding.text = sow_shielding_text

	var sow_earth_tokens = (run.sow_earth_token_base + run.sow_earth_token_bonus) * run.sow_earth_token_mult
	var sow_grass_tokens = (run.sow_grass_token_base + run.sow_grass_token_bonus) * run.sow_grass_token_mult
	var sow_tokens_text = "        +" + str(sow_earth_tokens) + " [color=saddlebrown] Earth[/color]" + (" Tokens" if sow_earth_tokens >= 2 else " Token") + "  +" + str(sow_grass_tokens) + " [color=webgreen] Grass[/color]" + (" Tokens" if sow_grass_tokens >= 2 else " Token")
	earth_sow_tokens.text = sow_tokens_text
	grass_sow_tokens.text = sow_tokens_text
	
	# Fire Damage
	fire_damage_bonus.text = " [color=coral]Fire Damage Bonus[/color]  :  " + str(run.fire_damage_bonus)
	fire_damage_mult.text = " [color=coral]Fire Damage Multiplier[/color]  :  " + str(run.fire_damage_mult)
	fire_damage_bonus_2.text = fire_damage_bonus.text
	fire_damage_mult_2.text = fire_damage_mult.text

	# Water Damage
	water_damage_bonus.text = " [color=darkcyan]Water Damage Bonus[/color]  :  " + str(run.water_damage_bonus)
	water_damage_mult.text = " [color=darkcyan]Water Damage Multiplier[/color]  :  " + str(run.water_damage_mult)
	water_damage_bonus_2.text = water_damage_bonus.text
	water_damage_mult_2.text = water_damage_mult.text

	# Lightning Damage
	lightning_damage_bonus.text = " [color=purple]Lightning Damage Bonus[/color]  :  " + str(run.lightning_damage_bonus)
	lightning_damage_mult.text = " [color=purple]Lightning Damage Multiplier[/color]  :  " + str(run.lightning_damage_mult)
	lightning_damage_bonus_2.text = lightning_damage_bonus.text
	lightning_damage_mult_2.text = lightning_damage_mult.text

	# Grass Damage
	grass_damage_bonus.text = " [color=webgreen]Grass Damage Bonus[/color]  :  " + str(run.grass_damage_bonus)
	grass_damage_mult.text = " [color=webgreen]Grass Damage Multiplier[/color]  :  " + str(run.grass_damage_mult)
	grass_damage_bonus_2.text = grass_damage_bonus.text
	grass_damage_mult_2.text = grass_damage_mult.text

	# Earth Damage
	earth_damage_bonus.text = " [color=saddlebrown]Earth Damage Bonus[/color]  :  " + str(run.earth_damage_bonus)
	earth_damage_mult.text = " [color=saddlebrown]Earth Damage Multiplier[/color]  :  " + str(run.earth_damage_mult)
	earth_damage_bonus_2.text = earth_damage_bonus.text
	earth_damage_mult_2.text = earth_damage_mult.text

	# Healing
	healing_bonus.text = " [color=web_green]Healing Bonus[/color]  :  " + str(run.healing_bonus)
	healing_mult.text = " [color=web_green]Healing Multiplier[/color]  :  " + str(run.healing_mult)
	healing_bonus_2.text = healing_bonus.text
	healing_mult_2.text = healing_mult.text

	# Shielding
	shielding_bonus.text = " [color=saddle_brown]Shielding Bonus[/color]  :  " + str(run.shielding_bonus)
	shielding_mult.text = " [color=saddle_brown]Shielding Multiplier[/color]  :  " + str(run.shielding_mult)
	shielding_bonus_2.text = shielding_bonus.text
	shielding_mult_2.text = shielding_mult.text

	# Physical Damage
	physical_damage_bonus.text = " Physical Damage Bonus  :  " + str(run.physical_damage_bonus)
	physical_damage_mult.text = " Physical Damage Multiplier  :  " + str(run.physical_damage_mult)

	# All Damage
	all_damage_bonus.text = " All Damage Bonus  :  " + str(run.all_damage_bonus)
	all_damage_mult.text = " All Damage Multiplier  :  " + str(run.all_damage_mult)

	# Gold
	bonus_gold.text = " [color=yellow]Bonus Gold[/color]  :  " + str(run.bonus_gold)
	gold_mult.text = " [color=yellow]Gold Multiplier[/color]  :  " + str(run.gold_mult)


func _on_fire_page_button_pressed() -> void:
	change_page("fire")


func _on_water_page_button_pressed() -> void:
	change_page("water")


func _on_lightning_page_button_pressed() -> void:
	change_page("lightning")


func _on_grass_page_button_pressed() -> void:
	change_page("grass")


func _on_earth_page_button_pressed() -> void:
	change_page("earth")


func _on_more_stats_button_pressed() -> void:
	change_page("stats")
