extends Node2D
class_name RegionCell

@onready var CameraLimits: Node2D = $Utils/CameraLimits
@onready var CameraTargets: Node2D = $Utils/CameraTargets
@onready var RegionChangers: Node2D = $RegionChangers
@onready var Monsters: Node2D = $Monsters
@onready var MonsterSpawnPositions: Node2D = $MonsterSpawnPositionsContainer

#@export var override_encounter_table: Resource
#@export_range(0, 99) var minimum_monster_spawns: int = 0
#@export_range(0, 99) var maximum_monster_spawns: int = 0

var empty_spawn_positions: Array

var region_key: String
var active = false

var WorldRegionReference: Resource

func _ready() -> void:
	if not WorldRegion.is_initialized():
		await WorldRegion.initialize_complete
	#WorldRegionReference = ResourceLoader.load("res://game_files/utils/WorldRegionReference.tres")
	for spawn_position in MonsterSpawnPositions.get_children():
		empty_spawn_positions.append(spawn_position)
	region_key = get_region_key()
	#handle_monster_spawns()

# spookyrpg specific
func handle_monster_spawns() -> void:
	return
	#var potential_spawn_positions: Array = MonsterSpawnPositions.get_children()
	#maximum_monster_spawns = clamp(maximum_monster_spawns, maximum_monster_spawns, potential_spawn_positions.size())
	#if minimum_monster_spawns > maximum_monster_spawns:
	#	minimum_monster_spawns = maximum_monster_spawns
	
	# warning-ignore:narrowing_conversion
	#var number_of_spawns: int = round(randf_range(minimum_monster_spawns, maximum_monster_spawns))
	#if number_of_spawns == 0:
	#	return
	
	# first time startup handling
	#if not WorldRegion.is_initialized():
	#	await WorldRegion.initialize_complete
	
	#for _i in number_of_spawns:
	#	var new_monster_packed: PackedScene 
	#	if has_override_encounter_table():
	#		new_monster_packed = override_encounter_table.get_encounter()
	#	else:
	#		new_monster_packed = WorldRegion.encounter_table.get_encounter()
		#var chosen_spawn_position: MonsterSpawnPosition = Utils.get_random_array_element(empty_spawn_positions)
		#empty_spawn_positions.erase(chosen_spawn_position)
		#var _new_monster_instance: WorldMonster = Utils.instance_scene(new_monster_packed, Monsters, chosen_spawn_position.global_position)

#func has_override_encounter_table() -> bool:
#	return override_encounter_table != null

func get_region_key() -> String:
	# the name of a scene is now a class called StringName, which is immutable
	# cast to plain Jane string to use string operations
	return str(name).rsplit("_", false, 1)[0]

func is_active() -> bool:
	return active

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
func _on_PlayerDetector_body_entered(body):
	if not active:
		if not WorldRegionReference.WorldCameraInstance.is_connected("cell_change_complete", Callable(self, "_on_cell_change_complete")):
			WorldRegionReference.WorldCameraInstance.connect("cell_change_complete", Callable(self, "_on_cell_change_complete"))
		var new_camera_target = get_new_camera_target(body.global_position)
		WorldRegionReference.WorldCameraInstance.change_cell(new_camera_target)

# when the player leaves a given area, that area disconnects from the main camera
func _on_PlayerDetector_body_exited(_body):
	if WorldRegionReference.WorldCameraInstance.is_connected("cell_change_complete", Callable(self, "_on_cell_change_complete")):
		WorldRegionReference.WorldCameraInstance.disconnect("cell_change_complete", Callable(self, "_on_cell_change_complete"))
	if not WorldRegionReference.WorldCameraInstance.is_connected("cell_change_started", Callable(self, "_on_cell_change_started")):
		WorldRegionReference.WorldCameraInstance.connect("cell_change_started", Callable(self, "_on_cell_change_started"))

func get_new_camera_target(player_origin) -> Vector2:
	var closest_node = null
	var shortest_distance = Vector2(10000,10000)
	for target_node in CameraTargets.get_children():
		if (target_node.global_position - player_origin).length() < shortest_distance.length():
			shortest_distance = target_node.global_position - player_origin
			closest_node = target_node
	return closest_node.global_position

func _on_cell_change_complete() -> void:
	_activate() 

func _on_cell_change_started() -> void:
	WorldRegionReference.WorldCameraInstance.disconnect("cell_change_started", Callable(self, "_on_cell_change_started"))
	_deactivate()

func _activate() -> void:
	active = true
	_add_adjacent_cells()
	WorldRegionReference.WorldCameraInstance.set_camera_limits(CameraLimits.get_children())

func _add_adjacent_cells() -> void:
	var this_cell_mapping: Dictionary = WorldRegion.cell_mapping[name] # location of current RegionCell in RegionMapping
	var adjacent_area_names: Array = [name]
	for adjacent_cell_filepath in this_cell_mapping:
		var value: Vector2 = str_to_var(this_cell_mapping.get(adjacent_cell_filepath))
		var last_forward_slash_index: int = adjacent_cell_filepath.rfindn("/") + 1
		var new_area_name: String = (adjacent_cell_filepath.substr(last_forward_slash_index, -1)) # remove_at filepath
		new_area_name = new_area_name.left(new_area_name.length() - 5) # remove_at super.tscn extension
		adjacent_area_names.append(new_area_name)
		if not get_parent().has_node(new_area_name):
			# warning-ignore:return_value_discarded
			WorldRegion.instance_cell_in_region(load(adjacent_cell_filepath), global_position + value)
	_free_distant_cells(adjacent_area_names)

func _free_distant_cells(adjacent_area_names) -> void:
	var loaded_areas: Node = get_parent()
	for area in loaded_areas.get_children():
		if not adjacent_area_names.has(area.name):
			area.queue_free()

func _deactivate() -> void:
	active = false

func get_class() -> String:
	return "RegionCell"

func is_class(test_class: String) -> bool:
	return test_class == get_class()




