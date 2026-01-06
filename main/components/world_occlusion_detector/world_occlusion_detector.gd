extends Node3D
class_name WorldOcclusionDetector

@export_range(0.1, 4.0, 0.05) var occlusion_check_width: float = 0.25

var _cast_0: RayCast3D
var _cast_1: RayCast3D
var _cast_2: RayCast3D
var _current_camera: Camera3D

func _ready() -> void:
	_cast_0 = RayCast3D.new()
	add_child(_cast_0)
	_cast_0.set_target_position(Vector3.ZERO)
	_cast_1 = RayCast3D.new()
	add_child(_cast_1)
	_cast_1.position.x = (occlusion_check_width/2.0)
	_cast_1.set_target_position(Vector3.ZERO)
	_cast_2 = RayCast3D.new()
	add_child(_cast_2)
	_cast_2.position.x = -(occlusion_check_width/2.0)
	_cast_2.set_target_position(Vector3.ZERO)
	# TODO update current camera when it changes?
	_current_camera = get_viewport().get_camera_3d()

func _physics_process(_delta: float) -> void:
	look_at(_current_camera.global_position)
	_cast_0.set_target_position(
		_cast_0.to_local(_current_camera.global_position)
	)
	_cast_1.set_target_position(
		_cast_1.to_local(_current_camera.global_position)
	)
	_cast_2.set_target_position(
		_cast_2.to_local(_current_camera.global_position)
	)

func is_occluded() -> bool:
	return _cast_0.is_colliding() and _cast_1.is_colliding() and _cast_2.is_colliding()
