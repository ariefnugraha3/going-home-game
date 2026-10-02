class_name CozyDressing
extends RefCounted

static func interior(parent: Node3D, office: bool) -> void:
	var root := Node3D.new()
	parent.add_child(root)
	# Plank joints, skirting and framed window reveal establish a human scale.
	for x in range(-7,8): LowPoly.box(root,Vector3(x*.55,.007,0),Vector3(.018,.012,6),Color("88765d"))
	for z in [-2.0,0,2.0]: LowPoly.box(root,Vector3(0,.008,z),Vector3(8,.012,.012),Color("8c795e"))
	LowPoly.box(root,Vector3(0,.12,-2.86),Vector3(8,.23,.08),Color("cdbb99"))
	for x in [-3.85,3.85]: LowPoly.box(root,Vector3(x,.12,0),Vector3(.08,.23,6),Color("cdbb99"))
	LowPoly.box(root,Vector3(-1.9,1.18,-2.72),Vector3(2.7,.12,.33),Color("c5ad86"))
	LowPoly.beam(root,Vector3(-3.3,3.2,-2.65),Vector3(-.5,3.2,-2.65),.035,Color("705d47"))
	for x in [-3.15,-2.98,-.82,-.65]:
		LowPoly.box(root,Vector3(x,2.16,-2.65),Vector3(.20,1.97,.1),Color("c9b791") if int(x*100)%2 else Color("b3ac87"))
	LowPoly.planter(root,Vector3(-3.35,0,-1.8),1.5)
	LowPoly.box(root,Vector3(2.0,2.4,-2.85),Vector3(1.3,.97,.12),Color("8f7154"))
	LowPoly.box(root,Vector3(2.0,2.4,-2.775),Vector3(1.14,.81,.02),Color("e6d5ae"))
	LowPoly.sphere(root,Vector3(2.25,2.6,-2.751),Vector3(.23,.23,.009),Color("d6ac70"))
	for i in range(3):
		var hill := LowPoly.sphere(root,Vector3(1.7+i*.28,2.24,-2.735-i*.005),Vector3(.61,.45,.008),Color("8e9a7c") if i%2 else Color("6e8980"))
		hill.rotation.z = i*.13
	if not office:
		LowPoly.box(root,Vector3(.6,.014,1.65),Vector3(2.7,.025,1.7),Color("b48564"))
		for z in [.92,1.02,2.28,2.38]: LowPoly.box(root,Vector3(.6,.03,z),Vector3(2.6,.01,.045),Color("d6ba8d"))
		LowPoly.box(root,Vector3(2.5,.14,-1),Vector3(1.45,.24,2.65),Color("997451"))
		LowPoly.box(root,Vector3(2.5,.73,-.32),Vector3(1.42,.06,.55),Color("c4b490"))
		for x in [2.05,2.18,2.81,2.94]: LowPoly.box(root,Vector3(x,.77,-.32),Vector3(.045,.012,.52),Color("dfcda7"))
		LowPoly.box(root,Vector3(2.5,.8,-2.30),Vector3(1.48,.65,.14),Color("8c7052"))
	var shelf := Vector3(-3.2,0,1.2)
	for y in [.25,.9,1.55]:
		LowPoly.box(root,shelf+Vector3(0,y,0),Vector3(1.0,.09,.5),Color("a2835c"))
	for x in [-.47,.47]: LowPoly.box(root,shelf+Vector3(x,.85,0),Vector3(.08,1.7,.5),Color("8f7351"))
	for i in range(6):
		var book := LowPoly.box(root,shelf+Vector3(-.35+i*.13,1.15,.03),Vector3(.10,.41+(i%3)*.035,.34),Color("718b80") if i%2 else Color("bd8c68"))
		book.rotation.z = -.06 if i == 0 else 0
	LowPoly.planter(root,shelf+Vector3(0,1.6,0),.55)
	LowPoly.bake(root,100)

static func shelter(parent: Node3D, id: String) -> void:
	var root := Node3D.new()
	parent.add_child(root)
	LowPoly.box(root,Vector3(0,1.45,-3.6),Vector3(8,2.9,.15),Color("c6b795"))
	for x in [-3.7,-1.85,0,1.85,3.7]:
		LowPoly.box(root,Vector3(x,1.45,-3.48),Vector3(.09,2.85,.11),Color("a38d69"))
	for x in [-3.9,3.9]: LowPoly.planter(root,Vector3(x,0,1.9),1.15)
	LowPoly.box(root,Vector3(2.6,.84,-2.4),Vector3(2,.14,.7),Color("a27b53"))
	for x in [1.8,3.4]: LowPoly.box(root,Vector3(x,.4,-2.4),Vector3(.12,.8,.6),Color("8a6b4e"))
	for x in [2,2.5,3]:
		LowPoly.cylinder(root,Vector3(x,1.1,-2.4),.17,.38,Color("c4ad79"))
		LowPoly.cylinder(root,Vector3(x,1.31,-2.4),.19,.06,Color("927559"))
	LowPoly.box(root,Vector3(-2.4,1.8,-3.45),Vector3(1.8,1.25,.1),Color("937452"))
	LowPoly.box(root,Vector3(-2.4,1.8,-3.38),Vector3(1.63,1.08,.025),Color("506e60"))
	for y in [1.6,1.8,2.0]: LowPoly.box(root,Vector3(-2.4,y,-3.35),Vector3(.95,.025,.01),Color("c5c4a2"))
	# Visible pendant shades read as warm lighting even in the daytime.
	for x in [-2.2,2.2]:
		LowPoly.beam(root,Vector3(x,3.2,-1.6),Vector3(x,2.64,-1.6),.018,Color("71624c"))
		LowPoly.cylinder(root,Vector3(x,2.59,-1.6),.30,.18,Color("bc9870"),.12)
		var bulb := LowPoly.sphere(root,Vector3(x,2.49,-1.6),Vector3(.18,.14,.18),Color("f5d6a0"))
		bulb.material_override = LowPoly.material(Color("f5d6a0"),true)
	if id == "pekalongan":
		for i in range(4):
			LowPoly.box(root,Vector3(-3.3+i*.38,1.6,-2.7),Vector3(.32,1.4,.04),Color("a96e58") if i%2 else Color("788e96"))
	LowPoly.bake(root,160)

static func vehicle(parent: Node3D, variant: int) -> Node3D:
	var root := Node3D.new()
	parent.add_child(root)
	var paint := Color("82a99b") if variant%2 else Color("cab17c")
	LowPoly.box(root,Vector3(0,.69,0),Vector3(1.65,.60,3.5),paint)
	LowPoly.box(root,Vector3(0,1.08,.13),Vector3(1.48,.40,1.95),paint)
	LowPoly.mesh(root,CozyForms.loft([Vector4(.74,1.12,1.01,.12),Vector4(.63,1.69,.70,.21)],8),Vector3.ZERO,Color("567a7b"))
	LowPoly.box(root,Vector3(0,1.70,.21),Vector3(1.34,.10,1.50),paint)
	for side in [-1,1]:
		LowPoly.box(root,Vector3(side*.72,1.4,.14),Vector3(.10,.52,.12),paint)
		LowPoly.box(root,Vector3(side*.83,1.1,-.70),Vector3(.19,.12,.23),paint)
		LowPoly.box(root,Vector3(side*.827,.92,.1),Vector3(.025,.035,.25),Color("d5cfb7"))
		for z in [-1.1,1.1]:
			var tire := LowPoly.cylinder(root,Vector3(side*.8,.37,z),.34,.19,Color("3b4039"),-1,12)
			tire.rotation.z = PI/2
			var hub := LowPoly.cylinder(root,Vector3(side*.91,.37,z),.19,.02,Color("acae9b"),-1,10)
			hub.rotation.z = PI/2
		LowPoly.box(root,Vector3(side*.55,.78,-1.76),Vector3(.35,.16,.025),Color("f5ddaa"))
		LowPoly.box(root,Vector3(side*.56,.8,1.76),Vector3(.3,.14,.025),Color("b66d50"))
	for z in [-1.77,1.77]: LowPoly.box(root,Vector3(0,.48,z),Vector3(1.6,.10,.10),Color("768278"))
	LowPoly.box(root,Vector3(0,.75,-1.77),Vector3(.48,.12,.035),Color("47594f"))
	LowPoly.bake(root,240)
	return root

static func town_building(parent: Node3D, pos: Vector3, height: float, side: int) -> Node3D:
	var root := Node3D.new()
	parent.add_child(root)
	root.position = pos
	root.rotation.y = -side * PI/2
	LowPoly.box(root,Vector3(0,height*.5,0),Vector3(12,height,12),Color("a5b4a5") if side > 0 else Color("c2b89c"))
	LowPoly.box(root,Vector3(0,height+.09,0),Vector3(12.5,.22,12.5),Color("d2c4a4"))
	LowPoly.box(root,Vector3(0,.16,6.7),Vector3(12.7,.32,1.8),Color("b6ad94"))
	LowPoly.box(root,Vector3(0,2.85,6.65),Vector3(12.5,.18,1.75),Color("7d9589"))
	for x in [-4.3,0,4.3]:
		LowPoly.box(root,Vector3(x,1.4,6.06),Vector3(2.2,2.6,.10),Color("668b88"))
		LowPoly.box(root,Vector3(x,1.4,6.13),Vector3(.09,2.6,.08),Color("c4bba1"))
	for y in range(4,int(height)-1,3):
		LowPoly.box(root,Vector3(0,y-1.1,6.08),Vector3(12.2,.13,.22),Color("c9c0a5"))
		for x in [-4.3,0,4.3]:
			LowPoly._window(root,Vector3(x,y,6.02))
	for x in [-5.8,5.8]: LowPoly.box(root,Vector3(x,height*.5,6.12),Vector3(.19,height,.19),Color("d0c4a6"))
	LowPoly.bake(root,300)
	return root
