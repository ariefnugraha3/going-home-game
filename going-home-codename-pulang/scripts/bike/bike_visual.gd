class_name BikeVisual
extends Node3D

# Shared model-space anchors keep the parked bike, cockpit and actor contacts aligned.
const WHEEL_RADIUS := .315
const FRONT_AXLE := Vector3(0, WHEEL_RADIUS, -.72)
const REAR_AXLE := Vector3(0, WHEEL_RADIUS, .70)
const IGNITION := Vector3(.08, 1.10, -.32)
const HEADLIGHT := Vector3(0, .99, -.735)

var show_rider_arms: bool = true
var instruments: BikeInstruments
var bars: Node3D
var tank: MeshInstance3D
var seat: MeshInstance3D
var luggage: Node3D
var wheels: Array[Node3D] = []
var footrests: Array[MeshInstance3D] = []
var brake_pedal: MeshInstance3D
var shift_toe_peg: MeshInstance3D

static func foot_anchor(side: int) -> Vector3:
	return Vector3(side*.285,.395,.14)

static func hand_grip(side: int) -> Vector3:
	return Vector3(side * .38, 1.115, -.285)

func _ready() -> void:
	var steel := Color("b7bdb2")
	var black := Color("363a35")
	var paint := Color("467c72")
	var metal := LowPoly.material(steel)
	metal.metallic = .58
	metal.roughness = .34
	# Broad curved shoulders taper into a narrow knee/seat junction.
	tank = LowPoly.mesh(self,BikeForms.tank(),Vector3.ZERO,paint)
	LowPoly.cylinder(self, Vector3(0, 1.025, -.24), .047, .013, steel)
	LowPoly.box(self, Vector3(0, 1.034, -.24), Vector3(.028, .004, .007), black)
	seat = LowPoly.mesh(self, _seat_mesh(), Vector3.ZERO, black)
	# Subtle curved upholstery seams follow the crown rather than floating above it.
	for z in [.46, .56, .66, .76]:
		var y: float = .857 + smoothstep(.4,.78,z)*.008
		_tube([Vector3(-.145,y-.010,z),Vector3(-.08,y,z),Vector3(0,y+.003,z),Vector3(.08,y,z),Vector3(.145,y-.010,z)],.002,Color("6b6959"))
	for side in [-1, 1]:
		var panel := LowPoly.mesh(self,BikeForms.body([Vector4(.002,.67,.66,.09),Vector4(.024,.719,.57,.19),Vector4(.027,.727,.53,.32),Vector4(.02,.704,.58,.49),Vector4(.002,.665,.66,.56)],16),Vector3(side*.165,0,0),paint)
		panel.name = "SideCoverLeft" if side < 0 else "SideCoverRight"
		var stripe := BikeForms.ellipsoid(self,Vector3(side*.226,.867,-.24),Vector3(.012,.016,.12),Color("d8cba0"))
		stripe.rotation.y = side*.02
		LowPoly.beam(self,Vector3(side*.10,.86,-.55),Vector3(side*.23,.86,-.65),.009,black)
		BikeForms.ellipsoid(self,Vector3(side*.24,.86,-.66),Vector3(.075,.049,.055),Color("dca258"))
		LowPoly.beam(self,Vector3(side*.12,.78,.89),Vector3(side*.21,.78,.89),.009,black)
		BikeForms.ellipsoid(self,Vector3(side*.23,.78,.89),Vector3(.075,.049,.055),Color("dca258"))
	LowPoly.box(self,Vector3(0,.62,.28),Vector3(.27,.21,.32),black)
	LowPoly.mesh(self,BikeForms.body([Vector4(.10,.78,.73,.52),Vector4(.16,.80,.725,.66),Vector4(.164,.82,.74,.80),Vector4(.12,.81,.755,.92),Vector4(.04,.79,.765,.96)],20),Vector3.ZERO,paint)
	# Compact crankcase and upright finned cylinder; leave air around the engine.
	BikeForms.ellipsoid(self, Vector3(0,.36,.015), Vector3(.29,.27,.35), Color("929c95"))
	LowPoly.cylinder(self, Vector3(0,.54,-.14), .106,.25, Color("778780"), -1, 12)
	for i in range(8):
		var fin := LowPoly.mesh(self,BikeForms.plate(Vector3(.25,.255,.010),.055),Vector3(0,.43+i*.028,-.14),Color("a9b3aa"))
		fin.rotation.x = PI/2
	var rocker := LowPoly.mesh(self,BikeForms.plate(Vector3(.24,.24,.065),.065),Vector3(0,.675,-.14),steel)
	rocker.rotation.x = PI/2
	for side in [-1,1]:
		var cover := LowPoly.mesh(self,BikeForms.lathe([Vector2(.085,-.018),Vector2(.103,-.008),Vector2(.105,0),Vector2(.095,.015),Vector2(.072,.022),Vector2(.012,.026)]),Vector3(side*.148,.35,.02),steel)
		cover.rotation.y = side*PI/2
		for i in range(6):
			var a := i*TAU/6
			LowPoly.sphere(self, Vector3(side*.164,.35+cos(a)*.085,.02+sin(a)*.085), Vector3(.009,.012,.012), Color("59675f"))
	LowPoly.cylinder(self,Vector3(0,.58,.105),.045,.10,Color("56685e"),-1,12)
	LowPoly.beam(self,Vector3(.06,.71,-.12),Vector3(.09,.77,.04),.006,black)
	for axle in [FRONT_AXLE, REAR_AXLE]:
		var wheel := Node3D.new()
		add_child(wheel)
		wheel.position = axle
		wheels.append(wheel)
		var tire := _ring(wheel, .224, WHEEL_RADIUS, black)
		tire.rotation.z = PI/2
		tire.scale.y = 1.10 if axle.z > 0 else .94
		_ring(wheel, .207, .235, steel).rotation.z = PI/2
		var hub := LowPoly.cylinder(wheel, Vector3.ZERO, .062,.13,steel,-1,12)
		hub.rotation.z = PI/2
		for spoke in range(36):
			var angle := spoke*TAU/36
			var offset := .19 if spoke%2 else -.19
			LowPoly.beam(wheel,Vector3(-.033 if spoke%2 else .033,.052*cos(angle),.052*sin(angle)),Vector3(0,.218*cos(angle+offset),.218*sin(angle+offset)),.0025,steel)
		if axle.z < 0:
			var disc := LowPoly.cylinder(wheel,Vector3(-.060,0,0),.132,.009,Color("a3aca4"),-1,28)
			disc.rotation.z = PI/2
			for i in range(14):
				var a := i*TAU/14
				var hole := LowPoly.cylinder(wheel,Vector3(-.066,.112*cos(a),.112*sin(a)),.006,.002,black,-1,8)
				hole.rotation.z = PI/2
			LowPoly.box(self,Vector3(-.083,.40,axle.z+.10),Vector3(.040,.080,.050),Color("58665d"))
		LowPoly.bake(wheel,240)
		_fender(axle.z,paint if axle.z < 0 else black)
	for side in [-1,1]:
		# Telescopic forks: the polished stanchion enters a thicker lower slider.
		LowPoly.beam(self,Vector3(side*.10,.33,-.72),Vector3(side*.10,1.065,-.49),.018,steel)
		LowPoly.beam(self,Vector3(side*.10,.315,-.72),Vector3(side*.10,.66,-.612),.030,Color("a7b1a8"))
		LowPoly.beam(self,Vector3(side*.16,.34,.70),Vector3(side*.17,.74,.47),.023,steel)
		LowPoly.beam(self,Vector3(side*.155,.71,.49),Vector3(side*.115,.29,-.26),.019,black)
		LowPoly.beam(self,Vector3(side*.115,.29,-.26),Vector3(side*.17,.315,.70),.022,black)
		LowPoly.beam(self,Vector3(side*.10,.91,-.49),Vector3(side*.115,.29,-.26),.020,steel)
		LowPoly.beam(self,Vector3(side*.10,.91,-.49),Vector3(side*.16,.73,.65),.020,black)
		LowPoly.beam(self,Vector3(side*.16,.73,.65),Vector3(side*.14,.81,.91),.017,black)
		for turn in range(9):
			var coil := _ring(self,.030,.041,black)
			coil.position = Vector3(side*.161,.40,.665).lerp(Vector3(side*.169,.70,.493),turn/8.0)
			coil.rotation.x = -.52
			coil.scale.y = .65
	_build_foot_controls(steel,black)
	# One bent grab rail wraps around the raised pillion.
	_tube([Vector3(-.18,.80,.62),Vector3(-.195,.88,.80),Vector3(-.16,.91,.90),Vector3(.16,.91,.90),Vector3(.195,.88,.80),Vector3(.18,.80,.62)],.013,steel)
	LowPoly.mesh(self,BikeForms.plate(Vector3(.18,.075,.045),.026),Vector3(0,.785,.98),Color("a95042"))
	var mudguard := LowPoly.mesh(self,BikeForms.plate(Vector3(.13,.20,.025),.033),Vector3(0,.64,.958),black)
	mudguard.rotation.x = -.18
	LowPoly.box(self,Vector3(0,.60,.985),Vector3(.21,.105,.012),Color("d6cbb0"))
	# Two thin headers curve down from the single-cylinder head into one silencer.
	for x in [.055,.11]:
		_tube([Vector3(x,.60,-.27),Vector3(x,.56,-.34),Vector3(.16,.29,-.38),Vector3(.205,.225,-.24),Vector3(.235,.225,.28)],.018,steel)
	var exhaust_from := Vector3(.235,.225,.25)
	var exhaust_to := Vector3(.24,.31,.932)
	var length := exhaust_from.distance_to(exhaust_to)
	var silencer := LowPoly.mesh(self,BikeForms.lathe([Vector2(.027,0),Vector2(.034,.035),Vector2(.045,.085),Vector2(.046,length-.05),Vector2(.043,length-.018),Vector2(.033,length)]),exhaust_from,steel)
	silencer.quaternion = Quaternion(Vector3.BACK,(exhaust_to-exhaust_from).normalized())
	var outlet := LowPoly.cylinder(self,exhaust_to,.029,.003,black,-1,24)
	outlet.quaternion = Quaternion(Vector3.UP,(exhaust_to-exhaust_from).normalized())
	LowPoly.beam(self,Vector3(.235,.29,.51),Vector3(.17,.48,.43),.014,black)
	LowPoly.beam(self,Vector3(-.13,.29,.09),Vector3(-.13,.34,.70),.007,Color("5a655c"))
	LowPoly.beam(self,Vector3(-.13,.24,.09),Vector3(-.13,.28,.70),.007,Color("5a655c"))
	LowPoly.box(self,Vector3(-.14,.40,.43),Vector3(.040,.022,.57),black)
	# Triple clamps and brackets connect the lamp and instruments to the fork.
	for y in [.84,1.035]:
		LowPoly.beam(self,Vector3(-.12,y,-.49-(1.035-y)*.31),Vector3(.12,y,-.49-(1.035-y)*.31),.021,black)
	for side in [-1,1]:
		LowPoly.beam(self,Vector3(side*.10,.985,-.52),Vector3(side*.105,.99,-.705),.012,steel)
	LowPoly.mesh(self,BikeForms.lathe([Vector2(.106,-.068),Vector2(.109,-.058),Vector2(.106,-.038),Vector2(.096,-.005),Vector2(.073,.037),Vector2(.04,.06),Vector2(.009,.067)]),HEADLIGHT,steel)
	var glass := LowPoly.cylinder(self,HEADLIGHT+Vector3(0,0,-.075),.096,.014,Color("f5eac6"),-1,24)
	glass.rotation.x = PI/2
	for i in range(-3,4):
		var x := i*.022
		var h := sqrt(.088*.088-x*x)
		LowPoly.beam(self,HEADLIGHT+Vector3(x,-h,-.084),HEADLIGHT+Vector3(x,h,-.084),.0015,Color("d4d9bf"))
	bars = Node3D.new()
	add_child(bars)
	LowPoly.beam(bars,Vector3(-.13,1.055,-.43),Vector3(.13,1.055,-.43),.011,steel)
	for side in [-1,1]:
		_tube([Vector3(side*.13,1.055,-.43),Vector3(side*.25,1.10,-.36),Vector3(side*.44,1.105,-.27)],.011,steel,bars)
		LowPoly.beam(bars,Vector3(side*.32,1.105,-.326),Vector3(side*.44,1.105,-.27),.019,black)
		LowPoly.mesh(bars,BikeForms.plate(Vector3(.047,.046,.05),.016),Vector3(side*.305,1.108,-.333),Color("404b46"))
		LowPoly.beam(bars,Vector3(side*.29,1.11,-.365),Vector3(side*.43,1.103,-.345),.006,steel)
		LowPoly.beam(bars,Vector3(side*.295,1.13,-.345),Vector3(side*.37,1.33,-.44),.007,steel)
		BikeForms.ellipsoid(bars,Vector3(side*.39,1.355,-.44),Vector3(.175,.098,.025),black)
		var mirror := BikeForms.ellipsoid(bars,Vector3(side*.39,1.355,-.425),Vector3(.15,.076,.006),Color("a9c2ba"))
		mirror.material_override = LowPoly.material(Color("a9c2ba"),true)
		LowPoly.box(bars,Vector3(side*.39,1.332,-.421),Vector3(.113,.018,.003),Color("758b7b"))
		if show_rider_arms:
			LowPoly.sphere(bars,hand_grip(side),Vector3(.10,.06,.14),Color("6d5d47"))
			LowPoly.beam(bars,hand_grip(side)+Vector3(0,-.025,.04),Vector3(side*.34,.98,.20),.052,Color("65715d"))
	LowPoly.beam(bars,Vector3(.08,1.055,-.43),IGNITION-Vector3(0,.022,0),.011,steel)
	LowPoly.cylinder(bars,IGNITION-Vector3(0,.018,0),.024,.034,black,-1,12)
	LowPoly.cylinder(bars,IGNITION,.013,.008,Color("bdb293"))
	instruments = BikeInstruments.new()
	instruments.position = Vector3(0,1.08,-.59)
	instruments.scale = Vector3.ONE*.53
	instruments.rotation_degrees.x = 22
	bars.add_child(instruments)
	for side in [-1,1]:
		var badge := LowPoly.label(self,"250",Vector3(side*.191,.68,.35),18)
		badge.pixel_size = .0018
		badge.rotation.y = side*PI/2
	luggage = Node3D.new()
	add_child(luggage)
	LowPoly.box(luggage,Vector3(0,1.04,.55),Vector3(.63,.38,.50),Color("8d7755"))
	LowPoly.box(luggage,Vector3(0,1.24,.55),Vector3(.65,.025,.52),Color("756646"))
	for x in [-.2,.2]:
		LowPoly.box(luggage,Vector3(x,1.26,.55),Vector3(.035,.012,.53),black)
		for z in [.29,.81]:
			LowPoly.box(luggage,Vector3(x,1.04,z),Vector3(.035,.42,.012),black)
		LowPoly.box(luggage,Vector3(x,1.08,.824),Vector3(.066,.05,.016),steel)
	luggage.visible = false

func _build_foot_controls(steel: Color, rubber: Color) -> void:
	# Model forward is -Z: the rider's right is +X, left is -X.
	# Short frame-mounted folding pegs replace the low, dangling diagonal stalks.
	var controls := Node3D.new()
	controls.name = "FootControls"
	add_child(controls)
	for side in [-1,1]:
		var mount := LowPoly.mesh(controls,BikeForms.plate(Vector3(.10,.075,.028),.024),Vector3(side*.165,.30,.17),steel)
		mount.rotation.y = PI/2
		LowPoly.beam(controls,Vector3(side*.14,.30,.17),Vector3(side*.222,.285,.14),.014,steel)
		var hinge := LowPoly.cylinder(controls,Vector3(side*.213,.285,.14),.017,.063,steel,-1,16)
		hinge.rotation.x = PI/2
		var peg := LowPoly.mesh(self,BikeForms.plate(Vector3(.12,.061,.040),.017),Vector3(side*.28,.285,.14),rubber)
		peg.name = "LeftFootrest" if side < 0 else "RightFootrest"
		peg.rotation.x = -PI/2
		footrests.append(peg)
		for i in range(7):
			LowPoly.box(controls,Vector3(side*(.238+i*.014),.305,.14),Vector3(.005,.001,.045),Color("60645b"))
		LowPoly.beam(controls,Vector3(side*.331,.285,.14),Vector3(side*.343,.285,.14),.014,steel)
		var bolt := LowPoly.cylinder(controls,Vector3(side*.184,.308,.182),.010,.007,Color("657369"),-1,6)
		bolt.rotation.z = PI/2
	# Right rear-brake lever: frame pivot, low curved arm, broad serrated toe pad.
	var brake_pivot := LowPoly.cylinder(controls,Vector3(.196,.263,.18),.022,.039,steel,-1,16)
	brake_pivot.rotation.z = PI/2
	_tube([Vector3(.196,.263,.18),Vector3(.196,.248,.09),Vector3(.199,.252,-.025),Vector3(.235,.272,-.073),Vector3(.285,.282,-.073)],.008,steel,controls)
	brake_pedal = LowPoly.mesh(self,BikeForms.plate(Vector3(.079,.055,.018),.012),Vector3(.285,.283,-.073),steel)
	brake_pedal.name = "RightRearBrakePedal"
	brake_pedal.rotation.x = -PI/2
	for z in [-.091,-.073,-.055]:
		LowPoly.box(controls,Vector3(.285,.293,z),Vector3(.060,.002,.005),Color("67756c"))
	# Mechanical rod runs inside the exhaust to a stationary rear drum brake arm.
	LowPoly.beam(controls,Vector3(.192,.244,.193),Vector3(.090,.242,.636),.004,steel)
	LowPoly.beam(controls,Vector3(.087,.315,.70),Vector3(.090,.242,.636),.009,Color("68786e"))
	var drum_plate := LowPoly.cylinder(controls,Vector3(.077,.315,.70),.059,.012,steel,-1,20)
	drum_plate.rotation.z = PI/2
	# Left gearbox selector: short shaft and forged arm, rubber transverse toe peg.
	var selector := LowPoly.cylinder(controls,Vector3(-.175,.352,.02),.016,.035,steel,-1,16)
	selector.rotation.z = PI/2
	_tube([Vector3(-.190,.352,.02),Vector3(-.191,.332,-.055),Vector3(-.211,.331,-.111),Vector3(-.244,.331,-.111)],.007,steel,controls)
	shift_toe_peg = LowPoly.mesh(self,BikeForms.lathe([Vector2(.010,0),Vector2(.014,.008),Vector2(.014,.070),Vector2(.010,.079)],16),Vector3(-.244,.331,-.111),rubber)
	shift_toe_peg.name = "LeftGearShiftToePeg"
	shift_toe_peg.rotation.y = -PI/2
	for i in range(5):
		var rib := _ring(controls,.013,.015,Color("60645b"))
		rib.position = Vector3(-.257-i*.012,.331,-.111)
		rib.rotation.z = PI/2
		rib.scale.y = .5

func _seat_mesh() -> ArrayMesh:
	return BikeForms.body([Vector4(.025,.828,.775,.075),Vector4(.11,.855,.744,.12),Vector4(.145,.855,.744,.20),Vector4(.155,.855,.748,.30),Vector4(.177,.858,.755,.49),Vector4(.18,.865,.77,.74),Vector4(.155,.86,.79,.86),Vector4(.09,.842,.805,.915),Vector4(.016,.826,.819,.935)],24,.45)

func _tube(points: Array, radius: float, color: Color, parent: Node3D = null) -> void:
	if parent == null: parent = self
	LowPoly.mesh(parent,BikeForms.tube(points,radius),Vector3.ZERO,color)

func _ring(parent: Node3D, inner: float, outer: float, color: Color) -> MeshInstance3D:
	var ring := TorusMesh.new()
	ring.inner_radius = inner
	ring.outer_radius = outer
	ring.rings = 32
	ring.ring_segments = 8
	return LowPoly.mesh(parent,ring,Vector3.ZERO,color)

func _fender(z: float, color: Color) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Crown across the tire, with a small rolled edge; no flat ribbon silhouette.
	for i in range(16):
		for j in range(6):
			var points: Array[Vector3] = []
			for corner in [Vector2(i,j),Vector2(i+1,j),Vector2(i,j+1),Vector2(i,j+1),Vector2(i+1,j),Vector2(i+1,j+1)]:
				var a: float = -.95+corner.x*1.9/16
				var across: float = -PI/2+corner.y*PI/6
				var radius := WHEEL_RADIUS+.021+.024*cos(across)
				points.append(Vector3(.066*sin(across),WHEEL_RADIUS+radius*cos(a),z+radius*sin(a)))
			for point in points: surface.add_vertex(point)
	surface.index()
	surface.generate_normals()
	var fender := LowPoly.mesh(self,surface.commit(),Vector3.ZERO,color)
	# Both faces are visible at the rolled rim.
	var material := LowPoly.material(color).duplicate() as StandardMaterial3D
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	fender.material_override = material

func roll_wheels(distance: float) -> void:
	for wheel in wheels: wheel.rotation.x = fposmod(wheel.rotation.x-distance/WHEEL_RADIUS,TAU)

func update_instruments(speed: float, steer: float, rpm: float = 0, powered: bool = false, night: float = 0) -> void:
	instruments.update_readings(speed,rpm,powered,night)
	bars.rotation.y = -steer*.07
