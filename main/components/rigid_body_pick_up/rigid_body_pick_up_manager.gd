extends Node3D
class_name RigidBodyPickUpManager

@export_category("Dependencies")
@export var physics_anchor: Node3D

@export_category("Configuration")
@export_range(0.1, 4.0, 0.05) var pick_up_reach_length: float = 1.5
@export_range(0.5, 2.0, 0.05) var pick_up_carry_radius: float = 0.75

@export_group("Debug")
@export var _show_test_anchor_box: bool = false

var _ray_cast: RayCast3D 
var _rigid_body_anchor: Node3D
var _pick_up_component: RigidBodyPickUpComponent

func _ready() -> void:
	_ray_cast = RayCast3D.new()
	_ray_cast.set_collision_mask_value(1, false)
	_ray_cast.set_collision_mask_value(31, true)
	_ray_cast.collide_with_areas = true
	_ray_cast.collide_with_bodies = false
	_ray_cast.target_position = Vector3.FORWARD * pick_up_reach_length
	add_child(_ray_cast)
	
	_rigid_body_anchor = Node3D.new()
	#_rigid_body_anchor.set_as_top_level(true)
	add_child(_rigid_body_anchor)
	# Important to initialize at the correct radius
	_rigid_body_anchor.position = -global_basis.z * pick_up_carry_radius
	
	# make sure the box presents no stutter
	if _show_test_anchor_box:
		var test_box: MeshInstance3D = MeshInstance3D.new()
		var box_mesh: BoxMesh = BoxMesh.new()
		box_mesh.size = Vector3(0.2, 0.2, 0.2)
		test_box.mesh = box_mesh
		_rigid_body_anchor.add_child(test_box)
	
	set_as_top_level(true)

func _physics_process(_delta: float) -> void:
	
	if not _pick_up_component: return
	if _rigid_body_anchor.global_position.distance_to(_pick_up_component.global_position) >= pick_up_reach_length: release()

func _process(_delta: float) -> void:
	
	global_transform = physics_anchor.get_global_transform_interpolated()
	
	# Update follow target position
	var forward_vector: Vector3 = -global_basis.z
	var flat_offset: Vector3 = Vector3(forward_vector.x, 0.0, forward_vector.z) # flatten to 2D space (looking down)
	var constrained_flat: Vector3 = flat_offset.normalized() * pick_up_carry_radius
	_rigid_body_anchor.global_position = global_position + Vector3(
		constrained_flat.x,
		forward_vector.y,
		constrained_flat.z
	)
	_rigid_body_anchor.global_rotation.x = 0.0
	_rigid_body_anchor.global_rotation.z = 0.0

func pick_up() -> void:
	if not _ray_cast.is_colliding(): return
	_pick_up_component = _ray_cast.get_collider()
	if not _pick_up_component: return
	_pick_up_component.set_follow_target(_rigid_body_anchor)

func release() -> void:
	if not _pick_up_component: return
	_pick_up_component.remove_follow_target()
	_pick_up_component = null

func has_pick_up() -> bool:
	return is_instance_valid(_pick_up_component)
