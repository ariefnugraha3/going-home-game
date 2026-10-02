class_name CharacterForms
extends RefCounted

# Meshes follow the existing joint lengths; anatomical shaping must not stretch
# bones or move the hand/foot anchors used by interaction animation.
static func limb(parent: Node3D, a: Vector3, b: Vector3, widths: Vector3, color: Color) -> MeshInstance3D:
	var length := a.distance_to(b)
	var rings := [Vector4(widths.x,0,widths.x*.85,0),Vector4(widths.y,length*.28,widths.y*.88,0),Vector4(widths.y*.92,length*.58,widths.y*.82,0),Vector4(widths.z,length,widths.z*.88,0)]
	var node := LowPoly.mesh(parent,CozyForms.loft(rings,12),a,color)
	node.quaternion = Quaternion(Vector3.UP,(b-a).normalized())
	return node

static func face(parent: Node3D, female: bool) -> void:
	var skin := Color("c49373")
	# Jaw, cheeks, temples and crown: the face is no longer an icosphere.
	var head_mesh := CozyForms.loft([Vector4(.057 if female else .065,.035,.073,-.022),Vector4(.092 if female else .105,.073,.103,-.012),Vector4(.134 if female else .143,.155,.132,0),Vector4(.147,.245,.132,.005),Vector4(.126,.317,.112,.012),Vector4(.07,.35,.07,.015)],16)
	LowPoly.mesh(parent,head_mesh,Vector3.ZERO,skin)
	for side in [-1,1]:
		LowPoly.sphere(parent,Vector3(side*.15,.185,0),Vector3(.043,.075,.047),skin)
		LowPoly.sphere(parent,Vector3(side*.166,.184,-.009),Vector3(.012,.034,.016),Color("a77158"))
		# Almond sockets sit on the face, with iris and upper lid following it.
		LowPoly.sphere(parent,Vector3(side*.061,.221,-.119),Vector3(.060,.026,.016),Color("ece0c9"))
		LowPoly.sphere(parent,Vector3(side*.059,.222,-.128),Vector3(.022,.023,.008),Color("493b30"))
		LowPoly.sphere(parent,Vector3(side*.057,.225,-.133),Vector3(.006,.007,.003),Color("fff1d6"))
		LowPoly.beam(parent,Vector3(side*.036,.235,-.12),Vector3(side*.086,.232,-.113),.005,Color("755540"))
	# Bridge + tip avoids a detached spherical nose.
	LowPoly.mesh(parent,CozyForms.loft([Vector4(.021,.14,.022,-.138),Vector4(.027,.16,.033,-.146),Vector4(.016,.207,.012,-.130)],8),Vector3.ZERO,skin.lightened(.04))
	LowPoly.beam(parent,Vector3(-.032,.112,-.12),Vector3(0,.108,-.129),.004,Color("925f50") if female else Color("895d4b"))
	LowPoly.beam(parent,Vector3(0,.108,-.129),Vector3(.032,.112,-.12),.004,Color("925f50") if female else Color("895d4b"))

static func hand(parent: Node3D, side: int) -> void:
	var skin := Color("bc8968")
	LowPoly.sphere(parent,Vector3(0,-.271,0),Vector3(.072,.088,.045),skin)
	# Fingers remain inside the old contact envelope, with a separate thumb.
	for i in range(4):
		var x := (i-1.5)*.016
		limb(parent,Vector3(x,-.285,-.004),Vector3(x,-.326+absf(i-1.5)*.005,-.012),Vector3(.009,.009,.007),skin)
	limb(parent,Vector3(-side*.03,-.257,0),Vector3(-side*.044,-.286,-.016),Vector3(.014,.012,.009),skin)

static func shoe(parent: Node3D, pos: Vector3) -> MeshInstance3D:
	# Single shaped upper, child sole/welt: animation still moves one shoe node.
	var result := LowPoly.mesh(parent,CozyForms.loft([Vector4(.078,-.065,.14,-.015),Vector4(.08,-.035,.145,-.015),Vector4(.072,.018,.13,-.015),Vector4(.055,.06,.065,.045)],12),pos,Color("3c403b"))
	LowPoly.box(result,Vector3(0,-.061,-.015),Vector3(.155,.018,.28),Color("857c65"))
	for z in [.005,.03,.055]: LowPoly.beam(result,Vector3(-.035,.055,z),Vector3(.035,.055,z),.004,Color("b3a58a"))
	return result

static func helmet_shell() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for layer in [0,1]:
		for row in range(6):
			for column in range(24):
				var points := []
				for uv in [Vector2(column,row),Vector2(column+1,row),Vector2(column+1,row+1),Vector2(column,row+1)]:
					var azimuth: float = uv.x*TAU/24
					# Higher brow opening in front; shell wraps down behind ears.
					var rim: float = lerpf(1.89,1.15,clampf(-sin(azimuth)*2,0,1))
					var polar: float = lerpf(.02,rim,uv.y/6)
					var r: float = .22-layer*.012
					points.append(Vector3(cos(azimuth)*sin(polar)*r,cos(polar)*(.205-layer*.012)-.045,sin(azimuth)*sin(polar)*r))
				var normal: Vector3 = (points[1]-points[0]).cross(points[2]-points[0]).normalized()
				if normal.dot(points[0]) < 0: normal = -normal
				CozyForms.polygon(st,points,normal if layer == 0 else -normal)
	return st.commit()
