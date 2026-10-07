@tool
extends Node2D
class_name SoundPool2D

var _sound_queues: Array[SoundQueue2D] 
var _last_index: int = -1

func _ready() -> void:
	for child: Node in get_children():
		if not child is SoundQueue2D: 
			push_warning(child.name + " is not an instance of SoundQueue2D.")
			continue
		_sound_queues.append(child)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if get_child_count() == 0: 
		warnings.append("No child SoundQueue2D found, this SoundPool2D will not function.")
	elif not get_child(0) is SoundQueue2D: 
		warnings.append("Child at index 0 is not instance of SoundQueue2D, this SoundPool2D will not function.")
	elif get_child_count() == 1: 
		warnings.append("Only 1 SoundQueue2D provided, this SoundPool2D is a waste of your time.")
	elif not get_child(1) is SoundQueue2D:
		warnings.append("Child at index 1 is not instance of SoundQueue2D, this SoundPool2D is a waste of your time.")
	return warnings

func play() -> void:
	if _sound_queues.size() == 0: return
	var random_index: int = -1
	while random_index == _last_index:
		random_index = randi_range(0, _sound_queues.size() - 1)
	_sound_queues[random_index].play()
	_last_index = random_index
