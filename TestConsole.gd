@tool
extends Node

func _ready() -> void:
	pass
	#test()

func test() -> void:
	var final_path: String 
	var parent_dir: String = get_script().resource_path.get_base_dir()
	var last_forward_slash_index: int = parent_dir.rfindn("/")
	var module_root_dir: String = parent_dir.left(last_forward_slash_index)
	final_path = module_root_dir + "/world_data/"
	print(parent_dir)
