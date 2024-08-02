extends Node2D
class_name WRSMWorld

@onready var loaded_region_cells: Node2D = $LoadedRegionCells
@onready var player_container: Node2D = $PlayerContainer
@onready var world_camera: WorldCamera = $WorldCamera

var world_data: Dictionary = {}
var region_key: String = ""
var node_references: WRSMNodeReferences
var world_data_dictionary: WRSMWorldDataDictionary

#signal world_process_changed
signal cell_change_initiated(target_cell_file_path: String, target_cell_changer_id: String)
signal cell_change_completed

func _ready() -> void:
	
	world_data = _get_world_data()
	
	var starting_cell: RegionCell = loaded_region_cells.get_child(0) 
	region_key = starting_cell.get_region_key()
	
	node_references = ResourceLoader.load(
		get_script().resource_path.get_base_dir() + "/resources/WRSMNodeReferences.tres"
	)
	node_references.loaded_region_cells = loaded_region_cells
	node_references.current_cell = starting_cell
	node_references.player = player_container.get_child(0)
	node_references.world_camera = world_camera
	
	world_data_dictionary = ResourceLoader.load(
		get_script().resource_path.get_base_dir() + "/resources/WRSMWorldDataDictionary.tres"
	)
	
	_initialize_cell(starting_cell)
	
	world_camera.initialize(node_references)
	
	var cell_position_adjust: Vector2 = str_to_var(world_data[region_key]["region_cells"][starting_cell.name]["global_position"])
	starting_cell.global_position += cell_position_adjust
	node_references.player.global_position += cell_position_adjust

func _get_world_data() -> Dictionary:
	var mapping: Dictionary
	var file: FileAccess = FileAccess.open(get_script().resource_path.get_base_dir() + "/world_data/world_data.json", FileAccess.READ)
	if file.get_as_text() != "":
		var test_json_conv = JSON.new()
		@warning_ignore("return_value_discarded")
		test_json_conv.parse(file.get_as_text())
		mapping = test_json_conv.get_data()
	return mapping

func _instance_cell_in_region(cell_packed: PackedScene, target_position: Vector2) -> RegionCell:
	if node_references.loaded_region_cells == null:
		return null
	var cell_instance: RegionCell = cell_packed.instantiate()
	node_references.loaded_region_cells.call_deferred("add_child", cell_instance)
	cell_instance.global_position = target_position
	_initialize_cell(cell_instance)
	return cell_instance

func _initialize_cell(cell_instance: RegionCell) -> void:
	cell_instance.node_references = node_references
	cell_instance.player_entered.connect(_on_player_entered_cell)
	for cell_changer in cell_instance.get_node("CellChangers").get_children():
		cell_changer.activated.connect(_on_cell_change_activated)

func clear_loaded_cells() -> void:
	for child in node_references.loaded_region_cells.get_children():
		node_references.loaded_region_cells.remove_child(child)
		child.queue_free()

func _on_player_entered_cell(entered_cell: RegionCell) -> void:
	focus_cell(entered_cell)

func focus_cell(new_cell: RegionCell) -> void:
	
	#if new_cell != node_references.current_cell:
		
	#world_process = false
	get_tree().paused = true
	
	#var adjacent_cells: Dictionary = cell_mapping[new_cell.name]
	#adjacent_cells[new_cell.scene_file_path] = var_to_str(Vector2.ZERO)
	_add_adjacent_cells(new_cell)
	var new_camera_target: Vector2 = new_cell.get_new_camera_target(node_references.player.global_position)
	#node_references.world_camera.move_to_new_camera_target(new_camera_target)
	#if node_references.world_camera.is_changing_cells():
		#await node_references.world_camera.cell_focus_complete
	node_references.world_camera.snap_to_position(new_camera_target)
	new_cell.activate() # updates node_references.current_cell, sets WorldCamera limits
	_free_distant_cells(new_cell)
	
	#world_process = true
	get_tree().paused = false

func _on_cell_change_activated(activated_cell_changer: CellChanger) -> void:
	var target_cell_file_path: String = activated_cell_changer.target_cell_file_path
	var target_cell_changer_id: String = activated_cell_changer.id
	cell_change_initiated.emit(target_cell_file_path, target_cell_changer_id)

func change_cell(target_cell_file_path: String, target_cell_changer_id: String) -> void:
	
	var target_cell_name: String = _get_cell_name_from_filepath(target_cell_file_path)
	if !world_data[region_key]["region_cells"].has(target_cell_name):
		printerr("WorldRegion @ change_cell(): activated_cell_changer's target_cell_path of '", target_cell_file_path, "' resulted target cell name '", target_cell_name ,"', which is not present in world_data.")
		return
	
	clear_loaded_cells()
	var target_cell_global_position: Vector2 = str_to_var(world_data[region_key]["region_cells"][target_cell_name]["global_position"])
	var target_cell_instance: RegionCell = _instance_cell_in_region(
		load(target_cell_file_path), 
		target_cell_global_position
	)
	await target_cell_instance.ready # because we have to instance RegionCells in the above call using call_deferred()
	
	var target_cell_changer: CellChanger = target_cell_instance.get_corresponding_cell_changer(target_cell_changer_id)
	var player_spawn_position: Vector2 = target_cell_changer.get_player_target_position()
	node_references.player.global_position = player_spawn_position 
	region_key = target_cell_instance.get_region_key()
	cell_change_completed.emit() # is this necessary?

func _add_adjacent_cells(reference_cell: RegionCell) -> void:
	var adjacent_cell_scene_file_paths: Array = world_data[region_key]["region_cells"][reference_cell.name]["adjacent_cell_scene_paths"]
	for adjacent_cell_scene_file_path in adjacent_cell_scene_file_paths:
		var adjacent_cell_name: String = _get_cell_name_from_filepath(adjacent_cell_scene_file_path)
		
		if !world_data[region_key]["region_cells"].has(adjacent_cell_name):
			printerr("WorldRegion @ _add_adjacent_cells(): attempted to instance adjacent RegionCell ", adjacent_cell_name, " but scene is not present in world_data.json.")
			continue
		
		if not node_references.loaded_region_cells.has_node(adjacent_cell_name):
			var adjacent_cell_global_position: Vector2 = str_to_var(world_data[region_key]["region_cells"][adjacent_cell_name]["global_position"])
			
			_instance_cell_in_region(
				load(adjacent_cell_scene_file_path), 
				adjacent_cell_global_position
			)

func _get_cell_name_from_filepath(cell_filepath: String) -> String:
	var last_forward_slash_index: int = cell_filepath.rfindn("/") + 1
	var cell_name: String = (cell_filepath.substr(last_forward_slash_index, -1)) # remove leading filepath
	cell_name = cell_name.left(cell_name.length() - 5) # remove .tscn extension
	return cell_name

func _free_distant_cells(reference_cell: RegionCell) -> void:
	var adjacent_cell_scene_file_paths: Array = world_data[region_key]["region_cells"][reference_cell.name]["adjacent_cell_scene_paths"]
	# append reference_cell's path because a cell will never be adjacent to itself and we don't want
	# to delete the room the Player just walked into or spawned in.
	adjacent_cell_scene_file_paths.append(reference_cell.get_scene_file_path())
	for cell in node_references.loaded_region_cells.get_children():
		if not adjacent_cell_scene_file_paths.has(cell.scene_file_path):
			cell.queue_free()

func persistent_scene_saved(region_cell: RegionCell, scene: Node2D) -> bool:
	var current_cell_persistent_scenes: Array = world_data[region_cell.get_region_key()]["region_cells"][region_cell.name]["persistent_scenes"]
	for index in range(current_cell_persistent_scenes.size()):
		if scene.name == current_cell_persistent_scenes[index]["scene_name"]:
			return true
	return false

func save_persistent_scene(region_cell: RegionCell, scene: Node2D) -> void:
	var persistent_scene_registry: Dictionary = world_data_dictionary.PERSISTENT_SCENE_REGISTRY.duplicate(true)
	persistent_scene_registry["scene_name"] = scene.name
	persistent_scene_registry["scene_file_path"] = scene.get_scene_file_path()
	persistent_scene_registry["global_position"] = var_to_str(scene.global_position)
	world_data[region_cell.get_region_key()]["region_cells"][region_cell.name]["persistent_scenes"].append(persistent_scene_registry) 

func delete_persistent_scene(region_cell: RegionCell, scene: Node2D) -> void:
	var persistent_scenes_iteration_array: Array = world_data[region_cell.get_region_key()]["region_cells"][region_cell.name]["persistent_scenes"].duplicate()
	for index in range(persistent_scenes_iteration_array.size()):
		var persistent_scene_registry: Dictionary = persistent_scenes_iteration_array[index]
		if scene.name == persistent_scene_registry["scene_name"]:
			world_data[region_cell.get_region_key()]["region_cells"][region_cell.name]["persistent_scenes"].remove_at(index)

func get_persistent_scenes(region_cell: RegionCell) -> Array:
	return world_data[region_cell.get_region_key()]["region_cells"][region_cell.name]["persistent_scenes"]
