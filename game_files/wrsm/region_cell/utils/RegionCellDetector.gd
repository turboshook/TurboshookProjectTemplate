extends Area2D
class_name RegionCellDetector

func get_parent_cell() -> Node2D:
	# get_parent().get_parent().get_parent()
	var parent_cell: Node2D = get_node("../../../")
	return parent_cell

func get_parent_cell_position(relative_to):
	return get_parent_cell().global_position - relative_to

func get_class() -> String:
	return "RegionCellDetector"

func is_class(test_class: String) -> bool:
	return test_class == get_class()
