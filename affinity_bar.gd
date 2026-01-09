extends Control

@onready var bar_container: HBoxContainer = %HBoxContainer

@onready var fire_affinity: ColorRect = %FireAffinity
@onready var water_affinity: ColorRect = %WaterAffinity
@onready var lightning_affinity: ColorRect = %LightningAffinity
@onready var grass_affinity: ColorRect = %GrassAffinity
@onready var earth_affinity: ColorRect = %EarthAffinity


func _ready() -> void:
	# Wait one frame so container sizes are valid
	await get_tree().process_frame


func set_affinities(
	fire_pct: float,
	water_pct: float,
	lightning_pct: float,
	grass_pct: float,
	earth_pct: float
) -> void:
	var total_width := bar_container.size.x
	if total_width <= 0.0:
		return

	_set_bar_width(fire_affinity, fire_pct, total_width)
	_set_bar_width(water_affinity, water_pct, total_width)
	_set_bar_width(lightning_affinity, lightning_pct, total_width)
	_set_bar_width(grass_affinity, grass_pct, total_width)
	_set_bar_width(earth_affinity, earth_pct, total_width)


func _set_bar_width(bar: ColorRect, percent: float, total_width: float) -> void:
	percent = clamp(percent, 0.0, 100.0)
	bar.custom_minimum_size.x = total_width * (percent / 100.0)
