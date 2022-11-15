extends Node2D

@onready var LoadedRegionCells: Node2D = $LoadedRegionCells
@onready var PlayerContainer: Node2D = $PlayerContainer

var NodeReferences: Resource 

func _ready() -> void:
	NodeReferences = ResourceLoader.load(WorldRegion.get_node_references_path())
	NodeReferences.World = self
	NodeReferences.LoadedRegionCells = LoadedRegionCells
	NodeReferences.Player = PlayerContainer.get_child(0) # just to avoid extra code in the Player script
	WorldRegion.initialize()

# not presently used
func get_current_cell() -> RegionCell:
	for cell in LoadedRegionCells.get_children():
		if cell.is_active():
			return cell
	return null
