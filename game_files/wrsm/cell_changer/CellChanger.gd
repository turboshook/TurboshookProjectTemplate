extends Area2D
class_name CellChanger

@export var id: String = ""
@export_file("*.tscn") var target_cell_file_path: String = ""

signal activated(self_reference: CellChanger)

func get_player_target_position() -> Vector2:
	return $PlayerTargetPosition.global_position

func activate() -> void:
	activated.emit(self)
