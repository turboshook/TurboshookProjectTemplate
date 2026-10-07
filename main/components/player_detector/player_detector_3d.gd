@tool
extends Area3D
class_name PlayerDetector3D

@export var supplement_with_ray_cast: bool = true
@export var player_body_center_offset: Vector3 = Vector3.ZERO
var _world_check: RayCast3D
var _player_body: CharacterBody3D

func _init() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if not supplement_with_ray_cast: return
	_world_check = RayCast3D.new()
	add_child(_world_check)

func _on_body_entered(body: Node3D) -> void:
	_player_body = body

func _on_body_exited(_body: Node3D) -> void:
	_player_body = null

func can_see_player() -> bool:
	if not is_instance_valid(_player_body):
		return false
	elif supplement_with_ray_cast: 
		var cast_position: Vector3 = to_local(_player_body.global_position + player_body_center_offset)
		_world_check.set_target_position(cast_position)
		_world_check.force_raycast_update()
		if _world_check.is_colliding(): return false
	return true

func get_player() -> Node3D:
	return _player_body
