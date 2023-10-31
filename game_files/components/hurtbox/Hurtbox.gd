extends Area2D
class_name Hurtbox

signal hit_detected(hit_data: HitData)

@export var _owner_type: Hitbox.HitboxOwnerType = Hitbox.HitboxOwnerType.WORLD

func initialize(new_owner: Hitbox.HitboxOwnerType) -> void:
	if new_owner < 0 or new_owner > 2:
		return
	_owner_type = new_owner

func get_owner_type() -> int:
	return _owner_type

func report_hit(hit_data: HitData) -> void:
	hit_detected.emit(hit_data)
