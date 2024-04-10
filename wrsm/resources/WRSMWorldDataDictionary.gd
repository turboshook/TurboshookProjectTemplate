extends Resource
class_name WRSMWorldDataDictionary

# world_data = {
#	"Region0Key": WORLD_REGION_REGISTRY_0,
#	"Region1Key": WORLD_REGION_REGISTRY_1,
#	...

const WORLD_REGION_REGISTRY: Dictionary = {
	"region_cells": {
		# region_cell_0_name: REGION_CELL_REGISTRY_0,
		# region_cell_1_name: REGION_CELL_REGISTRY_1,
		# ...
	},
	"region_data": {
		# totally arbitrary keys and values, specific to use case
	}
}

const REGION_CELL_REGISTRY: Dictionary = {
	"global_position": Vector2.ZERO,
	"adjacent_cell_scene_paths": {
		# "/path/to/region_cell_0.tscn": region_cell_0.global_position: Vector2,
		# "/path/to/region_cell_1.tscn": region_cell_1.global_position: Vector2,
		# ...
	},
	"persistent_scenes": [
		# PERSISTENT_SCENE_REGISTRY_0,
		# PERSISTENT_SCENE_REGISTRY_1,
		# ...
	] 
}

const PERSISTENT_SCENE_REGISTRY: Dictionary = {
	"scene_name": "",
	"scene_file_path": "",
	"global_position": Vector2.ZERO
}
