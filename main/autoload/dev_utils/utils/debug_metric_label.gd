extends Control
class_name DevUtilsDebugMetricLabel

@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var _metric_name_label: Label = $HBoxContainer/MetricName
@onready var _metric_value_label: Label = $HBoxContainer/MetricValue

var _metric_name: String
var _update_callable: Callable

signal update_callable_invalid(self_reference: DevUtilsDebugMetricLabel)

func init(metric_name: String, update_callable: Callable) -> void:
	_metric_name = metric_name
	_metric_name_label.text = _metric_name
	_update_callable = update_callable

func _process(_delta: float) -> void:
	if not is_visible_in_tree(): return
	if not _update_callable: return
	if _update_callable.is_valid():
		var return_value: Variant = _update_callable.call()
		_metric_value_label.text = str(return_value)
	else: update_callable_invalid.emit(self)

func get_metric_name() -> String:
	return _metric_name
