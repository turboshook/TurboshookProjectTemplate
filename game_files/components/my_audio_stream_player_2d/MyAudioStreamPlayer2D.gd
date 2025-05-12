extends AudioStreamPlayer2D
class_name MyAudioStreamPlayer2D

func set_random_pitch(threshold: float = 0.1) -> void:
	threshold = clamp(threshold, 0.1, 3.9) # kinda arbitrary
	pitch_scale = randf_range(1.0 - threshold, 1.0 + threshold)
