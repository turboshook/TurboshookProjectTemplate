# warning-ignore-all:unused_argument
extends StateMachine

func _ready():
	add_state("idle")
	add_state("move")
	add_state("crouch")
	add_state("stand")
	add_state("jump")
	add_state("fall")
	add_state("wall_slide")
	add_state("wall_jump")
	add_state("grab_forward")
	add_state("throw_forward")
	add_state("grab_up")
	add_state("throw_up")
	add_state("grab_down")
	add_state("throw_down")
	add_state("hold")
	add_state("change_cell")
	add_state("dead")
	call_deferred("set_state", states.idle)

func _state_logic(delta):
	if state == states.idle:
		parent.get_horizontal_velocity()
		parent.apply_friction()
		parent.apply_velocity() # necessary for moving platforms to work
	elif state == states.move:
		parent.get_horizontal_velocity()
		parent.handle_body_face()
		parent.look_for_floor() # check for walking unchecked ledge, manages CoyoteJumpTimer
		parent.apply_velocity()
	elif state == states.crouch:
		parent.apply_friction()
		parent.apply_velocity() # necessary for moving platforms to work
	elif state == states.stand:
		parent.apply_friction()
		parent.apply_velocity() # necessary for moving platforms to work
	elif state == states.jump:
		parent.get_horizontal_velocity()
		parent.handle_body_face()
		parent.apply_gravity(delta)
		if parent.is_on_ceiling(): # don't get stuck checked ceilings
			parent.input_vector.y = 0
		if Input.is_action_just_released("jump"): # truly variable jump height
			parent.input_vector.y = 0
		parent.apply_velocity()
	elif state == states.fall:
		parent.get_horizontal_velocity()
		parent.handle_body_face()
		parent.apply_gravity(delta)
		parent.apply_velocity()
	elif state == states.wall_slide:
		parent.get_horizontal_velocity()
		parent.apply_wall_slide_gravity(delta)
		parent.apply_velocity()
	elif state == states.wall_jump:
		# regain horizontal control of Player once half of wall jump force is expended
		# until this is triggered, the input_vector defined in wall_jump() will not be overwritten
		if parent.input_vector.y > parent.jump_velocity * 0.5:
			parent.get_horizontal_velocity()
		parent.handle_body_face()
		parent.apply_gravity(delta)
		parent.apply_velocity()
		if parent.is_on_ceiling():
			parent.input_vector.y = 0
	elif state == states.grab_forward:
		if not parent.is_on_floor():
			parent.get_horizontal_velocity()
			parent.apply_gravity(delta)
		if parent.is_on_ceiling(): # don't get stuck checked ceilings
			parent.input_vector.y = 0
		if Input.is_action_just_released("jump"): # truly variable jump height
			parent.input_vector.y = 0
		parent.apply_velocity()
	elif state == states.grab_up:
		if not parent.is_on_floor():
			parent.get_horizontal_velocity()
			parent.apply_gravity(delta)
		parent.apply_velocity()
	elif state == states.grab_down:
		if not parent.is_on_floor():
			parent.get_horizontal_velocity()
			parent.apply_gravity(delta)
		parent.apply_velocity()
	elif state == states.change_cell:
		pass
	#elif state == states.text_layer:
	#	pass
	elif state == states.dead:
		pass

func _get_transition():
	if state == states.idle:
		if parent.has_horizontal_input():
			return states.move
		elif Input.is_action_just_pressed("crouch"):
			return states.crouch
		elif Input.is_action_just_pressed("jump"):
			return states.jump
		elif Input.is_action_just_pressed("grab") and parent.GrabCooldownTimer.is_stopped():
			return states.grab_forward
		elif !parent.is_on_floor():
			return states.fall
		elif parent.is_changing_cell():
			return states.change_cell
	elif state == states.move:
		if not parent.has_horizontal_input():
			return states.idle
		elif Input.is_action_just_pressed("crouch"):
			return states.crouch
		elif Input.is_action_just_pressed("jump") and parent.CoyoteJumpTimer.is_stopped():
			return states.jump
		elif Input.is_action_just_pressed("grab") and parent.GrabCooldownTimer.is_stopped():
			return states.grab_forward
		elif !parent.is_on_floor():
			return states.fall
		elif parent.is_changing_cell():
			return states.change_cell
	elif state == states.crouch:
		if Input.is_action_just_released("crouch"):
			return states.stand
		elif Input.is_action_just_pressed("jump") and parent.CoyoteJumpTimer.is_stopped():
			return states.jump
		elif parent.is_changing_cell():
			return states.change_cell
	elif state == states.stand:
		if not parent.Animations.is_playing():
			return states.idle
		elif parent.has_horizontal_input():
			return states.move
		elif Input.is_action_just_pressed("crouch"):
			return states.crouch
		elif Input.is_action_just_pressed("jump") and parent.CoyoteJumpTimer.is_stopped():
			return states.jump
		elif parent.is_changing_cell():
			return states.change_cell
	elif state == states.jump:
		if parent.input_vector.y >= 0:
			return states.fall
		elif parent.is_touching_wall():
			return states.wall_slide
		elif Input.is_action_just_pressed("jump") and parent.has_jumps_remaining():
			return states.jump
		elif Input.is_action_just_pressed("grab") and parent.GrabCooldownTimer.is_stopped():
			return states.grab_forward
		elif parent.is_changing_cell():
			return states.change_cell
	elif state == states.fall:
		if parent.is_on_floor():
			return states.idle
		elif parent.is_touching_wall():
			return states.wall_slide
		elif Input.is_action_just_pressed("jump") and parent.has_jumps_remaining():
			return states.jump
		elif Input.is_action_just_pressed("grab") and parent.GrabCooldownTimer.is_stopped():
			return states.grab_forward
		elif parent.is_changing_cell():
			return states.change_cell
		elif parent.out_of_bounds():
			return states.dead
	elif state == states.wall_slide:
		if parent.is_on_floor():
			return states.idle
		if not parent.is_touching_wall():
			return states.fall
		elif Input.is_action_just_pressed("jump"):
			return states.wall_jump
		elif parent.is_changing_cell():
			return states.change_cell
	elif state == states.wall_jump:
		if parent.is_on_floor():
			return states.idle
		elif parent.is_touching_wall():
			return states.wall_slide
		elif Input.is_action_just_pressed("jump") and parent.jumps_remaining > 0:
			return states.jump
		elif Input.is_action_just_pressed("grab") and parent.GrabCooldownTimer.is_stopped():
			return states.grab_forward
		elif parent.input_vector.y > 0:
			return states.fall
		elif parent.is_changing_cell():
			return states.change_cell
	elif state == states.grab_forward:
		if not parent.Animations.is_playing():
			if parent.is_on_floor():
				return states.idle
			else:
				return states.fall
	elif state == states.grab_up:
		if not parent.Animations.is_playing():
			if parent.is_on_floor():
				return states.idle
			else:
				return states.fall
	elif state == states.grab_down:
		if not parent.Animations.is_playing():
			if parent.is_on_floor():
				return states.idle
			else:
				return states.fall
	elif state == states.change_cell:
		if not parent.is_changing_cell():
			return states.idle
	elif state == states.dead:
		return states.idle

@warning_ignore(unused_parameter)
func _enter_state(new_state, old_state):
	if state == states.idle:
		parent.Animations.play("Idle")
		parent.enable_snap_vector()
		parent.clear_horizontal_bonus_velocity()
		parent.input_vector.y = 0
		parent.jumps_remaining = parent.max_jumps
		if [states.jump, states.fall, states.wall_jump].has(old_state):
			parent._play_footstep_sound()
	elif state == states.move:
		parent.Animations.play("Move")
	elif state == states.crouch:
		parent.input_vector.x = 0
		parent.Animations.play("Crouch")
	elif state == states.stand:
		parent.input_vector.x = 0
		parent.Animations.play("Stand")
	elif state == states.jump:
		parent.Animations.play("Jump")
		parent.disable_snap_vector()
		parent.get_horizontal_bonus_velocity()
		parent.jump()
		#AudioManager.play(Sounds.player_jump)
	elif state == states.fall:
		parent.Animations.play("Fall")
		if old_state == states.move:
			parent.jumps_remaining -= 1
	elif state == states.wall_slide:
		parent.Animations.play("WallSlide")
		parent.clear_horizontal_bonus_velocity()
		parent._play_footstep_sound()
	elif state == states.wall_jump:
		parent.Animations.play("Jump")
		parent.wall_jump()
		#AudioManager.play(Sounds.player_jump)
	elif state == states.grab_forward:
		if parent.is_on_floor():
			parent.input_vector.x = 0
		parent.Animations.play("GrabForward")
		parent.GrabCooldownTimer.start()
	elif state == states.grab_up:
		if parent.is_on_floor():
			parent.input_vector.x = 0
		parent.Animations.play("GrabUp")
		parent.GrabCooldownTimer.start()
	elif state == states.grab_down:
		if parent.is_on_floor():
			parent.input_vector.x = 0
		parent.Animations.play("GrabDown")
		parent.GrabCooldownTimer.start()
	elif state == states.change_cell:
		parent.Animations.play("Idle")
	elif state == states.dead:
		parent.respawn()

@warning_ignore(unused_parameter)
func _exit_state(old_state, new_state):
	if state == states.idle:
		pass














 
