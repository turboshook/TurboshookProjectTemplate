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
			adjacent_cells[cell.get_parent_cell().filename] = var_to_str(cell.get_parent_cell_position(global_position))
	
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









