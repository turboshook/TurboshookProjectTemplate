extends Area2D
class_name HurtBox

@export var owner_source: HitData.Source = HitData.Source.WORLD
var _enabled: bool = true
var _last_hit: HitData

signal hit_detected(hit_data: HitData)

func _ready() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_mask_value(32, true)
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if not _enabled: return
	if not area is HitBox: return
	if not area.hit_data: return
	var hitbox: HitBox = area
	if hitbox.hit_data.source == owner_source: return
	hitbox.hit_detected.emit(self)
	handle_hit(hitbox.hit_data)

func handle_hit(hit_data: HitData) -> void:
	_last_hit = hit_data
	hit_detected.emit(_last_hit)

func has_hit_data() -> bool:
	return (_last_hit != null)

func extract_hit_data() -> HitData:
	var data_copy: HitData = _last_hit.duplicate()
	_last_hit = null
	return data_copy

func is_enabled() -> bool:
	return _enabled

func set_enabled(set_value: bool) -> void:
	_enabled = set_value
