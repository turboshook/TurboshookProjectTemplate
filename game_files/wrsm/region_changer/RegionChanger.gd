extends Node2D
class_name RegionChanger

enum SPAWN_POSITIONS {
	NORTH,
	SOUTH,
	EAST,
	WEST
}

@onready var PlayerSpawnPositionsContainer: Node2D = $PlayerSpawnPositionsContainer

@export var id: float = 0.0
@export_file("*.tscn") var target_cell_path: String
@export var spawn_position: SPAWN_POSITIONS

func get_player_spawn_position() -> Vector2:
	var selected_spawn_position: Vector2 = Vector2.ZERO
	match spawn_position:
		SPAWN_POSITIONS.NORTH:
			selected_spawn_position = PlayerSpawnPositionsContainer.get_child(0).global_position
		SPAWN_POSITIONS.SOUTH:
			selected_spawn_position = PlayerSpawnPositionsContainer.get_child(1).global_position
		SPAWN_POSITIONS.EAST:
			selected_spawn_position = PlayerSpawnPositionsContainer.get_child(2).global_position
		SPAWN_POSITIONS.WEST:
			selected_spawn_position = PlayerSpawnPositionsContainer.get_child(3).global_position
	return selected_spawn_position

func get_id() -> float:
	return id

@warning_ignore(unused_parameter)
func _on_player_detection_body_entered(_body: Node2D):
	if target_cell_path != "":
		var current_room_global_position: Vector2 = get_parent().global_position # as long as we don't move the container scene, we're good
		@warning_ignore(narrowing_conversion)
		WorldRegion.change_region(target_cell_path, current_room_global_position, id)
	else:
		print("no cell path specified")
