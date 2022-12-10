extends Node
class_name BaseState

@export var animation_name: String = ""

# Pass in a reference to the player's kinematic body so that it can be used by the state
var state_parent: Node

func enter() -> void:
	if animation_name != "":
		state_parent.Animations.play(animation_name)

func exit() -> void:
	pass

func input(_event: InputEvent) -> BaseState:
	return null

func process(_delta: float) -> BaseState:
	return null

func physics_process(_delta: float) -> BaseState:
	return null
