extends CanvasLayer

const BASE_CANVAS_LAYER: int = 100

const VERSION_TEXT: String = 					" -- DevUtils [v0.0.5] -- "
const BYLINE: String = 							"      by turboshook     \n "
const COMMAND_TAG: String = 					"-> "
const RETURN_VALUE_TAG: String = 				"<- "
const ERROR_TAG: String = 						" x "
const INFO_COLOR: Color = 						Color.YELLOW
const COMMAND_COLOR: Color = 					Color.GRAY
const RETURN_VALUE_COLOR: Color = 				Color.WHITE
const ERROR_COLOR: Color = 						Color.RED
const EXPRESSION_EVALUATION_TAG: String = 		"exp"

const DEBUG_METRIC_LABEL_PATH: String = 		"res://devutils/utils/DebugMetricLabel.tscn"
const OUTPUT_SCROLL_INCREMENT: float = 8.0

const ERROR_MISSING_BASE: String = 				"missing base for [command]"
const ERROR_UNKNOWN_COMMAND: String = 			"unknown command"
const ERROR_ARGUMENT_COUNT: String = 			"arg count mismatch"
const ERROR_ARGUMENT_TYPE_MISMATCH: String = 	"arg type mismatch"
const ERROR_BLACKLISTED_FUNCTION: String = 		"function not allowed: "

const HELP_TEXT: String = 						"\nHello! Welcome to DevUtils. \n\nTo get started, use the 'commandlist' command to see all commands in the database. To learn about a specific command, type 'explain' followed by that command's name. \n\nArbitrary GDScript can be provided using the 'exp' command. For example, 'exp 2+2' will return 4. \n\nRefer to the docs to learn how to implement your own custom commands. \n\nI hope this helps you!"
const LOREM_IPSUM: String = 					"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla malesuada sed tortor sed sagittis. Duis mattis at magna non volutpat. Phasellus ut metus dignissim, tempus arcu at, fermentum velit. Phasellus tincidunt dapibus massa, at ultrices nunc lobortis eu. Fusce ac nisi porttitor, molestie tortor ut, posuere ligula."

const SCROLL_HOLD_TIME: float = 0.25

enum ArgTypes {
	INT,
	STRING,
	BOOL,
	FLOAT
}

enum LogTypes {
	INFO,
	COMMAND,
	RETURN_VALUE,
	ERROR
}

var _expression_base: Node = null
var _metrics_container: Control = null
var _console_container: Control = null
var _console_output: RichTextLabel = null
var _console_output_max_height: float = 0.0
var _console_input: LineEdit = null
var _metrics_labels: Dictionary = {}
var _command_history: Array[String] = []
var _command_history_index: int = 0
var _base_viewport_size: Vector2 = Vector2.ZERO
var _debug_theme: Theme = null

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
var _function_blacklist: Array = []

var _hold_accumulator: float = 0.0
var _scroll_direction: int = 0

func _ready() -> void:
	
	InputMap.add_action("devutils")
	var devutils_input: InputEventKey = InputEventKey.new()
	devutils_input.physical_keycode = KEY_QUOTELEFT
	InputMap.action_add_event("devutils", devutils_input)
	
	layer = BASE_CANVAS_LAYER
	
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	_expression_base = Node.new()
	add_child(_expression_base)
	_expression_base.name = "ExpressionBase"
	
	_base_viewport_size = get_viewport().content_scale_size
	_debug_theme = load("res://devutils/resources/devutils_theme.tres")
	
	# Metrics
	_build_metric_layer()
	_init_builtin_metrics()
	
	# Console
	_build_console()
	_import_command_dictionary()
	_import_function_blacklist()
	_init_builtin_commands()
	_clear_output()

func _build_metric_layer() -> void:
	
	# Container
	_metrics_container = Control.new()
	add_child(_metrics_container)
	_metrics_container.name = "MetricsContainer"
	_metrics_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	_metrics_container.theme = _debug_theme
	
	# LeftPanel
	var left_metrics_panel: VBoxContainer = VBoxContainer.new()
	_metrics_container.add_child(left_metrics_panel)
	left_metrics_panel.name = "LeftPanel"
	left_metrics_panel.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	left_metrics_panel.custom_minimum_size = Vector2(
		_base_viewport_size.x * 0.5,
		_base_viewport_size.y
	)
	left_metrics_panel.position = Vector2.ZERO
	
	# Right Panel
	var right_metrics_panel: VBoxContainer = VBoxContainer.new()
	_metrics_container.add_child(right_metrics_panel)
	right_metrics_panel.name = "RightPanel"
	right_metrics_panel.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	right_metrics_panel.custom_minimum_size = Vector2(
		_base_viewport_size.x * 0.5,
		_base_viewport_size.y
	)
	right_metrics_panel.position = Vector2(
		_base_viewport_size.x * 0.5,
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
	_console_container.size = _base_viewport_size
	_console_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	_console_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_console_container.theme = _debug_theme
	
	# Shader Background
	var shader_background: ColorRect = ColorRect.new()
	_console_container.add_child(shader_background)
	shader_background.name = "ShaderBackground"
	shader_background.set_deferred("anchors_preset", Control.PRESET_FULL_RECT)
	shader_background.size = _base_viewport_size
	shader_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shader_background.material = load("res://devutils/resources/background_shader_material.tres")
	
	# Gray Background
	var console_background: ColorRect = ColorRect.new()
	_console_container.add_child(console_background)
	console_background.name = "Background"
	console_background.set_deferred("anchors_preset", Control.PRESET_FULL_RECT)
	console_background.size = _base_viewport_size
	console_background.color = Color("55555555")
	console_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# ConsoleOutput
	_console_output = RichTextLabel.new()
	_console_container.add_child(_console_output)
	_console_output.name = "ConsoleOutput"
	_console_output.fit_content = true
	_console_output.scroll_active = false
	_console_output.scroll_following = true
	_console_output.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_console_output.size = Vector2(_base_viewport_size.x, 0.0)
	_console_output.custom_minimum_size = Vector2(
		_base_viewport_size.x,
		#_base_viewport_size.y - 16.0
		0.0
	)
	_console_output.set_deferred("anchors_preset", Control.PRESET_BOTTOM_WIDE)
	_console_output.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_console_output_max_height = _base_viewport_size.y - 16.0
	_console_output.resized.connect(_on_console_output_resized)
	
	# ConsoleInput
	_console_input = LineEdit.new()
	_console_container.add_child(_console_input)
	_console_input.name = "ConsoleInput"
	_console_input.set_caret_blink_enabled(true)
	_console_input.set_caret_blink_interval(0.25)
	_console_input.size = Vector2(_base_viewport_size.x, 16.0)
	_console_input.position = Vector2(0.0, _base_viewport_size.y - 16.0)
	_console_input.set_deferred("anchors_preset", Control.PRESET_BOTTOM_WIDE)
	_console_input.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_console_input.text_submitted.connect(_on_console_input_submitted)
	
	_console_container.visible = false

func _import_command_dictionary() -> void:
	if !FileAccess.file_exists("res://devutils/data/commands.json"):
		printerr("DevUtils @ _import_command_dictionary(): COMMAND_FILE_PATH is invalid.")
		return
	var file_access: FileAccess = FileAccess.open("res://devutils/data/commands.json", FileAccess.READ)
	_command_dictionary = JSON.parse_string(file_access.get_as_text())
	file_access.close()
	if _command_dictionary == null:
		printerr("DevUtils @ _import_command_dictionary(): commands.json failed to parse, make sure it is formatted correctly!")
		return
	for command_string in _command_dictionary.keys():
		if !_command_dictionary[command_string].has("arg_count"):
			_command_dictionary[command_string]["arg_count"] = 0
		if !_command_dictionary[command_string].has("missing_base_error"):
			_command_dictionary[command_string]["missing_base_error"] = ERROR_MISSING_BASE
		_command_dictionary[command_string]["arg_types"] = []
		_command_dictionary[command_string]["callable"] = null

func _import_function_blacklist() -> void:
	if !FileAccess.file_exists("res://devutils/data/function_blacklist.json"):
		printerr("DevUtils @ _import_function_blacklist(): file path is invalid.")
		return
	var file_access: FileAccess = FileAccess.open("res://devutils/data/function_blacklist.json", FileAccess.READ)
	var dictionary: Dictionary = JSON.parse_string(file_access.get_as_text())
	_function_blacklist = dictionary["expressions"]
	file_access.close()
	if _function_blacklist == null:
		printerr("DevUtils @ _import_function_blacklist(): function_blacklist.json failed to parse, make sure it is formatted correctly!")
		return

func _init_builtin_commands() -> void:
	init_command("help", _debug_help)
	init_command("commandlist", _debug_commandlist)
	init_command("explain", _debug_explain, [ArgTypes.STRING])
	init_command("clearout", _clear_output)
	init_command("clearhist", _clear_history)
	init_command("clearall", _clear_all)
	init_command("metrics", _show_metrics)
	init_command("dump", _dump_output)
	init_command("newline", _log_empty_line)
	init_command("loremipsum", _debug_lorem_ipsum)
	init_command("quit", get_tree().quit)

func init_command(command_string: String, callable: Callable, args: Array[ArgTypes] = []) -> void:
	command_string = command_string.replace(" ", "")
	if !_command_dictionary.has(command_string):
		printerr("DevUtils @ init_command(): Failed to init command ", command_string, " as it does not exist in commands.json.")
		return
	if args.size() != _command_dictionary[command_string]["arg_count"]:
		printerr("DevUtils @ init_command(): Failed to init command ", command_string, ". Expected ", _command_dictionary[command_string]["arg_count"], " arguments, but was provided ", args.size(), ".")
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
		
		if event.is_action_pressed("devutils"): 
			_close_console()
	elif event.is_action_pressed("devutils"):
		_open_console()

func _physics_process(delta: float) -> void:
	var scroll_released: bool = (Input.is_action_just_released("ui_page_up") or Input.is_action_just_released("ui_page_down"))
	var both_held: bool = (Input.is_action_pressed("ui_page_up") and Input.is_action_pressed("ui_page_down"))
	
	if scroll_released or both_held:
		_scroll_direction = 0
		_hold_accumulator = 0.0
		return
	
	if Input.is_action_just_pressed("ui_page_up"):
		_scroll_direction = 1
		_scroll_output(_scroll_direction)
	elif Input.is_action_just_pressed("ui_page_down"):
		_scroll_direction = -1
		_scroll_output(_scroll_direction)
	
	if _scroll_direction != 0:
		_hold_accumulator += delta
		if _hold_accumulator >= SCROLL_HOLD_TIME:
			_scroll_output(_scroll_direction)

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
	if _console_output.size.y <= _console_output_max_height:
		return
	_console_output.position.y += OUTPUT_SCROLL_INCREMENT * scroll_direction
	_console_output.position.y = clamp(
		_console_output.position.y, 
		(_console_output_max_height - _console_output.size.y), 
		0.0
	) 

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

func _console_log(log_text: String, log_type: LogTypes) -> void:
	var output_string: String = str(log_text)
	match log_type:
		LogTypes.INFO:
			_console_output.push_color(INFO_COLOR)
			_console_output.append_text(str("\n", output_string))
			_console_output.pop()
		LogTypes.COMMAND:
			output_string = str(COMMAND_TAG, output_string)
			_console_output.push_color(COMMAND_COLOR)
			_console_output.append_text(str("\n", output_string))
			_console_output.pop()
		LogTypes.RETURN_VALUE:
			output_string = str(RETURN_VALUE_TAG, output_string)
			_console_output.push_color(RETURN_VALUE_COLOR)
			_console_output.append_text(str("\n", output_string))
			_console_output.pop()
		LogTypes.ERROR:
			output_string = str(ERROR_TAG, output_string)
			_console_output.push_color(ERROR_COLOR)
			_console_output.append_text(str("\n", output_string))
			_console_output.pop()

func _on_console_output_resized() -> void:
	# simulate scroll
	# use the signal because there is literally no other way to tell EXACTLY
	# when a Control has resized...
	_console_output.position.y = _console_output_max_height - _console_output.size.y

func _on_console_input_submitted(new_text: String) -> void:
	if new_text == "": return
	_console_input.text = ""
	_command_history.append(new_text)
	_command_history_index = _command_history.size()
	_handle_command(new_text)
	#if result != "":
		#_console_log(result, LogTypes.RETURN_VALUE)

func _handle_command(command_text: String) -> void:
	var words: PackedStringArray = command_text.split(" ", false)
	if words.size() == 0: return
	
	if words[0] == "exp": 
		_handle_expression(command_text)
		return 
	
	if command_text != "newline":
		_console_log(command_text, LogTypes.COMMAND)
	
	if !_command_dictionary.has(words[0]):
		_console_log(str(ERROR_UNKNOWN_COMMAND, " '", words[0], "'"), LogTypes.ERROR)
		return
	
	var command: Dictionary = _command_dictionary[words[0]]
	if command["callable"] == null or !command["callable"].is_valid():
		var missing_base_error: String = command["missing_base_error"]
		if missing_base_error.contains("[command]"):
			missing_base_error = missing_base_error.replace("[command]", words[0])
		_console_log(missing_base_error, LogTypes.ERROR)
		return
	
	var command_args: Array[String] = []
	for i in range(words.size()):
		if i == 0: continue
		command_args.append(words[i])
	
	if command_args.size() != command["arg_count"]:
		var info: String = str(" (expected ", command["arg_count"], ", received ", command_args.size(), ")")
		_console_log(str(ERROR_ARGUMENT_COUNT, info), LogTypes.ERROR)
		return
	
	if command["arg_count"] == 0:
		var no_arg_result: Variant = command["callable"].call()
		if no_arg_result == null: return
		_console_log(no_arg_result, LogTypes.RETURN_VALUE)
		return
	
	var cast_args: Array = []
	for i in range(command["arg_count"]):
		var arg_type: int = _get_arg_type(command_args[i])
		if arg_type != command["arg_types"][i]:
			var info: String = str(" (expected ", _get_type_string(command["arg_types"][i]), ", received ", _get_type_string(arg_type), " at position ", i, ")")
			_console_log(str(ERROR_ARGUMENT_TYPE_MISMATCH, info), LogTypes.ERROR)
			return 
		cast_args.append(_cast_type(command_args[i], arg_type))
	
	var arg_result: Variant = command["callable"].callv(cast_args)
	if arg_result == null: return
	_console_log(arg_result, LogTypes.RETURN_VALUE)

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

func _handle_expression(command_text: String) -> void:
	_console_log(command_text, LogTypes.COMMAND)
	var expression_text: String = command_text.lstrip(str(EXPRESSION_EVALUATION_TAG, " "))
	var blacklisted_function: String = _get_blacklisted_function(expression_text)
	if blacklisted_function != "":
		_console_log(str(ERROR_BLACKLISTED_FUNCTION, blacklisted_function), LogTypes.ERROR)
		return
	var expression: Expression = Expression.new()
	var error: Error = expression.parse(expression_text)
	if error != OK:
		_console_log(str(expression.get_error_text()), LogTypes.ERROR)
		return
	var result: Variant = expression.execute([], _expression_base, false)
	if expression.has_execute_failed():
		_console_log("execution failed", LogTypes.ERROR)
		return
	_console_log(str(result), LogTypes.RETURN_VALUE)

func _get_blacklisted_function(expression_text: String) -> String:
	for function in _function_blacklist:
		if function in expression_text:
			return function
	return ""

func _clear_output() -> void:
	_console_output.clear()
	_console_output.size = _console_output.custom_minimum_size
	_console_output.position = Vector2.ZERO
	_console_log(VERSION_TEXT, LogTypes.INFO)
	_console_log(BYLINE, LogTypes.INFO)

func _clear_history() -> void:
	_command_history = []
	_command_history_index = 0

func _clear_all() -> void:
	_clear_output()
	_clear_history()

func _debug_commandlist() -> String:
	var commands: Array = _command_dictionary.keys()
	commands.sort()
	var return_string: String = ""
	for command in commands:
		return_string += str("\n", command)
	return return_string

func _debug_help() -> String:
	return HELP_TEXT

func _debug_explain(command_name: String) -> String:
	var valid_commands: Array = _command_dictionary.keys()
	if command_name not in valid_commands:
		return str("'", command_name, "' is not a recognized command.")
	var command: Dictionary = _command_dictionary[command_name]
	if not command.has("explain_text"):
		return "no explain text provided :("
	return command["explain_text"]

func _show_metrics() -> void:
	_metrics_container.visible = !_metrics_container.visible

func _dump_output() -> void:
	var module_directory: String = get_script().resource_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(str(module_directory) + "/dump"):
		DirAccess.make_dir_absolute(str(module_directory) + "/dump")
	var datetime_string: String = Time.get_datetime_string_from_system().replace(":", "-")
	var file_name: String = str(module_directory + "/dump/output_dump-" + datetime_string + ".txt")
	var dump: FileAccess = FileAccess.open(file_name, FileAccess.WRITE)
	dump.store_line(_console_output.get_parsed_text())
	dump.close()

func _log_empty_line() -> void:
	_console_log(" ", LogTypes.RETURN_VALUE)

func _debug_lorem_ipsum() -> void:
	_console_log(LOREM_IPSUM, LogTypes.RETURN_VALUE)

func _debug_get_static_memory_usage() -> String:
	return String.humanize_size(OS.get_static_memory_usage())









