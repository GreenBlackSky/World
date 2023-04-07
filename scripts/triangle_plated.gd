extends Triangle


class_name PlateTriangle

const NO_PLATE_INDEX = -1

var plate_index: int = -1


func update_radius(R: float):
	var material = self.mesh_instance.get_surface_override_material(0)
	super.update_radius(R)
	self.mesh_instance.set_surface_override_material(0, material)


func colorize(color: Color):
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	self.mesh_instance.set_surface_override_material(0, material)
