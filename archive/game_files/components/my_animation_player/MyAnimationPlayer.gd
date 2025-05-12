extends AnimationPlayer
class_name MyAnimationPlayer

var _pause: bool = false
var _target_pause_time: float = 1.0
var _current_pause_time: float = 0.0

func _physics_process(delta: float) -> void:
	if _pause:
		_current_pause_time += delta
		if _current_pause_time >= _target_pause_time:
			speed_scale = 1.0
			_pause = false

func pause_animation(target_pause_timne: float = 1.0) -> void:
	_target_pause_time = target_pause_timne
	_current_pause_time = 0.0
	_pause = true
	speed_scale = 0.0

func resume_animation() -> void:
	_current_pause_time = _target_pause_time # force timeout
