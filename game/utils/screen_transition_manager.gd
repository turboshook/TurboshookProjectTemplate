extends CanvasLayer
class_name ScreenTransitionManager

@onready var screen_fade_rect: ColorRect = $ScreenFadeRect

func screen_fade_out(fade_time: float = 0.5) -> Tween:
	if fade_time <= 0.0:
		screen_fade_rect.color.a = 1.0
		return
	var fade_out_tween: Tween = create_tween()
	fade_out_tween.tween_property(screen_fade_rect, "color:a", 1.0, fade_time)
	return fade_out_tween

func screen_fade_in(fade_time: float = 0.5) -> Tween:
	if fade_time <= 0.0:
		screen_fade_rect.color.a = 0.0
		return
	var fade_in_tween: Tween = create_tween()
	fade_in_tween.tween_property(screen_fade_rect, "color:a", 0.0, fade_time)
	return fade_in_tween
