class_name PracticeWorld
extends RoadWorld

var route := RidingRoute.new()
var definition: Dictionary

func build(_is_city: bool = false) -> void:
	route.practice = true
	definition = JSON.parse_string(FileAccess.get_file_as_string("res://data/chapters/practice.json"))
	_build_environment()
	_build_surface(8.0, -0.09, Color("a49f82"), false)
	_build_surface(5.0, 0.0, Color("555954"), true)
	var ground := LowPoly.box(self, Vector3(0, -1.5, -350), Vector3(400, 1, 850), Color("7c9560"))
	ground.create_trimesh_collision()
	for d in range(0, 720, 8):
		var pos := route.sample(d)
		var mark := LowPoly.box(self, pos + Vector3(0, 0.025, -1), Vector3(0.12, 0.02, 2.0), Color("ddd3ad"))
		mark.rotation.y = route.heading(d)
		mark.visibility_range_end = 180
		for side in [-1, 1]:
			if d % 24 == 0:
				LowPoly.cylinder(self, pos + Vector3(side * 6, 0.28, 0), 0.18, 0.55, Color("c89156"), 0.04).visibility_range_end = 150
			if d % 48 == 0:
				LowPoly.cylinder(self, pos + Vector3(side * 17, 2.2, 0), 0.18, 4.4, Color("736b49")).visibility_range_end = 220
				LowPoly.sphere(self, pos + Vector3(side * 17, 5, 0), Vector3(6, 3, 5), Color("57764e")).visibility_range_end = 230
	for section in definition.sections:
		var pos := route.sample(section.start)
		LowPoly.box(self, pos + Vector3(-7, 2.5, 0), Vector3(3.5, 1.1, 0.12), Color("345747"))
		LowPoly.cylinder(self, pos + Vector3(-7, 1.1, 0), 0.07, 2.2, Color("77694c"))
		LowPoly.label(self, section.sign, pos + Vector3(-7, 2.5, 0.09), 26)
	# Authored cross street; no traffic or navigation decision is required.
	var junction := LowPoly.box(self, route.sample(625) + Vector3(0, -0.09, 0), Vector3(64, 0.16, 10), Color("555954"))
	junction.create_trimesh_collision()
	for side in [-1, 1]:
		LowPoly.box(self, route.sample(625) + Vector3(side * 26, 0.55, 0), Vector3(0.3, 1.1, 9), Color("b0a27a")).create_trimesh_collision()
	# Solid practice barrier outside the normal left lane for collision/recovery QA.
	LowPoly.box(self, route.sample(650) + Vector3(3, 0.55, 0), Vector3(2.4, 1.1, 0.5), Color("b17b4a")).create_trimesh_collision()
	LowPoly.house(self, route.sample(687) + Vector3(-15, 0, -3), Color("bcb997"), "TAKE A BREAK")
	LowPoly.box(self, route.sample(687) + Vector3(-2.5, 0.018, 0), Vector3(4, 0.025, 12), Color("7a9278"))
	# A physical end barrier is a fallback behind the automatic gentle stop.
	LowPoly.box(self, route.sample(724) + Vector3(0, 0.5, 0), Vector3(16, 1, 0.4), Color("8b8165")).create_trimesh_collision()

func _build_surface(half_width: float, height: float, color: Color, is_road: bool) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Half-meter sampling keeps the small bumps physical and smooth.
	for i in range(-24, 1456):
		var a := route.sample(i * 0.5) + Vector3(0, height, 0)
		var b := route.sample((i + 1) * 0.5) + Vector3(0, height, 0)
		for vertex in [a + Vector3(-half_width, 0, 0), b + Vector3(-half_width, 0, 0), a + Vector3(half_width, 0, 0), a + Vector3(half_width, 0, 0), b + Vector3(-half_width, 0, 0), b + Vector3(half_width, 0, 0)]:
			surface.add_vertex(vertex)
	surface.generate_normals()
	var mesh := MeshInstance3D.new()
	mesh.mesh = surface.commit()
	mesh.material_override = LowPoly.material(color).duplicate()
	add_child(mesh)
	mesh.create_trimesh_collision()
	if is_road:
		road_material = mesh.material_override
