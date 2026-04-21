extends Area3D
class_name EventActivator3D

## Any node in the SceneTree. 
@export var context: Node

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
