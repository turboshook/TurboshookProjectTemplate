extends Camera2D

#export (float) var follow_rate = 16.0

signal cell_change_started
signal cell_change_complete

var ignore_first_room: bool = true
var changing_cells: bool = false
var Player: CharacterBody2D = null
var WorldRegionReference = ResourceLoader.load("res://game_files/utils/WorldRegionReference.tres")

func _ready() -> void:
	WorldRegionReference.WorldCamera = self
	Player = WorldRegionReference.Player
	#PositionTween = create_tween()

#func _physics_process(delta):
#	disable_camera_limits()

func follow_player(_delta: float) -> void:
	# redundant check, state machine currently does not handle this properly and will be slightly
	# offset from the center of the screen while attempting to follow player for some iterations before
	# the tween starts
	# new tween system does not kick in *immediately* like the Tween node does when you start() it.
	if not is_changing_cells(): 
		#global_position = lerp(global_position, Player.global_position, delta * follow_rate)
		global_position = Player.global_position

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

	### THESE FUNCTIONS ###
	# are intended specifically to interact with a StateMachine in a project that uses my World/Region/Cell system
func is_changing_cells() -> bool:
	return changing_cells

func change_cell(new_camera_target: Vector2) -> void:
	if ignore_first_room:
		ignore_first_room = false
		emit_signal("cell_change_complete")
	else:
		changing_cells = true
		# because global_position will always be at or near the Player here, it must be reset
		# to the center of the current screen in order to prevent snapping
		global_position = get_screen_center_position()
		disable_camera_limits()
		var tween: Tween = get_tree().create_tween()
		# warning-ignore:return_value_discarded
		tween.tween_property(self, "global_position", new_camera_target, .5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT) # work checked this, doesn't feel right
		# warning-ignore:return_value_discarded
		tween.connect("finished",Callable(self,"_on_cell_change_completed"))
		emit_signal("cell_change_started")

func _on_cell_change_completed() -> void:
	emit_signal("cell_change_complete")
	changing_cells = false

func set_camera_position(destination: Vector2) -> void:
	global_position = destination

func get_class() -> String:
	return "PlayerCamera"

func is_class(test_string: String) -> bool:
	return test_string == get_class()

