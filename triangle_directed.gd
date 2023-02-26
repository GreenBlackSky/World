extends PlateTriangle


class_name DirectedTriangle


var movement_direction: Vector3


func _init(vertice1: Vector3, vertice2: Vector3, vertice3: Vector3).(vertice1, vertice2, vertice3):
	pass


func draw_arrow():
	var arrow = Sprite3D.new()
	arrow.texture = load("res://arrow.png")
	self.mesh_instance.add_child(arrow)
	arrow.set_owner(self.mesh_instance.get_tree().edited_scene_root)
	arrow.name = "Arrow"

	var center = (self.vert1 + self.vert2 + self.vert3)/3 * 1.01
	arrow.transform.origin = center

	var side = (self.vert1 - self.vert2).length()
	arrow.scale = Vector3.ONE * side / 20

	arrow.look_at(self.normale + mesh_instance.global_translation, Vector3.UP)
#	arrow.rotate(self.normale, 90)
	var pointer = CSGSphere.new()
	pointer.radius = 0.05

	self.mesh_instance.add_child(pointer)
	pointer.set_owner(self.mesh_instance.get_tree().edited_scene_root)

	pointer.translate(center + movement_direction)
