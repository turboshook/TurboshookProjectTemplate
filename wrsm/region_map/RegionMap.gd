@tool
extends Node2D
class_name RegionMap

var region_key: String

@export var region_key_override: String = ""
@export var build_mapping_file: bool = false:
	get:
		return build_mapping_file
	set(mod_value):
		_build_mapping_file()

func _ready() -> void:
	if region_key_override == "":
		region_key = str(name)
	else:
		region_key = region_key_override

func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("menu") or event.is_action_pressed("interact"):
	if event.is_action_pressed("ui_accept"):
		_build_mapping_file()

func _build_mapping_file() -> void:
	
	if get_child_count() == 0:
		print("NO CELLS")
		return
	
	var world_data_dictionary: WRSMWorldDataDictionary = ResourceLoader.load(
		"res://game_files/wrsm/resources/WRSMWorldDataDictionary.tres"
	)
	
	print(" # writing data for region ", region_key)
	var region_registry: Dictionary = world_data_dictionary.WORLD_REGION_REGISTRY.duplicate(true)
	print(" # ")
	
	for cell_layer in get_children():
		if !("Layer" in cell_layer.name):
			continue
	
		for cell in cell_layer.get_children():
			print(" #   current cell: ", cell.name)
			
			var region_cell_registry: Dictionary = world_data_dictionary.REGION_CELL_REGISTRY.duplicate(true)
			region_cell_registry["global_position"] = var_to_str(cell.global_position)
			var adjacent_cell_scene_paths: Array[String] = _get_adjacent_cell_scene_paths(cell)
			region_cell_registry["adjacent_cell_scene_paths"] = adjacent_cell_scene_paths
			print(" #     writing ", adjacent_cell_scene_paths.size(), " adjacent cell(s)")
			
			var persistent_scene_count: int = 0
			for scene in cell.persistent_scene_container.get_children():
				var persistent_scene_registry: Dictionary = world_data_dictionary.PERSISTENT_SCENE_REGISTRY.duplicate(true)
				persistent_scene_registry["scene_name"] = scene.name
				persistent_scene_registry["scene_file_path"] = scene.get_scene_file_path()
				persistent_scene_registry["global_position"] = var_to_str(scene.global_position)
				region_cell_registry["persistent_scenes"].append(persistent_scene_registry)
				persistent_scene_count += 1
			print(" #     writing ", persistent_scene_count, " persistent scene(s)")
			
			print(" #   writing region cell registry to region")
			region_registry["region_cells"][cell.name] = region_cell_registry
			
			print(" # ")
			#await get_tree().physics_frame # just to avoid print overflow
		
	print(" # append/overwrite of world_data.json")
	# manipulate a copy of this mapping file as a dictionary so we can append region maps/overwrite old ones
	
	var updated_world_data: Dictionary = _get_world_data().duplicate()
	updated_world_data[region_key] = region_registry
	
	#var world_mapping_file: FileAccess = File.new()
	# https://github.com/godotengine/godot/issues/6886
	# GDScript export variables do not work correctly for tool scripts that access autoloads
	# this has been a bug for 5 years
	#world_mapping_file.open(RegionMap.world_data_path, File.WRITE) 
	# workaround
	
	var world_data_write: FileAccess = FileAccess.open(_get_world_data_path(), FileAccess.WRITE) 
	world_data_write.store_line(JSON.new().stringify(updated_world_data))
	world_data_write.close()
	
	print(" # write complete")

func _get_adjacent_cell_scene_paths(reference_cell: RegionCell) -> Array[String]:
	var adjacent_cells: Array[String] = []
	for cell_detector in reference_cell.region_cell_detectors.get_children():
		var overlapping_areas: Array = cell_detector.get_overlapping_areas()
		if overlapping_areas.size() == 0:
			continue
		for colliding_cell_detector in overlapping_areas:
			if _cells_on_same_layer(cell_detector.get_parent_cell(), colliding_cell_detector.get_parent_cell()):
				adjacent_cells.append(colliding_cell_detector.get_parent_cell().get_scene_file_path())
	return adjacent_cells

func _cells_on_same_layer(test_cell_0: RegionCell, test_cell_1: RegionCell) -> bool:
	return test_cell_0.get_parent() == test_cell_1.get_parent()

func _get_world_data() -> Dictionary:
	var mapping: Dictionary
	var file: FileAccess = FileAccess.open(_get_world_data_path(), FileAccess.READ)
	if file.get_as_text() != "":
		var test_json_conv = JSON.new()
		@warning_ignore("return_value_discarded")
		test_json_conv.parse(file.get_as_text())
		mapping = test_json_conv.get_data()
	return mapping

func _get_world_data_path() -> String:
	# https://godotengine.org/qa/65885/relative-paths-available-resourceloader-load-like-preload
	var final_path: String
	var parent_dir: String = get_script().resource_path.get_base_dir()
	var last_forward_slash_index: int = parent_dir.rfindn("/")
	var module_root_dir: String = parent_dir.left(last_forward_slash_index)
	final_path = module_root_dir + "/world_data/world_data.json"
	return final_path


























