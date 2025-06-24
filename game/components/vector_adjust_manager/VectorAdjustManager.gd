extends Node
class_name VectorAdjustManager

const ALLOWED_DIRECTIONS: int = 8

func get_snapped_vector(input_vector: Vector2) -> Vector2:
	
	if input_vector == Vector2.ZERO:
		return Vector2.ZERO
	
	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()
	
	var input_direction: float = input_vector.angle()
	
	@warning_ignore("integer_division")
	var snapped_vector: Vector2 = Vector2.RIGHT.rotated(
		snapped(input_direction, PI / (ALLOWED_DIRECTIONS / 2))
	)
	
	return snapped_vector

func vector_is_diagonal(input_vector: Vector2) -> bool:
	return !(is_equal_approx(input_vector.x, 0.0) or is_equal_approx(input_vector.y, 0.0))
