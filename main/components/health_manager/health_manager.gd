extends Node
class_name HealthManager

@export_range(1, 999, 1) var _max_health: int = 3
@onready var _current_health: int = _max_health

signal current_health_changed(current_value: int, previous_value: int)
signal max_health_changed(new_max: int, previous_max: int)

func change_health(change_amount: int) -> void:
	var previous_health: int = _current_health
	_current_health = clamp(_current_health + change_amount, 0, _max_health)
	if previous_health == _current_health: return
	current_health_changed.emit(_current_health, previous_health)

func change_max_health(change_amount: int) -> void:
	var previous_max: int = _max_health
	_max_health = clamp(_max_health + change_amount, 0, 6)
	_current_health = clamp(_current_health, 0, _max_health)
	if previous_max == _max_health: return
	max_health_changed.emit(_max_health, previous_max)

func restore_health() -> void:
	change_health(_max_health)

func get_health() -> Dictionary:
	return {
		"max": _max_health,
		"current": _current_health
	}
