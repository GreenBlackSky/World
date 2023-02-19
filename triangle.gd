extends Node

class_name Triangle

var vert1 : Vector3
var vert2 : Vector3
var vert3 : Vector3
var color: Color
var neighbours: Array

const VECTOR_TOLERANCE: float = 0.001


func _init(vertice1: Vector3, vertice2: Vector3, vertice3: Vector3):
	vert1 = vertice1
	vert2 = vertice2
	vert3 = vertice3


func _to_string() -> String:
	return "Triangle obgect(%s, %s, %s)" % [str(vert1), str(vert2), str(vert3)]


func vertices() -> Array:
	return [self.vert1, self.vert2, self.vert3]


func calc_surface_normal() -> Vector3:
	var U = vert2 - vert1
	var V = vert3 - vert1
	return U.cross(V).normalized()


func draw(parent: Spatial, name: String) -> void:
	var surface_array= []
	surface_array.resize(Mesh.ARRAY_MAX)
	var vertices = PoolVector3Array()
	var indices = PoolIntArray()

	for vertice in self.vertices():
		vertices.append(vertice)

	for i in range(2, -1, -1):
		indices.append(i)

	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_INDEX] = indices

	var material = SpatialMaterial.new()
	material.albedo_color = color

	var mesh = Mesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)

	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = mesh
	mesh_instance.name = name
	mesh_instance.set_surface_material(0, material)
	parent.add_child(mesh_instance)
	mesh_instance.set_owner(parent.get_tree().edited_scene_root)


func subdivide() -> Array:
	var radius: float = vert1.length()

	var vert4 = ((vert1 + vert2)/2).normalized() * radius
	var vert5 = ((vert2 + vert3)/2).normalized() * radius
	var vert6 = ((vert3 + vert1)/2).normalized() * radius

	return [
		get_script().new(vert1, vert4, vert6),
		get_script().new(vert4, vert2, vert5),
		get_script().new(vert6, vert5, vert3), 
		get_script().new(vert5, vert6, vert4)
	]
#

func find_neighbours(triangles: Array) -> Array:
	if neighbours:
		return neighbours

	for triangle in triangles:
		var count = 0
		for v in vertices():
			for vt in triangle.vertices():
				if are_vectors_similar(v, vt):
					count+= 1
		if count == 2:
			neighbours.append(triangle)
	return neighbours


func are_vectors_similar(vec1: Vector3, vec2: Vector3) -> bool:
	var dot_product = vec1.dot(vec2)
	var mag_product = vec1.length() * vec2.length()
	return abs(dot_product - mag_product) < VECTOR_TOLERANCE