extends Node3D
class_name RigidBodyPickUpManager3D

@export_category("Config")
@export_range(0.5, 5.0, 0.1) var pick_up_range: float = 1.5
@export_range(1.0, 16.0, 0.1) var carry_delta_modifier: float = 4.0
@export_range(1.0, 32.0, 0.1) var throw_force: float = 5.0
@export_range(0.0, 8.0, 0.1) var throw_y_axis_adjustment: float = 1.0
@export_category("Debug")
@export var _show_anchor_mesh: bool = false
var _grabbed_body: RigidBody3D = null

@onready var rigid_body_pick_up_component_check: RayCast3D = $RigidBodyPickUpComponentCheck
@onready var grabbed_body_anchor: Marker3D = $SpringArm3D/GrabbedBodyAnchor
@onready var world_obstruction_check: RayCast3D = $SpringArm3D/GrabbedBodyAnchor/WorldObstructionCheck
@onready var anchor_mesh: MeshInstance3D = $SpringArm3D/GrabbedBodyAnchor/AnchorMesh

func _ready() -> void:
	_update_pick_up_range()
	anchor_mesh.visible = _show_anchor_mesh

func _update_pick_up_range() -> void:
	rigid_body_pick_up_component_check.target_position.z = -pick_up_range

func attempt_grab() -> void:
	if is_holding_body(): return
	if not rigid_body_pick_up_component_check.is_colliding(): return
	var component: RigidBodyPickUpComponent3D = rigid_body_pick_up_component_check.get_collider()
	if not is_instance_valid(component): return
	var body: RigidBody3D = component.get_rigid_body()
	if not is_instance_valid(body): return
	_grabbed_body = body
	_grabbed_body.set_collision_layer_value(31, false)
	_grabbed_body.set_collision_mask_value(2, false)

func attempt_release() -> void:
	_grabbed_body.linear_velocity *= 0.1
	_release_body()
	world_obstruction_check.target_position = Vector3.ZERO

func attempt_throw() -> void:
	_grabbed_body.linear_velocity = Vector3.ZERO
	_grabbed_body.apply_central_impulse(
		(-global_basis.z * throw_force) + Vector3(0.0, throw_y_axis_adjustment, 0.0)
	)
	_release_body()
	world_obstruction_check.target_position = Vector3.ZERO

func is_holding_body() -> bool:
	return is_instance_valid(_grabbed_body)

func _grab_anchor_obstructed() -> bool:
	if not is_holding_body(): return false
	world_obstruction_check.target_position = grabbed_body_anchor.to_local(_grabbed_body.global_position)
	world_obstruction_check.force_raycast_update()
	return world_obstruction_check.is_colliding()

func _release_body() -> void:
	_grabbed_body.set_collision_layer_value(31, true)
	_grabbed_body.set_collision_mask_value(2, true)
	_grabbed_body = null

func _physics_process(delta: float) -> void:
	if not _grabbed_body: return
	var grab_move_direction: Vector3 = \
		grabbed_body_anchor.global_position - _grabbed_body.global_position
	# without modifying delta, there is still evident jitter on fps > physics tick
	var required_velocity: Vector3 = grab_move_direction / (delta * carry_delta_modifier)
	_grabbed_body.linear_velocity = required_velocity
	_grabbed_body.angular_velocity *= 0.5
	if _grab_anchor_obstructed(): attempt_release()
