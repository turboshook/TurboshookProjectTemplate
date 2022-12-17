extends Node

var world_data_path: String
var world_data: Dictionary
var region_key: String
var cell_mapping: Dictionary

var region_data: Dictionary

var initialized: bool = false # used just for that first RegionCell check checked _ready()
signal initialize_complete

var NodeReferences: WRSMNodeReferences

func _ready() -> void:
	world_data_path = get_world_data_path()
	world_data = get_world_data()
	NodeReferences = ResourceLoader.load(get_node_references_path())

func initialize() -> void:
	region_key = NodeReferences.LoadedRegionCells.get_child(0).get_region_key() # ONLY ONE RegionCell can be instanced in LoadedRegionCells on startup, or this breaks. Cannot think of workaround for now.
	cell_mapping = world_data[region_key]["region_cell_mapping"]
	region_data = world_data[region_key]["region_data"]
	initialized = true
	@warning_ignore(return_value_discarded)
	emit_signal("initialize_complete")

func is_initialized() -> bool:
	return initialized

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

func get_node_references_path() -> String:
	return get_module_path() + "/node_references/NodeReferences.tres"

func get_world_data_path() -> String:
	var final_path: String
	final_path = get_module_path() + "/world_data/world_data.json"
	return final_path

func get_world_data() -> Dictionary:
	var mapping: Dictionary
	var file: FileAccess = FileAccess.open(world_data_path, FileAccess.READ)
	if file.get_as_text() != "":
		var test_json_conv = JSON.new()
		@warning_ignore(return_value_discarded)
		test_json_conv.parse(file.get_as_text())
		mapping = test_json_conv.get_data()
	return mapping

func change_cell(new_cell: RegionCell) -> void:
	if new_cell != NodeReferences.CurrentCell:
		get_tree().paused = true
		var new_camera_target: Vector2 = new_cell.get_new_camera_target(NodeReferences.Player.global_position)
		NodeReferences.WorldCamera.move_to_new_camera_target(new_camera_target)
		if NodeReferences.WorldCamera.is_changing_cells():
			await NodeReferences.WorldCamera.cell_change_complete
		new_cell.activate() 
		get_tree().paused = false

func instance_cell_in_region(cell_packed: PackedScene, target_position: Vector2) -> RegionCell:
	if NodeReferences.LoadedRegionCells == null:
		return null
	var cell_instance: RegionCell = cell_packed.instantiate()
	NodeReferences.LoadedRegionCells.call_deferred("add_child", cell_instance)
	cell_instance.global_position = target_position
	return cell_instance

func clear_loaded_cells() -> void:
	for child in NodeReferences.LoadedRegionCells.get_children():
		NodeReferences.LoadedRegionCells.remove_child(child)
		child.queue_free()

func change_region(target_cell_path: String, target_cell_position: Vector2, target_region_changer_id: int) -> void:
	clear_loaded_cells()
	var target_cell_instance: RegionCell = instance_cell_in_region(load(target_cell_path), target_cell_position)
	await target_cell_instance.ready # because we have to instance RegionCells in the above call using call_deferred()
	var target_region_changer: RegionChanger = target_cell_instance.get_corresponding_region_changer(target_region_changer_id)
	var player_spawn_position: Vector2 = target_region_changer.get_player_spawn_position()
	NodeReferences.Player.global_position = player_spawn_position 
	update_region(target_cell_instance)
