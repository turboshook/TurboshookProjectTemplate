# warning-ignore-all:unused_argument
extends FiniteStackMachineState

# minion = Entity using the state
# state_time = time in seconds we have been in this state

# Have process return 1 or -1 when the state is finished,
# otherwise return 0 to continue

# Constructor, called checked state creation
func _init() -> void:
	name = "Blank State"

# on_start is run once when the Command is first processed (input or process)
func on_start() -> void: # Run once when the state starts
	pass

# on_end is called once when the state is finished or 'popped' from the stack 
func on_end() -> void: # Run once when the state is finished
	# end logic goes here
	emit_signal("state_popped")

# typically process is called once every frame in the minion's _process() callback
func process(delta: float) -> void: # Run usually each step of the minion, but can be called to run whenever
	pass

# alterante to process, if you want the physics thread
func physics_process(delta: float) -> void:
	pass

# typically input is called in the minion's _input() callback
func input(event: InputEvent) -> void:
	pass
