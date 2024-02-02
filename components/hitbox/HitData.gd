extends Resource
class_name HitData

enum DamageType {
	NORMAL,
	STUN,
	FIRE,
	FORCE
}

## Amount to be deducted from the target's hit points.
@export_range(0, 99) var damage: int = 0
## Strength of knockback applied to a target, as a proportion of the Player's move speed.
@export_range(0.0, 10.0, 0.1) var knockback: float = 0.0
## Type of damage applied.
@export var damage_type: DamageType = DamageType.NORMAL
