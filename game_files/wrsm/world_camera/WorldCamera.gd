extends Camera2D
class_name WorldCamera

@onready var ShakeTimer: Timer = $ShakeTimer
var shake_amount: float = 0.0

enum States {
	FOLLOW_PLAYER,
	CHANGE_CELL
}
var current_state: int = States.FOLLOW_PLAYER

@export var follow_rate: float = 16.0

signal cell_change_started
signal cell_change_complete

var ignore_first_room: bool = true
var move_tween_active: bool = false

func _ready() -> void:
	WorldRegion.NodeReferences.WorldCamera = self

func _physics_process(delta: float) -> void:
	match current_state:
		States.FOLLOW_PLAYER:
			follow_player(delta)
			if ShakeTimer.time_left != 0:
				offset.x = randf_range(-shake_amount, shake_amount)
				offset.y = randf_range(-shake_amount, shake_amount)
		States.CHANGE_CELL:
			pass

func follow_player(delta: float) -> void:
	if not is_changing_cells(): 
		global_position = lerp(global_position, WorldRegion.NodeReferences.Player.global_position, delta * follow_rate)

func disable_camera_limits() -> void:
	limit_top = -10000000
	limit_bottom = 10000000
	limit_left = -10000000
	limit_right = 10000000

func set_camera_limits(limits: Array) -> void:
	limit_top = limits[0].global_position.y
	limit_bottom = limits[1].global_position.y
	limit_left = limits[2].global_position.x
	limit_right = limits[3].global_position.x

func move_to_new_camera_target(new_camera_target: Vector2) -> void:
	if ignore_first_room:
		ignore_first_room = false
	else:
		current_state = States.CHANGE_CELL
		# because global_position will always be at or near the Player here, it must be reset
		# to the center of the current screen in order to prevent snapping
		global_position = get_screen_center_position()
		disable_camera_limits()
		var tween: Tween = get_tree().create_tween()
		@warning_ignore(return_value_discarded)
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		@warning_ignore(return_value_discarded)
		tween.tween_property(self, "global_position", new_camera_target, .5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT) # work checked this, doesn't feel right
		move_tween_active = true
		@warning_ignore(return_value_discarded)
		tween.finished.connect(Callable(self, "_on_cell_change_completed"))
		@warning_ignore(return_value_discarded)
		emit_signal("cell_change_started")

func _on_cell_change_completed() -> void:
	current_state = States.FOLLOW_PLAYER
	move_tween_active = false
	@warning_ignore(return_value_discarded)
	emit_signal("cell_change_complete")

func is_changing_cells() -> bool:
	return move_tween_active

func set_camera_position(destination: Vector2) -> void:
	global_position = destination

func bump(_direction: Vector2, _force: float) -> void:
	# the idea here is to get a single directional hit, most likely using a tween
	print("this don't do nothing yet")

func shake(force: float, duration: float) -> void:
	shake_amount = force
	ShakeTimer.start(duration)

func _on_shake_timer_timeout():
	offset = Vector2.ZERO

func get_class() -> String:
	return "PlayerCamera"

func is_class(test_string: String) -> bool:
	return test_string == get_class()




