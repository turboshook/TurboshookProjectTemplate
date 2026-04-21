extends Area3D
class_name RigidBodyPickUpComponent

const FOLLOW_MAX_DISTANCE_RAMP: float = 0.5
const FOLLOW_DEADZONE: float = 0.01
const SEGMENT_MIN_TRAVEL_SPEED: float = 0.01
const SEGMENT_MAX_TRAVEL_SPEED: float = 8.0

@export var _rigid_body: RigidBody3D 
var _follow_target: Node3D = null

func _init() -> void:
	set_collision_layer_value(1, false)
	set_collision_layer_value(31, true)
	set_collision_mask_value(1, false)

func _ready() -> void:
	if not _rigid_body:
		push_warning("RigidBodyPickUpManager @ _ready(): No _rigid_body defined, this component will not function.")
		return

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_follow_target): return
	
	# Update position via velocity
	var move_target: Vector3 = _follow_target.global_position
	var direction: Vector3 = move_target - global_transform.origin
	var distance: float = direction.length()
	if distance > FOLLOW_DEADZONE:
		var speed_modifier: float = clamp(
			distance / FOLLOW_MAX_DISTANCE_RAMP,
			0.0, 1.0
		)
		var speed: float = lerp(SEGMENT_MIN_TRAVEL_SPEED, SEGMENT_MAX_TRAVEL_SPEED, speed_modifier)
		_rigid_body.linear_velocity = direction.normalized() * speed
	else:
		_rigid_body.linear_velocity = Vector3.ZERO
		_rigid_body.global_position = _follow_target.global_position
	
	# Update rotation directly (I think this is fine).
	_rigid_body.angular_velocity = Vector3.ZERO
	_rigid_body.global_rotation.x = lerp_angle(_rigid_body.global_rotation.x, 0.0, delta * 16.0)
	_rigid_body.global_rotation.y = lerp_angle(
		_rigid_body.global_rotation.y, _follow_target.global_rotation.y, 16.0 * delta
	)
	_rigid_body.global_rotation.z = lerp_angle(_rigid_body.global_rotation.z, 0.0, delta * 16.0)

func set_follow_target(follow_target: Node3D) -> void:
	_rigid_body.orthonormalize() # account for excessive rotation angles
	_follow_target = follow_target
	_rigid_body.can_sleep = false

func remove_follow_target() -> void:
	_follow_target = null
	_rigid_body.can_sleep = true
