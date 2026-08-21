extends Node3D

@export_category("Dependencies")
## [CharacterBody3D] scene that this controller will assist in managing (most likely a first-person player controller).
@export var parent_controller: CharacterBody3D
## Some [Node3D] child scene of [param parent_controller] that is used to fix the spatial offset of this scene in relation to it.
@export var camera_anchor: Node3D

@export_category("Configuration")
@export_range(0.001, 0.1, 0.0005) var mouse_sensitivity: float = 0.0025

@onready var camera: Camera3D = $Camera3D
@onready var aim_cast: RayCast3D = $AimCast

var _input_rotation: Vector3
var _mouse_input: Vector2
var _frozen: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if _frozen: return
	if event is InputEventMouseMotion:
		_mouse_input -= event.screen_relative * mouse_sensitivity

func _physics_process(_delta: float) -> void:
	_input_rotation.x = clampf(_input_rotation.x + _mouse_input.y, deg_to_rad(-89.0), deg_to_rad(89.0))
	_input_rotation.y += _mouse_input.x
	
	# rotate vertically
	camera_anchor.basis = Basis.from_euler(Vector3(_input_rotation.x, 0.0, 0.0))
	
	# rotate horizontally
	parent_controller.global_basis = Basis.from_euler(Vector3(0.0, _input_rotation.y, 0.0))
	
	global_transform = camera_anchor.get_global_transform_interpolated()
	_mouse_input = Vector2.ZERO

func get_aim_position(check_distance: float = 100.0) -> Vector3:
	aim_cast.target_position = Vector3.FORWARD * check_distance
	aim_cast.force_raycast_update()
	if aim_cast.is_colliding(): return aim_cast.get_collision_point()
	return aim_cast.to_global(aim_cast.target_position)

func set_frozen(set_value: bool) -> void:
	_frozen = set_value

func is_frozen() -> bool:
	return _frozen
