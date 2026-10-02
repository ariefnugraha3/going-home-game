class_name BikeForms
extends RefCounted

# Small, scene-owned curved meshes for painted bodywork and cast metal.
# Low segment counts shape the silhouette; shared normals soften broad surfaces.
static func body(sections: Array, sides: int = 24, crown: float = 1.0) -> ArrayMesh:
	var rings: Array[PackedVector3Array] = []
	for i in range(sections.size()-1):
		for step in range(4):
			var s: Vector4 = _spline(sections[maxi(i-1,0)],sections[i],sections[i+1],sections[mini(i+2,sections.size()-1)],step/4.0)
			rings.append(_body_ring(s,sides,crown))
	rings.append(_body_ring(sections.back(),sides,crown))
	return _skin(rings)

static func _body_ring(s: Vector4, sides: int, crown: float) -> PackedVector3Array:
	var ring := PackedVector3Array()
	for i in range(sides):
		var a := TAU*i/sides
		var c := cos(a)
		ring.append(Vector3(maxf(s.x,.001)*sin(a),(s.y+s.z)*.5+(s.y-s.z)*.5*signf(c)*pow(absf(c),crown),s.w))
	return ring

static func _spline(a: Vector4, b: Vector4, c: Vector4, d: Vector4, t: float) -> Vector4:
	return .5*((2*b)+(-a+c)*t+(2*a-5*b+4*c-d)*t*t+(-a+3*b-3*c+d)*t*t*t)

static func _skin(rings: Array[PackedVector3Array]) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var count := rings[0].size()
	for i in range(rings.size()-1):
		for j in range(count):
			var k := (j+1)%count
			for p in [rings[i][j],rings[i][k],rings[i+1][j],rings[i][k],rings[i+1][k],rings[i+1][j]]:
				st.add_vertex(p)
	st.set_smooth_group(-1)
	for end in [0,rings.size()-1]:
		var center := Vector3.ZERO
		for p in rings[end]: center += p/count
		for j in range(count):
			var tri := [center,rings[end][(j+1)%count],rings[end][j]]
			if end != 0: tri.reverse()
			for p in tri: st.add_vertex(p)
	st.index()
	st.generate_normals()
	return st.commit()

static func tank() -> ArrayMesh:
	var shape := body([Vector4(.012,.88,.79,-.555),Vector4(.115,.975,.725,-.49),Vector4(.208,1.018,.69,-.36),Vector4(.228,1.019,.70,-.205),Vector4(.192,.978,.75,-.035),Vector4(.112,.898,.785,.095),Vector4(.045,.845,.80,.142),Vector4(.006,.825,.815,.153)])
	return shape

static func tube(points: Array, radius: float) -> ArrayMesh:
	var path := PackedVector3Array()
	for i in range(points.size()-1):
		var a: Vector3 = points[maxi(i-1,0)]
		var b: Vector3 = points[i]
		var c: Vector3 = points[i+1]
		var d: Vector3 = points[mini(i+2,points.size()-1)]
		for step in range(4):
			var t := step/4.0
			path.append(.5*((2*b)+(-a+c)*t+(2*a-5*b+4*c-d)*t*t+(-a+3*b-3*c+d)*t*t*t))
	path.append(points.back())
	var rings: Array[PackedVector3Array] = []
	for i in range(path.size()):
		var tangent := (path[mini(i+1,path.size()-1)]-path[maxi(i-1,0)]).normalized()
		var right := (Vector3.RIGHT if absf(tangent.y) > .98 else Vector3.UP).cross(tangent).normalized()
		var up := tangent.cross(right).normalized()
		var ring := PackedVector3Array()
		for j in range(12):
			var angle := TAU*j/12
			ring.append(path[i]+radius*(right*sin(angle)+up*cos(angle)))
		rings.append(ring)
	return _skin(rings)

static func lathe(profile: Array, sides: int = 24) -> ArrayMesh:
	var rings: Array[PackedVector3Array] = []
	for p in profile:
		var ring := PackedVector3Array()
		for i in range(sides):
			var a := TAU*i/sides
			ring.append(Vector3(p.x*sin(a),p.x*cos(a),p.y))
		rings.append(ring)
	# Axis Z; profiles progress from negative to positive Z.
	return _skin(rings)

static func plate(size: Vector3, radius: float) -> ArrayMesh:
	# Rounded rectangle in XY, extruded along Z with a small rolled edge.
	var rings: Array[PackedVector3Array] = []
	var bevel := minf(size.z*.24,.008)
	for section in [Vector2(-size.z*.5,.95),Vector2(-size.z*.5+bevel,1),Vector2(size.z*.5-bevel,1),Vector2(size.z*.5,.95)]:
		var ring := PackedVector3Array()
		for corner in range(4):
			var center := Vector2(1 if corner < 2 else -1,1 if corner == 0 or corner == 3 else -1)*(Vector2(size.x,size.y)*.5-Vector2.ONE*radius)
			for step in range(5):
				var a := PI*.5-corner*PI*.5-step*PI/8
				var p: Vector2 = (center+Vector2(cos(a),sin(a))*radius)*section.y
				ring.append(Vector3(p.x,p.y,section.x))
		rings.append(ring)
	return _skin(rings)

static func ellipsoid(parent: Node3D, point: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var shape := SphereMesh.new()
	shape.radius = .5
	shape.height = 1
	shape.radial_segments = 24
	shape.rings = 12
	var mesh := LowPoly.mesh(parent,shape,point,color)
	mesh.scale = size
	return mesh

static func tank_contact(tank_mesh: MeshInstance3D, direction: Vector3) -> Transform3D:
	# The authored tank is no longer an ellipsoid. Contact follows real triangles.
	if not tank_mesh.has_meta("contact_faces"):
		tank_mesh.set_meta("contact_faces",tank_mesh.mesh.get_faces())
		var arrays := tank_mesh.mesh.surface_get_arrays(0)
		var vertex_normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
		var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		var expanded := PackedVector3Array()
		if indices.is_empty(): expanded = vertex_normals
		else:
			for index in indices: expanded.append(vertex_normals[index])
		tank_mesh.set_meta("contact_normals",expanded)
	var faces: PackedVector3Array = tank_mesh.get_meta("contact_faces")
	var normals: PackedVector3Array = tank_mesh.get_meta("contact_normals")
	var origin := Vector3(0,.855,-.205)
	var ray := direction * Vector3(.46,.33,.70) * 2
	var point := origin
	var normal := Vector3.UP
	for i in range(0,faces.size(),3):
		var hit = Geometry3D.segment_intersects_triangle(origin,origin+ray,faces[i],faces[i+1],faces[i+2])
		if hit == null: continue
		point = hit
		# Match the rendered smooth normal to avoid cloth rotation popping at edges.
		var v0 := faces[i+1]-faces[i]
		var v1 := faces[i+2]-faces[i]
		var v2: Vector3 = hit-faces[i]
		var denominator := v0.dot(v0)*v1.dot(v1)-pow(v0.dot(v1),2)
		var b := (v1.dot(v1)*v2.dot(v0)-v0.dot(v1)*v2.dot(v1))/denominator
		var c := (v0.dot(v0)*v2.dot(v1)-v0.dot(v1)*v2.dot(v0))/denominator
		normal = (normals[i]*(1-b-c)+normals[i+1]*b+normals[i+2]*c).normalized()
		if normal.dot(ray) < 0: normal = -normal
		break
	var world_normal := (tank_mesh.global_basis.inverse().transposed()*normal).normalized()
	return Transform3D(Basis(Quaternion(Vector3.UP,world_normal)),tank_mesh.to_global(point))
