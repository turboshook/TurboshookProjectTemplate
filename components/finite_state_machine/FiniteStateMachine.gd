extends Node
class_name FiniteStateMachine

var state_parent: Node = null
var current_state: FSMState = null
var previous_state: FSMState = null

signal initialized
signal state_changed(new_state, old_state)

func initialize(parent_scene: Node) -> void:
	state_parent = parent_scene
	if get_child_count() == 0:
		printerr("FiniteStateMachine @ _ready(): No initial state provided. Create at least one instance of FSMState as a child of this node.")
		return
	var initial_state: FSMState = get_child(0)
	if !initial_state:
		printerr("FiniteStateMachine @ _ready(): Initial state (child at index 0) is not FSMState.")
		return
	current_state = initial_state
	current_state.state_parent = state_parent
	current_state.enter()
	initialized.emit()

func process(delta: float) -> void:
	if current_state: _handle_returned_path(current_state.process(delta))

func physics_process(delta: float) -> void:
	if current_state: _handle_returned_path(current_state.physics_process(delta))

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
	previous_state.exit()
	current_state = new_state
	current_state.state_parent = state_parent
	current_state.enter()
	state_changed.emit(current_state, previous_state)















