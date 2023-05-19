extends Area2D
class_name CellChanger

enum SPAWN_POSITIONS {
	NORTH,
	SOUTH,
	EAST,
	WEST
}

@onready var PlayerSpawnPositionsContainer: Node2D = $PlayerSpawnPositionsContainer
@onready var _spawn_positions: Array = PlayerSpawnPositionsContainer.get_children()

@export var id: int = 0
@export_file("*.tscn") var target_cell_path: String
@export var spawn_position: SPAWN_POSITIONS
var activated_by_interactable: bool = false

func activate() -> void:
	GameStateManager.change_region_cell(self)

func get_player_spawn_position() -> Vector2:
	var selected_spawn_position: Vector2 = Vector2.ZERO
	match spawn_position:
		SPAWN_POSITIONS.NORTH:
			selected_spawn_position = _spawn_positions[0].global_position
		SPAWN_POSITIONS.SOUTH:
			selected_spawn_position = _spawn_positions[1].global_position
		SPAWN_POSITIONS.EAST:
			selected_spawn_position = _spawn_positions[2].global_position
		SPAWN_POSITIONS.WEST:
			selected_spawn_position = _spawn_positions[3].global_position
	return selected_spawn_position

func get_id() -> int:
	return id

func _on_CellChanger_body_entered(body: CharacterBody2D):
	if body == null:
		return
	# referring to Player class anywhere in this script causes this class not to be 
	# fully loaded by RegionCell.gd 
	# honestly 3.5 gd script is kind of ass
#	elif !(body is Player):
#		return
	if not activated_by_interactable:
		activate()
