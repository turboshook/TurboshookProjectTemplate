extends Marker2D
class_name CameraTarget

func get_class() -> String:
	return "CameraTarget"

func is_class(test_string: String) -> bool:
	return test_string == get_class()
