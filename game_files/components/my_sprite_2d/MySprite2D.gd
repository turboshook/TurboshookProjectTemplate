extends Sprite2D
class_name MySprite2D

## When [param true], this sprite will track the rounded [param global_position] of its parent.[br][br] 
## Because this changes the positional arguments of the node, any placement adjustments made to 
## assigned textures should be done using the [param offset] property.
@export var pixel_snap_fix: bool = true

var _parent_node: Node = null

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

func _ready() -> void:
	_original_offset = offset
	if pixel_snap_fix:
		_parent_node = get_parent()

func _process(_delta: float) -> void:
	if pixel_snap_fix:
		if _parent_node is Node2D or _parent_node is Control:
			global_position = _parent_node.global_position.round()
		else:
			global_position = global_position.round()

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
