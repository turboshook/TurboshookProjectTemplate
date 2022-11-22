@tool
extends Node2D
class_name RegionCell

@onready var CameraLimits: Node2D = $Utils/CameraLimits
@onready var CameraTargets: Node2D = $Utils/CameraTargets
@onready var RegionChangers: Node2D = $RegionChangers

@onready var ProjectileLayer: Node2D = $ProjectileLayer

var empty_spawn_positions: Array

var region_key: String

func _ready() -> void:
	#if not WorldRegion.is_initialized():
	#	await WorldRegion.initialize_complete
	region_key = get_region_key()

func get_region_key() -> String:
	return str(name).rsplit("_", false, 1)[0]

func get_corresponding_region_changer(target_id: float) -> RegionChanger:
	for region_changer in RegionChangers.get_children():
		if region_changer.id == target_id:
			return region_changer
	return null

func get_adjacent_cells() -> Dictionary:
	var adjacent_cells: Dictionary = {}
	var RegionCellDetectorContainer: Node2D = $Utils/RegionCellDetectorContainer
	for cell_detector in RegionCellDetectorContainer.get_children():
		if cell_detector.get_overlapping_areas().size() > 0:
			var cell = cell_detector.get_overlapping_areas()[0]
			adjacent_cells[cell.get_parent_cell().get_scene_file_path()] = var_to_str(cell.get_parent_cell_position(global_position))
	
	print("\n- - - - - - - - - - - - - - - - - - - - - - - - - - - ")
	print(name, " adjacent cells: ", adjacent_cells)
	print("- - - - - - - - - - - - - - - - - - - - - - - - - - - \n")
	
	return adjacent_cells

# when the player enters a new area, that area connects to the main camera
func _on_player_detector_body_entered(_body):
	WorldRegion.change_cell(self)

func get_new_camera_target(player_origin: Vector2) -> Vector2:
	var closest_node = null
	var shortest_distance = Vector2(10000,10000)
	for target_node in CameraTargets.get_children():
		if (target_node.global_position - player_origin).length() < shortest_distance.length():
			shortest_distance = target_node.global_position - player_origin
			closest_node = target_node
	return closest_node.global_position

func activate() -> void:
	WorldRegion.NodeReferences.WorldCamera.set_camera_limits(CameraLimits.get_children())
	WorldRegion.NodeReferences.CurrentCell = self
	_add_adjacent_cells()

func _add_adjacent_cells() -> void:
	var this_cell_mapping: Dictionary = WorldRegion.cell_mapping[name] # location of current RegionCell in RegionMapping
	var adjacent_area_names: Array = [name]
	for adjacent_cell_filepath in this_cell_mapping:
		var value: Vector2 = str_to_var(this_cell_mapping.get(adjacent_cell_filepath))
		var last_forward_slash_index: int = adjacent_cell_filepath.rfindn("/") + 1
		var new_area_name: String = (adjacent_cell_filepath.substr(last_forward_slash_index, -1)) # remove_at filepath
		new_area_name = new_area_name.left(new_area_name.length() - 5) # remove_at super.tscn extension
		adjacent_area_names.append(StringName(new_area_name)) # cast to StringName to avoid issues with comparing area names in _free_distant_cells()
		if not get_parent().has_node(new_area_name):
			@warning_ignore(return_value_discarded)
			WorldRegion.instance_cell_in_region(load(adjacent_cell_filepath), global_position + value)
	_free_distant_cells(adjacent_area_names)

func _free_distant_cells(adjacent_area_names) -> void:
	var loaded_areas: Node = get_parent()
	for area in loaded_areas.get_children():
		if not adjacent_area_names.has(area.name):
			area.queue_free()

func get_class() -> String:
	return "RegionCell"

func is_class(test_class: String) -> bool:
	return test_class == get_class()







