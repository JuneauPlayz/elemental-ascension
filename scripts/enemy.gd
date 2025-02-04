extends Unit
class_name Enemy

# Unique Variables
@export var skill1 : Skill
@export var skill2 : Skill
@export var skill3 : Skill
@export var skill4 : Skill
var current_skill : Skill


@export var reaction_primed = 0

@onready var skill_info: Control = $ShowNextSkill/SkillInfo
@onready var sprite_spot: Sprite2D = $SpriteSpot
@onready var show_next_skill: Control = $ShowNextSkill

var sow_just_applied = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	combat_manager = get_parent().get_parent().get_combat_manager()
	run = get_tree().get_first_node_in_group("run")
	ReactionManager = combat_manager.ReactionManager
	hp_bar = $"HP Bar"
	targeting_area = $TargetingArea
	self.died.connect(combat_manager.reaction_signal)
	health = res.starting_health
	max_health = res.starting_health
	shield = 0
	if res.skill1 != null:
		skill1 = res.skill1
		current_skill = skill1
	if res.skill2 != null:
		skill2 = res.skill2
	if res.skill3 != null:
		skill3 = res.skill3
	if res.skill4 != null:
		skill4 = res.skill4
	if res.name != null:
		title = res.name
	print("title:" + title)
	sprite_spot.texture = load(res.sprite.resource_path)
	sprite_spot.scale = Vector2(res.sprite_scale,res.sprite_scale)
	skill_info.skill = current_skill
	skill_info.update_skill_info()
	
	print(health)
	hp_bar = get_child(1)
	hp_bar.set_hp(health)
	hp_bar.set_maxhp(health)
	hp_bar.update_statuses(status)
	self.target_chosen.connect(combat_manager.target_signal)

func change_skills():
	var rng = RandomNumberGenerator.new()
	var random_num = 1
	if skill2 != null:
		random_num = rng.randi_range(1,2)
	if skill3 != null:
		random_num = rng.randi_range(1,3)
	if skill4 != null:
		random_num = rng.randi_range(1,4)
	match random_num:
		1:
			current_skill = skill1
		2:
			current_skill = skill2
		3:
			current_skill = skill3
		4:
			current_skill = skill4
	skill_info.skill = current_skill
	skill_info.update_skill_info()

func hide_next_skill_info():
	show_next_skill.visible = false
	
func show_next_skill_info():
	show_next_skill.visible = true
	
func attack_animation():
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		sprite_spot, "position:y", sprite_spot.position.y - 50, GC.GLOBAL_INTERVAL
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		sprite_spot, "rotation", sprite_spot.rotation + deg_to_rad(45), GC.GLOBAL_INTERVAL
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		sprite_spot, "rotation", sprite_spot.rotation - deg_to_rad(30), 0.05
	).set_ease(Tween.EASE_OUT).set_delay(GC.GLOBAL_INTERVAL)
	tween.tween_property(
		sprite_spot, "position:x", sprite_spot.position.x - 25, 0.05
	).set_ease(Tween.EASE_OUT).set_delay(GC.GLOBAL_INTERVAL)
	tween.tween_property(
		sprite_spot, "position:y", sprite_spot.position.y, 0.05
	).set_ease(Tween.EASE_IN).set_delay(0.30)
	tween.tween_property(
		sprite_spot, "rotation", sprite_spot.rotation, 0.20
	).set_ease(Tween.EASE_IN).set_delay(0.30)
	tween.tween_property(
		sprite_spot, "position:x", sprite_spot.position.x, 0.05
	).set_ease(Tween.EASE_OUT).set_delay(0.30)

	
func _on_targeting_area_pressed() -> void:
	target_chosen.emit(self)
