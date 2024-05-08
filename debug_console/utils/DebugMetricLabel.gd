extends Control

@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var _metric_name_label: Label = $HBoxContainer/MetricName
@onready var _metric_value_label: Label = $HBoxContainer/MetricValue

var _update_callable: Callable

func init(metric_name: String, update_callable: Callable) -> void:
	_metric_name_label.text = metric_name
	_update_callable = update_callable

func _process(_delta: float) -> void:
	if not visible:
		return
	if not _update_callable: 
		return
	if _update_callable.is_valid():
		var return_value: Variant = _update_callable.call()
		_metric_value_label.text = str(return_value)
