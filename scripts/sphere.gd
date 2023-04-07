@tool

extends Node3D

class_name Sphere

@export var RADIUS: float = 1.0 : set = set_radius
@export_range(0, 5) var DENSITY = 0 : set = set_density

var triangles: Array


func set_radius(value):
	var old_val = RADIUS
	RADIUS = value
	if old_val != value and get_tree() and get_child_count() != 0:
		for triangle in triangles:
			triangle.update_radius(RADIUS)
		notify_property_list_changed()


func set_density(value):
	var old_val = DENSITY
	DENSITY = value
	if old_val != value and get_tree() and get_child_count() != 0:
		delete_elements()
		create_elements()
		notify_property_list_changed()


func create_elements():
	generate_icosahedron()
	for i in range(DENSITY):
		subdivide_triangles()
	connect_triangles()
	draw()


func delete_elements():
	triangles.clear()
	for n in get_children():
		remove_child(n)
		n.queue_free()


func _ready():
	if get_child_count() == 0:
		create_elements()


func create_triangle(vert1: Vector3, vert2: Vector3, vert3: Vector3):
	return Triangle.new(vert1, vert2, vert3)


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
		var triangle = create_triangle(
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


func draw():
	for triangle in triangles:
		triangle.draw(self)
