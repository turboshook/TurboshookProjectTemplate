extends Node

var world_data_path: String = ""
var world_data: Dictionary = {}
var region_key: String = ""
var cell_mapping: Dictionary = {}
var region_data: Dictionary = {}

var node_references: WRSMNodeReferences

signal world_process_changed

var world_process: bool = false: 
	get:
		return world_process
	set(new_value):
		world_process = new_value
		world_process_changed.emit()

func _ready() -> void:
	node_references = ResourceLoader.load(get_wrsm_resources_path() + "/NodeReferences.tres")

func initialize_world_data(wrsm_world_scene: Node2D) -> void:
	world_data_path = get_world_data_path()
	world_data = get_world_data()
	
	node_references = ResourceLoader.load(get_wrsm_resources_path() + "/NodeReferences.tres")
	node_references.world = wrsm_world_scene
	node_references.loaded_region_cells = wrsm_world_scene.loaded_region_cells
	node_references.player = wrsm_world_scene.player_container.get_child(0)
	node_references.world_camera = wrsm_world_scene.world_camera
	
	region_key = node_references.loaded_region_cells.get_child(0).get_region_key() # ONLY ONE RegionCell can be instanced in loaded_region_cells on startup, or this breaks. Cannot think of workaround for now.
	cell_mapping = world_data[region_key]["region_cell_mapping"]
	region_data = world_data[region_key]["region_data"]
	
	wrsm_world_scene.tree_exiting.connect(_clear_world_data)
	
	world_process = true

func _clear_world_data() -> void:
	world_data_path = ""
	world_data = {}
	
	node_references.world = null
	node_references.loaded_region_cells = null
	node_references.current_cell = null # cleared here but NOT SET in above initialization function
	node_references.player = null
	node_references.world_camera = null
	
	region_key = ""
	cell_mapping = {}
	region_data = {}
	
	world_process = false

func update_region(new_region_cell: RegionCell) -> void:
	region_key = new_region_cell.get_region_key()
	cell_mapping = world_data[region_key]["region_cell_mapping"]
	region_data = world_data[region_key]["region_data"]

func get_module_path() -> String:
	# https://godotengine.org/qa/65885/relative-paths-available-resourceloader-load-like-preload
	var parent_dir: String = get_script().resource_path.get_base_dir()
	var last_forward_slash_index: int = parent_dir.rfindn("/")
	var module_root_dir: String = parent_dir.left(last_forward_slash_index)
	return module_root_dir

func get_wrsm_resources_path() -> String:
	return get_module_path() + "/resources"

func get_world_data_path() -> String:
	var final_path: String
	final_path = get_module_path() + "/world_data/world_data.json"
	return final_path

func get_world_data() -> Dictionary:
	var mapping: Dictionary
	var file: FileAccess = FileAccess.open(world_data_path, FileAccess.READ)
	if file.get_as_text() != "":
		var test_json_conv = JSON.new()
		@warning_ignore("return_value_discarded")
		test_json_conv.parse(file.get_as_text())
		mapping = test_json_conv.get_data()
	return mapping

func instance_cell_in_region(cell_packed: PackedScene, target_position: Vector2) -> RegionCell:
	if node_references.loaded_region_cells == null:
		return null
	var cell_instance: RegionCell = cell_packed.instantiate()
	node_references.loaded_region_cells.call_deferred("add_child", cell_instance)
	cell_instance.global_position = target_position
	return cell_instance

func clear_loaded_cells() -> void:
	for child in node_references.loaded_region_cells.get_children():
		node_references.loaded_region_cells.remove_child(child)
		child.queue_free()

func focus_cell(new_cell: RegionCell) -> void:
	if new_cell != node_references.current_cell:
		
		world_process = false
		
		var adjacent_cells: Dictionary = cell_mapping[new_cell.name]
		adjacent_cells[new_cell.scene_file_path] = var_to_str(Vector2.ZERO)
		_add_adjacent_cells(new_cell, adjacent_cells)
		var new_camera_target: Vector2 = new_cell.get_new_camera_target(node_references.player.global_position)
		#node_references.world_camera.move_to_new_camera_target(new_camera_target)
		#if node_references.world_camera.is_changing_cells():
			#await node_references.world_camera.cell_focus_complete
		node_references.world_camera.snap_to_position(new_camera_target)
		new_cell.activate() # updates node_references.current_cell
		_free_distant_cells(adjacent_cells)
		
		world_process = true

func change_cell(target_cell_path: String, target_cell_changer_id: String) -> void:
	
	world_process = false
	
	# OPTIONAL: SceneTransitionManager as autoload #
	SceneTransitionManager.fade_out(SceneTransitionManager.TransitionTypes.FADE)
	await SceneTransitionManager.fade_out_complete
	
	var target_cell_position: Vector2 = node_references.current_cell.global_position
	clear_loaded_cells()
	var target_cell_instance: RegionCell = instance_cell_in_region(load(target_cell_path), target_cell_position)
	await target_cell_instance.ready # because we have to instance RegionCells in the above call using call_deferred()
	
	var target_cell_changer: CellChanger = target_cell_instance.get_corresponding_cell_changer(target_cell_changer_id)
	var player_spawn_position: Vector2 = target_cell_changer.get_player_target_position()
	node_references.player.global_position = player_spawn_position 
	#node_references.player.force_idle_pose() # hehe
	update_region(target_cell_instance) 
	
	# OPTIONAL: SceneTransitionManager as autoload #
	SceneTransitionManager.fade_in(SceneTransitionManager.TransitionTypes.FADE)
	await SceneTransitionManager.fade_in_complete
	
	world_process = true

func _add_adjacent_cells(reference_cell: RegionCell, adjacent_cells: Dictionary) -> void:
	for adjacent_cell_filepath in adjacent_cells.keys():
		var adjacent_cell_name: String = _get_cell_name_from_filepath(adjacent_cell_filepath)
		if not node_references.loaded_region_cells.has_node(adjacent_cell_name):
			var adjacent_cell_relative_position = str_to_var(adjacent_cells[adjacent_cell_filepath])
			
			instance_cell_in_region(
				load(adjacent_cell_filepath), 
				reference_cell.global_position + adjacent_cell_relative_position
			)

func _free_distant_cells(adjacent_cells: Dictionary) -> void:
	for cell in node_references.loaded_region_cells.get_children():
		if not adjacent_cells.has(cell.scene_file_path):
			cell.queue_free()

func _get_cell_name_from_filepath(cell_filepath: String) -> String:
	var last_forward_slash_index: int = cell_filepath.rfindn("/") + 1
	var cell_name: String = (cell_filepath.substr(last_forward_slash_index, -1)) # remove leading filepath
	cell_name = cell_name.left(cell_name.length() - 5) # remove .tscn extension
	return cell_name






