extends Resource
class_name Status

@export var name : String
@export_enum("countdown", "event_based") var type : String
@export var stack : bool
@export var stacks : int
@export var pre_turn : bool
@export_enum("none", "water", "fire", "lightning", "earth", "grass") var element : String
@export var turns_remaining : int
@export var max_stacks : int
@export var icon : Texture
