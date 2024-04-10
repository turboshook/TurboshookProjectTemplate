extends Node2D
class_name RegionCell

@onready var camera_bottom_right_limit = $Utils/CameraBottomRightLimit
@onready var camera_targets: Node2D = $Utils/CameraTargets
@onready var region_cell_detectors: Node2D = $Utils/RegionCellDetectorContainer
@onready var cell_changers: Node2D = $CellChangers
@onready var persistent_scene_container: Node2D = $PersistentSceneContainer
@onready var projectile_layer: Node2D = $ProjectileLayer
@onready var effect_layer: Node2D = $EffectLayer

var empty_spawn_positions: Array
var region_key: String
var node_references: WRSMNodeReferences 
var persistent_scenes_array: Array = []

signal player_entered(self_reference: RegionCell)

func _ready() -> void:
	region_key = get_region_key()
	_initialize_persistent_scenes_container()

func initialize(wrsm_node_references: WRSMNodeReferences) -> void:
	node_references = wrsm_node_references

func get_region_key() -> String:
	return str(name).rsplit("_", false, 1)[0]

func get_corresponding_cell_changer(target_id: String) -> CellChanger:
	for cell_changer in cell_changers.get_children():
		if cell_changer.id == target_id:
			return cell_changer
	return null

func _on_player_detector_area_entered(_area: Area2D) -> void:
	player_entered.emit(self)

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
	node_references.world_camera.set_limits(
		camera_limits[0],
		camera_limits[1],
		camera_limits[2],
		camera_limits[3]
	)
	node_references.current_cell = self

func _initialize_persistent_scenes_container() -> void:
	pass
	#var saved_persistent_scenes: Array = WorldRegion.get_persistent_scenes(self)
	#_free_deleted_persistent_scenes(saved_persistent_scenes)
	#_instance_saved_persistent_scenes(saved_persistent_scenes)
	#persistent_scene_container.child_entered_tree.connect(_on_persistent_scene_container_child_entered_tree)
	#persistent_scene_container.child_exiting_tree.connect(_on_persistent_scene_container_child_exiting_tree)

func _free_deleted_persistent_scenes(saved_persistent_scenes: Array) -> void:
	
	for instanced_persistent_scene in persistent_scene_container.get_children():
		var scene_deleted: bool = true
		for persistent_scene_registry in saved_persistent_scenes:
			if instanced_persistent_scene.name == persistent_scene_registry["scene_name"]:
				scene_deleted = false
				break
		if scene_deleted:
			instanced_persistent_scene.queue_free()

func _instance_saved_persistent_scenes(saved_persistent_scenes: Array) -> void:
	pass

func _on_persistent_scene_container_child_entered_tree(scene: Node) -> void:
	# world_data == {} when current scene is RegionMap 
	#if !(scene is Node2D) or WorldRegion.world_data == {}:
		#return
	#if !WorldRegion.persistent_scene_saved(self, scene):
		#WorldRegion.save_persistent_scene(self, scene)
	pass

func _on_persistent_scene_container_child_exiting_tree(scene: Node) -> void:
	# world_data == {} when current scene is RegionMap 
	#if !(scene is Node2D) or WorldRegion.world_data == {}:
		#return
	#if WorldRegion.persistent_scene_saved(self, scene):
		#WorldRegion.delete_persistent_scene(self, scene)
	pass

func _on_initial_persistent_scene_container_child_exiting_tree(scene: Node) -> void:
	#WorldRegion.delete_persistent_scene(self, scene)
	pass























