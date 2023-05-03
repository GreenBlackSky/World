extends Triangle


class_name PlateTriangle

const NO_PLATE_INDEX = -1

var plate_index: int = -1


func _init(vertice1: Vector3, vertice2: Vector3, vertice3: Vector3):
	super._init(vertice1, vertice2, vertice3)


func update_radius(R: float):
	var material = self.mesh_instance.get_surface_override_material(0)
	super.update_radius(R)
	self.mesh_instance.set_surface_override_material(0, material)


func colorize(color: Color):
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	self.mesh_instance.set_surface_override_material(0, material)
