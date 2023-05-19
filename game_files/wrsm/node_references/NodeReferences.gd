extends Resource
class_name WRSMNodeReferences

signal world_ready
signal player_ready
signal world_camera_ready
signal loaded_region_cells_ready
signal current_cell_ready

var World: Node2D = null:
	get:
		return World
	set(mod_value):
		World = mod_value
		world_ready.emit()

var PlayerScene: CharacterBody2D = null:
	get:
		return PlayerScene
	set(mod_value):
		PlayerScene = mod_value
		player_ready.emit()

var WorldCameraScene: WorldCamera = null:
	get:
		return WorldCameraScene
	set(mod_value):
		WorldCameraScene = mod_value
		world_camera_ready.emit()

var LoadedRegionCells: Node2D = null:
	get:
		return LoadedRegionCells
	set(mod_value):
		LoadedRegionCells = mod_value
		loaded_region_cells_ready.emit()

var CurrentCell: RegionCell = null:
	get:
		return CurrentCell
	set(new_value):
		CurrentCell = new_value
		CurrentEffectLayer = CurrentCell.get_node("Effects")
		current_cell_ready.emit()

var CurrentEffectLayer: Node = null:
	get:
		return CurrentEffectLayer
	set(new_value):
		CurrentEffectLayer = new_value
