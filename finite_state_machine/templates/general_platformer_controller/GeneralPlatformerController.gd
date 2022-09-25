extends CharacterBody2D


@export var move_speed: float = 200.0
@export var ground_friction: float = 0.2
@export var max_jumps: int = 2
@export var jump_height: float = 48
@export var jump_time_to_peak: float = .5
@export var jump_time_to_descent: float = .4

# multiply everything here by -1 to account for down being positive in Godot 2D space
@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1
@onready var jump_gravity: float = ((-2.0 * jump_height) / pow(jump_time_to_peak, 2)) * -1
@onready var fall_gravity: float = ((-2.0 * jump_height) / pow(jump_time_to_descent, 2)) * -1

	### PLAYER BODY ###
@onready var Body: Node2D = $Body
@onready var PlayerBodySprite: Sprite2D = $Body/PlayerBodySprite
@onready var WallCheck: RayCast2D = $Body/WallCheck

	### UTILS ###
@onready var PlayerStateMachine: StateMachine = $PlayerStateMachine
@onready var StaticBodyChecks: Node2D = $StaticBodyChecks
@onready var PlayerVisibilityNotifier: VisibleOnScreenNotifier2D = $PlayerVisibilityNotifier
@onready var CoyoteJumpTimer: Timer = $CoyoteJumpTimer
@onready var Animations: AnimationPlayer = $Animations

var spawn_position: Vector2
var jumps_remaining: int = max_jumps
var input_vector: Vector2 = Vector2.ZERO
var bonus_velocity: Vector2 = Vector2.ZERO
var horizontal_bonus_velocity: float = 0
var vertical_bonus_velocity: float = 0
var snap_vector: Vector2 = Vector2.DOWN * 4
var floor_normal: Vector2 = Vector2.UP


func _ready() -> void:
	spawn_position = global_position
	CoyoteJumpTimer.stop()

func get_horizontal_velocity() -> void:
	var right_action_strength: float = Input.get_action_strength("move_right")
	var left_action_strength: float = Input.get_action_strength("move_left")
	input_vector.x = (right_action_strength - left_action_strength) * move_speed
	# THIS WAS CAUSING THAT CRAZY AIR ACCELERATION BUG
	# if the Player inputs a direction opposite the horizontal_velocity_bonus, taking the
	# min/max of that respective input results in rapid acceleration
	#if Input.is_action_pressed("MOVE_right"):
	#	velocity.x = min(velocity.x + MOVE_acceleration, move_speed)
	#elif Input.is_action_pressed("MOVE_left"):
	#	velocity.x = max(velocity.x - MOVE_acceleration, -move_speed)

func has_horizontal_input() -> bool:
	return Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left")

func handle_body_face() -> void:
	if sign(input_vector.x) != 0:
		Body.scale.x = sign(input_vector.x)
		WallCheck.force_raycast_update()

func look_for_floor():
	if is_on_floor():
		CoyoteJumpTimer.stop()
	else:
		CoyoteJumpTimer.start()

func apply_friction() -> void:
	velocity.x = lerp(velocity.x, 0.0, ground_friction)

func has_jumps_remaining() -> bool:
	return jumps_remaining > 0

func jump() -> void:
	input_vector.y = jump_velocity
	jumps_remaining -= 1

func get_horizontal_bonus_velocity():
	for ray in StaticBodyChecks.get_children():
		var collider = ray.get_collider()
		if collider == null:
			continue
		if !(collider is StaticBody2D):
			continue
		if sign(collider.constant_linear_velocity.x) == sign(input_vector.x):
			horizontal_bonus_velocity = collider.constant_linear_velocity.x

func clear_horizontal_bonus_velocity():
	horizontal_bonus_velocity = 0

func apply_air_drag() -> void:
	pass # might not add? idk

func below_half_jump_height() -> bool:
	return velocity.y < jump_velocity/2

func disable_snap_vector() -> void:
	snap_vector = Vector2.ZERO

func enable_snap_vector() -> void:
	snap_vector = Vector2.DOWN * 4

func is_touching_wall() -> bool:
	return WallCheck.is_colliding() and sign(input_vector.x) == sign(Body.scale.x)

func wall_jump() -> void:
	input_vector.y = jump_velocity
	input_vector.x = move_speed * -(Body.scale.x)

func apply_gravity(delta: float) -> void:
	input_vector.y += _get_gravity() * delta
	input_vector.y = min(input_vector.y, fall_gravity)

func _get_gravity() -> float:
	if input_vector.y < 0.0:
		return jump_gravity
	else:
		return fall_gravity

func apply_wall_slide_gravity(delta) -> void:
	input_vector.y += _get_gravity() * delta
	input_vector.y = min(input_vector.y, fall_gravity / 8)

func apply_velocity() -> void:
	bonus_velocity.x = horizontal_bonus_velocity
	bonus_velocity.y = vertical_bonus_velocity
	set_velocity(input_vector + bonus_velocity)
	# TODOConverter40 looks that snap in Godot 4.0 is float, not vector like in Godot 3 - previous value `snap_vector`
	set_up_direction(floor_normal)
	move_and_slide()
	velocity = velocity

func _play_footstep_sound() -> void:
	pass
#	var index = round(randf_range(0, footstep_sounds.size() - 1))
#	AudioManager.play(footstep_sounds[index])

func is_changing_cell() -> bool:
	if WorldRegion.WorldCamera == null:
		return false
	else:
		return WorldRegion.WorldCamera.is_changing_cells()

func text_layer_active() -> bool:
	return false
	#if MainInstances.TextLayer == null:
	#	return false
	#else:
	#	return MainInstances.TextLayer.is_open()

func out_of_bounds() -> bool:
	return not PlayerVisibilityNotifier.is_on_screen()

# CALLED BY UTILS WHEN CHANGING LEVELS
func _reset(new_spawn_position: Vector2) -> void:
	spawn_position = new_spawn_position
	global_position = spawn_position
	Animations.play("idle")
	Body.scale.x = 1

func respawn() -> void:
	global_position = spawn_position
	#MainInstances.WorldCamera.shake()
	#AudioManager.play(Sounds.player_death)
	#Global.player_deaths += 1

func _on_Hurtbox_area_entered(area):
	if "Hitbox" in area.name:
		respawn()

func is_class(test_class: String) -> bool:
	return test_class == "PlayerCharacter"















