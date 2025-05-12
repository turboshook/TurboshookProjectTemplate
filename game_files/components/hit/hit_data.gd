extends Resource
class_name HitData

enum Source {
	WORLD,
	PLAYER,
	ENEMY
}

@export var source: Source = Source.WORLD
@export var damage: int = 1
