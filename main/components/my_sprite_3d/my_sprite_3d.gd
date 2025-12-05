extends Sprite3D
class_name MySprite3D

@export var face_camera: bool = false

var _flicker: bool = false
var _target_flicker_time: float = 0.0 			# total amount of time this sprite flicker will be active
var _total_flicker_time: float = 0.0 			# elapsed time of this sprite flicker
var _flicker_interval: float = 0.0				# time between changes in visibility 
var _current_flicker_interval: float = 0.0		# time since the last change in visibility

var _sprite_shake: bool = false
var _original_offset: Vector2
var _shake_amount: float = 1.0
var _shake_time: float = 0.0
var _total_shake_time: float = 0.0

var _current_camera: Camera3D

func _ready() -> void:
	if not face_camera: return
	_current_camera = get_viewport().get_camera_3d()
	#flip_h = true

func _process(_delta: float) -> void:
	if not face_camera: return
	if _current_camera != get_viewport().get_camera_3d():
		_current_camera = get_viewport().get_camera_3d()
	var xz_look_at_pos: Vector3 = Vector3(
		_current_camera.global_position.x,
		global_position.y,
		_current_camera.global_position.z
	)
	look_at(xz_look_at_pos)

func _physics_process(delta: float) -> void:
	if _flicker:
		_handle_sprite_flicker(delta)
	if _sprite_shake:
		_handle_sprite_shake(delta)

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

func _handle_sprite_flicker(delta: float) -> void:
	_total_flicker_time += delta
	if _total_flicker_time >= _target_flicker_time:
		stop_sprite_flicker()
	else:
		_current_flicker_interval += delta
		if _current_flicker_interval >= _flicker_interval:
			visible = !visible
			_current_flicker_interval = 0.0

func start_sprite_shake(shake_amount: float, shake_time: float) -> void:
	_shake_amount = shake_amount
	_shake_time = shake_time
	_total_shake_time = 0.0
	_sprite_shake = true

func stop_sprite_shake() -> void:
	_sprite_shake = false
	offset = _original_offset

func _handle_sprite_shake(delta: float) -> void:
	_total_shake_time += delta
	if _total_shake_time >= _shake_time:
		stop_sprite_shake()
	else:
		var offset_x: float = randf_range(-_shake_amount, _shake_amount)
		var offset_y: float = randf_range(-_shake_amount, _shake_amount)
		offset = Vector2(_original_offset.x + offset_x, _original_offset.y + offset_y)

func flash(ramp_down_time: float = 0.1) -> void:
	# https://www.reddit.com/r/godot/comments/y8n1wa/is_it_possible_to_make_a_sprite_flash_white_using/
	var flash_tween: Tween = create_tween()
	flash_tween.tween_property(
		self,
		"self_modulate:v",
		1.0,
		ramp_down_time
	).from(3.0)

func stretch() -> void:
	pass # TODO
