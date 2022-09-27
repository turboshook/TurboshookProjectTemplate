extends Node2D

@onready var LoadedRegionCells: Node2D = $LoadedRegionCells
@onready var PlayerContainer: Node2D = $PlayerContainer

var WorldReference: Resource 

func _ready() -> void:
	WorldReference = ResourceLoader.load(WorldRegion.get_world_reference_path())
	WorldReference.World = self
	WorldReference.LoadedRegionCells = LoadedRegionCells
	WorldReference.Player = PlayerContainer.get_child(0) # just to avoid extra code in the Player script
	WorldRegion.initialize()

# not presently used
func get_current_cell() -> RegionCell:
	for cell in LoadedRegionCells.get_children():
		if cell.is_active():
			return cell
	return null
