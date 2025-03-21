extends Resource
class_name Status

@export var name : String
@export var pre_turn : bool
@export var damage : int
@export_enum("none", "water", "fire", "lightning", "earth", "grass") var element : String
@export var turns_remaining : int
@export var event_based : bool
@export_enum("bubble", "muck", "nitro", "sow") var unique_type : String
@export var icon : Texture
