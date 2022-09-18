# warning-ignore-all:unused_argument
extends Node

# this will act like an interface
class_name StateMachine

var state: int
var previous_state: int
var states: Dictionary = {}

# get the parent whose state we will be modifying 
@onready var parent = get_parent()

func _physics_process(delta: float) -> void:
#func update(delta: float) -> void:
	if state != null:
		_state_logic(delta)
		var transition = _get_transition()
		if transition != null:
			set_state(transition)

# will contain all functions that will be running for given certain state
func _state_logic(_delta: float) -> void:
	pass

# define logic that will trigger transitions between states
func _get_transition() -> int:
	return 0

# cause things to happen when states are entered, like animations
@warning_ignore(unused_parameter)
func _enter_state(new_state: int, old_state: int):
	pass

# cause things to happen when states are exited, like death effects
@warning_ignore(unused_parameter)
func _exit_state(old_state: int, new_state: int):
	pass

func set_state(new_state: int):
	previous_state = state
	state = new_state
	
	if previous_state != null:
		_exit_state(previous_state, new_state)
	if new_state != null:
		_enter_state(new_state, previous_state)

func add_state(state_name: String):
	states[state_name] = states.size()









