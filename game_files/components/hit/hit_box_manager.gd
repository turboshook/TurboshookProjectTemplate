extends Node2D
class_name HitBoxManager

@export var hit_rect_size: Vector2 = Vector2(8.0, 8.0)
@export var hit_data: HitData
@export_range(0.0, 1.0, 0.05) var spawn_delay: float = 0.0
@export_range(0.0, 10.0, 0.05) var lifetime: float = 0.5 

var _hit_box_instance: HitBox
var _elapsed_lifetime: float = 0.0

func create_hitbox() -> void:
	# await delay BEFORE checking if current hitbox is valid
	if spawn_delay > 0.0: await get_tree().create_timer(spawn_delay).timeout 
	# remove old hitbox
	if is_instance_valid(_hit_box_instance): _hit_box_instance.queue_free() 
	var collision_rect: RectangleShape2D = RectangleShape2D.new()
	collision_rect.size = hit_rect_size
	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	collision_shape.shape = collision_rect
	_hit_box_instance = HitBox.new()
	add_child(_hit_box_instance)
	_hit_box_instance.add_child(collision_shape)
	_hit_box_instance.hit_data = hit_data
	_elapsed_lifetime = 0.0

func destroy_hitbox() -> void:
	if not is_instance_valid(_hit_box_instance): return
	_hit_box_instance.queue_free()

func get_hit_box() -> HitBox:
	if not is_instance_valid(_hit_box_instance): return null
	return _hit_box_instance

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_hit_box_instance): return
	if lifetime == 0.0: return # lifetime of zero is indefinite
	_elapsed_lifetime += delta
	if _elapsed_lifetime > lifetime: _hit_box_instance.queue_free()
