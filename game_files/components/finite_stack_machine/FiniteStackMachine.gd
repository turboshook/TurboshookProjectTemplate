# FiniteStackMachine.gd
extends Node
class_name FiniteStackMachine

var state_parent: Node
# Node that the stateStack is attached to

var stack_machine = []
# This member array is the heart of the whole operation.
# It looks like this:
# [[state_object1, [arg1, arg2, ...]], [state_object2, [arg1, arg2, ...]], ...]

var default_state: Array
# [0] String path to a state object that is push_create()ed if the stack is empty
# [1] is args[] for state object

#signal state_time_changed(new_value)
signal stack_machine_changed

func process(delta: float) -> void:
	# Method for processing the current state @ pos 0
	#if stack_machine.size() == 0:
	#	print("STACK MACHINE EMPTY FOR ", get_parent().name)
	if stack_machine.size() > 0:
		# get top state info
		var state_object = stack_machine[0]
		
		# Check for first time running, and start state
		if state_object.started == false:
			state_object.on_start()
			state_object.started = true
			
		# Run the state's process method
		state_object.process(delta)
		
		# increment state_time by delta
		state_object.state_time += delta # keep in mind that if a state is using both _process and _physics_process, state_time is incremented in BOTH functions
		#emit_signal("state_time_changed", state_object.state_time)
		
	elif default_state != null:
		# If state stack is empty, we push the default
		#push_create(default_state.state_class, default_state.args)
		push_create(default_state[0], default_state[1])
		process(delta) # and try to run it right away

func physics_process(delta: float) -> void:
	if stack_machine.size() > 0:
		# get top state info
		var state_object = stack_machine[0]
		
		# Check for first time running, and start state
		if state_object.started == false:
			state_object.on_start()
			state_object.started = true
			
		# Run the state's process method
		state_object.physics_process(delta)
		
		# increment state_time by delta
		state_object.state_time += delta 
		#emit_signal("state_time_changed", state_object.state_time)
		
	elif default_state != null:
		# If state stack is empty, we push the default
		#push_create(default_state.state_class, default_state.args)
		push_create(default_state[0], default_state[1])
		physics_process(delta) # and try to run it right away

func input(event: InputEvent):
	# Method for processing the current state @ pos 0
	if stack_machine.size() > 0:
		# get top state info
		var state_object = stack_machine[0]
		
		# Check for first time running, and start state
		if state_object.started == false:
			state_object.on_start()
			state_object.started = true
			
		# Run the state's input method
		state_object.input(event)
	
	# default state is just a string now
	elif default_state != null:
		# If state stack is empty, we push the default
		#push_create(default_state.state_class, default_state.args)
		push_create(default_state[0], default_state[1])
		input(event) # and try to run it right away

func push(state):
	# add a state to front of state stack
	stack_machine.push_front(state)
	emit_signal("stack_machine_changed")

func add(state):
	# add a state to end of state stack
	stack_machine.append(state)
	emit_signal("stack_machine_changed")

func push_create(state_path, args = []):
	# create and add a state class with args to front of state stack
	push(state_create(state_path, args))

func add_create(state_class, args = []):
	# create and add a state class and args to end of state stack
	add(state_create(state_class, args))

func pop():
	# pop the top state from the from state stack
	var state_object = stack_machine.pop_front()
	# process on_end event for the popped state
	state_object.on_end()
	emit_signal("stack_machine_changed")

func state_create(state_path, args = []):
	# creates an entry appropriate for the stack_machine array
	# [state_ref, [arg1, arg2, ...]]
	#var state_object = state_class.new() 
	var state_object = load(state_path).new()
	state_object.state_parent = state_parent
	#state_object.state_class = state_class # ? 
	state_object.args = args
	return state_object

func get_current_state():
	return stack_machine[0] 

	### MY SPECIAL NEW FUNCTIONS ###
func pop_until(target_state_name: String) -> void:
	if _state_exists_in_stack(target_state_name):
		while (get_current_state().name != target_state_name):
			pop()

func _state_exists_in_stack(target_state_name: String) -> bool:
	for state in stack_machine:
		if state.name == target_state_name:
			return true
	return false

func get_state_below_self() -> Resource:
	if stack_machine.size() == 1:
		return null
	return stack_machine[1]

func get_state_below(state_name: String) -> Resource:
	var state_index: int = _get_index_of_state(state_name)
	if state_index == -1 or state_index >= stack_machine.size() - 1:
		return null
	return stack_machine[state_index + 1]

func _get_index_of_state(target_name: String) -> int:
	var index: int = -1
	for i in range(stack_machine.size()):
		if stack_machine[i].name == target_name:
			index = i
	return index






