extends Area3D
class_name HurtBox

@export var owner_source: HitData.Source = HitData.Source.WORLD

signal hit_detected(hit_data: HitData)

func _ready() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(32, true)
	set_collision_mask_value(31, true)
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	if not area is HitBox: return
	if not area.hit_data: return
	var hitbox: HitBox = area
	if hitbox.hit_data.source == owner_source: return
	handle_hit(hitbox.hit_data)

func handle_hit(hit_data: HitData) -> void:
	hit_detected.emit(hit_data)
