extends Node2D
@onready var game: Node2D = $"."
const RUN = preload("res://scenes/main scenes/run.tscn")
const SETUP_COMBAT = preload("res://scenes/main scenes/setup_combat.tscn")
const NEW_CHARACTER_SELECT = preload("res://scenes/main scenes/new_character_select.tscn")
const TUTORIAL = preload("uid://xir7bryx68b8")


func _ready():
	game = get_tree().get_first_node_in_group("game")
	AudioPlayer.play_music("lake", -35)
	
func _on_exit_game_pressed() -> void:
	AudioPlayer.play_FX("deeper_new_click",0)
	get_tree().quit()


func _on_start_b_pressed() -> void:
	AudioPlayer.play_FX("deeper_new_click",0)
	game.new_scene(NEW_CHARACTER_SELECT)


func _on_combat_testing_pressed() -> void:
	AudioPlayer.play_FX("deeper_new_click",0)
	game.new_scene(SETUP_COMBAT)


func _on_tutorial_pressed() -> void:
	AudioPlayer.play_FX("deeper_new_click",0)
	game.new_scene(TUTORIAL)
