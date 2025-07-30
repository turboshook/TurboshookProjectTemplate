extends Control
class_name MainMenu

@onready var start_button: Button = $OptionButtonContainer/StartButton
@onready var options_button: Button = $OptionButtonContainer/OptionsButton
@onready var credits_button: Button = $OptionButtonContainer/CreditsButton
@onready var exit_button: Button = $OptionButtonContainer/ExitButton

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
	for button: Button in $OptionButtonContainer.get_children():
		button.set_disabled(!set_value)
