# warning-ignore-all:unused_argument
extends StateMachine

enum States {
	IDLE
}

func _ready():
	call_deferred("set_state", States.IDLE)

func _state_logic(delta: float) -> void:
	match state:
		States.IDLE:
			pass

# excluding the -> int from the end of this function lets us not have a buffer return at the very bottom
# doing so slows down movement because Player is constantly switching to and from 0 == states.idle
func _get_transition():
	match state:
		States.IDLE:
			pass

func _enter_state(new_state: int, old_state: int) -> void:
	match new_state:
		States.IDLE:
			pass

func _exit_state(old_state: int, new_state: int) -> void:
	match old_state:
		States.IDLE:
			pass














 
