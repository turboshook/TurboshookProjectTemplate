extends Node

enum ArgTypes {
	INT,
	STRING,
	BOOL,
	FLOAT
}

var _settings: DevUtilsSettings = null
var _context: DevUtilsContext = null
var _canvas_layer: CanvasLayer
var _metrics_viewer: DevUtilsMetricsViewer
var _console: DevUtilsConsole
var _hold_accumulator: float = 0.0
var _enabled: bool = true

func _ready() -> void:
	
	_enabled = OS.is_debug_build()
	if !_enabled: return
	
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	
	# Get settings Resource
	var module_directory: String = get_script().resource_path.get_base_dir()
	_settings = load(module_directory + "/settings.tres")
	if not _settings:
		push_warning("DevUtils @ _ready(): settings.tres not found in module root directory. DevUtils will not function.")
		_enabled = false
		return
	# This value is overridden if not using the Forward+ renderer.
	_settings.use_shader_background = (
		_settings.use_shader_background and 
		ProjectSettings.get_setting("rendering/renderer/rendering_method") == "forward_plus"
	)
	
	# Initialize context Resource
	_context = DevUtilsContext.new()
	_context.module_directory = module_directory
	_context.base_viewport_size = get_viewport().content_scale_size 
	_context.expression_base =  DevUtilsExpressionBase.new()
	add_child(_context.expression_base)
	_context.expression_base.name = "DevUtilsExpressionBase"
	
	# Create required input actions
	InputMap.add_action("dev_utils_console")
	var devutils_input: InputEventKey = InputEventKey.new()
	devutils_input.physical_keycode = KEY_QUOTELEFT
	InputMap.action_add_event("dev_utils_console", devutils_input)
	
	InputMap.add_action("history_up")
	var history_up_input: InputEventKey = InputEventKey.new()
	history_up_input.physical_keycode = KEY_UP
	InputMap.action_add_event("history_up", history_up_input)
	
	InputMap.add_action("history_down")
	var history_down_input: InputEventKey = InputEventKey.new()
	history_down_input.physical_keycode = KEY_DOWN
	InputMap.action_add_event("history_down", history_down_input)
	
	InputMap.add_action("output_scroll_up")
	var output_scroll_up_input: InputEventKey = InputEventKey.new()
	output_scroll_up_input.physical_keycode = KEY_PAGEUP
	InputMap.action_add_event("output_scroll_up", output_scroll_up_input)
	
	InputMap.add_action("output_scroll_down")
	var output_scroll_down_input: InputEventKey = InputEventKey.new()
	output_scroll_down_input.physical_keycode = KEY_PAGEDOWN
	InputMap.action_add_event("output_scroll_down", output_scroll_down_input)
	
	# CanvasLayer
	_canvas_layer = CanvasLayer.new()
	add_child(_canvas_layer)
	_canvas_layer.name = "CanvasLayer"
	_canvas_layer.layer = _settings.base_canvas_layer
	
	# Metrics
	_metrics_viewer = DevUtilsMetricsViewer.new()
	_canvas_layer.add_child(_metrics_viewer)
	_metrics_viewer.name = "DevUtilsMetricsViewer"
	_metrics_viewer.initialize(_context, _settings)
	_init_builtin_metrics()
	_metrics_viewer.metric_invalidated.connect(_on_metric_invalidated)
	
	# Console
	_console = DevUtilsConsole.new()
	_canvas_layer.add_child(_console)
	_console.name = "DevUtilsConsole"
	_console.initialize(_context, _settings)
	_import_command_dictionary()
	_import_function_blacklist()
	_init_builtin_commands()

func init_metric(metric_name: String, update_callable: Callable, left_panel: bool = true) -> void:
	
	if !_enabled: return
	
	# metric already exists
	if _context.metrics.has(metric_name):
		push_warning("DevUtils @ init_metric(): Metric '", metric_name, "' already exists. Current update callable will be overridden.")
		return
		#_metrics_viewer.update_metric_label(metric_name, update_callable)
	
	# create new metric label
	_context.metrics[metric_name] = update_callable
	_metrics_viewer.create_metric_label(metric_name, update_callable, left_panel)

func _init_builtin_metrics() -> void:
	init_metric("fps", Engine.get_frames_per_second, false)
	init_metric("mem", func(): return String.humanize_size(OS.get_static_memory_usage()), false)

func _on_metric_invalidated(metric_name: String) -> void:
	if _context.metrics.has(metric_name):
		_context.metrics.erase(metric_name)

func init_command(command_string: String, callable: Callable, args: Array[ArgTypes] = []) -> void:
	
	if !_enabled: return
	
	command_string = command_string.replace(" ", "")
	var command_found: bool = false
	var command_base: String = ""
	for base in _context.command_dictionary.keys():
		command_base = base
		for command in _context.command_dictionary[base].keys():
			if command_string == command:
				command_found = true
				break
		if command_found:
			break
	if !command_found:
		printerr("DevUtils @ init_command(): Failed to init command '", command_string, "'; it does not exist in commands.json.")
		return
	if args.size() != _context.command_dictionary[command_base][command_string]["arg_count"]:
		printerr("DevUtils @ init_command(): Failed to init command '", command_string, "'; expected ", _context.command_dictionary[command_base][command_string]["arg_count"], " arguments, but was provided ", args.size(), ".")
		return
	for arg_type in args:
		_context.command_dictionary[command_base][command_string]["arg_types"].append(arg_type)
	_context.command_dictionary[command_base][command_string]["callable"] = callable

func _import_command_dictionary() -> void:
	if !FileAccess.file_exists(_context.module_directory + "/data/commands.json"):
		printerr("DevUtils @ _import_command_dictionary(): COMMAND_FILE_PATH is invalid.")
		return
	var file_access: FileAccess = FileAccess.open(_context.module_directory + "/data/commands.json", FileAccess.READ)
	var command_dictionary: Dictionary = JSON.parse_string(file_access.get_as_text())
	file_access.close()
	if command_dictionary == null:
		printerr("DevUtils @ _import_command_dictionary(): commands.json failed to parse, make sure it is formatted correctly!")
		return
	for category in command_dictionary.keys():
		for command in command_dictionary[category].keys():
			if !command_dictionary[category][command].has("arg_count"):
				command_dictionary[category][command]["arg_count"] = 0
			if !command_dictionary[category][command].has("missing_base_error"):
				command_dictionary[category][command]["missing_base_error"] = _settings.missing_base_error_string
			command_dictionary[category][command]["arg_types"] = []
			command_dictionary[category][command]["callable"] = null
	_context.command_dictionary = command_dictionary

func _import_function_blacklist() -> void:
	if !FileAccess.file_exists(_context.module_directory + "/data/function_blacklist.json"):
		printerr("DevUtils @ _import_function_blacklist(): file path is invalid.")
		return
	var file_access: FileAccess = FileAccess.open(_context.module_directory + "/data/function_blacklist.json", FileAccess.READ)
	var dictionary: Dictionary = JSON.parse_string(file_access.get_as_text())
	var function_blacklist: Array = dictionary["expressions"]
	file_access.close()
	if function_blacklist == null:
		printerr("DevUtils @ _import_function_blacklist(): function_blacklist.json failed to parse, make sure it is formatted correctly!")
		return
	_context.function_blacklist = function_blacklist as Array[String]

func _init_builtin_commands() -> void:
	init_command("commandlist", _commandlist)
	init_command("explain", _explain, [ArgTypes.STRING])
	init_command("help", func(): return _settings.help_command_string)
	init_command("clearout", _console.clear_output)
	init_command("clearhist", _console.clear_history)
	init_command("clearall", _console.clear_all)
	init_command("metrics", func(): _metrics_viewer.visible = !_metrics_viewer.visible)
	init_command("dump", func(): return dump_file_text("console_output", _console.get_output()))
	init_command("screenshot", _take_screenshot)
	init_command("timescale", Engine.set_time_scale, [ArgTypes.FLOAT])
	init_command("newline", func(): return " ")
	init_command("loremipsum", func(): return _settings.lorem_ipsum)
	init_command("quit", get_tree().quit)

func _commandlist() -> String:
	var categories: Array = _context.command_dictionary.keys()
	var return_string: String = "\n"
	for category in categories:
		return_string += str("\n" + category.to_upper())
		var commands: Array = _context.command_dictionary[category].keys()
		commands.sort()
		for command in commands:
			return_string += str("\n" + " - " + command)
		return_string += "\n"
	return return_string

func _explain(command_name: String) -> String:
	var categories: Array = _context.command_dictionary.keys()
	for category in categories:
		if not _context.command_dictionary[category].has(command_name): 
			continue
		var command_dictionary: Dictionary = _context.command_dictionary[category][command_name]
		if not command_dictionary.has("explain_text"):
			return _settings.missing_explain_text_string
		return command_dictionary["explain_text"]
	return str("'", command_name, "' is not a recognized command.")

func dump_file_text(file_name_identifier: String, data: String) -> String:
	if not DirAccess.dir_exists_absolute(_context.module_directory + "/dump"):
		DirAccess.make_dir_absolute(_context.module_directory + "/dump")
	var datetime_string: String = Time.get_datetime_string_from_system().replace(":", "-")
	var file_path: String = _context.module_directory + "/dump/"
	var file_name: String = file_name_identifier + "-" + datetime_string + ".txt"
	var dump: FileAccess = FileAccess.open(file_path + file_name, FileAccess.WRITE)
	dump.store_line(data)
	dump.close()
	return file_name

func dump_file_json(file_name_identifier: String, data: Dictionary) -> String:
	if not DirAccess.dir_exists_absolute(_context.module_directory + "/dump"):
		DirAccess.make_dir_absolute(_context.module_directory + "/dump")
	var datetime_string: String = Time.get_datetime_string_from_system().replace(":", "-")
	var file_path: String = _context.module_directory + "/dump/"
	var file_name: String = file_name_identifier + "-" + datetime_string + ".json"
	var dump: FileAccess = FileAccess.open(file_path + file_name, FileAccess.WRITE)
	var string_data: String = JSON.stringify(data, "\t", false)
	dump.store_line(string_data)
	dump.close()
	return file_name

func _take_screenshot() -> String:
	if not DirAccess.dir_exists_absolute(_context.module_directory + "/dump"):
		DirAccess.make_dir_absolute(_context.module_directory + "/dump")
	var file_path: String = _context.module_directory + "/dump/"
	var datetime_string: String = Time.get_datetime_string_from_system().replace(":", "-")
	var file_name: String = "screenshot-" + datetime_string + ".png"
	_console.close()
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	var window_width_override: int = ProjectSettings.get_setting("display/window/size/window_width_override")
	var window_height_override: int = ProjectSettings.get_setting("display/window/size/window_height_override")
	@warning_ignore("integer_division")
	var scale_factor_x: int = max(1, (window_width_override / image.get_width()))
	@warning_ignore("integer_division")
	var scale_factor_y: int = max(1, (window_height_override / image.get_height()))
	image.resize(
		image.get_width() * scale_factor_x, 
		image.get_height() * scale_factor_y, 
		Image.INTERPOLATE_NEAREST
	)
	image.save_png(file_path + file_name)
	_console.open()
	return file_name

func _process(delta: float) -> void:
	
	if !_enabled: return
	
	var scroll_released: bool = (Input.is_action_just_released("ui_page_up") or Input.is_action_just_released("ui_page_down"))
	var both_held: bool = (Input.is_action_pressed("ui_page_up") and Input.is_action_pressed("ui_page_down"))
	
	if scroll_released or both_held:
		_hold_accumulator = 0.0
		return
	
	# Scroll action pressed
	var scroll_direction: int = 0
	if Input.is_action_just_pressed("output_scroll_up"):
		scroll_direction = 1
		_console.scroll_output(1)
	elif Input.is_action_just_pressed("output_scroll_down"):
		scroll_direction = -1
		_console.scroll_output(-1)
	
	# Scroll action held
	if scroll_direction != 0:
		_hold_accumulator += delta
		if _hold_accumulator >= 0.25:
			_console.scroll_output(scroll_direction)

func _input(event: InputEvent) -> void:
	
	if !_enabled: return
	
	if _console.visible:
		if event.is_action_pressed("history_up"): _console.check_history(-1)
		elif event.is_action_pressed("history_down"): _console.check_history(1)
		if event.is_action_pressed("dev_utils_console"): _close_console()
	elif event.is_action_pressed("dev_utils_console"):
		_open_console()

func _open_console() -> void:
	get_tree().paused = true
	_console.visible = true
	_console.open()

func _close_console() -> void:
	get_tree().paused = false
	_console.close()

func _on_dev_utils_tree_exiting() -> void:
	_context.metrics = {}
