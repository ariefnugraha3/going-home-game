class_name LowPoly
extends RefCounted

static var materials: Dictionary = {}

static func material(color: Color, unshaded: bool = false) -> StandardMaterial3D:
	var key := str(color) + str(unshaded)
	if not materials.has(key):
		var mat := StandardMaterial3D.new()
		mat.albedo_color = color
		mat.roughness = 0.88
		if unshaded:
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		materials[key] = mat
	return materials[key]

static func mesh(parent: Node3D, shape: Mesh, pos: Vector3, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = shape
	node.material_override = material(color)
	node.position = pos
	parent.add_child(node)
	return node

static func box(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var shape := BoxMesh.new()
	shape.size = size
	return mesh(parent, shape, pos, color)

static func cylinder(parent: Node3D, pos: Vector3, radius: float, height: float, color: Color, top: float = -1.0, sides: int = 10) -> MeshInstance3D:
	var shape := CylinderMesh.new()
	shape.top_radius = radius if top < 0 else top
	shape.bottom_radius = radius
	shape.height = height
	shape.radial_segments = sides
	return mesh(parent, shape, pos, color)

static func sphere(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var shape := SphereMesh.new()
	shape.radial_segments = 10
	shape.rings = 5
	var node := mesh(parent, shape, pos, color)
	node.scale = size
	return node

static func beam(parent: Node3D, a: Vector3, b: Vector3, radius: float, color: Color) -> MeshInstance3D:
	var node := cylinder(parent, (a + b) * 0.5, radius, a.distance_to(b), color)
	var direction := (b - a).normalized()
	node.quaternion = Quaternion(Vector3.UP, direction)
	return node

static func label(parent: Node3D, text: String, pos: Vector3, size: int = 40) -> Label3D:
	var node := Label3D.new()
	node.text = text
	node.position = pos
	node.font_size = size
	node.pixel_size = 0.012
	node.modulate = Color("fff3d4")
	node.outline_size = 0
	parent.add_child(node)
	return node

static func person(parent: Node3D, pos: Vector3, shirt: Color) -> Node3D:
	var root := Node3D.new()
	root.position = pos
	parent.add_child(root)
	box(root, Vector3(0, 1.02, 0), Vector3(0.46, 0.63, 0.28), shirt)
	sphere(root, Vector3(0, 1.58, 0), Vector3(0.37, 0.27, 0.36), Color("b87f55"))
	sphere(root, Vector3(0, 1.76, -0.025), Vector3(0.4, 0.1, 0.37), Color("29312e"))
	for side in [-1, 1]:
		box(root, Vector3(side * 0.13, 0.38, 0), Vector3(0.19, 0.77, 0.24), Color("394653"))
		beam(root, Vector3(side * 0.25, 1.24, 0), Vector3(side * 0.32, 0.78, 0.08), 0.09, shirt)
	return root

static func house(parent: Node3D, pos: Vector3, color: Color, title: String = "") -> Node3D:
	var root := Node3D.new()
	root.position = pos
	parent.add_child(root)
	box(root, Vector3(0, 1.8, 0), Vector3(7, 3.6, 5), color)
	box(root, Vector3(0, 0.08, 1.6), Vector3(8.5, 0.16, 7), Color("b4ac8c"))
	for side in [-1, 1]:
		var roof := box(root, Vector3(side * 1.9, 4.05, 0), Vector3(4.4, 0.18, 6.5), Color("955b43"))
		roof.rotation.z = side * -0.28
		box(root, Vector3(side * 2.1, 1.95, 2.52), Vector3(1.3, 1.25, 0.06), Color("354c4e"))
	box(root, Vector3(0, 1.25, 2.53), Vector3(1.15, 2.5, 0.08), Color("605345"))
	if not title.is_empty():
		box(root, Vector3(0, 3.05, 2.68), Vector3(5.8, 0.8, 0.12), Color("344d42"))
		label(root, title, Vector3(0, 3.07, 2.77), 36)
	return root

static func warung(parent: Node3D, pos: Vector3) -> Node3D:
	var root := house(parent, pos, Color("d4c7a0"), "SARI'S WARUNG")
	box(root, Vector3(0, 2.65, 5), Vector3(8.4, 0.14, 5), Color("617d70"))
	for x in [-3.8, 3.8]:
		cylinder(root, Vector3(x, 1.3, 7), 0.07, 2.6, Color("735c44"))
	for x in [-2.0, 1.6]:
		box(root, Vector3(x, 0.85, 4.9), Vector3(1.5, 0.12, 1.2), Color("8b6345"))
		for dx in [-0.55, 0.55]:
			box(root, Vector3(x + dx, 0.4, 4.9), Vector3(0.1, 0.8, 0.8), Color("614f3b"))
		cylinder(root, Vector3(x, 1.02, 4.9), 0.12, 0.23, Color("c5a972"))
		for dz in [-1.1, 1.1]:
			box(root, Vector3(x, 0.45, 4.9 + dz), Vector3(0.65, 0.13, 0.65), Color("a45643"))
			box(root, Vector3(x, 0.8, 4.9 + dz + signf(dz) * 0.27), Vector3(0.65, 0.65, 0.1), Color("a45643"))
	person(root, Vector3(0, 0.12, 3.7), Color("ad7557"))
	person(root, Vector3(-2.7, 0.12, 5.1), Color("5c7180"))
	# Counter jars and a kettle: small, ordinary roadside details.
	box(root, Vector3(2.4, 0.85, 3), Vector3(1.8, 0.12, 0.6), Color("8b6345"))
	for x in [1.8, 2.3, 2.8]:
		cylinder(root, Vector3(x, 1.08, 3), 0.16, 0.34, Color("bfa875"))
		cylinder(root, Vector3(x, 1.27, 3), 0.17, 0.045, Color("835744"))
	cylinder(root, Vector3(0.5, 1.1, 4.9), 0.17, 0.32, Color("818f8c"))
	# Parked small scooter; traffic remains decoration, never a punishment.
	box(root, Vector3(5, 0.8, 4), Vector3(0.55, 0.5, 1.5), Color("8e5347"))
	box(root, Vector3(5, 1.1, 4.2), Vector3(0.55, 0.12, 0.8), Color("303d36"))
	beam(root, Vector3(5, 0.8, 3.4), Vector3(5, 1.5, 3.3), 0.045, Color("82938a"))
	beam(root, Vector3(4.65, 1.5, 3.3), Vector3(5.35, 1.5, 3.3), 0.035, Color("303d36"))
	for z in [3.4, 4.6]:
		var wheel := cylinder(root, Vector3(5, 0.35, z), 0.32, 0.12, Color("303d36"))
		wheel.rotation.z = PI / 2
	return root
