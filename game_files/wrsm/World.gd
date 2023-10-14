extends Node2D

@onready var loaded_region_cells: Node2D = $LoadedRegionCells
@onready var player_container: Node2D = $PlayerContainer
@onready var world_camera: WorldCamera = $WorldCamera

func _ready() -> void:
	WorldRegion.initialize_world_data(self)

