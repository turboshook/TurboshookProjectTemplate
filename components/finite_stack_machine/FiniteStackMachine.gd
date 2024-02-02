# FiniteStackMachine.gd
extends Node
class_name FiniteStackMachine

var state_parent: Node
# Node that the stateStack is attached to

var state_stack: Array[FiniteStackMachineState] = []
# This member array is the heart of the whole operation.
# It looks like this:
# [[state_object1, [arg1, arg2, ...]], [state_object2, [arg1, arg2, ...]], ...]

var default_state: Array
# [0] String path to a state object that is push_create()ed if the stack is empty
# [1] is args[] for state object

#signal state_time_changed(new_value)
signal stack_machine_changed

func initialize(parent_scene: Node, default_state_path: String, default_state_arguments: Array = []) -> void:
	state_parent = parent_scene
	default_state = [default_state_path, default_state_arguments]

func process(delta: float) -> void:
	# Method for processing the current state @ pos 0
	#if stack_machine.size() == 0:
	#	print("STACK MACHINE EMPTY FOR ", get_parent().name)
	if state_stack.size() > 0:
		# get top state info
		var state_object: FiniteStackMachineState = state_stack[0]
		
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
	if state_stack.size() > 0:
		# get top state info
		var state_object: FiniteStackMachineState = state_stack[0]
		
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
	if state_stack.size() > 0:
		# get top state info
		var state_object: FiniteStackMachineState = state_stack[0]
		
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
	state_stack.push_front(state)
	stack_machine_changed.emit()

func add(state):
	# add a state to end of state stack
	state_stack.append(state)
	stack_machine_changed.emit()

func push_create(state_path, args = []):
	# create and add a state class with args to front of state stack
	push(state_create(state_path, args))

func add_create(state_class, args = []):
	# create and add a state class and args to end of state stack
	add(state_create(state_class, args))

func pop():
	# pop the top state from the from state stack
	var old_state: FiniteStackMachineState = state_stack.pop_front()
	# process on_end event for the popped state
	old_state.on_end()
	old_state.queue_free()
	stack_machine_changed.emit()

func state_create(state_path, args = []):
	# creates an entry appropriate for the state_stack array
	# [state_ref, [arg1, arg2, ...]]
	#var state_object = state_class.new() 
	var state_object: FiniteStackMachineState = load(state_path).new()
	state_object.state_parent = state_parent
	#state_object.state_class = state_class # ? 
	state_object.args = args
	add_child(state_object)
	return state_object

func get_current_state():
	return state_stack[0] 

	### MY SPECIAL NEW FUNCTIONS ###
func pop_until(target_state_name: String) -> void: # this may be dangerous now that states are nodes? lmao
	if _state_exists_in_stack(target_state_name):
		while (get_current_state().state_name != target_state_name):
			pop()

func _state_exists_in_stack(target_state_name: String) -> bool:
	for state in state_stack:
		if state.state_name == target_state_name:
			return true
	return false

func get_state_below_self() -> FiniteStackMachineState:
	if state_stack.size() == 1:
		return null
	return state_stack[1]

func get_state_below(state_name: String) -> FiniteStackMachineState:
	var state_index: int = _get_index_of_state(state_name)
	if state_index == -1 or state_index >= state_stack.size() - 1:
		return null
	return state_stack[state_index + 1]

func _get_index_of_state(target_name: String) -> int:
	var index: int = -1
	for i in range(state_stack.size()):
		if state_stack[i].state_name == target_name:
			index = i
	return index

func get_current_state_name() -> String:
	if state_stack.size() == 0:
		return "NONE"
	return state_stack[0].state_name





