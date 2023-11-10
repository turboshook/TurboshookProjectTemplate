extends Sprite2D
class_name MySprite2D

## Indicates the behavior of this node with regard to pixel snapping.
enum PixelSnapMode {
	## No attempt in-node pixel snapping is made, consistent with default [Sprite2D] behavior.
	NONE, 
	## Snap to the rounded [param global_position] of its parent scene every process frame. 
	PARENT,
	## Same as [param PixelSnapMode.PARENT], but adds any provided [param offset] to the 
	## new rounded [param global_position]. Useful for when this node is parented by some
	## [Node2D] in order to have both an offset value and some non-origin axis of rotation.
	## If you aren't rotating this node, don't worry about this.
	PARENT_WITH_OFFSET
}

## Desired pixel snap behavior of this node.
@export var pixel_snap_mode: PixelSnapMode = PixelSnapMode.PARENT

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
	_parent_node = get_parent()
	if !(_parent_node is Node2D or _parent_node is Control) and pixel_snap_mode != PixelSnapMode.NONE:
		printerr("MySprite2D @ _ready(): Parent node does not inherit from Node2D or Control and therefore has no positional data. Pixel snapping will not function.")

func _process(_delta: float) -> void:
	
	if pixel_snap_mode == PixelSnapMode.NONE:
		return
	if (_parent_node is Node2D or _parent_node is Control):
		return
	
	match pixel_snap_mode:
		PixelSnapMode.PARENT:
			global_position = _parent_node.global_position.round()
		PixelSnapMode.PARENT_WITH_OFFSET:
			global_position = (global_position + _original_offset).round()

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





