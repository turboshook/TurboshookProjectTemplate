extends Node3D
class_name Node3DPhysicsInterpolater

## Optional. Use only if you want the interpolation anchor scene to be something 
## other than this node's direct parent.
@export var anchor_override: Node3D

var _enabled: bool = true
var _anchor: Node3D 
var _update: bool = false
var _global_transform_previous: Transform3D
var _global_transform_current: Transform3D

func _ready() -> void:
	if not anchor_override: _anchor = get_parent()
	else: _anchor = anchor_override
	set_as_top_level(true)

func _physics_process(_delta: float) -> void:
	if not _enabled: return
	_update = true

func _process(_delta: float) -> void:
	if not _enabled: return
	if _update:
		update_transform()
		_update = false
	
	var interpolation_fraction: float = clamp(Engine.get_physics_interpolation_fraction(), 0, 1)
	global_transform = _global_transform_previous.interpolate_with(
		_global_transform_current,
		interpolation_fraction
	)

func initialize(new_anchor: Node3D) -> void:
	_anchor = new_anchor
	global_transform = _anchor.global_transform
	_global_transform_previous = _anchor.global_transform
	_global_transform_current = _anchor.global_transform

func update_transform() -> void:
	_global_transform_previous = _global_transform_current
	_global_transform_current = _anchor.global_transform

func set_enabled(set_value: bool) -> void:
	_enabled = set_value

func force_update() -> void:
	global_transform = _anchor.global_transform
	_global_transform_current = global_transform
	_global_transform_previous = _global_transform_current
	
