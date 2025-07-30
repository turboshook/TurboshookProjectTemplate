extends Node

const INTRO_SCREEN_UID: String = "uid://crar046dhlaut"
const MAIN_MENU_UID: String = "uid://dc5hu774r52wf"

@export var _main_scene_packed: PackedScene
@export_category("Debug")
@export var _skip_intro: bool = false
@export var _skip_main_menu: bool = false

@onready var current_scene_container: Node = $CurrentSceneContainer
@onready var screen_transition_manager: ScreenTransitionManager = $ScreenTransitionManager

func _ready() -> void:
	screen_transition_manager.screen_fade_out(0.0)
	_free_current_scene()
	if not _skip_intro:
		await get_tree().create_timer(0.5).timeout
		var intro_scene: IntroductionScreen = load(INTRO_SCREEN_UID).instantiate()
		current_scene_container.add_child(intro_scene)
		intro_scene.intro_complete.connect(_on_intro_complete)
		await screen_transition_manager.screen_fade_in().finished
		return
	_on_intro_complete()

func _on_intro_complete() -> void:
	await screen_transition_manager.screen_fade_out().finished
	_free_current_scene()
	if not _skip_main_menu:
		var main_menu: Control = load(MAIN_MENU_UID).instantiate()
		current_scene_container.add_child(main_menu)
		main_menu.main_scene_requested.connect(_load_main_scene)
		await screen_transition_manager.screen_fade_in().finished
		return
	_load_main_scene()

func _load_main_scene() -> void:
	await screen_transition_manager.screen_fade_out().finished
	_free_current_scene()
	if not _main_scene_packed: 
		printerr("game.gd @ _load_main_scene(): No PackedScene provided.")
		return
	var main_scene: Node = _main_scene_packed.instantiate()
	current_scene_container.add_child(main_scene)
	### can init main scene here ###
	await screen_transition_manager.screen_fade_in().finished

func _free_current_scene() -> void:
	for scene: Node in current_scene_container.get_children(): scene.queue_free()
