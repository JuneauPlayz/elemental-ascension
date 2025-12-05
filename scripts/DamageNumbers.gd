extends Node
var element_dict = {"none": Color.WHITE, "fire": Color.CORAL, "water": Color.DARK_CYAN, "lightning": Color.YELLOW, "earth": Color.SADDLE_BROWN, "grass": Color.WEB_GREEN}
func display_number(value: int, position: Vector2, element : String, reaction : String):
	var rng = RandomNumberGenerator.new()
	var random_num = Vector2(rng.randf_range(-25,25), rng.randf_range(-25,25))
	var number = Label.new()
	value = -value
	# randomizes where the number will spawn by a range of 25 px
	number.global_position = position + random_num
	number.text = str(value) + reaction
	number.z_index = 5
	number.label_settings = LabelSettings.new()
	
	var color = element_dict.get(element)
	
	number.label_settings.font_color = color
	number.label_settings.font_size = 56
	number.label_settings.outline_color = "#000000"
	number.label_settings.outline_size = 10
	
	call_deferred("add_child", number)
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number, "position:y", number.position.y - 24, 0.15
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:y", number.position.y+25, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.4)
	tween.tween_property(
		number, "scale", number.scale*0.5, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	number.queue_free()

func display_number_size(value: int, position: Vector2, element : String, reaction : String, size : int):
	var rng = RandomNumberGenerator.new()
	var random_num = Vector2(rng.randf_range(-25,25), rng.randf_range(-25,25))
	var number = Label.new()
	value = -value
	# randomizes where the number will spawn by a range of 25 px
	number.global_position = position + random_num
	number.text = str(value) + reaction
	number.z_index = 5
	number.label_settings = LabelSettings.new()
	
	var color = element_dict.get(element)
	
	number.label_settings.font_color = color
	number.label_settings.font_size = size
	number.label_settings.outline_color = "#000000"
	number.label_settings.outline_size = 10
	
	call_deferred("add_child", number)
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number, "position:y", number.position.y - 24, 0.15
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:y", number.position.y+25, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.4)
	tween.tween_property(
		number, "scale", number.scale*0.5, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	number.queue_free()

func display_number_plus(value: int, position: Vector2, element : String, reaction : String):
	var rng = RandomNumberGenerator.new()
	var random_num = Vector2(rng.randf_range(15,30), rng.randf_range(-25,25))
	var number = Label.new()
	number.global_position = position + random_num
	number.text = "+" + str(value) + reaction
	number.z_index = 5
	number.label_settings = LabelSettings.new()
	
	var color = element_dict.get(element)
	
	
	number.label_settings.font_color = color
	number.label_settings.font_size = 56
	number.label_settings.outline_color = "#000000"
	number.label_settings.outline_size = 10
	
	call_deferred("add_child", number)
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number, "position:y", number.position.y - 24, 0.15
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:y", number.position.y+25, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.4)
	tween.tween_property(
		number, "scale", number.scale*0.5, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	number.queue_free()
	
func display_text(position: Vector2, element : String, text : String, size : int, random := true):
	var random_offset = Vector2(0,0)
	if random:
		var rng = RandomNumberGenerator.new()
		random_offset = Vector2(rng.randf_range(15,30), rng.randf_range(-50,-25))
	var number = Label.new()
	number.text = text
	number.global_position = position + random_offset
	number.z_index = 5
	number.label_settings = LabelSettings.new()
	
	var color = element_dict.get(element)
	
	
	number.label_settings.font_color = color
	number.label_settings.font_size = size
	number.label_settings.outline_color = "#000000"
	number.label_settings.outline_size = 10
	
	call_deferred("add_child", number)
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number, "position:y", number.position.y - 24, 0.15
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:y", number.position.y+25, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.4)
	tween.tween_property(
		number, "scale", number.scale*0.5, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	number.queue_free()
