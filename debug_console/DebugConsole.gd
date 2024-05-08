extends CanvasLayer

const COMMAND_FILE_PATH: String = "res://debug_console/data/commands.json"
const VERSION_TEXT: String = " -- ShookStation -- [v0.0.1]\n "
const COMMAND_TAG: String = "-> "
const RETURN_VALUE_TAG: String = "<- "
const ERROR_TAG: String = " x "
const DEFAULT_MISSING_BASE_ERROR: String = "missing base for [command]"
const DEFAULT_UNKNOWN_COMMAND_ERROR: String = "unknown command"
const DEFAULT_ARGUMENT_COUNT_ERROR: String = "arg count mismatch"
const DEFAULT_ARGUMENT_TYPE_MISMATCH_ERROR: String = "arg type mismatch"
const EXPRESSION_EVALUATION_TAG: String = "exp"
const DEBUG_METRIC_LABEL_PATH: String = "res://debug_console/utils/DebugMetricLabel.tscn"
const OUTPUT_SCROLL_INCREMENT: float = 10.0
const HELP_TEXT: String = "Hello! Use the 'commandlist' command to see all commands in the database. To learn about a specific command, type 'explain' followed by that command's name. I hope this helps you!"
const LOREM_IPSUM: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla malesuada sed tortor sed sagittis. Duis mattis at magna non volutpat. Phasellus ut metus dignissim, tempus arcu at, fermentum velit. Phasellus tincidunt dapibus massa, at ultrices nunc lobortis eu. Fusce ac nisi porttitor, molestie tortor ut, posuere ligula."

enum ArgTypes {
	INT,
	STRING,
	BOOL,
	FLOAT
}

@onready var _expression_base: Node = $ExpressionBase

var _metrics_container: Control = null
var _console_container: Control = null
var _console_output: Label = null
var _console_output_base_height: float = 0.0
var _console_input: LineEdit = null

var _metrics_labels: Dictionary = {}

# Example of a command in commands.json:
# 
# "command_text": {
#	"arg_count": x,
#	"missing_base_error": "Some helpful error text.",
#	"base": "true",
#	"help_text:" "Some descriptive help text."
#
# }
# The "arg_types" and "callable" keys are added on initialization

var _command_dictionary: Dictionary = {}

var _command_history: Array[String] = []
var _command_history_index: int = 0

var base_viewport_size: Vector2 = Vector2.ZERO
var debug_theme: Theme = null

func _ready() -> void:
	
	base_viewport_size = get_viewport().content_scale_size
	debug_theme = load("res://debug_console/resources/debug_console_theme.tres")
	
	# Metrics
	_build_metric_layer()
	_init_builtin_metrics()
	
	# Console
	_build_console()
	_import_command_dictionary()
	_init_builtin_commands()
	_clear_output()

func _build_metric_layer() -> void:
	
	# Container
	_metrics_container = Control.new()
	add_child(_metrics_container)
	_metrics_container.name = "MetricsContainer"
	_metrics_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	_metrics_container.theme = debug_theme
	
	# LeftPanel
	var left_metrics_panel: VBoxContainer = VBoxContainer.new()
	_metrics_container.add_child(left_metrics_panel)
	left_metrics_panel.name = "LeftPanel"
	left_metrics_panel.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	left_metrics_panel.custom_minimum_size = Vector2(
		base_viewport_size.x * 0.5,
		base_viewport_size.y
	)
	left_metrics_panel.position = Vector2.ZERO
	
	# Right Panel
	var right_metrics_panel: VBoxContainer = VBoxContainer.new()
	_metrics_container.add_child(right_metrics_panel)
	right_metrics_panel.name = "RightPanel"
	right_metrics_panel.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	right_metrics_panel.custom_minimum_size = Vector2(
		base_viewport_size.x * 0.5,
		base_viewport_size.y
	)
	right_metrics_panel.position = Vector2(
		base_viewport_size.x * 0.5,
		0.0
	) 
	
	_metrics_container.visible = false

func _init_builtin_metrics() -> void:
	init_metric("fps", Engine.get_frames_per_second, false)
	init_metric("mem", _debug_get_static_memory_usage, false)

func init_metric(metric_name: String, update_callable: Callable, left_panel: bool = true) -> void:
	# metric already exists
	if metric_name in _metrics_labels.keys():
		_metrics_labels[metric_name].init(metric_name, update_callable)
		return
	
	# new metric
	var metric_label: Control = load(DEBUG_METRIC_LABEL_PATH).instantiate()
	if left_panel:
		_metrics_container.get_node("LeftPanel").add_child(metric_label)
	else:
		_metrics_container.get_node("RightPanel").add_child(metric_label)
		metric_label.h_box_container.alignment = BoxContainer.AlignmentMode.ALIGNMENT_END
	_metrics_labels[metric_name] = metric_label
	metric_label.init(metric_name, update_callable)

func _build_console() -> void:
	
	# Container
	_console_container = Control.new()
	add_child(_console_container)
	_console_container.name = "ConsoleContainer"
	_console_container.size = base_viewport_size
	_console_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	_console_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_console_container.theme = debug_theme
	
	# Background
	var console_background: ColorRect = ColorRect.new()
	_console_container.add_child(console_background)
	console_background.name = "Background"
	console_background.set_deferred("anchors_preset", Control.PRESET_FULL_RECT)
	console_background.size = base_viewport_size
	console_background.color = Color("55555555")
	console_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# ConsoleOutput
	_console_output = Label.new()
	_console_container.add_child(_console_output)
	_console_output.name = "ConsoleOutput"
	_console_output.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_console_output.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_console_output.set_deferred("anchors_preset", Control.PRESET_BOTTOM_WIDE)
	_console_output.custom_minimum_size = Vector2(
		base_viewport_size.x,
		base_viewport_size.y - 20.0
	)
	_console_output_base_height = base_viewport_size.y - 20.0
	_console_output.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_console_output.resized.connect(_on_console_output_resized)
	
	# ConsoleInput
	_console_input = LineEdit.new()
	_console_container.add_child(_console_input)
	_console_input.name = "ConsoleInput"
	_console_input.set_caret_blink_enabled(true)
	_console_input.set_caret_blink_interval(0.25)
	_console_input.size = Vector2(base_viewport_size.x, 20.0)
	_console_input.position = Vector2(0.0, base_viewport_size.y - 20.0)
	_console_input.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_console_input.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_console_input.text_submitted.connect(_on_console_input_submitted)
	
	_console_container.visible = false

func _import_command_dictionary() -> void:
	if !FileAccess.file_exists(COMMAND_FILE_PATH):
		printerr("DebugConsole @ _import_command_dictionary(): COMMAND_FILE_PATH is invalid.")
		return
	var file_access: FileAccess = FileAccess.open(COMMAND_FILE_PATH, FileAccess.READ)
	_command_dictionary = JSON.parse_string(file_access.get_as_text())
	file_access.close()
	if _command_dictionary == null:
		printerr("DebugConsole @ _import_command_dictionary(): commands.json failed to parse, make sure it is formatted correctly!")
		return
	for command_string in _command_dictionary.keys():
		if !_command_dictionary[command_string].has("arg_count"):
			_command_dictionary[command_string]["arg_count"] = 0
		if !_command_dictionary[command_string].has("missing_base_error"):
			_command_dictionary[command_string]["missing_base_error"] = DEFAULT_MISSING_BASE_ERROR
		_command_dictionary[command_string]["arg_types"] = []
		_command_dictionary[command_string]["callable"] = null

func _init_builtin_commands() -> void:
	init_command("help", _debug_help)
	init_command("commandlist", _debug_commandlist)
	init_command("explain", _debug_explain, [ArgTypes.STRING])
	init_command("clearout", _clear_output)
	init_command("clearhist", _clear_history)
	init_command("clearall", _clear_all)
	init_command("metrics", _show_metrics)
	init_command("newline", _log_empty_line)
	init_command("loremipsum", _debug_lorem_ipsum)

func init_command(command_string: String, callable: Callable, args: Array[ArgTypes] = []) -> void:
	command_string = command_string.replace(" ", "")
	if !_command_dictionary.has(command_string):
		printerr("DebugConsole @ init_command(): Failed to init command ", command_string, " as it does not exist in commands.json.")
		return
	if args.size() != _command_dictionary[command_string]["arg_count"]:
		printerr("DebugConsole @ init_command(): Failed to init command ", command_string, ". Expected ", _command_dictionary[command_string]["arg_count"], " arguments, but was provided ", args.size(), ".")
		return
	for arg_type in args:
		_command_dictionary[command_string]["arg_types"].append(arg_type)
	_command_dictionary[command_string]["callable"] = callable

func _input(event: InputEvent) -> void:
	if is_open():
		
		if event.is_action_pressed("ui_up"):
			_check_history(-1)
		elif event.is_action_pressed("ui_down"):
			_check_history(1)
		
		if event.is_action_pressed("ui_page_up"):
			_scroll_output(1)
		elif event.is_action_pressed("ui_page_down"):
			_scroll_output(-1)
		
		if event.is_action_pressed("debug_console"): 
			_close_console()
	elif event.is_action_pressed("debug_console"):
		_open_console()

func _check_history(index_change: int) -> void:
	_command_history_index += index_change
	_command_history_index = clamp(_command_history_index, 0, _command_history.size())
	if _command_history_index == _command_history.size():
		_console_input.text = ""
	else:
		var recalled_command_text: String = _command_history[_command_history_index]
		_console_input.text = recalled_command_text
		await get_tree().process_frame # womp womp
		_console_input.caret_column = recalled_command_text.length()

func _scroll_output(scroll_direction: int) -> void:
	# return if no resizing due to text
	if _console_output.position.y == 0.0: 
		return
	_console_output.position.y += OUTPUT_SCROLL_INCREMENT * scroll_direction
	_console_output.position.y = clamp(
		_console_output.position.y, 
		(_console_output_base_height - _console_output.size.y), 
		debug_theme.get("Label/constants/line_spacing")
	) 
	# account for the X pixels of line spacing in Label
	# this is because a Label collapses all free whitespace ABOVE the first line
	# of text when it is resized to accommodate new lines, moving the effective
	# starting position by those pixels. As far as I know, there is not a way to 
	# override this behavior.
	# It is stuff like this that makes me worry about portability...
	
	# JUST MOVE THIS BY ONE PIXEL EVERY TIME, ALLOW FOR HOLDING THE KEY DOWN

func is_open() -> bool:
	if not _console_container: return false
	return _console_container.visible

func _open_console() -> void:
	get_tree().paused = true
	_console_container.visible = true
	_console_input.grab_focus.call_deferred()

func _close_console() -> void:
	get_tree().paused = false
	_console_container.visible = false

func _console_log(log_text: String = "") -> void:
	_console_output.text += "\n" + str(log_text)

func _on_console_output_resized() -> void:
	# simulate scroll
	# use the signal because there is literally no other way to tell EXACTLY
	# when a Control has resized...
	_console_output.position.y = _console_output_base_height - _console_output.size.y

func _on_console_input_submitted(new_text: String) -> void:
	if new_text == "": return
	_console_input.text = ""
	_command_history.append(new_text)
	_command_history_index = _command_history.size()
	var result: String = _handle_command(new_text)
	if result != "":
		_console_log(str(RETURN_VALUE_TAG, result))

func _handle_command(command_text: String) -> String:
	var words: PackedStringArray = command_text.split(" ", false)
	if words.size() == 0: return ""
	if words[0] == "exp": return _handle_expression(command_text)

	if !_command_dictionary.has(words[0]):
		_console_log(str(ERROR_TAG, DEFAULT_UNKNOWN_COMMAND_ERROR, " '", words[0], "'"))
		return ""
	
	var command: Dictionary = _command_dictionary[words[0]]
	if command["callable"] == null or !command["callable"].is_valid():
		var missing_base_error: String = command["missing_base_error"]
		if missing_base_error.contains("[command]"):
			missing_base_error = missing_base_error.replace("[command]", words[0])
		_console_log(str(ERROR_TAG, missing_base_error))
		return ""
	
	var command_args: Array[String] = []
	for i in range(words.size()):
		if i == 0: continue
		command_args.append(words[i])
	
	if command_args.size() != command["arg_count"]:
		var info: String = str(" (expected ", command["arg_count"], ", received ", command_args.size(), ")")
		_console_log(str(ERROR_TAG, DEFAULT_ARGUMENT_COUNT_ERROR, info))
		return ""
	
	if command_text != "newline":
		_console_log(str(COMMAND_TAG, command_text))
	
	if command["arg_count"] == 0:
		var no_arg_result: Variant = command["callable"].call()
		if no_arg_result == null: return ""
		return no_arg_result
	
	var cast_args: Array = []
	for i in range(command["arg_count"]):
		var arg_type: int = _get_arg_type(command_args[i])
		if arg_type != command["arg_types"][i]:
			var info: String = str(" (expected ", _get_type_string(command["arg_types"][i]), ", received ", _get_type_string(arg_type), " at position ", i, ")")
			_console_log(str(ERROR_TAG, DEFAULT_ARGUMENT_TYPE_MISMATCH_ERROR, info))
			return ""
		cast_args.append(_cast_type(command_args[i], arg_type))
	
	var arg_result: Variant = command["callable"].callv(cast_args)
	if arg_result == null: return ""
	return arg_result

func _get_arg_type(arg_string: String) -> ArgTypes:
	if arg_string.is_valid_int(): return ArgTypes.INT
	if arg_string.is_valid_float(): return ArgTypes.FLOAT
	if (arg_string == "true" or arg_string == "false"): return ArgTypes.BOOL
	return ArgTypes.STRING

func _get_type_string(arg_type: ArgTypes) -> String:
	if arg_type == ArgTypes.INT: return "INT"
	if arg_type == ArgTypes.FLOAT: return "FLOAT"
	if arg_type == ArgTypes.STRING: return "STR"
	if arg_type == ArgTypes.BOOL: return "BOOL"
	return "_"

func _cast_type(arg_string: String, type: ArgTypes):
	if type == ArgTypes.INT: return arg_string as int
	if type == ArgTypes.FLOAT: return arg_string as float
	if type == ArgTypes.STRING: return arg_string as String
	if type == ArgTypes.BOOL: return arg_string as bool
	return "BAD CAST"

func _handle_expression(command_text: String) -> String:
	_console_log(command_text)
	#var expression_command: String = _format_string(command_text)
	var expression_text: String = command_text.lstrip(str(EXPRESSION_EVALUATION_TAG, " "))
	var expression: Expression = Expression.new()
	var error: Error = expression.parse(expression_text)
	if error != OK:
		_console_log(str(ERROR_TAG, expression.get_error_text()))
		return ""
	var result: Variant = expression.execute([], _expression_base, false)
	if expression.has_execute_failed():
		_console_log(str(ERROR_TAG, "execution failed"))
		return ""
	if result is Object:
		return ""
	return str(result)

func _clear_output() -> void:
	_console_output.text = ""
	_console_output.size = _console_output.custom_minimum_size
	_console_output.position = Vector2.ZERO
	_console_log(VERSION_TEXT)

func _clear_history() -> void:
	_command_history = []
	_command_history_index = 0

func _clear_all() -> void:
	_clear_output()
	_clear_history()

func _debug_commandlist() -> String:
	var commands: Array = _command_dictionary.keys()
	commands.sort()
	var return_string: String = "\n"
	for command in commands:
		return_string += str(command, "\n")
	return return_string

func _debug_help() -> String:
	return HELP_TEXT

func _debug_explain(command_name: String) -> String:
	var command: Dictionary = _command_dictionary[command_name]
	if not command.has("explain_text"):
		return "no explain text provided :("
	return command["explain_text"]

func _show_metrics() -> void:
	_metrics_container.visible = !_metrics_container.visible

func _log_empty_line() -> void:
	_console_log(" ")

func _debug_lorem_ipsum() -> void:
	_console_log(str(RETURN_VALUE_TAG, LOREM_IPSUM))

func _debug_get_static_memory_usage() -> String:
	return String.humanize_size(OS.get_static_memory_usage())









