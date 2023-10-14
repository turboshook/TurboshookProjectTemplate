extends Node2D
class_name RegionCell

@onready var camera_bottom_right_limit = $Utils/CameraBottomRightLimit
@onready var camera_targets: Node2D = $Utils/CameraTargets

@onready var cell_changers: Node2D = $CellChangers
@onready var projectile_layer: Node2D = $ProjectileLayer
@onready var effect_layer: Node2D = $EffectLayer

var empty_spawn_positions: Array

var region_key: String

func _ready() -> void:
	region_key = get_region_key()

func get_region_key() -> String:
	return str(name).rsplit("_", false, 1)[0]

func get_corresponding_cell_changer(target_id: String) -> CellChanger:
	for cell_changer in cell_changers.get_children():
		if cell_changer.id == target_id:
			return cell_changer
	return null

func get_adjacent_cells() -> Dictionary:
	var adjacent_cells: Dictionary = {}
	var RegionCellDetectorContainer: Node2D = $Utils/RegionCellDetectorContainer
	for cell_detector in RegionCellDetectorContainer.get_children():
		if cell_detector.get_overlapping_areas().size() > 0:
			var cell = cell_detector.get_overlapping_areas()[0]
			adjacent_cells[cell.get_parent_cell().scene_file_path] = var_to_str(cell.get_parent_cell_position(global_position))
	
	print("\n- - - - - - - - - - - - - - - - - - - - - - - - - - - ")
	print(name, " adjacent cells: ", adjacent_cells)
	print("- - - - - - - - - - - - - - - - - - - - - - - - - - - \n")
	
	return adjacent_cells

# when the player enters a new area, that area connects to the main camera
func _on_player_detector_body_entered(_body) -> void:
	WorldRegion.focus_cell(self)

func get_camera_limits() -> Array[int]:
	return [
		global_position.y,
		global_position.y + camera_bottom_right_limit.position.y,
		global_position.x,
		global_position.x + camera_bottom_right_limit.position.x
	]

func get_new_camera_target(player_origin: Vector2) -> Vector2:
	var closest_node = null
	var shortest_distance = Vector2(10000,10000)
	for target_node in camera_targets.get_children():
		if (target_node.global_position - player_origin).length() < shortest_distance.length():
			shortest_distance = target_node.global_position - player_origin
			closest_node = target_node
	return closest_node.global_position

func activate() -> void:
	var camera_limits: Array[int] = get_camera_limits()
	WorldRegion.node_references.world_camera.set_limits(
		camera_limits[0],
		camera_limits[1],
		camera_limits[2],
		camera_limits[3]
	)
	WorldRegion.node_references.current_cell = self









