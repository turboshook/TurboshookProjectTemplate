extends Control
class_name DevUtilsConsole

enum LogTypes {
	INFO,
	COMMAND,
	RETURN_VALUE,
	ERROR,
	BLANK
}

const EXPRESSION_EVALUATION_TAG: String = "exp"
const OUTPUT_SCROLL_INCREMENT: float = 			8.0

var _context: DevUtilsContext
var _settings: DevUtilsSettings

var _console_output: RichTextLabel
var _console_input: LineEdit 

var _console_output_max_height: float = 0.0
var _max_scroll_height: float = 0.0
var _command_history: Array[String] = []
var _command_history_index: int = 0

func initialize(context: DevUtilsContext, settings: DevUtilsSettings) -> void:
	_context = context
	_settings = settings
	_build_scene()
	clear_all()

func _build_scene() -> void:
	
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = _settings.dev_utils_theme
	
	# Shader Background
	if _settings.use_shader_background:
		var shader_background: ColorRect = ColorRect.new()
		add_child(shader_background)
		shader_background.name = "ShaderBackground"
		shader_background.set_deferred("anchors_preset", Control.PRESET_FULL_RECT)
		shader_background.size = _context.base_viewport_size
		shader_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		shader_background.material = load(_context.module_directory + "/resources/shader/background_shader_material.tres")
	
	# Console Background Rect
	var console_background: ColorRect = ColorRect.new()
	add_child(console_background)
	console_background.name = "Background"
	console_background.set_deferred("anchors_preset", Control.PRESET_FULL_RECT)
	console_background.size = _context.base_viewport_size
	console_background.color = _settings.console_output_background_color
	console_background.color.a = _settings.console_output_background_alpha
	console_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Console Output
	_console_output = RichTextLabel.new()
	add_child(_console_output)
	_console_output.name = "ConsoleOutput"
	_console_output.fit_content = true
	_console_output.scroll_active = false
	_console_output.scroll_following = true
	_console_output.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_console_output.size = Vector2(_context.base_viewport_size.x, 0.0)
	_console_output.custom_minimum_size = Vector2(
		_context.base_viewport_size.x,
		0.0
	)
	_console_output.set_deferred("anchors_preset", Control.PRESET_BOTTOM_WIDE)
	_console_output.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_console_output_max_height = _context.base_viewport_size.y - 16.0
	_console_output.resized.connect(_on_console_output_resized)
	
	# ConsoleInput
	_console_input = LineEdit.new()
	add_child(_console_input)
	_console_input.name = "ConsoleInput"
	_console_input.keep_editing_on_text_submit = true
	_console_input.caret_blink = true
	_console_input.caret_blink_interval = 0.25
	_console_input.size = Vector2(_context.base_viewport_size.x, 16.0)
	_console_input.position = Vector2(0.0, _context.base_viewport_size.y - 16.0)
	_console_input.set_deferred("anchors_preset", Control.PRESET_BOTTOM_WIDE)
	var _input_normal_stylebox: StyleBoxFlat = _settings.dev_utils_theme.get_stylebox("normal", "LineEdit")
	_input_normal_stylebox.bg_color = _settings.console_input_background_color
	_input_normal_stylebox.bg_color.a = _settings.console_input_background_alpha
	_console_input.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_console_input.text_submitted.connect(_on_console_input_submitted)
	
	# ensure nice-looking output scrolling 
	var viewport_y_mod_line_height: float = fmod(_context.base_viewport_size.y, 8.0)
	if viewport_y_mod_line_height != 0: # I am so smart :)
		_max_scroll_height = viewport_y_mod_line_height - OUTPUT_SCROLL_INCREMENT
	
	visible = false

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

func log_output(log_text: String, log_type: LogTypes) -> void:
	var output_string: String = str(log_text)
	match log_type:
		LogTypes.INFO:
			_console_output.push_color(_settings.info_color)
			_console_output.append_text(str("\n", output_string))
			_console_output.pop()
		LogTypes.COMMAND:
			output_string = str(_settings.command_tag, output_string)
			_console_output.push_color(_settings.comand_color)
			_console_output.append_text(str("\n", output_string))
			_console_output.pop()
		LogTypes.RETURN_VALUE:
			output_string = str(_settings.return_value_tag, output_string)
			_console_output.push_color(_settings.return_value_color)
			_console_output.append_text(str("\n", output_string))
			_console_output.pop()
		LogTypes.ERROR:
			output_string = str(_settings.error_tag, output_string)
			_console_output.push_color(_settings.error_color)
			_console_output.append_text(str("\n", output_string))
			_console_output.pop()
		LogTypes.BLANK:
			output_string = str("   ", output_string)
			_console_output.append_text(str("\n", output_string))

func _handle_command(command_text: String) -> void:
	var words: PackedStringArray = command_text.split(" ", false)
	if words.size() == 0: return
	
	if words[0] == EXPRESSION_EVALUATION_TAG: 
		_handle_expression(command_text)
		return 
	
	if command_text != "newline":
		log_output(command_text, LogTypes.COMMAND)
	
	var command_found: bool = false
	var command_category: String = ""
	for category in _context.command_dictionary.keys():
		command_category = category
		for command in _context.command_dictionary[category].keys():
			if words[0] == command:
				command_found = true
				break
		if command_found:
			break
	
	if !command_found:
		log_output(str(_settings.unknown_command_error_string, " '", words[0], "'"), LogTypes.ERROR)
		return
	
	var command: Dictionary = _context.command_dictionary[command_category][words[0]]
	if command["callable"] == null or !command["callable"].is_valid():
		var missing_base_error: String = command["missing_base_error"]
		if missing_base_error.contains("[command]"):
			missing_base_error = missing_base_error.replace("[command]", words[0])
		log_output(missing_base_error, LogTypes.ERROR)
		return
	
	var command_args: Array[String] = []
	for i in range(words.size()):
		if i == 0: continue
		command_args.append(words[i])
	
	if command_args.size() != command["arg_count"]:
		var info: String = str(" (expected ", int(command["arg_count"]), ", received ", command_args.size(), ")")
		log_output(str(_settings.argument_count_error_string, info), LogTypes.ERROR)
		return
	
	if command["arg_count"] == 0:
		var no_arg_result: Variant = await command["callable"].call()
		if no_arg_result == null: return
		log_output(str(no_arg_result), LogTypes.RETURN_VALUE)
		return
	
	var cast_args: Array = []
	for i in range(command["arg_count"]):
		
		# special case: clean otherwise valid float inputs given as integers
		if command["arg_types"][i] == DevUtils.ArgTypes.FLOAT and command_args[i].is_valid_int() and not command_args[i].contains("."):
			command_args[i] += ".0"
		
		var arg_type: int = _get_arg_type(command_args[i])
		if arg_type != command["arg_types"][i]:
			var info: String = str(" (expected ", _get_type_string(command["arg_types"][i]), ", received ", _get_type_string(arg_type), " at position ", i, ")")
			log_output(str(_settings.argument_type_error_string, info), LogTypes.ERROR)
			return 
		cast_args.append(_cast_type(command_args[i], arg_type))
	
	var arg_result: Variant = await command["callable"].callv(cast_args)
	if arg_result == null: return
	log_output(str(arg_result), LogTypes.RETURN_VALUE)

func _get_arg_type(arg_string: String) -> DevUtils.ArgTypes:
	if arg_string.is_valid_int(): return DevUtils.ArgTypes.INT
	if arg_string.is_valid_float(): return DevUtils.ArgTypes.FLOAT
	if (arg_string == "true" or arg_string == "false"): return DevUtils.ArgTypes.BOOL
	return DevUtils.ArgTypes.STRING

func _get_type_string(arg_type: DevUtils.ArgTypes) -> String:
	if arg_type == DevUtils.ArgTypes.INT: return "INT"
	if arg_type == DevUtils.ArgTypes.FLOAT: return "FLOAT"
	if arg_type == DevUtils.ArgTypes.STRING: return "STR"
	if arg_type == DevUtils.ArgTypes.BOOL: return "BOOL"
	return "_"

func _cast_type(arg_string: String, type: DevUtils.ArgTypes):
	if type == DevUtils.ArgTypes.INT: return arg_string as int
	if type == DevUtils.ArgTypes.FLOAT: return arg_string as float
	if type == DevUtils.ArgTypes.STRING: return arg_string
	if type == DevUtils.ArgTypes.BOOL: return str_to_var(arg_string)
	return "BAD CAST"

func _handle_expression(command_text: String) -> void:
	log_output(command_text, LogTypes.COMMAND)
	var expression_text: String = command_text.lstrip(str(EXPRESSION_EVALUATION_TAG, " "))
	var blacklisted_function: String = _get_blacklisted_function(expression_text)
	if blacklisted_function != "":
		log_output(str(_settings.blacklisted_function_error_string, blacklisted_function), LogTypes.ERROR)
		return
	var expression: Expression = Expression.new()
	var error: Error = expression.parse(expression_text, _context.expression_base.GLOBAL_NAMES)
	if error != OK:
		log_output(str(expression.get_error_text()), LogTypes.ERROR)
		return
	var result: Variant = expression.execute(
		_context.expression_base.get_global_classes(), _context.expression_base, false
	)
	if expression.has_execute_failed():
		log_output(expression.get_error_text(), LogTypes.ERROR)
		return
	log_output(str(result), LogTypes.RETURN_VALUE)

func _get_blacklisted_function(expression_text: String) -> String:
	for function in _context.function_blacklist:
		if function in expression_text:
			return function
	return ""

func _scroll_output(scroll_direction: int) -> void:
	# return if no resizing due to text
	if _console_output.size.y <= _console_output_max_height: return
	_console_output.position.y += OUTPUT_SCROLL_INCREMENT * scroll_direction
	_console_output.position.y = clamp(
		_console_output.position.y, 
		(_console_output_max_height - _console_output.size.y), 
		_max_scroll_height
	) 

func get_output() -> String:
	return _console_output.get_parsed_text()

func check_history(index_change: int) -> void:
	_command_history_index += index_change
	_command_history_index = clamp(_command_history_index, 0, _command_history.size())
	if _command_history_index == _command_history.size():
		_console_input.text = ""
	else:
		var recalled_command_text: String = _command_history[_command_history_index]
		_console_input.text = recalled_command_text
		await RenderingServer.frame_post_draw # awaits Control transform
		_console_input.caret_column = recalled_command_text.length()

func clear_history() -> void:
	_command_history = []
	_command_history_index = 0

func clear_output() -> void:
	_console_output.clear()
	_console_output.size = _console_output.custom_minimum_size
	_console_output.position = Vector2.ZERO
	await RenderingServer.frame_post_draw # otherwise below boilerplate is occasionally omitted
	log_output(str(" -- DevUtils [v", _settings.version, "] -- "), LogTypes.INFO)
	log_output("      by turboshook     ", LogTypes.INFO)

func clear_all() -> void:
	clear_output()
	clear_history()

func open() -> void:
	visible = true
	_console_input.grab_focus.call_deferred()

func close() -> void:
	visible = false
