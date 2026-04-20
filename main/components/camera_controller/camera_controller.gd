extends Node3D

@export_category("Dependencies")
## [CharacterBody3D] scene that this controller will assist in managing (most likely a first-person player controller).
@export var parent_controller: CharacterBody3D
## Some [Node3D] child scene of [param parent_controller] that is used to fix the spatial offset of this scene in relation to it.
@export var camera_anchor: Node3D

@export_category("Configuration")
@export_range(0.001, 0.1, 0.0005) var mouse_sensitivity: float = 0.0025

@onready var camera: Camera3D = $Camera3D

var _input_rotation: Vector3
var _mouse_input: Vector2

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_input -= event.screen_relative * mouse_sensitivity

func _process(_delta: float) -> void:
	_input_rotation.x = clampf(_input_rotation.x + _mouse_input.y, deg_to_rad(-89.0), deg_to_rad(89.0))
	_input_rotation.y += _mouse_input.x
	
	# rotate vertically
	camera_anchor.basis = Basis.from_euler(Vector3(_input_rotation.x, 0.0, 0.0))
	
	# rotate horizontally
	parent_controller.global_basis = Basis.from_euler(Vector3(0.0, _input_rotation.y, 0.0))
	
	global_transform = camera_anchor.get_global_transform_interpolated()
	_mouse_input = Vector2.ZERO
