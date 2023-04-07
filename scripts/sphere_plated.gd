@tool

extends Sphere

class_name PlatedSphere

@export_range(1, 20) var TECTONIC_PLATES_N = 3 : set = set_plates_n 

var plates_colors: Array
var plates_cores: Array


func create_triangle(vert1: Vector3, vert2: Vector3, vert3: Vector3) -> Triangle:
	return PlateTriangle.new(vert1, vert2, vert3)


func set_plates_n(value):
	var old_val = TECTONIC_PLATES_N
	TECTONIC_PLATES_N = value
	if old_val != value and get_tree() and get_child_count() != 0:
		if triangles.is_empty():
			delete_elements()
			create_elements()
		else:
			update_plates()
		notify_property_list_changed()


func update_plates_colors():
	plates_colors.clear()
	for i in range(TECTONIC_PLATES_N):
		plates_colors.append(Color(randf(), randf(), randf()))


func update_plates_cores():
	plates_cores.clear()
	var triangle_indices = []
	for i in range(triangles.size()):
		triangle_indices.append(i)
	for i in range(TECTONIC_PLATES_N):
		var index = randi() % triangle_indices.size()
		plates_cores.append(triangles[triangle_indices[index]])
		triangle_indices.remove_at(index)


func update_plates():
	for n in get_children():
		remove_child(n)
	draw()
	for triangle in triangles:
		triangle.plate_index = PlateTriangle.NO_PLATE_INDEX
	update_plates_colors()
	update_plates_cores()
	create_tectonic_plates()
	colorize()


func create_elements():
	super.create_elements()
	update_plates_colors()
	update_plates_cores()
	create_tectonic_plates()
	colorize()
	notify_property_list_changed()


func create_tectonic_plates():
	var queue = TriangleQueue.new()
	var i = 0
	for triangle in plates_cores:
		triangle.plate_index = i
		i += 1
		queue.add(triangle)

	while not queue.is_empty():
		var triangle = queue.pop_front()
		if triangle.plate_index == PlateTriangle.NO_PLATE_INDEX:
			for neighbour in triangle.neighbours:
				if neighbour.plate_index != PlateTriangle.NO_PLATE_INDEX:
					triangle.plate_index = neighbour.plate_index
					break
		
		for neighbour in triangle.neighbours:
			if neighbour.plate_index == PlateTriangle.NO_PLATE_INDEX:
				queue.add(neighbour)


func colorize():
	for triangle in triangles:
		var color = plates_colors[triangle.plate_index]
		triangle.colorize(color)
