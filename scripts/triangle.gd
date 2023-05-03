extends Node

class_name Triangle

var A: Vector3
var B: Vector3
var C: Vector3

var AB: Triangle
var BC: Triangle
var CA: Triangle

var ABtemp: TriangleHolder
var BCtemp: TriangleHolder
var CAtemp: TriangleHolder


var normale: Vector3
var id: int

var mesh_instance: MeshInstance3D

const VECTOR_TOLERANCE: float = 0.001


func _init(vertice1: Vector3,vertice2: Vector3,vertice3: Vector3):
	A = vertice1
	B = vertice2
	C = vertice3
	var U = B - A
	var V = C - A
	normale = U.cross(V).normalized()


func _to_string() -> String:
	return "△ %d" % id


func vertices() -> Array:
	return [self.A, self.B, self.C]


func neighbours() -> Array:
	return [self.AB, self.BC, self.CA]


func generate_children() -> Array:
#		A
#	   / \
#	  D---F
#	 / \ / \
#	B---E---C
	var radius: float = A.length()

	var D = ((A + B)/2).normalized() * radius
	var E = ((B + C)/2).normalized() * radius
	var F = ((C + A)/2).normalized() * radius

	var top = get_script().new(A, D, F)
	var left = get_script().new(D, B, E)
	var right = get_script().new(F, E, C)
	var center = get_script().new(E, F, D)

	return [top, left, right, center]


func update_radius(R: float):
	A = A.normalized() * R
	B = B.normalized() * R
	C = C.normalized() * R
	
	var U = B - A
	var V = C - A
	normale = U.cross(V).normalized()

	if mesh_instance != null:
		var parent = mesh_instance.get_parent()
		mesh_instance.remove_and_skip()
		draw(parent)


func draw(parent: Node3D) -> void:
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	var verts = PackedVector3Array()
	var indices = PackedInt32Array()

	for vertice in self.vertices():
		verts.append(vertice)

	for i in range(2, -1, -1):
		indices.append(i)

	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_INDEX] = indices

	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.name = "Triangle"

	parent.add_child(mesh_instance)
	mesh_instance.set_owner(parent.get_tree().edited_scene_root)
