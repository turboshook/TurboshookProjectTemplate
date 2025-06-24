extends Node

const INTRO_SCREEN_UID: String = "uid://crar046dhlaut"

@export var _skip_intro: bool = false
@export var _skip_main_menu: bool = false

@onready var current_scene_container: Node = $CurrentSceneContainer
@onready var screen_transition_manager: ScreenTransitionManager = $ScreenTransitionManager

func _ready() -> void:
	pass 
