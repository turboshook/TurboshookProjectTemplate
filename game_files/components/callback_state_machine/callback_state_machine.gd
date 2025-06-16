extends RefCounted
class_name CallbackStateMachine

var _states: Dictionary = {}
var _current_state: Callable
var _current_state_name: String
var _current_state_process_time: float = 0.0

func add_state(state: Callable, on_enter: Callable = Callable(), on_exit: Callable = Callable()) -> void:
	if state.get_argument_count() != 1: 
		printerr(
			"CallbackStateMachine @ add_state(): State callable ", 
			state.get_method(), 
			" must take one float argument."
		)
		return
	# cannot check callable argument TYPES, unfortunately...
	_states[state] = {
		"enter": on_enter,
		"exit": on_exit
	}

func set_initial_state(state: Callable) -> void:
	if not _states.has(state): return
	_current_state = state
	if _states[_current_state].enter.is_valid(): _states[_current_state].enter.call()
	_current_state_name = _current_state.get_method()

func change_state(new_state: Callable) -> void:
	if not _states.has(new_state): 
		printerr(
			"CallbackStateMachine @ change_state(): new state callable ", 
			new_state.get_method(), 
			" has not been added as a state."
		)
		return
	if _states[_current_state].exit.is_valid(): _states[_current_state].exit.call()
	_current_state = new_state
	if _states[_current_state].enter.is_valid(): _states[_current_state].enter.call()
	_current_state_name = _current_state.get_method()
	_current_state_process_time = 0.0

func update(delta: float) -> void:
	if not _current_state: 
		printerr("CallbackStateMachine @ update(): No current state.")
		return
	_current_state.call(delta)
	_current_state_process_time += delta

func get_current_state() -> Callable:
	return _current_state

func get_state_process_time() -> float:
	return _current_state_process_time
