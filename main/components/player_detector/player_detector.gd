extends Area3D
class_name PlayerDetector

# TODO
# additional raycast check for world obstruction

@export var enabled: bool = true
@export var _supplement_with_raycast: bool = true
var _world_check: RayCast3D
var _player_body: Player

func _init() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if not _supplement_with_raycast: return
	_world_check = RayCast3D.new()
	add_child(_world_check)

func _on_body_entered(body: Node3D) -> void:
	if not enabled: return
	if not body is Player: return
	_player_body = body

func _on_body_exited(body: Node3D) -> void:
	if not enabled: return
	if not body is Player: return
	_player_body = null

func can_see_player() -> bool:
	if not enabled: return false
	if not _supplement_with_raycast: 
		if not is_instance_valid(_player_body): return false
		return not _player_body.is_dead
	if not is_instance_valid(_player_body): return false
	var cast_position: Vector3 = to_local(_player_body.global_position)
	_world_check.set_target_position(cast_position)
	_world_check.force_raycast_update()
	if _world_check.is_colliding(): return false
	return not _player_body.is_dead

func get_player() -> Player:
	return _player_body
