extends PointLight2D
class_name MyPointLight2D

@export var _flicker_enabled: bool = false
@export_range(0.05, 0.8, 0.05) var _flicker_strength: float = 0.05
@export_range(1.0, 2.0, 0.05) var _flicker_strength_random: float = 1.0
@export_range(0.05, 1.0, 0.05) var _flicker_time: float = 0.25
@export_range(1.0, 3, 0.1) var _flicker_time_random: float = 1.0
var _starting_texture_scale: float = 1.0
var _flicker_sign: int = 1
var _flicker_tween: Tween

func _ready() -> void:
	if _flicker_enabled:
		_starting_texture_scale = texture_scale
		_start_flicker()

func _start_flicker() -> void:
	_flicker_sign *= -1
	var flicker_strength_random: float = randf_range(1.0, _flicker_strength_random)
	var flicker_time_random: float = randf_range(1.0, _flicker_time_random)
	var target_texture_scale: float = (_starting_texture_scale * (1 + _flicker_sign * _flicker_strength)) * flicker_strength_random
	var flicker_time: float = _flicker_time * flicker_time_random
	_flicker_tween = get_tree().create_tween()
	_flicker_tween.tween_property(
		self,
		"texture_scale",
		target_texture_scale,
		flicker_time
	)
	_flicker_tween.finished.connect(Callable(self, "_on_flicker_tween_finished"))

func _on_flicker_tween_finished() -> void:
	_start_flicker()
