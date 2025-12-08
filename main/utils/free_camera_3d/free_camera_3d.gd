extends Node3D
class_name FreeCamera3D

const MOUSE_SENSITIVITY: float = 0.0025
const BASE_MOVE_SPEED: float = 0.1

@onready var camera: Camera3D = $Camera3D

var _initial_mouse_mode: Input.MouseMode
var _movement_input: Vector2 
var _move_speed_bonus: float = 1.0
var _move_vector: Vector3 = Vector3.ZERO

func _ready() -> void:
	_initial_mouse_mode = Input.mouse_mode
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	tree_exiting.connect(_on_tree_exiting)

func _physics_process(_delta: float) -> void:
	if not camera.current: return
	
	_move_vector = Vector3.ZERO
	_calculate_horizontal_movement()
	_calculate_vertical_movement()
	if Input.is_key_pressed(KEY_SHIFT):
		_move_speed_bonus = 2.0
	else:
		_move_speed_bonus = 1.0
	global_position += _move_vector * _move_speed_bonus

func _input(event: InputEvent) -> void:
	if not camera.current: return
	
	if event is InputEventMouseMotion:
		_handle_mouse_motion(event)

func activate() -> void:
	camera.current = true

func _calculate_horizontal_movement() -> void:
	var right_input: float = 1.0 if Input.is_key_pressed(KEY_D) else 0.0
	var left_input: float = -1.0 if Input.is_key_pressed(KEY_A) else 0.0
	var forward_input: float = -1.0 if Input.is_key_pressed(KEY_W) else 0.0
	var back_input: float = 1.0 if Input.is_key_pressed(KEY_S) else 0.0
	
	_movement_input = Vector2(
		right_input + left_input,
		forward_input + back_input
	)
	
	var direction = (
		transform.basis * Vector3(_movement_input.x, 0, _movement_input.y)
	).normalized()
	
	if direction:
		_move_vector.x = direction.x * BASE_MOVE_SPEED * _move_speed_bonus
		_move_vector.z = direction.z * BASE_MOVE_SPEED * _move_speed_bonus

func _calculate_vertical_movement() -> void:
	if Input.is_key_pressed(KEY_SPACE):
		_move_vector.y = BASE_MOVE_SPEED
	elif Input.is_key_label_pressed(KEY_CTRL):
		_move_vector.y = -BASE_MOVE_SPEED

func _handle_mouse_motion(motion_event: InputEventMouseMotion) -> void:
	rotate_y(-motion_event.relative.x * MOUSE_SENSITIVITY)
	camera.rotate_x(-motion_event.relative.y * MOUSE_SENSITIVITY)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89.9), deg_to_rad(89.9))

func _on_tree_exiting() -> void:
	Input.set_mouse_mode(_initial_mouse_mode)
