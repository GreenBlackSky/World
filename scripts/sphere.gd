@tool

extends Node3D

class_name Sphere

@export var RADIUS: float = 1.0 : set = set_radius
@export_range(0, 5) var DENSITY = 0 : set = set_density

var triangles: Array
var tid = 0


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
	tid = 0
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
	var connection_indices = [
		{'CA': 1, 'AB': 4, 'BC': 6},
		{'AB': 0, 'CA': 2, 'BC': 5},
		{'AB': 1, 'CA': 3, 'BC': 9},
		{'AB': 2, 'CA': 4, 'BC': 8},
		{'CA': 0, 'AB': 3, 'BC': 7},
		{'AB': 1, 'CA': 19, 'BC': 15},
		{'AB': 0, 'CA': 15, 'BC': 16},
		{'AB': 4, 'CA': 16, 'BC': 17},
		{'AB': 3, 'CA': 17, 'BC': 18},
		{'AB': 2, 'CA': 18, 'BC': 19},
		{'CA': 11, 'AB': 14, 'BC': 15},
		{'AB': 10, 'CA': 12, 'BC': 16},
		{'AB': 11, 'CA': 13, 'BC': 17},
		{'AB': 12, 'CA': 14, 'BC': 18},
		{'CA': 10, 'AB': 13, 'BC': 19},
		{'BC': 5, 'CA': 6, 'AB': 10},
		{'BC': 6, 'CA': 7, 'AB': 11},
		{'BC': 7, 'CA': 8, 'AB': 12},
		{'BC': 8, 'CA': 9, 'AB': 13},
		{'CA': 5, 'BC': 9, 'AB': 14}
	]
	for indices in triangle_indices:
		var triangle = create_triangle(
			vertices[indices[0]] * RADIUS,
			vertices[indices[1]] * RADIUS,
			vertices[indices[2]] * RADIUS
		)
		triangle.id = tid
		tid += 1
		triangles.append(triangle)

	for i in range(20):
		var triangle = triangles[i]
		var connections = connection_indices[i]
		triangle.AB = triangles[connections["AB"]]
		triangle.BC = triangles[connections["BC"]]
		triangle.CA = triangles[connections["CA"]]


func subdivide_triangles():
	var more_triangles = []
	for triangle in triangles:
		var children = triangle.generate_children()
		for child in children:
			child.id = tid
			tid += 1
		connect_children(triangle, children)
		for child in children:
			more_triangles.append(child)
	triangles = more_triangles
#	for t in triangles:
#		print(t, " AB: ", t.AB, " BC ", t.BC, " CA ", t.CA)


func connect_children(triangle, children):
	var top = children[0]
	var left = children[1]
	var right = children[2]
	var center = children[3]
	
	center.BC = top
	top.BC = center
	
	center.CA = left
	left.CA = center
	
	center.AB = right
	right.AB = center
	
	reconnect_side_children(triangle, triangle.AB, triangle.ABtemp, top, left, "AB")
	reconnect_side_children(triangle, triangle.BC, triangle.BCtemp, left, right, "BC")
	reconnect_side_children(triangle, triangle.CA, triangle.CAtemp, right, top, "CA")


func reconnect_side_children(
	parent: Triangle,
	partner: Triangle,
	holder: TriangleHolder,
	child_1: Triangle,
	child_2: Triangle,
	mark: String
):
	if holder:
#		print(parent, " (", child_1, " ", child_2, ") <- ", holder)
		connect_triangles(mark, child_1, child_2, holder)
	else:
		var children_holder = TriangleHolder.new(mark, child_1, child_2)
#		print(parent, " -> ", partner, ": ", children_holder)
		set_triangle_holder(parent, partner, children_holder)


func connect_triangles(side: String, child1: Triangle, child2: Triangle, partner: TriangleHolder):
	match side:
		"AB":
			child1.AB = partner.triangle2
			child2.AB = partner.triangle1
		"BC":
			child1.BC = partner.triangle2
			child2.BC = partner.triangle1
		"CA":
			child1.CA = partner.triangle2
			child2.CA = partner.triangle1

	match partner.mark:
		"AB":
			partner.triangle2.AB = child1
			partner.triangle1.AB = child2
		"BC":
			partner.triangle2.BC = child1
			partner.triangle1.BC = child2
		"CA":
			partner.triangle2.CA = child1
			partner.triangle1.CA = child2


func set_triangle_holder(parent: Triangle, partner: Triangle, holder: TriangleHolder):
	match parent:
		partner.AB:
			partner.ABtemp = holder
		partner.BC:
			partner.BCtemp = holder
		partner.CA:
			partner.CAtemp = holder


func draw():
	for triangle in triangles:
		triangle.draw(self)
