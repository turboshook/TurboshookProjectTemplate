extends CharacterBody3D

const BASE_MOVE_SPEED: float = 1.5
const LOOK_SENSITIVITY: float = 0.0025

@onready var capsule_body: MeshInstance3D = $CapsuleBody
@onready var camera_anchor: Node3D = $CameraAnchor
@onready var player_camera: Camera3D = $CameraAnchor/Camera3D

var _forward_input: float = 0.0
var _strafe_input: float = 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	capsule_body.visible = false

func _physics_process(_delta: float) -> void:
	
	if Input.is_key_pressed(KEY_TAB):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else: Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	var left_input: float = -1.0 if Input.is_key_pressed(KEY_A) else 0.0
	var right_input: float = 1.0 if Input.is_key_pressed(KEY_D) else 0.0
	var forward_input: float = -1.0 if Input.is_key_pressed(KEY_W) else 0.0
	var back_input: float = 1.0 if Input.is_key_pressed(KEY_S) else 0.0
	
	_forward_input = forward_input - back_input
	_strafe_input = left_input - right_input
	
	if _forward_input == 0.0 and _strafe_input == 0.0: return
	var move_direction: Vector3 = Vector3(
		_strafe_input, 0.0, _forward_input
	).rotated(Vector3.UP, rotation.y)
	set_velocity(move_direction * BASE_MOVE_SPEED)
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.relative.x * LOOK_SENSITIVITY
		camera_anchor.rotation.x -= event.relative.y * LOOK_SENSITIVITY
		camera_anchor.rotation_degrees.x = clamp(camera_anchor.rotation_degrees.x, -89.0, 89.0)
