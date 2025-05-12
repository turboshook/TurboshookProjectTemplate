extends Camera2D
class_name WorldCamera

@onready var ShakeTimer: Timer = $ShakeTimer
var shake_amount: float = 0.0

enum States {
	FOLLOW_PLAYER,
	CHANGE_CELL
}
var current_state: int = States.FOLLOW_PLAYER

@export var cell_focus_time: float = 0.75
@export var follow_rate: float = 16.0

signal cell_focus_started
signal cell_focus_complete

var ignore_first_room: bool = true
var move_tween_active: bool = false
var node_references: WRSMNodeReferences 

func _physics_process(delta: float) -> void:
	match current_state:
		States.FOLLOW_PLAYER:
			follow_player(delta)
			if ShakeTimer.time_left != 0:
				offset.x = randf_range(-shake_amount, shake_amount)
				offset.y = randf_range(-shake_amount, shake_amount)
		States.CHANGE_CELL:
			pass
	force_update_scroll()

func initialize(wrsm_node_references: WRSMNodeReferences) -> void:
	node_references = wrsm_node_references

func follow_player(delta: float) -> void:
	if not is_changing_cells(): 
		#global_position = lerp(global_position, node_references.player.global_position, delta * follow_rate)
		global_position = node_references.player.global_position + Vector2(0, -12)

func set_limits(top_limit: int, bottom_limit: int, left_limit: int, right_limit: int) -> void:
	limit_top = top_limit
	limit_bottom = bottom_limit
	limit_left = left_limit
	limit_right = right_limit

func clear_limits() -> void:
	limit_top = -10000000
	limit_bottom = 10000000
	limit_left = -10000000
	limit_right = 10000000

func move_to_new_camera_target(new_camera_target: Vector2) -> void:
	if ignore_first_room:
		ignore_first_room = false
	else:
		current_state = States.CHANGE_CELL
		# because global_position will always be at or near the Player here, it must be reset
		# to the center of the current screen in order to prevent snapping
		global_position = get_screen_center_position()
		clear_limits()
		var tween: Tween = get_tree().create_tween()
		@warning_ignore("return_value_discarded")
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		@warning_ignore("return_value_discarded")
		tween.tween_property(self, "global_position", new_camera_target, cell_focus_time).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT) # work checked this, doesn't feel right
		move_tween_active = true
		@warning_ignore("return_value_discarded")
		tween.finished.connect(Callable(self, "_on_cell_change_completed"))
		@warning_ignore("return_value_discarded")
		cell_focus_started.emit()

## NEW
func snap_to_position(target_position: Vector2) -> void:
	clear_limits()
	global_position = target_position

func _on_cell_change_completed() -> void:
	current_state = States.FOLLOW_PLAYER
	move_tween_active = false
	@warning_ignore("return_value_discarded")
	cell_focus_complete.emit()

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




