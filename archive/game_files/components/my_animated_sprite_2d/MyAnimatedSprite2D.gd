extends AnimatedSprite2D
class_name MyAnimatedSprite2D

## When [param true], this scene will snap to the rounded [param global_position] of its parent.[br][br] 
## Because this setting directly changes positional properties, any placement adjustments made in-editor 
## to assigned textures should be done using the [param offset] property.
@export var pixel_snap_fix: bool = true
var _parent_node: Node = null

func _ready() -> void:
	if pixel_snap_fix:
		_parent_node = get_parent()
	if !is_playing():
		play()

func _process(_delta: float) -> void:
	if pixel_snap_fix:
		if _parent_node is Node2D or _parent_node is Control:
			global_position = _parent_node.global_position.round()
		else:
			global_position = global_position.round()
