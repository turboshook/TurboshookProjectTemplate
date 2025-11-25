extends Control
class_name IntroductionScreen

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal intro_finished

func _ready() -> void:
	var animations: PackedStringArray = animation_player.get_animation_list()
	if animations.size() == 0: 
		get_tree().create_timer(1.0).timeout.connect(func(_anim_name: String): intro_finished.emit())
		return
	animation_player.animation_finished.connect(func(_anim_name: String): intro_finished.emit())
	animation_player.play(animations[0])
