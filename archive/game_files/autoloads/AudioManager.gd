extends Node

@onready var _BGMPlayer: AudioStreamPlayer = $BGMPlayer
@onready var _SFXContainer: Node = $SFXContainer

@onready var _bgm_low_pass: AudioEffectLowPassFilter = AudioServer.get_bus_effect(1, 0)
enum BGMLowPassKeys {
	DEFAULT,
	HALF,
	LOW,
	LOWEST
}
const _BGM_LOW_PASS_CUTOFF_HZ_VALUES = [
	20500,
	10250,
	5125,
	2562
]

# Array[Array[audio_stream, loop_duration]]
var _looping_stream: AudioStreamPlayer = null

func set_bgm_pause(pause_value: bool) -> void:
	_BGMPlayer.stream_paused = pause_value

func set_bgm_low_pass_cutoff(low_pass_key: int, tween_time: float) -> void:
	if low_pass_key < 0 or low_pass_key > 3:
		return
	var cutoff_hz_tween: Tween = get_tree().create_tween()
	# warning-ignore:return_value_discarded
	cutoff_hz_tween.tween_property(
		_bgm_low_pass,
		"cutoff_hz",
		_BGM_LOW_PASS_CUTOFF_HZ_VALUES[low_pass_key],
		tween_time
	)

func set_bgm_volume(linear_volume: float, tween_time: float = 0.0) -> void:
	var clamped_linear_volume: float = clamp(linear_volume, 0.00, 1.0)
	var clamped_target_volume: float = clamp(linear_to_db(clamped_linear_volume), -80.0, 0.0)
	if tween_time > 0.0:
		var volume_tween: Tween = get_tree().create_tween()
		volume_tween.tween_property(
			_BGMPlayer,
			"volume_db",
			clamped_target_volume,
			tween_time
		)
	else:
		_BGMPlayer.volume_db = clamped_target_volume

func play_sfx(sfx_name: String) -> void:
	var selected_audio_stream: AudioStreamPlayer = _SFXContainer.get_node_or_null(sfx_name)
	if selected_audio_stream:
		selected_audio_stream.pitch_scale = 1.0
		selected_audio_stream.play()

func play_sfx_set_pitch(sfx_name: String, set_pitch_scale: float) -> void:
	var selected_audio_stream: AudioStreamPlayer = _SFXContainer.get_node_or_null(sfx_name)
	if selected_audio_stream:
		selected_audio_stream.pitch_scale = set_pitch_scale
		selected_audio_stream.play()

func play_sfx_random_pitch(sfx_name: String, pitch_scale_random_range: float = 0.1) -> void:
	var selected_audio_stream: AudioStreamPlayer = _SFXContainer.get_node_or_null(sfx_name)
	if selected_audio_stream:
		selected_audio_stream.pitch_scale = 1.0
		selected_audio_stream.pitch_scale += randf_range(-pitch_scale_random_range, pitch_scale_random_range)
		selected_audio_stream.play()

# For now, limit 1 looping stream
func play_sfx_loop(sfx_name: String, loop_duration: float = 1.0) -> void:
	var selected_audio_stream: AudioStreamPlayer = _SFXContainer.get_node_or_null(sfx_name)
	if selected_audio_stream:
		selected_audio_stream.stream.loop = true
		selected_audio_stream.play()
		_looping_stream = selected_audio_stream
		var sfx_loop_timer: SceneTreeTimer = get_tree().create_timer(loop_duration)
		sfx_loop_timer.timeout.connect(Callable(self, "_on_sfx_loop_timer_timeout"))

func _on_sfx_loop_timer_timeout() -> void:
	_looping_stream.stream.loop = false
	_looping_stream.stop()
