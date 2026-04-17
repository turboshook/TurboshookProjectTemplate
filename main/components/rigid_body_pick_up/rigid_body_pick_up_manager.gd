extends Node3D
class_name RigidBodyPickUpManager

@export var owner_camera: Camera3D
@export_range(0.1, 4.0, 0.05) var pick_up_reach_length: float = 1.5
@export_range(0.5, 2.0, 0.05) var pick_up_carry_radius: float = 0.75

var _ray_cast: RayCast3D 
var _follow_target: Node3D
var _pick_up_component: RigidBodyPickUpComponent

func _ready() -> void:
	_ray_cast = RayCast3D.new()
	_ray_cast.set_collision_mask_value(1, false)
	_ray_cast.set_collision_mask_value(31, true)
	_ray_cast.collide_with_areas = true
	_ray_cast.collide_with_bodies = false
	_ray_cast.target_position = Vector3.FORWARD * pick_up_reach_length
	add_child(_ray_cast)
	
	_follow_target = Node3D.new()
	add_child(_follow_target)
	# Important to initialize at the correct radius
	_follow_target.position = Vector3.FORWARD * pick_up_carry_radius

func _physics_process(_delta: float) -> void:
	var forward_vector: Vector3 = -global_basis.z
	var flat_offset: Vector3 = Vector3(forward_vector.x, 0.0, forward_vector.z) # flatten to 2D space (looking down)
	var constrained_flat: Vector3 = flat_offset.normalized() * pick_up_carry_radius
	var target_global_position: Vector3 = global_position + Vector3(
		constrained_flat.x,
		forward_vector.y,
		constrained_flat.z
	)
	_follow_target.global_position = target_global_position
	
	if not _pick_up_component: return
	if _follow_target.global_position.distance_to(_pick_up_component.global_position) >= pick_up_reach_length: release()

func pick_up() -> void:
	if not _ray_cast.is_colliding(): return
	_pick_up_component = _ray_cast.get_collider()
	if not _pick_up_component: return
	_pick_up_component.set_follow_target(_follow_target)

func release() -> void:
	if not _pick_up_component: return
	_pick_up_component.remove_follow_target()
	_pick_up_component = null

func has_pick_up() -> bool:
	return is_instance_valid(_pick_up_component)
