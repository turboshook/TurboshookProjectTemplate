extends Area3D
class_name RigidBodyPickUpComponent3D

var _rigid_body: RigidBody3D

func _init() -> void:
	set_collision_layer_value(1, false)
	set_collision_layer_value(31, true)
	set_collision_mask_value(1, false)

# TODO
# config warnings ensuring that parent scene is RigidBody3D to be grabbed

func _ready() -> void:
	_rigid_body = get_parent()
	_rigid_body.set_collision_layer_value(1, false)
	_rigid_body.set_collision_layer_value(31, true)
	_rigid_body.set_collision_mask_value(31, true)

func get_rigid_body() -> RigidBody3D:
	return _rigid_body
