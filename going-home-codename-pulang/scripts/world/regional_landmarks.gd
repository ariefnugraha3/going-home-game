class_name RegionalLandmarks
extends RefCounted

# Small authored roadside groups, rather than a second random scenery layer.
# Their roots sit outside the shoulder; none can block riding or recovery.
static func build(world: RoadWorld, id: String) -> Node3D:
	var root := Node3D.new()
	root.name = "RegionalLandmark"
	world.add_child(root)
	root.position = world.sample_route(680) + Vector3(-23, -.12, 0)
	root.rotation.y = PI / 2
	match id:
		"karawang":
			_warehouse(root)
		"cirebon":
			_canopy(root, Color("71887c"))
			_cart(root, Vector3(1.6, 0, .8), Color("94835c"))
			for x in [-2.6, -1.5, -.4]: _basket(root, Vector3(x, .3, .7))
			_sign(root, "COAST ROAD", Vector3(0, 2.75, 2.1))
		"tegal":
			_canopy(root, Color("6e7a79"))
			_sign(root, "MOTORCYCLE REPAIRS", Vector3(0, 2.75, 2.1))
			for x in [-2.8, -1.9]:
				for y in [.07, .21, .35]: _tire(root, Vector3(x, y, .3), false)
			LowPoly.box(root, Vector3(1.4, .85, -.6), Vector3(2.1, .18, 1), Color("927555"))
			for x in [.6, 2.2]: LowPoly.box(root, Vector3(x, .4, -.6), Vector3(.14, .8, .7), Color("6a6555"))
			LowPoly.cylinder(root, Vector3(.9, 1.12, -.6), .12, .4, Color("b28247"))
			LowPoly.beam(root, Vector3(1.2, .98, -.5), Vector3(2, .98, -.8), .035, Color("a5b5af"))
		"pekalongan":
			_canopy(root, Color("866d60"))
			for x in [-2.2, 0, 2.2]: _cloth_rack(root, Vector3(x, 0, .2), int(x + 3))
			_sign(root, "TEXTILES", Vector3(0, 2.75, 2.1))
		"semarang":
			_arcade(root)
		"salatiga":
			_overlook(root)
			for x in [-3, 3]: _pot(root, Vector3(x, 0, -.7))
		"solo":
			_courtyard(root)
			_cloth_rack(root, Vector3(-2.5, 0, -1.2), 2)
			_cart(root, Vector3(3.5, 0, 1), Color("658e7b"))
		"ngawi":
			_overlook(root)
			for x in [-3.5, 3.5]:
				LowPoly.cylinder(root, Vector3(x, 4, -2), .4, 8, Color("817c60"))
				LowPoly.sphere(root, Vector3(x, 8, -2), Vector3(7, 2.8, 6), Color("657d52"))
		"madiun":
			_canopy(root, Color("9b7157"))
			_cart(root, Vector3(0, 0, 0), Color("69998b"))
			for x in [-2.5, 2.5]: _stool(root, Vector3(x, 0, 1.3))
			_sign(root, "FOOD & TEA", Vector3(0, 2.75, 2.1))
		"kediri":
			_courtyard(root)
			_sign(root, "ROOMS", Vector3(0, 3.05, -1.24))
			for x in [-1.8, 1.8]: _pot(root, Vector3(x, 0, .1))
		"malang":
			_gate(root, "CAMPUS")
			_cart(root, Vector3(-3.5, 0, 1.4), Color("718487"))
			for i in range(5): LowPoly.box(root, Vector3(-3.8 + i * .16, 1.4, 1.4), Vector3(.12, .42, .35), Color("ae976b") if i % 2 else Color("557a73"))
		"lumajang":
			_overlook(root)
			for i in range(3):
				LowPoly.box(root, Vector3(0, -.18 - i * .3, -3 - i * 3), Vector3(12 + i * 4, .2, 2.5), Color("9ba66d") if i % 2 else Color("b1b279"))
		"jember":
			_canopy(root, Color("7c805b"))
			for x in [-2.3, 0, 2.3]:
				LowPoly.box(root, Vector3(x, .7, .5), Vector3(1.9, .1, 2.1), Color("907551"))
				for z in [-.3, .3, .9]: LowPoly.box(root, Vector3(x, .78, z), Vector3(1.65, .06, .36), Color("a19255"))
				for z in [-.3, 1.3]: LowPoly.box(root, Vector3(x, .3, z), Vector3(1.7, .6, .12), Color("716847"))
		"banyuwangi", "epilogue":
			_courtyard(root)
			for x in [-3, -1.5, 1.5, 3]: _pot(root, Vector3(x, 0, 1))
			_gate(root, "")
		_:
			root.queue_free()
			return null
	for child in root.find_children("*", "GeometryInstance3D", true, false):
		child.visibility_range_end = 220
	LowPoly.bake(root,220)
	return root

static func _canopy(root: Node3D, color: Color) -> void:
	LowPoly.box(root, Vector3(0, -.08, 0), Vector3(8, .16, 6), Color("b4ab8c"))
	var roof := LowPoly.box(root, Vector3(0, 3.05, 0), Vector3(8, .14, 5.5), color)
	roof.rotation.x = -.08
	for x in [-3.5, 3.5]:
		for z in [-2, 2]: LowPoly.cylinder(root, Vector3(x, 1.5, z), .07, 3, Color("897553"))
	LowPoly.box(root, Vector3(0, 1.4, -2.2), Vector3(7, 2.8, .1), Color("aaa081"))

static func _sign(root: Node3D, text: String, pos: Vector3) -> void:
	LowPoly.box(root, pos, Vector3(6.5, .6, .1), Color("4c6458"))
	LowPoly.label(root, text, pos + Vector3(0, 0, .065), 25)

static func _basket(root: Node3D, pos: Vector3) -> void:
	LowPoly.cylinder(root, pos, .32, .55, Color("b29460"), .43)
	for y in [-.16, 0, .16]:
		var ring := TorusMesh.new()
		ring.inner_radius = .30 + (y + .16) * .16
		ring.outer_radius = ring.inner_radius + .035
		ring.rings = 12
		ring.ring_segments = 5
		LowPoly.mesh(root, ring, pos + Vector3(0, y, 0), Color("896f48"))

static func _tire(root: Node3D, pos: Vector3, upright: bool = true) -> void:
	var tire := TorusMesh.new()
	tire.inner_radius = .20
	tire.outer_radius = .34
	tire.rings = 16
	tire.ring_segments = 8
	var node := LowPoly.mesh(root, tire, pos, Color("303d36"))
	if upright: node.rotation.z = PI / 2

static func _cart(root: Node3D, pos: Vector3, color: Color) -> void:
	var cart := Node3D.new()
	root.add_child(cart)
	cart.position = pos
	LowPoly.box(cart, Vector3(0, .8, 0), Vector3(1.9, .75, 1), color)
	LowPoly.box(cart, Vector3(0, 1.21, 0), Vector3(2.2, .1, 1.2), Color("bba886"))
	LowPoly.box(cart, Vector3(.4, 1.55, -.2), Vector3(.7, .6, .65), Color("788e86"))
	LowPoly.box(cart, Vector3(.4, 1.55, .14), Vector3(.58, .42, .025), Color("bdcaba"))
	LowPoly.cylinder(cart, Vector3(-.65, 1.4, 0), .18, .32, Color("b5b8a6"))
	for x in [-1.0, 1.0]: _tire(cart, Vector3(x, .34, 0))
	LowPoly.beam(cart, Vector3(1, 1, -.4), Vector3(1.9, 1, -.4), .045, Color("6c725b"))
	LowPoly.box(cart, Vector3(1.9, .5, -.4), Vector3(.1, 1, .1), Color("6c725b"))

static func _cloth_rack(root: Node3D, pos: Vector3, variant: int) -> void:
	for x in [-.95, .95]: LowPoly.cylinder(root, pos + Vector3(x, 1.15, 0), .035, 2.3, Color("78694b"))
	LowPoly.beam(root, pos + Vector3(-1.1, 2.15, 0), pos + Vector3(1.1, 2.15, 0), .045, Color("78694b"))
	var color := Color("a87959") if variant % 2 else Color("536f81")
	LowPoly.box(root, pos + Vector3(0, 1.45, 0), Vector3(1.75, 1.35, .045), color)
	for x in [-.58, 0, .58]:
		for y in [1.04, 1.43, 1.82]:
			var motif := LowPoly.box(root, pos + Vector3(x, y, .028), Vector3(.21, .21, .01), Color("c9b890"))
			motif.rotation.z = PI / 4

static func _stool(root: Node3D, pos: Vector3) -> void:
	LowPoly.box(root, pos + Vector3(0, .42, 0), Vector3(.6, .09, .6), Color("917b54"))
	for x in [-.2, .2]:
		for z in [-.2, .2]: LowPoly.box(root, pos + Vector3(x, .2, z), Vector3(.07, .4, .07), Color("796545"))

static func _pot(root: Node3D, pos: Vector3) -> void:
	LowPoly.planter(root,pos,.9)

static func _overlook(root: Node3D) -> void:
	LowPoly.box(root, Vector3(0, -.06, 0), Vector3(12, .12, 6), Color("b2a682"))
	for x in [-5, -2.5, 0, 2.5, 5]: LowPoly.box(root, Vector3(x, .55, -2), Vector3(.18, 1.1, .18), Color("b8b5a0"))
	for y in [.4, .95]: LowPoly.box(root, Vector3(0, y, -2), Vector3(10.2, .12, .12), Color("8a8d78"))
	LowPoly.box(root, Vector3(0, .5, .2), Vector3(3.5, .14, .7), Color("8e7555"))
	for x in [-1.3, 1.3]: LowPoly.box(root, Vector3(x, .25, .2), Vector3(.18, .5, .6), Color("756346"))

static func _courtyard(root: Node3D) -> void:
	LowPoly.house(root, Vector3(0, 0, -4), Color("c5bc9c"))
	LowPoly.box(root, Vector3(0, -.08, 1), Vector3(10, .16, 7), Color("aca184"))
	for side in [-1, 1]:
		for z in [-1, 0, 1, 2]: LowPoly.box(root, Vector3(side * 4.3, .5, z), Vector3(.12, 1, .15), Color("8e987b"))
		LowPoly.box(root, Vector3(side * 4.3, .75, .5), Vector3(.12, .12, 4), Color("8e987b"))

static func _gate(root: Node3D, title: String) -> void:
	for x in [-4.3, 4.3]:
		LowPoly.box(root, Vector3(x, 1.35, 3), Vector3(.6, 2.7, .6), Color("a89c7c"))
		LowPoly.box(root, Vector3(x, 2.75, 3), Vector3(.8, .2, .8), Color("6e7a65"))
	if not title.is_empty(): _sign(root, title, Vector3(0, 2.55, 3))

static func _arcade(root: Node3D) -> void:
	LowPoly.box(root, Vector3(0, 3, -2), Vector3(12, 6, 5), Color("b5af92"))
	for side in [-1,1]:
		var roof := LowPoly.box(root,Vector3(side*3.15,6.46,-2),Vector3(6.65,.18,6),Color("ad7959"))
		roof.rotation.z = side * -.16
	LowPoly.box(root,Vector3(0,5.98,.6),Vector3(12.4,.22,.35),Color("d5c29d"))
	LowPoly.box(root, Vector3(0, 3.1, 1.3), Vector3(13, .2, 3), Color("8b7f66"))
	for x in [-5, -2.5, 0, 2.5, 5]:
		LowPoly.box(root, Vector3(x, 1.5, 2.2), Vector3(.28, 3, .28), Color("c5bfa0"))
		LowPoly.box(root, Vector3(x, 4.6, .53), Vector3(1.15, 1.6, .07), Color("60796e"))
		LowPoly.box(root, Vector3(x, 4.6, .58), Vector3(.07, 1.6, .04), Color("bfb79a"))
		for side in [-1,1]: LowPoly.box(root,Vector3(x+side*.62,4.6,.6),Vector3(.1,1.8,.14),Color("c9b994"))
		LowPoly.box(root,Vector3(x,3.73,.65),Vector3(1.42,.12,.34),Color("d1bd96"))
	_sign(root, "DINNER & COFFEE", Vector3(0, 2.8, 2.38))

static func _warehouse(root: Node3D) -> void:
	LowPoly.box(root, Vector3(0, 3.5, -2), Vector3(14, 7, 10), Color("8d9991"))
	for side in [-1,1]:
		var roof := LowPoly.box(root,Vector3(side*3.6,7.45,-2),Vector3(7.5,.18,10.8),Color("8b9b90"))
		roof.rotation.z = side * -.12
	for x in [-6.8,-.5,6.8]: LowPoly.box(root,Vector3(x,3.5,3.13),Vector3(.16,7,.16),Color("b6b79d"))
	LowPoly.box(root,Vector3(0,.1,4.4),Vector3(14.3,.2,3),Color("afac91"))
	for x in [-4, 3]:
		LowPoly.box(root, Vector3(x, 2.2, 3.05), Vector3(4.5, 4.4, .08), Color("637670"))
		for y in range(1, 5): LowPoly.box(root, Vector3(x, y, 3.11), Vector3(4.4, .05, .04), Color("88968b"))
	for x in [-2, 0, 2]: LowPoly.box(root, Vector3(x, .5, 5), Vector3(1.8, 1, 1.4), Color("a38b62"))
	_sign(root, "DELIVERIES", Vector3(0, 5.5, 3.1))
