# warning-ignore-all:unused_argument
extends Resource
class_name FiniteStackMachineState

#var name = "state Superclass"
var name: String
var state_parent: Node
#var state_class # this was just being used to store a copy of this Resource inside of itself...
var args: Array = []
var state_time: float = 0
var started = false

# warning-ignore:unused_signal
signal state_popped # <- I added this

func on_start() -> void:
	pass

func on_end() -> void:
	emit_signal("state_popped")

func process(delta: float) -> void:
	pass

func physics_process(delta: float) -> void:
	pass

func input(event: InputEvent) -> void:
	pass

func get_class() -> String:
	return "State"

func is_class(value: String) -> bool:
	if value == "State":
		return true
	else:
		return false
