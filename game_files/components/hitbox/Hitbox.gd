extends Area2D
class_name Hitbox

@export var _owner_type: Global.HitboxOwnerTypes = Global.HitboxOwnerTypes.WORLD
@export var hit_data: HitData = null
@export_range(0.0, 5.0, 0.05) var lifetime: float = 0.0
var _current_lifetime: float = 0.0

signal hit_success

func _physics_process(delta: float) -> void:
	if lifetime == -1.0:
		return
	_current_lifetime += delta
	if _current_lifetime >= lifetime:
		queue_free()

func initialize(new_owner: int) -> void:
	if new_owner < 0 or new_owner > 2:
		return
	_owner_type = new_owner

func enable() -> void:
	monitoring = true

func disable() -> void:
	monitoring = false

func _on_area_entered(hurtbox: Hurtbox) -> void:
	if hurtbox:
		_handle_hurtbox(hurtbox)

func _handle_hurtbox(hurtbox: Hurtbox) -> void:
	if hurtbox.get_owner_type() != _owner_type:
		hurtbox.report_hit(hit_data)
		hit_success.emit()
