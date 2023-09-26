extends FiniteStackMachineState

func _init() -> void:
	state_name = "BLANKSTATE"

func on_start() -> void: 
	pass

func process(_delta: float) -> void: 
	pass

func physics_process(_delta: float) -> void:
	pass

func input(_event: InputEvent) -> void:
	pass

func on_end() -> void:
	emit_signal("state_popped")
