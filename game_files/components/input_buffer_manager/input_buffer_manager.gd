extends Node
class_name InputBufferManager

## Generalized solution for implementing input buffering. Provide an action name that the 
## [InputBufferManager] should listen to and it's buffer limit time (the length of time that
## input ought be considered valid in seconds). Whether the input is valid with respect to that time
## can be found by calling [method InputBufferManager.is_action_buffered]. Inputs can be checked 
## against arbitrary buffer limit times using [method InputBufferManager.is_action_buffered_at]. 
## [br]
## [br]
## Currently, this script only responds to inputs on pressed using [method InputEvent.is_action_pressed]. 
## An input's current buffer is not incremented past 1 second.

const _MAX_BUFFER_LIMIT: float = 1.0

var _input_action_dictionary: Dictionary = {}

func _physics_process(delta: float) -> void:
	if _input_action_dictionary.is_empty(): return
	for action_name: String in _input_action_dictionary.keys():
		if _input_action_dictionary[action_name].current_buffer >= _MAX_BUFFER_LIMIT: continue
		_input_action_dictionary[action_name].current_buffer = min(
			_input_action_dictionary[action_name].current_buffer + delta, _MAX_BUFFER_LIMIT
		)

func _input(event: InputEvent) -> void:
	if _input_action_dictionary.is_empty(): return
	for action_name: String in _input_action_dictionary.keys():
		if not event.is_action_pressed(action_name): return
		_input_action_dictionary[action_name].current_buffer = 0.0

## Add an input action to listen for.
func register_input(action_name: String, buffer_limit_time: float) -> void:
	if buffer_limit_time >= _MAX_BUFFER_LIMIT:
		push_warning(
			"Provided buffer limit of ", 
			buffer_limit_time, 
			" seconds exceeds current max buffer limit of ", 
			_MAX_BUFFER_LIMIT, " seconds. This code won't work so good now."
		)
	_input_action_dictionary[action_name] = {
		"buffer_limit" = buffer_limit_time,
		"current_buffer" = 0.0
	}

## Check whether an input has been pressed within its specified buffer limit. 
##
## An input must be provided via [method InputBufferManager.register_input] for this method to work.
func is_action_buffered(action_name: String) -> bool:
	if not _input_action_dictionary.has(action_name): return false
	return _input_action_dictionary[action_name].current_buffer <= _input_action_dictionary[action_name].buffer_limit

## Check whether an input has been pressed within an arbitrary buffer limit. 
##
## An input must be provided via [method InputBufferManager.register_input] for this method to work.
func is_action_buffered_at(action_name: String, buffer_limit_time: float) -> bool:
	if not _input_action_dictionary.has(action_name): return false
	return _input_action_dictionary[action_name].current_buffer <= buffer_limit_time
