extends Resource
class_name CoreUpgrade

@export_enum("water", "fire", "lightning", "earth", "grass") var element : String
@export_enum("skill_damage_bonus", "token_gen_bonus") var type : String
@export var amount : int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
