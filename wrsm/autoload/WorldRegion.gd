extends Node

var world_data_path: String
var world_data: Dictionary
var region_key: String
var cell_mapping: Dictionary

var region_data: Dictionary
#var encounter_table: EncounterTable

var initialized: bool = false # used just for that first RegionCell check checked _ready()
signal initialize_complete

var WorldScene: Node2D
var WorldCamera: Camera2D

func initialize() -> void:
	world_data_path = get_world_data_path()
	world_data = get_world_data()
	region_key = WorldScene.LoadedRegionCells.get_child(0).get_region_key() # ONLY ONE RegionCell can be instanced in LoadedRegionCells on startup, or this breaks. Cannot think of workaround for now.
	cell_mapping = world_data[region_key]["region_cell_mapping"]
	region_data = world_data[region_key]["region_data"]
	#encounter_table = load(region_data["encounter_table"])
	initialized = true
	emit_signal("initialize_complete")

func is_initialized() -> bool:
	return initialized

func update_region(new_region_cell: RegionCell) -> void:
	region_key = new_region_cell.get_region_key()
	cell_mapping = world_data[region_key]["region_cell_mapping"]
	region_data = world_data[region_key]["region_data"]
	#encounter_table = load(region_data["encounter_table"])

func get_world_data_path() -> String:
	var final_path: String 
	var parent_dir: String = get_script().resource_path.get_base_dir()
	var last_forward_slash_index: int = parent_dir.rfindn("/")
	var module_root_dir: String = parent_dir.left(last_forward_slash_index)
	final_path = module_root_dir + "/world_data/world_data.json"
	return final_path

func get_world_data() -> Dictionary:
	var mapping: Dictionary
	var file: File = File.new()
	file.open(world_data_path, File.READ)
	if file.get_as_text() != "":
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		mapping = test_json_conv.get_data()
	file.close()
	return mapping

func instance_cell_in_region(cell_packed: PackedScene, target_position: Vector2) -> RegionCell:
	if WorldScene.LoadedRegionCells == null:
		return null
	var cell_instance: RegionCell = cell_packed.instantiate()
	WorldScene.LoadedRegionCells.call_deferred("add_child", cell_instance)
	cell_instance.global_position = target_position
	return cell_instance

func clear_loaded_cells() -> void:
	for child in WorldScene.LoadedRegionCells.get_children():
		child.queue_free()

func change_region(target_cell_path: String, target_cell_position: Vector2, target_region_changer_id: int) -> void:
	clear_loaded_cells()
	var target_cell_instance: RegionCell = WorldRegion.instance_cell_in_region(load(target_cell_path), target_cell_position)
	await target_cell_instance.ready # because we have to instance RegionCells in the above call using call_deferred()
	var target_region_changer: RegionChanger = target_cell_instance.get_corresponding_region_changer(target_region_changer_id)
	var player_spawn_position: Vector2 = target_region_changer.get_player_spawn_position()
	WorldScene.PlayerContainer.get_child(0).global_position = player_spawn_position 
	WorldRegion.update_region(target_cell_instance)
	#MainInstances.GameRoot.StateStack.push_create(GameStates.SCENE_TRANSITION_IN, [Global.SceneTransitionTypes.FADE, 0.5])
	#MainInstances.GameRoot.StateStack.push_create(GameStates.CHANGE_REGION, [target_cell_path, target_cell_position, target_region_changer_id])
	#MainInstances.GameRoot.StateStack.push_create(GameStates.SCENE_TRANSITION_OUT, [Global.SceneTransitionTypes.FADE, 0.5])
