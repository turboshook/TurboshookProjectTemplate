extends Node2D

@onready var LoadedRegionCells: Node2D = $LoadedRegionCells
@onready var PlayerContainer: Node2D = $PlayerContainer

var WorldRegionReference = ResourceLoader.load("res://game_files/utils/MainInstances.tres")

func _ready() -> void:
	WorldRegionReference.GameWorld = self

# not presently used
func get_current_cell() -> RegionCell:
	for cell in LoadedRegionCells.get_children():
		if cell.is_active():
			return cell
	return null
