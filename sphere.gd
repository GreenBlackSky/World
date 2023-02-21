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
	if old_val != value and get_child_count() != 0:
		update_elements()


func set_density(value):
	var old_val = DENSITY
	DENSITY = value
	if old_val != value and get_child_count() != 0:
		update_elements()


func set_plates_n(value):
	var old_val = TECTONIC_PLATES_N
	TECTONIC_PLATES_N = value
	if old_val != value and get_child_count() != 0:
		update_elements()


func create_elements():
	for i in range(TECTONIC_PLATES_N):
		plates_colors.append(Color(randf(), randf(), randf()))
	generate_icosahedron()
	for i in range(DENSITY):
		subdivide_triangles()
	colorize()
	draw()


func delete_elements():
	triangles.clear()
	plates_colors.clear()
	for n in get_children():
		remove_child(n)
		n.queue_free()


func update_elements():
	delete_elements()
	create_elements()
	property_list_changed_notify()


func _ready():
	if get_child_count() == 0:
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
		var triangle = Triangle.new(
			vertices[indices[0]] * RADIUS,
			vertices[indices[1]] * RADIUS,
			vertices[indices[2]] * RADIUS
		)
		triangles.append(triangle)


func subdivide_triangles():
	var more_triangles = []
	for triangle in triangles:
		var children = triangle.subdivide()
		for child in children:
			more_triangles.append(child)
	triangles = more_triangles


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


func colorize():
	var queue = choose_tectonics_plates_origins()
	for i in range(TECTONIC_PLATES_N):
		queue[i].color = plates_colors[i]
	
	while queue:
		var triangle = queue.pop_front()
		var neighbours = triangle.find_neighbours(triangles)
		if triangle.color == Color.black:
			for neighbour in neighbours:
				if neighbour.color != Color.black:
					triangle.color = neighbour.color
					break
		
		for neighbour in neighbours:
			if neighbour.color == Color.black:
				queue.push_back(neighbour)


func draw():
	for i in range(triangles.size()):
		triangles[i].draw(self, str(i))
