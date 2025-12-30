extends Control

@onready var sprite = $Sprite
@onready var label = $SkillName
@onready var anim = $AnimationPlayer
@onready var background: ColorRect = $Background

signal ult_anim_done

func play_ultimate(sprite: Texture2D, skill_name: String):
	self.sprite.texture = sprite
	label.text = skill_name
	anim.play("Ultimate")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	ult_anim_done.emit()
