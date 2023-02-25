extends PlateTriangle


class_name DirectedTriangle


var movement_direction: Vector3


func _init(vertice1: Vector3, vertice2: Vector3, vertice3: Vector3).(vertice1, vertice2, vertice3):
	pass


func draw_arrow():
	var arrow = Sprite3D.new()
	arrow.texture = load("res://arrow.png")
	self.mesh_instance.add_child(arrow)

	var side_center = (self.vert2 + self.vert3)/2
	var lenght = (self.vert1 - side_center).length()
	arrow.scale = Vector3.ONE * 0.02 * lenght

	var center = ((self.vert1 + side_center)/2)*1.01
	var look_at_pos = center + movement_direction
	arrow.look_at(look_at_pos, self.normale)
	arrow.transform.origin = center
