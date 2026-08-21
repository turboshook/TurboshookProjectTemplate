extends Node
class_name SimpleSceneDestroyer2D

@export_category("Dependencies")
@export var scene: Node2D
@export var visual_representation: Node2D
@export_category("Config")
@export_range(0.1, 60.0, 0.05) var destroy_time: float = 3.0
@export_range(0.1, 60.0, 0.05) var flicker_time: float = 2.0
var _elapsed_destroy_time: float = 0.0
var _destroying: bool = false

func _ready() -> void:
	if not scene:
		push_warning("SimpleSceneDestroyer2D @ _ready(): no scene provided!")
	if not visual_representation:
		push_warning("SimpleSceneDestroyer2D @ _ready(): no visual_representation provided!")

func _physics_process(delta: float) -> void:
	if not scene or not visual_representation: return
	if not _destroying: return
	_elapsed_destroy_time += delta
	if _elapsed_destroy_time >= flicker_time:
		visual_representation.visible = !visual_representation.visible
	if _elapsed_destroy_time >= destroy_time:
		scene.queue_free()

func start() -> void:
	_destroying = true

func stop() -> void:
	_destroying = false
	_elapsed_destroy_time = 0.0
	if visual_representation:
		visual_representation.visible = true
