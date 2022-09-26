extends Node2D

@onready var LoadedRegionCells: Node2D = $LoadedRegionCells
@onready var PlayerContainer: Node2D = $PlayerContainer

var WorldRegionReference = ResourceLoader.load(WorldRegion.get_module_path() + "/world_region_reference/WorldRegionReference.tres")

func _ready() -> void:
	WorldRegionReference.World = self
	WorldRegionReference.Player = PlayerContainer.get_child(0)

# not presently used
func get_current_cell() -> RegionCell:
	for cell in LoadedRegionCells.get_children():
		if cell.is_active():
			return cell
	return null
