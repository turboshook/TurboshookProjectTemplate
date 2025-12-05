extends Control
class_name MainMenu

@onready var option_button_container: VBoxContainer = $CenterContainer/VBoxContainer/OptionButtonContainer
@onready var start_button: Button = $CenterContainer/VBoxContainer/OptionButtonContainer/StartButton
@onready var options_button: Button = $CenterContainer/VBoxContainer/OptionButtonContainer/OptionsButton
@onready var credits_button: Button = $CenterContainer/VBoxContainer/OptionButtonContainer/CreditsButton
@onready var exit_button: Button = $CenterContainer/VBoxContainer/OptionButtonContainer/ExitButton

signal main_scene_requested

func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	credits_button.pressed.connect(_on_credits_button_pressed)
	exit_button.pressed.connect(get_tree().quit)
	if OS.has_feature("web"):
		exit_button.hide()

func _on_start_button_pressed() -> void:
	_set_buttons_enabled(false)
	main_scene_requested.emit()

func _on_options_button_pressed() -> void:
	print("Showing options")
	#_set_buttons_enabled(false)
	# do something here

func _on_credits_button_pressed() -> void:
	print("Showing options")
	#_set_buttons_enabled(false)
	# do something here

func _set_buttons_enabled(set_value: bool) -> void:
	for button: Button in option_button_container.get_children():
		button.set_disabled(!set_value)
