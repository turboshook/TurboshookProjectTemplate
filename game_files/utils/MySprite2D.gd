extends Sprite2D
class_name MySprite2D

@onready var _FlickerTimer: Timer = $FlickerTimer


func start_sprite_flicker(flicker_interval: float = 0.05) -> void:
	_FlickerTimer.start(flicker_interval)

func stop_sprite_flicker() -> void:
	_FlickerTimer.stop()
	visible = true

func _on_flicker_timer_timeout():
	visible = !visible
	_FlickerTimer.start()

func get_class() -> String:
	return "MySprite2D"

func is_class(test_string: String) -> bool:
	return test_string == "MySprite2D"

