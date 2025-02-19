extends AudioStreamPlayer
# music
const zinnia_music = preload("res://assets/Pokémon Omega Ruby & Alpha Sapphire - Vs Zinnia (Highest Quality).mp3")
const og_music = preload("res://assets/Pokémon Red, Blue & Yellow - Trainer Battle Music (HQ).mp3")
const crimson_highlands_music = preload("res://assets/Crimson Highlands - Zodiac Battle.mp3")
const lake_music = preload("res://assets/Lake   Pokémon Diamond & Pearl Music Extended HD.mp3")
const iris_music = preload("res://assets/Pokémon B2W2 - Champion Iris Battle Music (HQ).mp3")
const wii_shop_music = preload("res://assets/Wii Shop Channel Main Theme (HQ).mp3")
#sound fx
const CLIACK = preload("res://assets/cliack.mp3")
const FIRE_HIT = preload("res://assets/fire hit.mp3")
const LIGHTNING_HIT = preload("res://assets/lightning_hit.mp3")
const WATER_HIT = preload("res://assets/water_hit.mp3")
const EARTH_HIT = preload("res://assets/earth_hit.mp3")
const GRASS_HIT = preload("res://assets/grass_hit.mp3")
const HEALING_EFFECT = preload("res://assets/healing_effect.mp3")

@onready var timer: Timer = $Timer
var timer_going = false
func play_music(song, volume):
	match song:
		"og":
			stream = og_music
		"zinnia":
			stream = zinnia_music
		"crimson":
			stream = crimson_highlands_music
		"lake":
			stream = lake_music
		"iris":
			stream = iris_music
		"wii_shop":
			stream = wii_shop_music
	stream.set_loop(true)
	volume_db = volume-5
	play()
	
func play_FX(sound, volume = 0.0):
	# timer so the same sound doesnt happen at once
	if not timer_going:
		var soundfx : AudioStream
		match sound:
			"click":
				soundfx = CLIACK
			"fire_hit":
				soundfx = FIRE_HIT
			"lightning_hit":
				soundfx = LIGHTNING_HIT
			"water_hit":
				soundfx = WATER_HIT
			"earth_hit":
				soundfx = EARTH_HIT
			"grass_hit":
				soundfx = GRASS_HIT
			"healing":
				soundfx = HEALING_EFFECT
		var fx_player = AudioStreamPlayer.new()
		fx_player.pitch_scale = randf_range(0.9,1.1)
		fx_player.stream = soundfx
		fx_player.name = "FX_PLAYER"
		fx_player.volume_db = volume-5
		add_child(fx_player)
		fx_player.play()
		timer.start()
		timer_going = true
		await fx_player.finished
		
		fx_player.queue_free()
	


func _on_timer_timeout() -> void:
	timer_going = false
