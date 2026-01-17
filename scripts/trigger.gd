class_name Trigger
extends Resource

@export var conditions : Array[TriggerCondition]
@export var effects : Array[TriggerEffect]

@export var turn_limit = 0
@export var fight_limit = 0

var caster : Unit
var targets : Array[Unit]

# weapon = 1, accessory = 2, armor = 3, keystones = 4
@export var order : int
