#https://www.youtube.com/watch?v=DPxIMVC0oZA&ab_channel=TheShaggyDev
extends Node
class_name StateMachine

@export var starting_state: NodePath

var current_state: BaseState # I added this
var current_state_name: StringName

# splitting this into two signals
#signal state_changed(new_state: BaseState)
signal state_entered(entered_state: BaseState)
signal state_exited(exited_state: BaseState)

func change_state(new_state: BaseState) -> void:
	if current_state:
		current_state.exit()
		state_exited.emit(current_state)

	current_state = new_state
	current_state.enter()
	current_state_name = current_state.name
	
	state_entered.emit(current_state)

# Initialize the state machine by giving each state a reference to the objects
# owned by the parent that they should be able to take control of
# and set a default state
func init(state_parent: Node) -> void:
	for child in get_children():
		child.state_parent = state_parent
	
	# Initialize with a default state of idle
	change_state(get_node(starting_state))

# Pass through functions for the Player to call,
# handling state changes as needed
func physics_process(delta: float) -> void:
	var new_state = current_state.physics_process(delta)
	if new_state:
		change_state(new_state)

func input(event: InputEvent) -> void:
	var new_state = current_state.input(event)
	if new_state:
		change_state(new_state)

func process(delta: float) -> void:
	var new_state = current_state.process(delta)
	if new_state:
		change_state(new_state)

