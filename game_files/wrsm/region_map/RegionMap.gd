@tool
extends Node2D
class_name RegionMap

var region_name: String

@export var build_mapping_file: bool = false:
	get:
		return build_mapping_file
	set(mod_value):
		_build_mapping_file()

func _ready() -> void:
	region_name = str(name)

func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("menu") or event.is_action_pressed("interact"):
	if event.is_action_pressed("jump"):
		_build_mapping_file()

func _build_mapping_file() -> void:
	
	if get_child_count() == 0:
		print("NO CELLS")
		return
	
	# structure
	# region_name {
	#   region_data {
	#     key: value
	#   }
	#   region_cells {
	#     cell_filepath: offset_vector
	#   }
	# }
	
	print("writing to mapping dictionary")
	var region_full: Dictionary = {}
	var region_data: Dictionary = {
		"custom_data_field": null
	}
	var region_cell_mapping: Dictionary = {}
	
	print("writing region data")
	#region_data["additional_data_key"] = some data important to you personally
	
	print("writing RegionCell mappings")
	for cell in get_children():
		region_cell_mapping[cell.name] = cell.get_adjacent_cells()
	
	print("combining to region_full")
	region_full["region_cell_mapping"] = region_cell_mapping
	region_full["region_data"] = region_data
	
	print("copying current world mapping data")
	# manipulate a copy of this mapping file as a dictionary so we can append region maps/overwrite old ones
	var current_world_data: Dictionary = WorldRegion.get_world_data().duplicate()
	var updated_world_data: Dictionary = current_world_data
	updated_world_data[region_name] = region_full
	
	print("appending to/overwriting mapping file")
	#var world_mapping_file: FileAccess = File.new()
	# https://github.com/godotengine/godot/issues/6886
	# GDScript export variables do not work correctly for tool scripts that access autoloads
	# this has been a bug for 5 years
	#world_mapping_file.open(RegionMap.world_data_path, File.WRITE) 
	# workaround
	var world_data_path: String = _get_world_data_path()
	var world_mapping_file: FileAccess = FileAccess.open(world_data_path, FileAccess.WRITE) 
	world_mapping_file.store_line(JSON.new().stringify(updated_world_data))
	
	print("mapping file write complete")
	#world_mapping_file.close()

func _get_world_data_path() -> String:
	# https://godotengine.org/qa/65885/relative-paths-available-resourceloader-load-like-preload
	var final_path: String
	var parent_dir: String = get_script().resource_path.get_base_dir()
	var last_forward_slash_index: int = parent_dir.rfindn("/")
	var module_root_dir: String = parent_dir.left(last_forward_slash_index)
	final_path = module_root_dir + "/world_data/world_data.json"
	return final_path

func get_class() -> String:
	return "RegionMap"

func is_class(test_string: String) -> bool:
	return test_string == get_class()

