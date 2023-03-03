extends PlateTriangle


class_name DirectedTriangle


var movement_direction: Vector3


func _init(vertice1: Vector3, vertice2: Vector3, vertice3: Vector3).(vertice1, vertice2, vertice3):
	pass


func draw_arrow():
	var arrowHolder = Spatial.new()
	self.mesh_instance.add_child(arrowHolder)
	arrowHolder.set_owner(self.mesh_instance.get_tree().edited_scene_root)

	var arrow = Sprite3D.new()
	arrow.texture = load("res://arrow.png")
	arrowHolder.add_child(arrow)
	arrow.set_owner(self.mesh_instance.get_tree().edited_scene_root)
	arrow.name = "Arrow"

	var center = (self.vert1 + self.vert2 + self.vert3)/3 * 1.01
	arrowHolder.transform.origin = center

	var side = (self.vert1 - self.vert2).length()
	arrow.scale = Vector3.ONE * side * movement_direction.length() * 0.05

	arrowHolder.look_at(self.normale + mesh_instance.global_translation, Vector3.UP)
	arrowHolder.look_at(center + movement_direction, self.normale)
	arrow.rotate(Vector3.UP, -PI/2)
	arrow.rotate(Vector3.FORWARD, PI/2)
