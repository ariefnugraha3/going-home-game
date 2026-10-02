class_name LowPoly
extends RefCounted

static var materials: Dictionary = {}

static func material(color: Color, unshaded: bool = false) -> StandardMaterial3D:
	var key := str(color) + str(unshaded)
	if not materials.has(key):
		var mat := StandardMaterial3D.new()
		mat.albedo_color = color
		mat.roughness = 0.82
		mat.metallic_specular = .28
		mat.vertex_color_use_as_albedo = true
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
	if minf(size.x, minf(size.y, size.z)) >= .045 and maxf(size.x, maxf(size.y, size.z)) < 30:
		return mesh(parent, CozyForms.bevel_box(size), pos, color)
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
	var node := mesh(parent, CozyForms.pebble(), pos, color)
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
	var figure := CinematicActor.new()
	root.add_child(figure)
	figure.build(shirt)
	figure.sample("walk",0)
	figure.rotation.y = PI
	figure.left_arm.rotation = Vector3(.06,0,-.05)
	figure.right_arm.rotation = Vector3(.06,0,.05)
	# Bake only visible geometry into the static roadside figure. It has no
	# running animation or hidden helmet/extra leg meshes after construction.
	bake(root,160)
	figure.queue_free()
	return root

static func cup(parent: Node3D, pos: Vector3, radius: float, height: float, color: Color) -> Node3D:
	var root := Node3D.new()
	parent.add_child(root)
	root.position = pos
	mesh(root,CozyForms.loft([Vector4(radius*.8,-height*.5,radius*.8,0),Vector4(radius,height*.44,radius,0),Vector4(radius,height*.5,radius,0)],16),Vector3.ZERO,color)
	cylinder(root,Vector3(0,height*.5+.001,0),radius*.84,.003,Color("503e2d"),-1,16)
	var ring := TorusMesh.new()
	ring.inner_radius = radius*.35
	ring.outer_radius = radius*.65
	ring.rings = 16
	ring.ring_segments = 6
	var handle := mesh(root,ring,Vector3(radius*.94,0,0),color)
	handle.rotation.x = PI/2
	return root

static func house(parent: Node3D, pos: Vector3, color: Color, title: String = "") -> Node3D:
	var root := Node3D.new()
	root.position = pos
	parent.add_child(root)
	box(root, Vector3(0, 1.8, 0), Vector3(7, 3.6, 5), color.lerp(Color("ead7b3"), .32))
	box(root, Vector3(0, 0.08, 1.6), Vector3(8.5, 0.16, 7), Color("b4ac8c"))
	box(root, Vector3(0,.22,2.4),Vector3(7.6,.28,1.3),Color("cdb693"))
	box(root, Vector3(0,.10,3.2),Vector3(2.1,.2,.55),Color("cdb693"))
	var gable := SurfaceTool.new()
	gable.begin(Mesh.PRIMITIVE_TRIANGLES)
	for side in [-1,1]: CozyForms.triangle(gable,Vector3(-3.5,3.6,side*2.5),Vector3(3.5,3.6,side*2.5),Vector3(0,4.83,side*2.5),Vector3(0,0,side))
	mesh(root,gable.commit(),Vector3.ZERO,color.lerp(Color("ead7b3"),.5))
	for side in [-1, 1]:
		var roof := box(root, Vector3(side * 1.95, 4.18, 0), Vector3(4.25, 0.22, 6.2), Color("bb7755"))
		roof.rotation.z = side * -.32
		for row in range(1,6):
			var x: float = side * row * .65
			box(root,Vector3(x,4.91-absf(x)*.331,0),Vector3(.09,.06,6.15),Color("d38e64"))
		for end in [-1,1]: beam(root,Vector3(0,4.88,end*3.10),Vector3(side*4,3.55,end*3.10),.07,Color("8e5c45"))
		_window(root,Vector3(side*2.1,1.98,2.56))
		box(root,Vector3(side*3.45,1.9,2.59),Vector3(.17,3.45,.18),Color("bba27e"))
	beam(root,Vector3(0,4.92,-3.15),Vector3(0,4.92,3.15),.10,Color("d19166"))
	box(root,Vector3(0,3.43,2.57),Vector3(7.2,.16,.16),Color("b5a080"))
	box(root, Vector3(0, 1.38, 2.57), Vector3(1.25, 2.5, 0.13), Color("71563f"))
	for y in [.80,1.85]: box(root,Vector3(0,y,2.65),Vector3(.96,.82,.045),Color("94714f"))
	sphere(root,Vector3(.42,1.36,2.71),Vector3(.10,.1,.09),Color("c5ad76"))
	for side in [-1,1]:
		box(root,Vector3(side*.72,1.46,2.6),Vector3(.13,2.85,.17),Color("bba27e"))
	box(root,Vector3(0,2.9,2.6),Vector3(1.55,.15,.17),Color("bba27e"))
	for x in [-2.9,2.9]: planter(root,Vector3(x,.17,3.1),.75)
	if not title.is_empty():
		box(root, Vector3(0, 3.05, 2.68), Vector3(5.8, 0.8, 0.12), Color("344d42"))
		label(root, title, Vector3(0, 3.07, 2.77), 36)
	bake(root)
	return root

static func _window(root: Node3D, pos: Vector3) -> void:
	box(root,pos,Vector3(1.4,1.4,.08),Color("567e7a"))
	box(root,pos+Vector3(0,0,.045),Vector3(.065,1.4,.05),Color("d1bf9a"))
	box(root,pos+Vector3(0,0,.045),Vector3(1.4,.065,.05),Color("d1bf9a"))
	for side in [-1,1]:
		box(root,pos+Vector3(side*.77,0,.03),Vector3(.12,1.62,.15),Color("c8b48f"))
		box(root,pos+Vector3(0,side*.76,.03),Vector3(1.65,.13,.15),Color("c8b48f"))
		var shutter := box(root,pos+Vector3(side*1.03,0,.09),Vector3(.34,1.35,.12),Color("75948b"))
		shutter.rotation.y = side*.14
		for y in [-.45,-.15,.15,.45]: box(root,pos+Vector3(side*1.03,y,.17),Vector3(.28,.055,.045),Color("a0b19a"))
	box(root,pos+Vector3(0,-.83,.18),Vector3(1.9,.14,.47),Color("b7a080"))

static func planter(root: Node3D, pos: Vector3, size: float = 1.0) -> Node3D:
	var pot := Node3D.new()
	root.add_child(pot)
	pot.position = pos
	pot.scale = Vector3.ONE * size
	cylinder(pot,Vector3(0,.24,0),.24,.48,Color("b97955"),.33)
	cylinder(pot,Vector3(0,.46,0),.35,.10,Color("d5966c"))
	cylinder(pot,Vector3(0,.52,0),.28,.025,Color("64513d"))
	for i in range(5):
		var angle := i * TAU/5
		var leaf := sphere(pot,Vector3(cos(angle)*.19,.78,sin(angle)*.19),Vector3(.24,.62,.30),Color("80965b") if i%2 else Color("5d825e"))
		leaf.rotation.z = cos(angle)*.45
		leaf.rotation.x = sin(angle)*.45
	return pot

static func bake(root: Node3D, distance: float = 260) -> void:
	var groups := {}
	var originals: Array[Node] = []
	_collect(root,Transform3D.IDENTITY,groups)
	for key in groups:
		var group: Dictionary = groups[key]
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for entry in group.items:
			var xf: Transform3D = entry.transform
			var normal_basis := xf.basis.inverse().transposed()
			for surface in range(entry.node.mesh.get_surface_count()):
				var arrays: Array = entry.node.mesh.surface_get_arrays(surface)
				var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
				var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
				var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR] if arrays[Mesh.ARRAY_COLOR] != null else PackedColorArray()
				var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
				if indices.is_empty():
					for i in range(vertices.size()): indices.append(i)
				for index in indices:
					st.set_color(colors[index] if not colors.is_empty() else Color.WHITE)
					st.set_normal((normal_basis * normals[index]).normalized())
					st.add_vertex(xf * vertices[index])
		var combined := MeshInstance3D.new()
		combined.mesh = st.commit()
		combined.material_override = group.material
		combined.visibility_range_end = distance
		root.add_child(combined)
		for entry in group.items: originals.append(entry.node)
	# Children may use a different material from their parent mesh. Copy every
	# group first, then release originals without deleting unread child geometry.
	for original in originals:
		if is_instance_valid(original): original.free()

static func _collect(root: Node3D, transform: Transform3D, groups: Dictionary) -> void:
	for child in root.get_children():
		if not child is Node3D or not child.visible or child.is_queued_for_deletion(): continue
		var local: Transform3D = transform * child.transform
		if child is MeshInstance3D and child.material_override != null:
			var key: int = child.material_override.get_instance_id()
			if not groups.has(key): groups[key] = {"material":child.material_override,"items":[]}
			groups[key].items.append({"node":child,"transform":local})
		_collect(child,local,groups)

static func warung(parent: Node3D, pos: Vector3) -> Node3D:
	var root := house(parent, pos, Color("d4c7a0"), "SARI'S WARUNG")
	box(root, Vector3(0, 2.65, 5), Vector3(8.4, 0.14, 5), Color("617d70"))
	for x in [-3.8, 3.8]:
		cylinder(root, Vector3(x, 1.3, 7), 0.07, 2.6, Color("735c44"))
	for x in [-2.0, 1.6]:
		box(root, Vector3(x, 0.85, 4.9), Vector3(1.5, 0.12, 1.2), Color("8b6345"))
		for dx in [-0.55, 0.55]:
			box(root, Vector3(x + dx, 0.4, 4.9), Vector3(0.1, 0.8, 0.8), Color("614f3b"))
		cup(root, Vector3(x, 1.02, 4.9), 0.12, 0.23, Color("c5a972"))
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
	bake(root)
	return root
