extends Node

var _events: Dictionary
# { "Key": false } = the event "Key" has not been triggered

func register_event(event_key: String) -> void:
	_events[event_key] = false

func is_event_registered(event_key: String) -> bool:
	return event_key in _events.keys()

func is_event_triggered(event_key: String) -> bool:
	if not is_event_registered(event_key):
		return false
	return _events[event_key]

func trigger_event(event_key: String) -> void:
	if not is_event_registered(event_key):
		register_event(event_key)
	_events[event_key] = true
