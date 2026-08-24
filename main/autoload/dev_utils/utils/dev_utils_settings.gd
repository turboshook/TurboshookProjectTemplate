@tool
extends Resource
class_name DevUtilsSettings

@export_group("Meta")
@export var version: String = "0.1.0"

@export_group("Background")
@export var console_output_background_color: Color = Color("292f65")
@export var console_output_background_alpha: float = 0.25
@export var console_input_background_color: Color = Color("292f65")
@export var console_input_background_alpha: float = 0.5

@export_group("Text")
@export var info_color: Color = Color("7be1f6")
@export var comand_color: Color = Color("9a8fe0") 
@export var return_value_color: Color = Color("ffffff")
@export var error_color: Color = Color("cf5d8b")

@export_group("Scene")
@export var dev_utils_font: Font
@export var dev_utils_theme: Theme
## Determines whether the [DevUtilsConsole] background rect will have the
## [param console_background_shader] material applied. This is set to [param false]
## automatically if not using the Forward+ renderer.
@export var use_shader_background: bool = true
@export var console_background_shader: ShaderMaterial
@export_range(-100, 100, 1) var base_canvas_layer: int = 100

@export_group("Test")
@export_multiline var help_command_string: String = "\nHello! Welcome to DevUtils. \n\nTo get started, use the 'commandlist' command to see all commands in the database. To learn about a specific command, type 'explain' followed by that command's name. \n\nArbitrary GDScript can be provided using the 'exp' command. For example, 'exp 2+2' will return 4. \n\nRefer to the docs to learn how to implement your own custom commands. \n\nI hope this helps you!"
@export_multiline var lorem_ipsum: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla malesuada sed tortor sed sagittis. Duis mattis at magna non volutpat. Phasellus ut metus dignissim, tempus arcu at, fermentum velit. Phasellus tincidunt dapibus massa, at ultrices nunc lobortis eu. Fusce ac nisi porttitor, molestie tortor ut, posuere ligula."

@export_group("Other")
@export var command_tag: String = "-> ":
	set(new_value):
		if new_value.length() >= 3:
			new_value = new_value.left(3)
		command_tag = new_value 
@export var return_value_tag: String = "<- ":
	set(new_value):
		if new_value.length() >= 3:
			new_value = new_value.left(3)
		return_value_tag = new_value 
@export var error_tag: String = " x ":
	set(new_value):
		if new_value.length() >= 3:
			new_value = new_value.left(3)
		error_tag = new_value 
@export var missing_base_error_string: String = "missing base for [command]"
@export var unknown_command_error_string: String = "unknown command"
@export var argument_count_error_string: String = "arg count mismatch"
@export var argument_type_error_string: String = "arg type mismatch"
@export var blacklisted_function_error_string: String = "function not allowed: "
@export var missing_explain_text_string: String = "No explain text provided for this command."
