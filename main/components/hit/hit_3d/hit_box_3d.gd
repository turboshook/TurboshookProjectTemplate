extends Area3D
class_name HitBox3D

@export var hit_data: HitData

@warning_ignore("unused_signal")
signal hit_detected(_colliding_hurt_box: HurtBox3D)
# signal is emitted by receiving hurtbox on a successful collision

func _ready() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(32, true)

func set_enabled(set_value: bool) -> void:
	set_deferred("monitoring", set_value)
	set_deferred("monitorable", set_value)

func is_enabled() -> bool:
	return (monitoring and monitorable)
