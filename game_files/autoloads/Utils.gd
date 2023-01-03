extends Node

func instance_scene(packed_scene: PackedScene, parent_node: Node, target_global_position: Vector2) -> Node:
	var instanced_scene: Node = packed_scene.instantiate()
	parent_node.add_child(instanced_scene)
	if instanced_scene is Control:
		instanced_scene.global_position = target_global_position
	else:
		instanced_scene.global_position = target_global_position
	return instanced_scene

func instance_projectile(packed_projectile_scene: PackedScene, projectile_direction_vector: Vector2, target_global_position: Vector2) -> Node:
	var projectile_scene: Node = packed_projectile_scene.instantiate()
	WorldRegion.NodeReferences.CurrentCell.ProjectileLayer.add_child(projectile_scene)
	projectile_scene.global_position = target_global_position
	projectile_scene.set_projectile_rotation_from_vector(projectile_direction_vector)
	# set once here, assuming only enemies spawn projectiles upon their instantiation
	projectile_scene.enable_hitbox() 
	return projectile_scene

func reparent_node(node: Node, new_parent: Node) -> void:
	var old_parent: Node = node.get_parent()
	old_parent.remove_child(node)
	new_parent.add_child(node)

func delete_child_nodes(parent_node: Node) -> void:
	for child in parent_node.get_children():
		parent_node.remove_child(child)
		child.queue_free()

func get_random_offset(width: float, rounding: bool = true) -> Vector2:
	width = abs(width)
	if width == 0:
		return Vector2.ZERO
	var rand_x: float = randf_range(-width, width)
	var rand_y: float = randf_range(-width, width)
	if rounding:
		return Vector2(round(rand_x), round(rand_y))
	else:
		return Vector2(rand_x, rand_y)

func get_array_sum(array: Array) -> float:
	var sum: float = 0
	for element in array:
		if not typeof(element) == TYPE_INT and not typeof(element) == TYPE_FLOAT:
			return 0.0 # zeroes are technically ambiguous with this function...
		else:
			sum += element
	return sum

func get_random_array_element(array: Array) -> Object:
	# warning-ignore:narrowing_conversion
	var random_index: int = round(randf_range(0, array.size() - 1))
	return array[random_index]
