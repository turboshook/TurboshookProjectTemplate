# warning-ignore-all:unused_argument
extends Node
class_name FiniteStackMachineState

var state_name: String
var state_parent: Node
var args: Array = []
var state_time: float = 0
var started = false

# warning-ignore:unused_signal
signal state_popped # <- I added this

func on_start() -> void:
	pass

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	pass

func input(_event: InputEvent) -> void:
	pass

func on_end() -> void:
	emit_signal("state_popped")
