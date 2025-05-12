extends Node
class_name FSMState

## A single state in a [FiniteStateMachine].
##
## This object provides functions that allow for specialized control of [Node]s
## that use a [FiniteStateMachine].

## The [Node]-derived object that this state controls. This field is populated 
## by the parent [FiniteStateMachine]. Used to directly access member variables
## and methods of the scene being controlled by this state.
var state_parent: Node

## Used to communicate up to the parent [FiniteStateMachine] that a state
## change has been requested using [method FSMState.request_state_change]
signal state_change_requested(state_path: String)

## Called once when transitioning to this state. Use this for state initialization.
func enter() -> void:
	pass

## This is called from the parent [FiniteStateMachine] and is equivalent to the
## [method Node._process] call in [param state_parent]. Returned [String] is 
## parsed as a [NodePath] to a sibling [FSMState] instance, triggering an attempt 
## at a state change.
## [br][br]
## NOTE: [param state_parent] [b]must call[/b] [method FiniteStateMachine.process] 
## directly in order to use this method.
@warning_ignore("unused_parameter")
func process(delta: float) -> String:
	return ""

## This is called from the parent [FiniteStateMachine] and is equivalent to the
## [method Node.__physics_process] call in [param state_parent]. Returned [String] 
## is parsed as a [NodePath] to a sibling [FSMState] instance, triggering an 
## attempt at a state change.
## [br][br]
## NOTE: [param state_parent] [b]must call[/b] [method FiniteStateMachine.physics_process] 
## directly in order to use this method.
@warning_ignore("unused_parameter")
func physics_process(delta: float) -> String:
	return ""

## This is called from the parent [FiniteStateMachine] and is equivalent to the
## [method Node._input] call in [param state_parent]. Returned [String] is 
## parsed as a [NodePath] to a sibling [FSMState] instance, triggering an attempt 
## at a state change.
## [br][br]
## NOTE: [param state_parent] [b]must call[/b] [method FiniteStateMachine.input] 
## directly in order to use this method.
@warning_ignore("unused_parameter")
func input(event: InputEvent) -> String:
	return ""

## Called once when transitioning out of this state. Use this for state deinitialization. 
func exit() -> void:
	pass

## Used to request an immediate state change from anywhere in the current script.
## This is intended to simplify situations where state changes should happen in
## response to signals handled by this [FSMState].
func request_state_change(state_path: String) -> void:
	state_change_requested.emit(state_path)
