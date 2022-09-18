@tool
extends Node2D
class_name RegionMap

@export var region_name: String = "RegionName"
@export var region_encounter_table: Resource
@export var build_mapping_file: bool = false:
	get:
		return build_mapping_file
	set(mod_value):
		_build_mapping_file()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu") or event.is_action_pressed("interact"):
		_build_mapping_file()

func _build_mapping_file() -> void:
	
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
		"encounter_table": null
	}
	var region_cell_mapping: Dictionary = {}
	
	print("writing region data")
	region_data["encounter_table"] = region_encounter_table.get_path()
	
	print("writing RegionCell mappings")
	for cell in get_children():
		#mapping_data[cell.name] = cell.get_adjacent_cells()
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
	# https://godotengine.org/qa/13830/creating-a-new-json-file-rather-than-just-saving-to-one
	# when a file is saved to using File.WRITE, and it does not exist, it is created
	var world_mapping_file: File = File.new()
	# warning-ignore:return_value_discarded
	world_mapping_file.open("res://game_files/world/map_files/world_data.json", File.WRITE) 
	world_mapping_file.store_line(JSON.new().stringify(updated_world_data))
	
	print("mapping file write complete")
	world_mapping_file.close()


func get_class() -> String:
	return "RegionMap"

func is_class(test_string: String) -> bool:
	return test_string == get_class()

