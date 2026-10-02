class_name BikeVisual
extends Node3D

var show_rider_arms: bool = true
var instruments: BikeInstruments
var bars: Node3D
var tank: MeshInstance3D
var luggage: Node3D
var wheels: Array[Node3D] = []

func _ready() -> void:
	var steel := Color("b7bdb2")
	var black := Color("363a35")
	var paint := Color("467c72")
	var metal := LowPoly.material(steel)
	metal.metallic = .58
	metal.roughness = .34
	var tank_shape := SphereMesh.new()
	tank_shape.radial_segments = 24
	tank_shape.rings = 12
	tank_shape.radius = .5
	tank_shape.height = 1.0
	tank = LowPoly.mesh(self,tank_shape,Vector3(0,.89,-.20),paint)
	tank.scale = Vector3(.64,.37,.91)
	LowPoly.cylinder(self, Vector3(0, 1.075, -0.22), 0.09, 0.018, steel)
	LowPoly.mesh(self,CozyForms.loft([Vector4(.195,.715,.34,.49),Vector4(.225,.775,.35,.49),Vector4(.218,.843,.325,.50)],16),Vector3.ZERO,black)
	for z in [.28,.38,.48,.58,.68]: LowPoly.beam(self,Vector3(-.21,.857,z),Vector3(.21,.857,z),.006,Color("6b6959"))
	for side in [-1,1]:
		var panel := LowPoly.sphere(self,Vector3(side*.21,.62,.32),Vector3(.10,.27,.43),paint)
		panel.rotation.x = -.2
		LowPoly.beam(self,Vector3(side*.30,.87,-.48),Vector3(side*.32,.87,.02),.018,Color("d8cba0"))
		for z in [-.82,.77]:
			LowPoly.beam(self,Vector3(side*.12,.70,z),Vector3(side*.29,.70,z),.016,steel)
			LowPoly.sphere(self,Vector3(side*.31,.70,z),Vector3(.13,.085,.10),Color("dca258"))
	var crank := LowPoly.cylinder(self,Vector3(.21,.35,.12),.14,.065,steel,-1,12)
	crank.rotation.z = PI/2
	LowPoly.box(self,Vector3(0,.59,1.03),Vector3(.27,.12,.018),Color("d6cbb0"))
	# Single-cylinder air-cooled engine: crankcase, barrel, fins and rocker cover.
	LowPoly.sphere(self,Vector3(0,.33,.06),Vector3(.38,.27,.40),Color("929c95"))
	LowPoly.cylinder(self,Vector3(0,.51,-.13),.145,.28,Color("778780"),-1,12)
	for y in range(8):
		LowPoly.box(self,Vector3(0,.40+y*.029,-.13),Vector3(.34,.013,.31),Color("a9b3aa"))
	LowPoly.box(self,Vector3(0,.65,-.13),Vector3(.29,.072,.27),steel)
	for side in [-1,1]:
		var cover := LowPoly.cylinder(self,Vector3(side*.192,.32,.07),.112,.026,steel,-1,16)
		cover.rotation.z = PI/2
		for i in range(6):
			var a := i*TAU/6
			LowPoly.sphere(self,Vector3(side*.212,.32+cos(a)*.092,.07+sin(a)*.092),Vector3(.012,.018,.018),Color("59675f"))
	LowPoly.cylinder(self,Vector3(0,.58,.16),.062,.12,Color("56685e"),-1,12)
	LowPoly.beam(self,Vector3(.075,.675,-.12),Vector3(.12,.75,.08),.008,black)
	for z in [-0.78, 0.76]:
		var wheel := Node3D.new()
		add_child(wheel)
		wheel.position = Vector3(0, .34, z)
		wheels.append(wheel)
		_ring(wheel, .25, .34, black).rotation.z = PI / 2
		_ring(wheel, .225, .258, steel).rotation.z = PI / 2
		var hub := LowPoly.cylinder(wheel, Vector3.ZERO, .075, .17, steel, -1, 12)
		hub.rotation.z = PI / 2
		for spoke in range(36):
			var angle := spoke * TAU / 36
			var offset := .19 if spoke % 2 else -.19
			LowPoly.beam(wheel,Vector3(-.045 if spoke%2 else .045,.065*cos(angle),.065*sin(angle)),Vector3(0,.241*cos(angle+offset),.241*sin(angle+offset)),.0035,steel)
		if z < 0:
			var disc := LowPoly.cylinder(wheel,Vector3(-.075,0,0),.174,.011,Color("a3aca4"),-1,28)
			disc.rotation.z = PI/2
			for i in range(14):
				var a := i*TAU/14
				var hole := LowPoly.cylinder(wheel,Vector3(-.082,.143*cos(a),.143*sin(a)),.009,.002,black,-1,8)
				hole.rotation.z = PI/2
			LowPoly.box(self,Vector3(-.115,.43,z+.13),Vector3(.055,.105,.065),Color("58665d"))
		LowPoly.bake(wheel,240)
		_fender(z, paint if z < 0 else black)
	for side in [-1, 1]:
		LowPoly.beam(self, Vector3(side * 0.14, 0.35, -0.78), Vector3(side * 0.14, 1.13, -0.57), 0.035, steel)
		LowPoly.beam(self, Vector3(side * 0.2, 0.36, 0.76), Vector3(side * 0.2, 0.75, 0.52), 0.05, steel)
		# Frame rails, swingarm and visible twin shock springs.
		LowPoly.beam(self, Vector3(side * .22, .72, .55), Vector3(side * .17, .31, -.32), .025, black)
		LowPoly.beam(self, Vector3(side * .17, .31, -.32), Vector3(side * .2, .34, .76), .03, black)
		LowPoly.beam(self, Vector3(side * .18, .88, -.55), Vector3(side * .17, .31, -.32), .025, black)
		for turn in range(6):
			var coil := _ring(self, .049, .064, black)
			coil.position = Vector3(side * .2, .40, .724).lerp(Vector3(side * .2, .71, .555), turn / 5.0)
			coil.rotation.x = -.73
		LowPoly.beam(self, Vector3(side * .12, .35, .08), Vector3(side * .37, .35, .08), .03, black)
	# Intact seat, rear grab rail, tail lamp and maintained exhaust.
	LowPoly.box(self, Vector3(0, .72, .95), Vector3(.27, .15, .1), Color("a95042"))
	LowPoly.beam(self, Vector3(-.27, .81, .72), Vector3(.27, .81, .72), .018, steel)
	LowPoly.beam(self, Vector3(.23, .37, -.29), Vector3(.28, .19, -.49), .045, Color("777f77"))
	LowPoly.beam(self, Vector3(.28, .19, -.49), Vector3(.3, .2, .27), .045, Color("777f77"))
	LowPoly.beam(self, Vector3(.3, .2, .27), Vector3(.32, .27, 1.05), .075, steel)
	# Rear chain run and guard stay outside the moving tire.
	LowPoly.beam(self,Vector3(-.18,.30,.10),Vector3(-.18,.35,.76),.010,Color("5a655c"))
	LowPoly.beam(self,Vector3(-.18,.25,.10),Vector3(-.18,.28,.76),.010,Color("5a655c"))
	LowPoly.box(self,Vector3(-.19,.42,.48),Vector3(.055,.03,.58),black)
	for side in [-1,1]:
		LowPoly.beam(self,Vector3(side*.14,.34,-.78),Vector3(side*.14,.72,-.64),.048,Color("a7b1a8"))
		for z in [-.22,-.15,-.08,.0]: LowPoly.box(self,Vector3(side*.19,.645,z),Vector3(.02,.023,.009),Color("68786c"))
	var lamp := LowPoly.cylinder(self, Vector3(0, 1.04, -0.84), 0.17, 0.12, steel, -1, 18)
	lamp.rotation.x = PI / 2
	var glass := LowPoly.cylinder(self, Vector3(0, 1.04, -0.911), 0.15, 0.015, Color("f5eac6"), -1, 18)
	glass.rotation.x = PI / 2
	for i in range(-3,4):
		var x := i*.032
		var h := sqrt(.14*.14-x*x)
		LowPoly.beam(self,Vector3(x,1.04-h,-.920),Vector3(x,1.04+h,-.920),.0025,Color("d4d9bf"))
	for y in [-.065,.0,.065]: LowPoly.beam(self,Vector3(-.12,1.04+y,-.922),Vector3(.12,1.04+y,-.922),.002,Color("e5dec3"))
	bars = Node3D.new()
	add_child(bars)
	LowPoly.beam(bars,Vector3(-.21,1.075,-.48),Vector3(.21,1.075,-.48),.022,steel)
	for side in [-1,1]:
		LowPoly.beam(bars,Vector3(side*.21,1.075,-.48),Vector3(side*.35,1.15,-.40),.022,steel)
		LowPoly.beam(bars,Vector3(side*.35,1.15,-.40),Vector3(side*.52,1.15,-.32),.022,steel)
	LowPoly.cylinder(bars, Vector3(.18, 1.16, -.38), .018, .03, Color("bdb293"))
	LowPoly.cylinder(bars,Vector3(.18,1.12,-.38),.035,.07,black,-1,12)
	LowPoly.beam(bars,Vector3(.18,1.075,-.48),Vector3(.18,1.11,-.38),.019,steel)
	for side in [-1, 1]:
		LowPoly.beam(bars, Vector3(side * 0.42, 1.15, -0.38), Vector3(side * 0.57, 1.15, -0.3), 0.047, black)
		LowPoly.box(bars, Vector3(side * .42, 1.16, -.34), Vector3(.09, .085, .09), Color("404b46"))
		LowPoly.beam(bars, Vector3(side * .43, 1.16, -.42), Vector3(side * .59, 1.14, -.39), .012, steel)
		LowPoly.beam(bars, Vector3(side * 0.46, 1.17, -0.38), Vector3(side * 0.58, 1.49, -0.55), 0.016, steel)
		LowPoly.sphere(bars, Vector3(side * 0.60, 1.53, -0.55), Vector3(0.25, 0.13, 0.045), black)
		var mirror := LowPoly.sphere(bars, Vector3(side * 0.60, 1.534, -0.524), Vector3(0.224, 0.106, 0.015), Color("a9c2ba"))
		mirror.material_override = LowPoly.material(Color("a9c2ba"), true)
		# Static sky/road approximation keeps mirrors inexpensive on WebGL.
		LowPoly.box(bars, Vector3(side * 0.60, 1.507, -0.513), Vector3(0.17, 0.03, 0.004), Color("758b7b"))
		if show_rider_arms:
			LowPoly.sphere(bars, Vector3(side * 0.51, 1.165, -0.29), Vector3(0.15, 0.08, 0.21), Color("6d5d47"))
			LowPoly.beam(bars, Vector3(side * 0.51, 1.13, -0.23), Vector3(side * 0.41, 0.98, 0.2), 0.078, Color("65715d"))
	instruments = BikeInstruments.new()
	instruments.position = Vector3(0, 1.16, -.67)
	instruments.rotation_degrees.x = 22
	bars.add_child(instruments)
	for side in [-1,1]:
		var badge := LowPoly.label(self,"250",Vector3(side*.263,.63,.32),18)
		badge.pixel_size = .003
		badge.rotation.y = side * PI/2
	luggage = Node3D.new()
	add_child(luggage)
	LowPoly.box(luggage, Vector3(0, 1.04, .55), Vector3(.63, .38, .50), Color("8d7755"))
	LowPoly.box(luggage, Vector3(0, 1.24, .55), Vector3(.65, .025, .52), Color("756646"))
	for x in [-.2, .2]:
		LowPoly.box(luggage, Vector3(x, 1.26, .55), Vector3(.035, .012, .53), black)
		for z in [.29, .81]:
			LowPoly.box(luggage, Vector3(x, 1.04, z), Vector3(.035, .42, .012), black)
		LowPoly.box(luggage, Vector3(x, 1.08, .824), Vector3(.066, .05, .016), steel)
	luggage.visible = false

func _ring(parent: Node3D, inner: float, outer: float, color: Color) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var ring := TorusMesh.new()
	ring.inner_radius = inner
	ring.outer_radius = outer
	ring.rings = 32
	ring.ring_segments = 8
	mesh.mesh = ring
	mesh.material_override = LowPoly.material(color)
	parent.add_child(mesh)
	return mesh

func _fender(z: float, color: Color) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(10):
		var a := -.85 + i * .17
		var b := a + .17
		var left_a := Vector3(-.10, .34 + .37 * cos(a), z + .37 * sin(a))
		var left_b := Vector3(-.10, .34 + .37 * cos(b), z + .37 * sin(b))
		for point in [left_a, left_b, left_a + Vector3(.2, 0, 0), left_a + Vector3(.2, 0, 0), left_b, left_b + Vector3(.2, 0, 0)]: surface.add_vertex(point)
	surface.generate_normals()
	var fender := MeshInstance3D.new()
	fender.mesh = surface.commit()
	fender.material_override = LowPoly.material(color)
	add_child(fender)

func roll_wheels(distance: float) -> void:
	for wheel in wheels: wheel.rotation.x = fposmod(wheel.rotation.x - distance / .34, TAU)

func update_instruments(speed: float, steer: float, rpm: float = 0, powered: bool = false, night: float = 0) -> void:
	instruments.update_readings(speed, rpm, powered, night)
	bars.rotation.y = -steer * 0.07
