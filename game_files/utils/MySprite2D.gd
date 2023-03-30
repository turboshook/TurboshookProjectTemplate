extends Sprite2D
class_name MySprite2D

var _flicker: bool = false
var _target_flicker_time: float = 0.0 			# amount of time sprite flicker will be active
var _total_flicker_time: float = 0.0 			# amount of time the sprite flicker has been happening
var _flicker_interval: float = 0.0				# amount of time between changes in visibility 
var _current_flicker_interval: float = 0.0		# amount of time since the last change in visibility

func _physics_process(delta: float) -> void:
	if _flicker:
		_total_flicker_time += delta
		if _total_flicker_time >= _target_flicker_time:
			stop_sprite_flicker()
		else:
			_current_flicker_interval += delta
			if _current_flicker_interval >= _flicker_interval:
				visible = !visible
				_current_flicker_interval = 0.0

func start_sprite_flicker(target_time: float = 1.0, flicker_interval: float = 0.05) -> void:
	_flicker = true
	_target_flicker_time = target_time
	_flicker_interval = flicker_interval
	_total_flicker_time = 0.0
	_current_flicker_interval = 0.0

func stop_sprite_flicker() -> void:
	visible = true
	_flicker = false
	_target_flicker_time = 0.0
	_flicker_interval = 0.0
	_total_flicker_time = 0.0
	_current_flicker_interval = 0.0
