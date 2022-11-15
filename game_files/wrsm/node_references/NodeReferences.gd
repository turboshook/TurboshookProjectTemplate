extends Resource

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

var Player: CharacterBody2D = null:
	get:
		return Player
	set(mod_value):
		Player = mod_value
		player_ready.emit()

var WorldCamera: Camera2D = null:
	get:
		return WorldCamera
	set(mod_value):
		WorldCamera = mod_value
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
	set(mod_value):
		CurrentCell = mod_value
		current_cell_ready.emit()
