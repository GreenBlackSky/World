@tool

extends PlatedSphere

class_name DirectedSphere


func update_plates():
	super.update_plates()
	calculate_plates_movement_directions()
	draw_arrows()


func create_elements():
	super.create_elements()
	calculate_plates_movement_directions()
	draw_arrows()


func create_triangle(vert1: Vector3, vert2: Vector3, vert3: Vector3):
	return DirectedTriangle.new(vert1, vert2, vert3)

# TODO rework directions
func calculate_plates_movement_directions():
	var queue = TriangleQueue.new()
	for triangle in plates_cores:
		triangle.movement_direction = Vector3(randf(), randf(), randf()).cross(triangle.normale)
		queue.add(triangle)

	while not queue.is_empty():
		var triangle = queue.pop_front()
		if triangle.movement_direction == Vector3.ZERO:
			for neighbour in triangle.neighbours():
				if neighbour.movement_direction != Vector3.ZERO:
					var axis = -triangle.normale.cross(neighbour.normale).normalized()
					var angle = triangle.normale.angle_to(neighbour.normale)
					triangle.movement_direction = neighbour.movement_direction.rotated(axis, angle).normalized()
					break

		for neighbour in triangle.neighbours():
			if neighbour.movement_direction == Vector3.ZERO:
				queue.add(neighbour)


func draw_arrows():
	for triangle in triangles:
		triangle.draw_arrow()
