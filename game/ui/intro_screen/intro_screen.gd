extends Control
class_name IntroductionScreen

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal intro_complete

func _ready() -> void:
	var animations: PackedStringArray = animation_player.get_animation_list()
	if animations.size() == 0: 
		intro_complete.emit()
		return
	animation_player.play(animations[0])

func _process(_delta: float) -> void:
	if not animation_player.is_playing():
		intro_complete.emit()
		return
