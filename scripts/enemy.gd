extends Unit
class_name Enemy

# Unique Variables
@export var skill1 : Skill
@export var skill2 : Skill
@export var skill3 : Skill
@export var skill4 : Skill

var skill1_cd : int
var skill2_cd : int
var skill3_cd : int
var skill4_cd : int

@export var countdown : int
var skill_used : bool
var current_skill : Skill

var animation = false

@export var reaction_primed = 0

@onready var skill_info: Control = $ShowNextSkill/SkillInfo
@onready var sprite_spot: TextureRect = $SpriteSpot
@onready var show_next_skill: Control = $ShowNextSkill
@onready var countdown_label: Label = $CountdownLabel
@onready var next_skill_label: Label = $ShowNextSkill/NextSkillLabel

var sow_just_applied = false

var can_attack = true

signal use_skill

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.005).timeout
	if not copy:
		combat_manager = get_parent().get_parent().get_combat_manager()
		ReactionManager = combat_manager.ReactionManager
	elif copy:
		combat_manager = get_tree().get_first_node_in_group("combat_sim")
		ReactionManager = combat_manager.reaction_manager
	run = get_tree().get_first_node_in_group("run")
	id = run.id
	run.id += 1
	hp_bar = $"HP Bar"
	targeting_area = $TargetingArea
	self.died.connect(combat_manager.reaction_signal)
	if not copy:
		health = res.starting_health
		max_health = res.starting_health
		shield = 0
	title = res.name
	if res.skill1 != null:
		skill1 = res.skill1.duplicate()
		current_skill = skill1
	if res.skill2 != null:
		skill2 = res.skill2.duplicate()
	if res.skill3 != null:
		skill3 = res.skill3.duplicate()
	if res.skill4 != null:
		skill4 = res.skill4.duplicate()
	if res.name != null:
		title = res.name
	if res.skill_1_cd != null:
		skill1_cd = res.skill_1_cd
	if res.skill_2_cd != null:
		skill2_cd = res.skill_2_cd
	if res.skill_3_cd != null:
		skill3_cd = res.skill_3_cd
	if res.skill_4_cd != null:
		skill4_cd = res.skill_4_cd
	print("title:" + title)
	sprite_spot.texture = load(res.sprite.resource_path)
	skill_used = false
	if not copy:
		if (run.hard == true):
			if skill1 != null:
				skill1.damage *= 2
			if skill2 != null:
				skill2.damage *= 2
			if skill3 != null:
				skill3.damage *= 2
			if skill4 != null:
				skill4.damage *= 2
			max_health = roundi(max_health * 2.5)
			health = max_health
	skill_info.skill = current_skill
	set_countdown()
	skill_info.update_skill_info()
	
	fire_damage_block = res.fire_damage_block
	if not copy:
		hp_bar = get_child(1)
		hp_bar.set_hp(health)
		hp_bar.set_maxhp(health)
		hp_bar.update_statuses(status)
		self.target_chosen.connect(combat_manager.target_signal)

func change_skills():
	skill_info.skill = current_skill
	skill_info.update_skill_info()
	var num_skills = 1
	if skill2 != null:
		num_skills = 2
	if skill3 != null:
		num_skills = 3
	if skill4 != null:
		num_skills = 4
	if num_skills == 1:
		return
	var rng = RandomNumberGenerator.new()
	var random_num = 1
	var new_skill
	random_num = rng.randi_range(1,num_skills)
	match random_num:
		1:
			new_skill = skill1
		2:
			new_skill = skill2
		3:
			new_skill = skill3
		4:
			new_skill = skill4
	while new_skill == current_skill or (new_skill.summon != null and combat_manager.enemies.size() == 4):
		random_num = rng.randi_range(1,num_skills)
		match random_num:
			1:
				new_skill = skill1
			2:
				new_skill = skill2
			3:
				new_skill = skill3
			4:
				new_skill = skill4
	current_skill = new_skill
	skill_info.skill = new_skill
	skill_info.update_skill_info()
	skill_used = false
	set_countdown()

func hide_next_skill_info():
	show_next_skill.visible = false
	
func show_next_skill_info():
	show_next_skill.visible = true
	
func attack_animation():
	animation = true
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
	await get_tree().create_timer(0.50).timeout
	animation = false
	
func _on_targeting_area_pressed() -> void:
	target_chosen.emit(self)
	
func decrease_countdown(num):
	countdown -= num
	if countdown <= 0 and skill_used == false and can_attack:
		skill_used = true
		combat_manager.enemy_skill_use(self)
	update_countdown_label()

func set_countdown():
	match current_skill:
		skill1:
			countdown = skill1_cd
		skill2:
			countdown = skill2_cd
		skill3:
			countdown = skill3_cd
		skill4:
			countdown = skill4_cd
	update_countdown_label()

func update_countdown_label():
	if can_attack:
		countdown_label.visible = true
		show_next_skill.visible = true
		if countdown > 0:
			countdown_label.text = "Countdown: " + str(countdown)
		elif countdown <= 0:
			countdown_label.text = "Skill Used This Turn"
	else:
		countdown_label.visible = false
		show_next_skill.visible = false
