extends Node
class_name FiniteStateMachine

## My implementation of a finite state machine.
##
## [FiniteStateMachine] facilitates specialized control of scenes by allowing complex 
## logic to be split among an arbitrary number of states. It allows some [Node]-derived 
## scene to pass its member variables and functions to instances of [FSMState], where  
## the work is done.
## [br][br]
##
## [b]To get started[/b], create an instance of [FiniteStateMachine] as a child of 
## the scene you want to control (the [param state_parent]). Then, use the helper 
## functions to initialize and pass calls down through [FiniteStateMachine]. In 
## its [b]most basic form[/b], a properly-configured [param state_parent] script 
## that uses all available features of [FiniteStateMachine] will contain the 
## following code:
##
## [codeblock]
## extends Node
##
## @onready var finite_state_machine: FiniteStateMachine = $FiniteStateMachine
##
## func _ready() -> void:
##    finite_state_machine.initialize(self)
##
## func _process(delta: float) -> void:
##     finite_state_machine.process(delta)
##
## func _physics_process(delta: float) -> void:
##     finite_state_machine.physics_process(delta)
##
## func _input(event: InputEvent) -> void:
##    finite_state_machine.input(event)
## [/codeblock]
##
## NOTE: This is configurable. If your [param state_parent] does not use the
## [method Node._process] loop, for instance, do not bother calling it here.
## [br][br]
##
## Next, create instances of [FSMState] in-editor 
## as children of this node to represent the states you want to implement.
## Extend their scripts, save the new scripts to a convenient location (ideally 
## somewhat colocated with their [param state_parent]), and override their built-in
## functions with state-specific logic.

## The [Node]-derived object that this state controls. Passed down to child 
## [FSMState] instances to provide access to member variables and methods.
var state_parent: Node = null
## The current [FSMState] being handled.
var current_state: FSMState = null
# Intended only to allow developer to see the current state at a glance in the 
# inspector while the game is running rather than having to click on current_state
# and then hovering over the path.
var _current_state_name: String = ""
## The [FSMState] most recently exited.
var previous_state: FSMState = null

## Used to manually specify an initial state in the editor. If this is left empty,
## the default initial state will be the child [FSMState] at index 0.
@export var initial_state_override: FSMState

## Emitted once after [method FiniteStateMachine.initialize] is executed without
## encountering any errors.
signal initialized
## Emitted any time [param current_state] changes to a new instance of [FSMState].
signal state_changed(new_state: FSMState, old_state: FSMState)

## Provides [param state_parent] with an initial value and performs miscellaneous 
## checks to ensure proper configuration. Improper configurations cause an early
## return and [method @GlobalScope.printerr] output.
func initialize(parent_scene: Node) -> void:
	state_parent = parent_scene
	if get_child_count() == 0:
		printerr("FiniteStateMachine @ _ready(): No initial state provided. Create at least one instance of FSMState as a child of this node.")
		return
	if initial_state_override:
		current_state = initial_state_override
	else:
		var initial_state: FSMState = get_child(0)
		if !initial_state:
			printerr("FiniteStateMachine @ _ready(): Initial state (child at index 0) is not FSMState.")
			return
		current_state = initial_state
	
	current_state.state_parent = state_parent
	current_state.state_change_requested.connect(_on_state_change_requested)
	current_state.enter()
	_current_state_name = current_state.name
	initialized.emit()

## Used to pass calls of [method Node._process] from [param state_parent] to 
## [param current_state].
## [br][br]
## NOTE: [b][param state_parent] must explicitly call this function from 
## [method Node._process][/b], otherwise it cannot be used by child [FSMState]
## instances.
func process(delta: float) -> void:
	if current_state: _handle_returned_path(current_state.process(delta))

## Used to pass calls of [method Node._physics_process] from [param state_parent] 
## to [param current_state].
## [br][br]
## NOTE: [b][param state_parent] must explicitly call this function from 
## [method Node._physics_process][/b], otherwise it cannot be used by child 
## [FSMState] instances.
func physics_process(delta: float) -> void:
	if current_state: _handle_returned_path(current_state.physics_process(delta))

## Used to pass calls of [method Node._input] from [param state_parent] to 
## [param current_state].
## [br][br]
## NOTE: [b][param state_parent] must explicitly call this function from 
## [method Node._input][/b], otherwise it cannot be used by child [FSMState]
## instances.
func input(event: InputEvent) -> void:
	if current_state: _handle_returned_path(current_state.input(event))

func _handle_returned_path(returned_path: String) -> void:
	if returned_path == "": return
	if !has_node(returned_path):
		printerr("FiniteStateMachine @ _handle_returned_path(): Given path '", returned_path, "' is invalid.")
		return
	_change_state(get_node(returned_path))

func _change_state(new_state: FSMState) -> void:
	if !new_state:
		printerr("FiniteStateMachine @ _change_state(): new_state is null. Returned path must point to instance of FSMState.")
		return
	
	previous_state = current_state
	previous_state.state_change_requested.disconnect(_on_state_change_requested)
	previous_state.exit()
	
	current_state = new_state
	current_state.state_parent = state_parent
	current_state.state_change_requested.connect(_on_state_change_requested)
	current_state.enter()
	_current_state_name = current_state.name
	
	state_changed.emit(current_state, previous_state)

func _on_state_change_requested(state_name: String) -> void:
	_handle_returned_path(state_name)
