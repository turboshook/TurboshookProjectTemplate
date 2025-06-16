extends Area2D
class_name HitBox

@export var hit_data: HitData

@warning_ignore("unused_signal")
signal hit_detected(_colliding_hurt_box: HurtBox)
# signal is emitted by receiving hurtbox on a successful collision

func _ready() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(32, true)
