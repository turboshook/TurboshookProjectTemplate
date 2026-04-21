extends CharacterBody3D

const BASE_MOVE_SPEED: float = 1.5

@onready var capsule_body: MeshInstance3D = $CapsuleBody
@onready var physics_anchor: Node3D = $PhysicsAnchor
@onready var camera_controller: Node3D = $CameraController

var _forward_input: float = 0.0
var _strafe_input: float = 0.0

func _ready() -> void:
	capsule_body.visible = false

func _physics_process(_delta: float) -> void:
	
	var left_input: float = -1.0 if Input.is_key_pressed(KEY_A) else 0.0
	var right_input: float = 1.0 if Input.is_key_pressed(KEY_D) else 0.0
	var forward_input: float = -1.0 if Input.is_key_pressed(KEY_W) else 0.0
	var back_input: float = 1.0 if Input.is_key_pressed(KEY_S) else 0.0
	
	_forward_input = forward_input + back_input
	_strafe_input = left_input + right_input
	
	if _forward_input == 0.0 and _strafe_input == 0.0: return
	var move_direction: Vector3 = Vector3(
		_strafe_input, 0.0, _forward_input
	).rotated(Vector3.UP, rotation.y)
	set_velocity(move_direction * BASE_MOVE_SPEED)
	move_and_slide()
