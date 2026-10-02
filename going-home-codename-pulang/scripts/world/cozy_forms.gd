class_name CozyForms
extends RefCounted

# Sculpted, flat-normal primitives. Meshes stay owned by their scene so unloading
# a chapter also releases the art; no growing global geometry cache is needed.
static func triangle(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, normal: Vector3) -> void:
	var tone := clampf(.96 + normal.y * .055 + normal.x * .018, .89, 1.03)
	surface.set_color(Color(tone, tone, tone))
	surface.set_normal(normal)
	surface.add_vertex(a)
	if (b - a).cross(c - a).dot(normal) > 0:
		surface.add_vertex(c)
		surface.add_vertex(b)
	else:
		surface.add_vertex(b)
		surface.add_vertex(c)

static func polygon(surface: SurfaceTool, points: Array, normal: Vector3) -> void:
	for i in range(1, points.size() - 1): triangle(surface, points[0], points[i], points[i + 1], normal)

static func bevel_box(size: Vector3, radius: float = -1) -> ArrayMesh:
	var h := size * .5
	var r := minf(minf(size.x, size.y), size.z) * .16 if radius < 0 else radius
	r = minf(r, .09)
	var inner := h - Vector3.ONE * r
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for axis in range(3):
		var u := (axis + 1) % 3
		var v := (axis + 2) % 3
		for sign_value in [-1, 1]:
			var n := Vector3.ZERO
			n[axis] = sign_value
			var face := []
			for pair in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
				var p := Vector3.ZERO
				p[axis] = h[axis] * sign_value
				p[u] = inner[u] * pair.x
				p[v] = inner[v] * pair.y
				face.append(p)
			polygon(st, face, n)
		for su in [-1, 1]:
			for sv in [-1, 1]:
				var face := []
				for item in [Vector2(-1, 0), Vector2(1, 0), Vector2(1, 1), Vector2(-1, 1)]:
					var p := Vector3.ZERO
					p[axis] = inner[axis] * item.x
					p[u] = (h[u] if item.y == 0 else inner[u]) * su
					p[v] = (inner[v] if item.y == 0 else h[v]) * sv
					face.append(p)
				var n := Vector3.ZERO
				n[u] = su
				n[v] = sv
				polygon(st, face, n.normalized())
	for x in [-1, 1]:
		for y in [-1, 1]:
			for z in [-1, 1]:
				var signs := Vector3(x, y, z)
				var corner := inner * signs
				triangle(st, corner + Vector3(x * r, 0, 0), corner + Vector3(0, y * r, 0), corner + Vector3(0, 0, z * r), signs.normalized())
	return st.commit()

static func pebble() -> ArrayMesh:
	var t := (1.0 + sqrt(5.0)) / 2.0
	var verts := [Vector3(-1,t,0),Vector3(1,t,0),Vector3(-1,-t,0),Vector3(1,-t,0),Vector3(0,-1,t),Vector3(0,1,t),Vector3(0,-1,-t),Vector3(0,1,-t),Vector3(t,0,-1),Vector3(t,0,1),Vector3(-t,0,-1),Vector3(-t,0,1)]
	var faces := [[0,11,5],[0,5,1],[0,1,7],[0,7,10],[0,10,11],[1,5,9],[5,11,4],[11,10,2],[10,7,6],[7,1,8],[3,9,4],[3,4,2],[3,2,6],[3,6,8],[3,8,9],[4,9,5],[2,4,11],[6,2,10],[8,6,7],[9,8,1]]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for face in faces:
		var a: Vector3 = verts[face[0]].normalized() * .5
		var b: Vector3 = verts[face[1]].normalized() * .5
		var c: Vector3 = verts[face[2]].normalized() * .5
		var ab := (a + b).normalized() * .5
		var bc := (b + c).normalized() * .5
		var ca := (c + a).normalized() * .5
		for tri in [[a,ab,ca],[b,bc,ab],[c,ca,bc],[ab,bc,ca]]:
			var n: Vector3 = (tri[1] - tri[0]).cross(tri[2] - tri[0]).normalized()
			if n.dot(tri[0]) < 0: n = -n
			triangle(st, tri[0], tri[1], tri[2], n)
	return st.commit()

static func loft(rings: Array, sides: int = 10) -> ArrayMesh:
	# Each Vector4 stores (half width, height, half depth, depth offset).
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for j in range(rings.size() - 1):
		for i in range(sides):
			var face := []
			for pair in [Vector2(i,j),Vector2(i+1,j),Vector2(i+1,j+1),Vector2(i,j+1)]:
				var ring: Vector4 = rings[int(pair.y)]
				var angle: float = TAU * pair.x / sides + PI / sides
				face.append(Vector3(cos(angle) * ring.x, ring.y, sin(angle) * ring.z + ring.w))
			var normal: Vector3 = (face[1] - face[0]).cross(face[2] - face[0]).normalized()
			if normal.dot(Vector3(face[0].x, 0, face[0].z - rings[j].w)) < 0: normal = -normal
			polygon(st, face, normal)
	for index in [0, rings.size() - 1]:
		var ring: Vector4 = rings[index]
		var points := []
		for i in range(sides): points.append(Vector3(cos(TAU * i / sides + PI / sides) * ring.x, ring.y, sin(TAU * i / sides + PI / sides) * ring.z + ring.w))
		polygon(st, points, Vector3.DOWN if index == 0 else Vector3.UP)
	return st.commit()

static func tree(parent: Node3D, pos: Vector3, variant: int = 0, height: float = 7.0) -> Node3D:
	var root := Node3D.new()
	parent.add_child(root)
	root.position = pos
	var k := height / 7.0
	root.scale = Vector3.ONE * k
	LowPoly.cylinder(root, Vector3(0, 1.8, 0), .36, 3.6, Color("846246"), .16, 7)
	for branch in [Vector3(-1.2,3.7,.3), Vector3(1.4,4.2,-.4), Vector3(.2,4.4,.8)]:
		LowPoly.beam(root, Vector3(0,2.3,0), branch, .13, Color("846246"))
	var colors := [Color("79985d"), Color("9fac69"), Color("597c59")]
	var lumps := [Vector3(-1.45,4.7,.15),Vector3(1.4,4.9,-.4),Vector3(.1,5.9,.1),Vector3(.1,4.7,1.45)]
	for i in range(lumps.size()):
		var crown := LowPoly.mesh(root, pebble(), lumps[i], colors[(i + variant) % 3])
		crown.scale = Vector3(3.5,3.5,3.4) if i == 2 else Vector3(3.4,3,3.1)
		crown.rotation.y = i * .8 + variant
	for child in root.find_children("*", "GeometryInstance3D", true, false): child.visibility_range_end = 260
	return root

static func palm(parent: Node3D, pos: Vector3) -> Node3D:
	var root := Node3D.new()
	parent.add_child(root)
	root.position = pos
	for i in range(5):
		var a := Vector3(.07*i*i, i*1.4, 0)
		var b := Vector3(.07*(i+1)*(i+1), (i+1)*1.4, 0)
		LowPoly.beam(root, a, b, .2-i*.02, Color("9b8256"))
	var tip := Vector3(1.75,7,0)
	for i in range(7):
		var angle := i * TAU / 7
		var direction := Vector3(cos(angle),0,sin(angle))
		var side := direction.cross(Vector3.UP)
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for j in range(4):
			var a := tip + direction * j * .95 + Vector3.UP * sin(j * .7)
			var b := tip + direction * (j+1) * .95 + Vector3.UP * sin((j+1) * .7)
			var width := sin((j+1) * PI / 5) * .6
			for sign_value in [-1,1]: triangle(st,a,b,a.lerp(b,.5)+side*width*sign_value,Vector3.UP)
		var leaf := LowPoly.mesh(root,st.commit(),Vector3.ZERO,Color("668657") if i%2 else Color("91a56b"))
		leaf.material_override = leaf.material_override.duplicate()
		leaf.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
	for child in root.find_children("*", "GeometryInstance3D", true, false): child.visibility_range_end = 280
	return root
