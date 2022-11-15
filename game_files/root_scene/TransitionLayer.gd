extends CanvasLayer

enum TransitionTypes {
	FADE,
	VERTICAL_SCROLL,
	HORIZONTAL_SCROLL
}

@onready var ScreenFadeTexture: ColorRect = $ScreenFadeTexture
@onready var Animations: AnimationPlayer = $AnimationPlayer

signal fade_out_started
signal fade_out_complete
signal fade_in_started
signal fade_in_complete

func fade_out(transition_type: int, transition_length: float = 0.5) -> void:
	emit_signal("fade_out_started")
	Animations.set_speed_scale(1.0 / transition_length)
	match transition_type:
		TransitionTypes.FADE:
			Animations.play("FadeOut")
		TransitionTypes.VERTICAL_SCROLL:
			print("TRANSITION NOT CREATED")
		TransitionTypes.HORIZONTAL_SCROLL:
			print("TRANSITION NOT CREATED")

func fade_in(transition_type: int, transition_length: float = 0.5) -> void:
	emit_signal("fade_in_started")
	Animations.set_speed_scale(1.0 / transition_length)
	match transition_type:
		TransitionTypes.FADE:
			Animations.play("FadeIn")
		TransitionTypes.VERTICAL_SCROLL:
			print("TRANSITION NOT CREATED")
		TransitionTypes.HORIZONTAL_SCROLL:
			print("TRANSITION NOT CREATED")

func _on_animation_player_animation_finished(anim_name):
	Animations.set_speed_scale(1.0)
	if "Out" in anim_name:
		emit_signal("fade_out_complete")
	else:
		emit_signal("fade_in_complete")
