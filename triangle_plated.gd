extends Triangle


class_name PlateTriangle

const NO_PLATE_INDEX = -1

var plate_index: int = -1


func _init(vertice1: Vector3, vertice2: Vector3, vertice3: Vector3).(vertice1, vertice2, vertice3):
	pass


func colorize(color: Color):
	var material = SpatialMaterial.new()
	material.albedo_color = color
	mesh_instance.set_surface_material(0, material)
