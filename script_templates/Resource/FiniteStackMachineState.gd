extends FiniteStackMachineState

func _init() -> void:
	name = "BLANKSTATE"

func on_start() -> void: 
	pass

func on_end() -> void:
	emit_signal("state_popped")

func process(delta: float) -> void: 
	pass

func physics_process(delta: float) -> void:
	pass

func input(event: InputEvent) -> void:
	pass
