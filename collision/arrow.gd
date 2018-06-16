extends Spatial

func set_color(clr):
	var mat = SpatialMaterial.new()
	mat.set_albedo(clr)
	$head.set_surface_material(0,mat)
	$body.set_surface_material(0,mat)
