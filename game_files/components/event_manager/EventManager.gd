extends Node
class_name EventManager

signal this_event_triggered

@export var enabled: bool = false
@export var free_on_event_triggered: bool = false
@export var immediate_free: bool = false

@onready var event_parent: Node = get_parent()

var event_key: String

func _ready() -> void:
	
	if not enabled:
		return
	
	event_key = _generate_event_key()
	
#	if event_parent is WorldEncounter:
#		var parent_state_manager: StateManager = event_parent.get_node("StateManagerContainer").get_child(0)
#		# warning-ignore:return_value_discarded
#		parent_state_manager.connect("state_entered", self, "_on_event_parent_state_changed")
#	elif event_parent is Interactable:
#		# warning-ignore:return_value_discarded
#		event_parent.connect("interacted", self, "_on_interacted")
	
	if Events.is_event_triggered(event_key):
		_handle_event_trigger()
	else:
		Events.register_event(event_key)
	
	#Events.event_triggered.connect(Callable(self, "_on_event_triggered"))

func _generate_event_key() -> String:
	return str(get_path())

	### EVENT PARENT PER-CLASS HANDLING ###

func _on_event_parent_state_changed(new_state: BaseState) -> void:
	if new_state.name == "Dead":
		#await event_parent.tree_exiting # let death animation play
		# no instantaneous Event change responses
		trigger_event()

func _on_interacted() -> void:
	trigger_event()
	if immediate_free:
		event_parent.queue_free()

func trigger_event() -> void:
	Events.trigger_event(event_key)

func _on_event_triggered(incoming_event_key: String) -> void:
	if incoming_event_key == event_key:
		_handle_event_trigger()

func _handle_event_trigger() -> void:
	if free_on_event_triggered:
		event_parent.queue_free()
	else:
		this_event_triggered.emit()
