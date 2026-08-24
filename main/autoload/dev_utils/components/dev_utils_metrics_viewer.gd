extends Control
class_name DevUtilsMetricsViewer

var _context: DevUtilsContext
var _settings: DevUtilsSettings
var _left_metrics_panel: VBoxContainer
var _right_metrics_panel: VBoxContainer

signal metric_invalidated(metric_name: String)

func initialize(context: DevUtilsContext, settings: DevUtilsSettings) -> void:
	_context = context
	_settings = settings
	_build_scene()

func _build_scene() -> void:
	
	# Container
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = _settings.dev_utils_theme
	
	# LeftPanel
	_left_metrics_panel = VBoxContainer.new()
	add_child(_left_metrics_panel)
	_left_metrics_panel.name = "LeftPanel"
	_left_metrics_panel.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	_left_metrics_panel.custom_minimum_size = Vector2(
		_context.base_viewport_size.x * 0.5,
		_context.base_viewport_size.y
	)
	_left_metrics_panel.position = Vector2.ZERO
	
	# Right Panel
	_right_metrics_panel = VBoxContainer.new()
	add_child(_right_metrics_panel)
	_right_metrics_panel.name = "RightPanel"
	_right_metrics_panel.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	_right_metrics_panel.custom_minimum_size = Vector2(
		_context.base_viewport_size.x * 0.5,
		_context.base_viewport_size.y
	)
	_right_metrics_panel.position = Vector2(
		_context.base_viewport_size.x * 0.5,
		0.0
	) 
	
	visible = false

func create_metric_label(metric_name: String, update_callable: Callable, left_panel: bool = true) -> void:
	var metric_label: DevUtilsDebugMetricLabel = load(_context.module_directory + "/utils/debug_metric_label.tscn").instantiate()
	if left_panel:
		_left_metrics_panel.add_child(metric_label)
	else:
		_right_metrics_panel.add_child(metric_label)
		metric_label.h_box_container.alignment = BoxContainer.AlignmentMode.ALIGNMENT_END
	metric_label.init(metric_name, update_callable)
	metric_label.update_callable_invalid.connect(_on_label_update_callable_invalid)

func _on_label_update_callable_invalid(label: DevUtilsDebugMetricLabel) -> void:
	metric_invalidated.emit(label.get_metric_name())
	label.queue_free()
