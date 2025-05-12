extends Area3D
class_name HitBox

@export var hit_data: HitData

func _ready() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(31, true)
	set_collision_mask_value(32, true)
