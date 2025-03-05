extends Node2D

func _ready():
	AudioPlayer.play_music("lake", -35)
	
func _on_exit_game_pressed() -> void:
	AudioPlayer.play_FX("click",0)
	get_tree().quit()


func _on_start_b_pressed() -> void:
	AudioPlayer.play_FX("click",0)
	get_tree().change_scene_to_file("res://scenes/main scenes/new_character_select.tscn")


func _on_combat_testing_pressed() -> void:
	AudioPlayer.play_FX("click",0)
	get_tree().change_scene_to_file("res://scenes/main scenes/setup_combat.tscn")
