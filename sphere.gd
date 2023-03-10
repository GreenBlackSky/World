tool

extends Spatial

class_name Sphere

export(float) var RADIUS = 1.0 setget set_radius
export(int, 0, 5) var DENSITY = 0 setget set_density
export(int, 1, 20) var TECTONIC_PLATES_N = 3 setget set_plates_n

var triangles: Array
var plates_colors: Array


func set_radius(value):
	var old_val = RADIUS
	RADIUS = value
	if old_val != value and get_tree() and get_child_count() != 0:
		delete_elements()
		update_plates_colors()
		create_elements()
		property_list_changed_notify()


func set_density(value):
	var old_val = DENSITY
	DENSITY = value
	if old_val != value and get_tree() and get_child_count() != 0:
		delete_elements()
		update_plates_colors()
		create_elements()
		property_list_changed_notify()


func set_plates_n(value):
	var old_val = TECTONIC_PLATES_N
	TECTONIC_PLATES_N = value
	if old_val != value and get_tree() and get_child_count() != 0:
		if not triangles:
			delete_elements()
			update_plates_colors()
			create_elements()
		else:
			update_plates_colors()
			update_plates()
		property_list_changed_notify()


func update_plates_colors():
	plates_colors.clear()
	for i in range(TECTONIC_PLATES_N):
		plates_colors.append(Color(randf(), randf(), randf()))


func update_plates():
	for n in get_children():
		remove_child(n)
	draw()
	for triangle in triangles:
		triangle.plate_index = PlateTriangle.NO_PLATE_INDEX
	create_tectonic_plates()
	colorize()
	calculate_plates_movement_directions()
	draw_arrows()


func create_elements():
	generate_icosahedron()
	for i in range(DENSITY):
		subdivide_triangles()
	draw()
	create_tectonic_plates()
	colorize()
	calculate_plates_movement_directions()
	draw_arrows()


func delete_elements():
	triangles.clear()
	for n in get_children():
		remove_child(n)
		n.queue_free()


func _ready():
	if get_child_count() == 0:
		update_plates_colors()
		create_elements()


func generate_icosahedron():
	var t = (1.0 + sqrt(5.0)) / 2.0
	var vertices = [
		Vector3(-1,  t,  0),
		Vector3( 1,  t,  0),
		Vector3(-1, -t,  0),
		Vector3( 1, -t,  0),
		Vector3( 0, -1,  t),
		Vector3( 0,  1,  t),
		Vector3( 0, -1, -t),
		Vector3( 0,  1, -t),
		Vector3( t,  0, -1),
		Vector3( t,  0,  1),
		Vector3(-t,  0, -1),
		Vector3(-t,  0,  1)
	]
	
	var triangle_indices = [
		[0, 11, 5],
		[0, 5, 1],
		[0, 1, 7],
		[0, 7, 10],
		[0, 10, 11],
		[1, 5, 9],
		[5, 11, 4],
		[11, 10, 2],
		[10, 7, 6],
		[7, 1, 8],
		[3, 9, 4],
		[3, 4, 2],
		[3, 2, 6],
		[3, 6, 8],
		[3, 8, 9],
		[4, 9, 5],
		[2, 4, 11],
		[6, 2, 10],
		[8, 6, 7],
		[9, 8, 1]
	]
	
	for indices in triangle_indices:
		var triangle = DirectedTriangle.new(
			vertices[indices[0]] * RADIUS,
			vertices[indices[1]] * RADIUS,
			vertices[indices[2]] * RADIUS
		)
		triangles.append(triangle)
	connect_triangles()


func subdivide_triangles():
	var more_triangles = []
	for triangle in triangles:
		var children = triangle.subdivide()
		for child in children:
			more_triangles.append(child)
	triangles = more_triangles
	connect_triangles()


func connect_triangles():
	var triangles_by_verts = {}
	for triangle in triangles:
		for vert in triangle.rounded_vertices():
			if not triangles_by_verts.has(vert):
				triangles_by_verts[vert] = []
			triangles_by_verts[vert].append(triangle)
	
	for triangle in triangles:
		for vert in triangle.rounded_vertices():
			for potential_neighbour in triangles_by_verts[vert]:
				if triangle.is_neighbour(potential_neighbour):
					potential_neighbour.add_neghbour(triangle)
					triangle.add_neghbour(potential_neighbour)


func choose_tectonics_plates_origins():
	var roots = []
	var triangle_indices = []
	for i in range(triangles.size()):
		triangle_indices.append(i)
	for i in range(TECTONIC_PLATES_N):
		var index = randi() % triangle_indices.size()
		roots.append(triangles[triangle_indices[index]])
		triangle_indices.remove(index)
	return roots


func create_tectonic_plates():
	var queue = choose_tectonics_plates_origins()
	for i in range(TECTONIC_PLATES_N):
		queue[i].plate_index = i
	
	while queue:
		var triangle = queue.pop_front()
		if triangle.plate_index == PlateTriangle.NO_PLATE_INDEX:
			for neighbour in triangle.neighbours:
				if neighbour.plate_index != PlateTriangle.NO_PLATE_INDEX:
					triangle.plate_index = neighbour.plate_index
					break
		
		for neighbour in triangle.neighbours:
			if neighbour.plate_index == PlateTriangle.NO_PLATE_INDEX:
				queue.push_back(neighbour)


func calculate_plates_movement_directions():
	var queue = []
	var plate_cores = {}
	for triangle in triangles:
		if not triangle.plate_index in plate_cores:
			var random_vector = Vector3(randf(), randf(), randf()).normalized()
			triangle.movement_direction = random_vector.cross(triangle.normale).normalized()
			plate_cores[triangle.plate_index] = triangle
			queue.append(triangle)
		if plate_cores.size() == TECTONIC_PLATES_N:
			break
	
	while queue:
		var triangle = queue.pop_front()
		if triangle.movement_direction == Vector3.ZERO:
			for neighbour in triangle.neighbours:
				if neighbour.movement_direction != Vector3.ZERO:
					var axis = triangle.normale.cross(neighbour.normale).normalized()
					var angle = triangle.normale.angle_to(neighbour.normale)
					triangle.movement_direction = neighbour.movement_direction.rotated(axis, angle)
					break
			
		for neighbour in triangle.neighbours:
			if neighbour.movement_direction == Vector3.ZERO:
				queue.append(neighbour)


func draw():
	for triangle in triangles:
		triangle.draw(self)


func colorize():
	for triangle in triangles:
		var color = plates_colors[triangle.plate_index]
		triangle.colorize(color)


func draw_arrows():
	for triangle in triangles:
		triangle.draw_arrow()
