extends Node
class_name VectorAdjustManager

const VECTOR_ANGLE_THRESHOLD: float = 15.0
const DIAGONAL_ROTATION_DEGREES: float = 45.0

func get_snapped_vector(input_vector: Vector2) -> Vector2:
	
	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()

	var x_sign: float = sign(input_vector.x)
	var y_sign: float = sign(input_vector.y)
	var snapped_vector: Vector2 = Vector2.ZERO
	
	if abs(input_vector.x) > abs(input_vector.y) or abs(input_vector.x) == abs(input_vector.y):
		# assert that (0.707107, 0.707107) is horizontal movement 
		snapped_vector.x = 1.0
		snapped_vector.y = 0.0
	else:
		snapped_vector.x = 0.0
		snapped_vector.y = 1.0
	
	snapped_vector.x *= x_sign
	snapped_vector.y *= y_sign
	
	var angle_difference: float = rad_to_deg(snapped_vector.angle_to(input_vector))
	if abs(angle_difference) > VECTOR_ANGLE_THRESHOLD:
		var rotation_sign: float = sign(angle_difference)
		snapped_vector = snapped_vector.rotated(rad_to_deg(rotation_sign * DIAGONAL_ROTATION_DEGREES))
	
	return snapped_vector

func vector_is_diagonal(input_vector: Vector2) -> bool:
	return !(is_equal_approx(input_vector.x, 0.0) or is_equal_approx(input_vector.y, 0.0))
