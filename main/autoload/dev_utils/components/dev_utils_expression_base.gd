extends Node
class_name DevUtilsExpressionBase

const GLOBAL_NAMES: PackedStringArray = [
	"Engine",
	"ProjectSettings",
	"Time",
	"DisplayServer"
]

func get_global_classes() -> Array:
	return [
		Engine,
		ProjectSettings,
		Time,
		DisplayServer
	]

var test: String = "This is an example member variable in DevUtilsExpressionBase!"

func update_test(new_string: String) -> void:
	test = new_string
