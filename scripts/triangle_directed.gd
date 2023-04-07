extends PlateTriangle


class_name DirectedTriangle


var movement_direction: Vector3


func update_radius(R: float):
	var arrowHolder: Node3D = self.mesh_instance.get_children()[0]
	var arrow: Sprite3D = arrowHolder.get_children()[0]
	super.update_radius(R)
	var center = (self.vert1 + self.vert2 + self.vert3)/3 * 1.01
	arrowHolder.transform.origin = center
	var side = (self.vert1 - self.vert2).length()
	arrow.scale = Vector3.ONE * side * movement_direction.length() * 0.05
	self.mesh_instance.add_child(arrowHolder)


func draw_arrow():
	var arrowHolder = Node3D.new()
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

	arrowHolder.look_at(self.normale + self.mesh_instance.global_position, Vector3.UP)
	arrowHolder.look_at(center + movement_direction + self.mesh_instance.global_position, self.normale)
	arrow.rotate(Vector3.UP, -PI/2)
	arrow.rotate(Vector3.FORWARD, PI/2)
