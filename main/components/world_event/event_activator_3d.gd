extends Area3D
class_name EventActivator3D

## Any node in the SceneTree. 
@export var context: Node
# my typical Player collision layer is 2.
@export_range(1, 32) var collision_mask_override: int = 2

func _init() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_mask_value(collision_mask_override, true)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	_event_activator_entered(body)

func _on_body_exited(body: Node3D) -> void:
	_event_activator_exited(body)

	# OVERRIDE ME #
@warning_ignore("unused_parameter")
func _event_activator_entered(body: Node3D) -> void:
	pass

	# OVERRIDE ME #
@warning_ignore("unused_parameter")
func _event_activator_exited(body: Node3D) -> void:
	pass
