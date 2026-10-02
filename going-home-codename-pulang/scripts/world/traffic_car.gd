class_name TrafficCar
extends Node3D

# Original compact hatchback / family wagon, in metres; front faces local -Z.
const TIRE_RADIUS := .32
var variant: int = 0
var wheels: Array[Node3D] = []
var axle_z: Array[float] = []
var body: Node3D
var wagon: bool
var paint: Color
var rear: float
var front := -1.83

static func create(parent: Node3D, index: int) -> TrafficCar:
	var car := TrafficCar.new()
	car.variant = posmod(index,4)
	parent.add_child(car)
	return car

func _ready() -> void:
	wagon = variant % 2 == 1
	paint = [Color("cfb27e"),Color("7da79c"),Color("a3b5c0"),Color("b98873")][variant]
	rear = 2.04 if wagon else 1.80
	axle_z = [-1.10,1.24 if wagon else 1.08]
	name = "FamilyWagon" if wagon else "CompactHatchback"
	body = Node3D.new()
	body.name = "Bodywork"
	add_child(body)
	_shell()
	_cabin()
	_details()
	# Preserve wheel pivots when batching the stationary body by material.
	LowPoly.bake(body,260)
	for side in [-1,1]:
		for axle in axle_z: _wheel(side,axle)

func _width(z: float) -> float:
	return .815 - .13 * pow(clampf((absf(z-(rear+front)*.5)/(rear-front))*2,0,1),8)

func _belt(z: float) -> float:
	return .91 - .16*smoothstep(.70,1.83,-z) - .07*smoothstep(rear-.4,rear,z)

func _arch(z: float) -> float:
	var height := .31
	for axle in axle_z:
		var offset := absf(z-axle)
		if offset < .39: height = maxf(height,.32+sqrt(.39*.39-offset*offset))
	return height

func _shell() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Sample actual semicircular wheel openings; no solid slab through the tires.
	var samples: Array[float] = [front,front+.06,-.62,-.35,0,.35,.62,rear-.06,rear]
	for axle in axle_z:
		for i in range(19): samples.append(axle+.39*cos(PI*i/18))
	samples.sort()
	for i in range(samples.size()-1):
		var a := samples[i]
		var b := samples[i+1]
		if b-a < .0001: continue
		for side in [-1,1]:
			# Rolled sill, broad door skin and rounded shoulder into hood/deck.
			var ra := [Vector3(side*(_width(a)-.024),_arch(a),a),Vector3(side*_width(a),_arch(a)+.035,a),Vector3(side*_width(a),_belt(a)-.085,a),Vector3(side*(_width(a)-.07),_belt(a),a)]
			var rb := [Vector3(side*(_width(b)-.024),_arch(b),b),Vector3(side*_width(b),_arch(b)+.035,b),Vector3(side*_width(b),_belt(b)-.085,b),Vector3(side*(_width(b)-.07),_belt(b),b)]
			for band in range(3):
				var normal: Vector3 = (rb[band]-ra[band]).cross(ra[band+1]-ra[band]).normalized()
				if normal.x*side < 0: normal = -normal
				CozyForms.polygon(st,[ra[band],rb[band],rb[band+1],ra[band+1]],normal)
		# Curved hood/deck crown instead of a flat rectangular roof on a block.
		for strip in range(8):
			var xa := -1.0+strip*.25
			var xb := xa+.25
			var normal := (_deck(b,xa)-_deck(a,xa)).cross(_deck(a,xb)-_deck(a,xa)).normalized()
			CozyForms.polygon(st,[_deck(a,xa),_deck(b,xa),_deck(b,xb),_deck(a,xb)],normal)
	for z in [front,rear]:
		var edge := [Vector3(-_width(z)+.024,.31,z),Vector3(_width(z)-.024,.31,z),Vector3(_width(z),.345,z),Vector3(_width(z),_belt(z)-.085,z)]
		# Match every crown vertex: a coarse end cap leaves gaps under the hood.
		for strip in range(9): edge.append(_deck(z,1-strip*.25))
		edge.append(Vector3(-_width(z),_belt(z)-.085,z))
		edge.append(Vector3(-_width(z),.345,z))
		CozyForms.polygon(st,edge,Vector3.FORWARD if z < 0 else Vector3.BACK)
	LowPoly.mesh(body,st.commit(),Vector3.ZERO,paint)
	# The underfloor fits between the inner tire faces.
	LowPoly.box(body,Vector3(0,.285,.10),Vector3(1.22,.08,2.55),Color("343e39"))
	for side in [-1,1]:
		for axle in axle_z:
			var points: Array = []
			var inner: Array = []
			for i in range(19):
				var a := PI*i/18
				var z := axle+.394*cos(a)
				points.append(Vector3(side*(_width(z)+.002),.32+.394*sin(a),z))
				inner.append(Vector3(side*.635,.32+.394*sin(a),z))
			LowPoly.mesh(body,BikeForms.tube(points,.012),Vector3.ZERO,paint.darkened(.17))
			# Recessed liner closes the view through the body, behind the tire.
			_panel(inner,Color("303b35"),Vector3(side,0,0))
			for i in range(18):
				_panel([inner[i],points[i],points[i+1],inner[i+1]],Color("39463d"),Vector3(0,-sin(PI*(i+.5)/18),-cos(PI*(i+.5)/18)))

func _deck(z: float, amount: float) -> Vector3:
	return Vector3(amount*(_width(z)-.07),_belt(z)+.035*(1-amount*amount),z)

func _cabin() -> void:
	var roof := 1.56 if wagon else 1.45
	var back_top := 1.38 if wagon else .88
	var back_base := 1.83 if wagon else 1.60
	var lower_front := Vector3(.735,.923,-.70)
	var upper_front := Vector3(.61,roof,-.29)
	var lower_rear := Vector3(.735,.923,back_base)
	var upper_rear := Vector3(.61,roof,back_top)
	for side in [-1,1]:
		var mirror := Vector3(side,1,1)
		var lf := lower_front*mirror
		var uf := upper_front*mirror
		var lr := lower_rear*mirror
		var ur := upper_rear*mirror
		_panel([lf,lr,ur,uf],paint,Vector3(side,0,0))
		_panel([lf,_deck(-.70,side),_deck(back_base,side),lr],paint,Vector3(side,0,0))
		# Window glass is inset into the painted A/B/C pillars, with opaque tint.
		var low_x: float = side*.729
		var high_x: float = side*.626
		var mid_z := .28
		_panel([Vector3(low_x,.975,-.596),Vector3(low_x,.975,mid_z-.035),Vector3(high_x,roof-.063,mid_z-.035),Vector3(high_x,roof-.063,-.266)],Color("4e7274"),Vector3(side,.22,0).normalized())
		_panel([Vector3(low_x,.975,mid_z+.035),Vector3(low_x,.975,back_base-.115),Vector3(high_x,roof-.063,back_top-.048),Vector3(high_x,roof-.063,mid_z+.035)],Color("557b7c"),Vector3(side,.22,0).normalized())
		# Door seam and separate handles on the metal below the glass.
		var back_door := 1.30 if wagon else 1.17
		for z in [-.59,mid_z,back_door]:
			var bottom := maxf(_arch(z)+.025,.37)
			LowPoly.beam(body,Vector3(side*(_width(z)+.002),bottom,z),Vector3(side*(_width(z)+.002),.81,z),.0035,paint.darkened(.28))
		for z in [mid_z-.17,back_door-.18]:
			LowPoly.mesh(body,BikeForms.plate(Vector3(.13,.026,.020),.010),Vector3(side*.812,.828,z),Color("e0d1ad")).rotation.y = PI/2
		LowPoly.beam(body,Vector3(side*.745,1.02,-.56),Vector3(side*.873,1.015,-.60),.019,Color("354c46"))
		BikeForms.ellipsoid(body,Vector3(side*.893,1.042,-.60),Vector3(.16,.10,.21),paint)
		BikeForms.ellipsoid(body,Vector3(side*.893,1.042,-.488),Vector3(.123,.071,.014),Color("9bb4b0"))
	# Sloped front and rear screens follow their cabin planes.
	for end in [false,true]:
		var lower := lower_rear if end else lower_front
		var upper := upper_rear if end else upper_front
		var normal := Vector3(0,.65,1 if end else -1).normalized()
		var quad := [Vector3(-lower.x,lower.y,lower.z),lower,upper,Vector3(-upper.x,upper.y,upper.z)]
		_panel(quad,paint,normal)
		var inset_low := lower.lerp(upper,.095)
		var inset_high := lower.lerp(upper,.895)
		_panel([Vector3(-inset_low.x+.05,inset_low.y,inset_low.z)+normal*.006,Vector3(inset_low.x-.05,inset_low.y,inset_low.z)+normal*.006,Vector3(inset_high.x-.05,inset_high.y,inset_high.z)+normal*.006,Vector3(-inset_high.x+.05,inset_high.y,inset_high.z)+normal*.006],Color("597f80"),normal)
		if not end:
			for x in [-.31,.28]:
				var start := lower.lerp(upper,.13)+normal*.018
				var finish := lower.lerp(upper,.29)+normal*.018
				LowPoly.beam(body,Vector3(x,start.y,start.z),Vector3(x+.17,finish.y,finish.z),.008,Color("354c46"))
	for strip in range(8):
		var a := -1+strip*.25
		var b := a+.25
		_panel([_deck(back_base,a),_deck(back_base,b),Vector3(b*lower_rear.x,lower_rear.y,back_base),Vector3(a*lower_rear.x,lower_rear.y,back_base)],paint,Vector3.BACK)
	# Soft roof crown with narrow rolled edges.
	for strip in range(12):
		var a := -1.0+strip/6.0
		var b := a+1.0/6
		_panel([Vector3(a*.61,roof+.045*(1-a*a),-.29),Vector3(b*.61,roof+.045*(1-b*b),-.29),Vector3(b*.61,roof+.045*(1-b*b),back_top),Vector3(a*.61,roof+.045*(1-a*a),back_top)],paint,Vector3((a+b)*.045/.61,1,0).normalized())
	# Curved front/back roof edges close the crown above the straight screens.
	for z in [-.29,back_top]:
		var crown: Array = [Vector3(-.61,roof,z),Vector3(.61,roof,z)]
		for strip in range(13):
			var x := 1-strip/6.0
			crown.append(Vector3(x*.61,roof+.045*(1-x*x),z))
		_panel(crown,paint,Vector3.FORWARD if z < 0 else Vector3.BACK)

func _panel(points: Array, color: Color, normal: Vector3) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	CozyForms.polygon(st,points,normal)
	LowPoly.mesh(body,st.commit(),Vector3.ZERO,color)

func _details() -> void:
	var trim := Color("46574f")
	for z in [front-.015,rear+.015]:
		LowPoly.mesh(body,BikeForms.plate(Vector3(1.43,.145,.105),.062),Vector3(0,.405,z),paint.darkened(.20))
		LowPoly.mesh(body,BikeForms.plate(Vector3(.34,.108,.016),.012),Vector3(0,.489,z+(-.058 if z < 0 else .058)),Color("38423c"))
		LowPoly.box(body,Vector3(0,.49,z+(-.068 if z < 0 else .068)),Vector3(.24,.013,.003),Color("c4c1a5"))
	LowPoly.mesh(body,BikeForms.plate(Vector3(.64,.155,.030),.043),Vector3(0,.636,front-.018),trim)
	for y in [.588,.625,.662]: LowPoly.box(body,Vector3(0,y,front-.036),Vector3(.52,.009,.010),Color("9aab9c"))
	for side in [-1,1]:
		LowPoly.mesh(body,BikeForms.plate(Vector3(.40,.158,.049),.058),Vector3(side*.51,.670,front-.020),Color("d9ceae"))
		LowPoly.mesh(body,BikeForms.plate(Vector3(.33,.115,.010),.039),Vector3(side*.51,.670,front-.050),Color("fff0c5"))
		LowPoly.mesh(body,BikeForms.plate(Vector3(.073,.091,.013),.022),Vector3(side*.669,.670,front-.055),Color("d7a363"))
		LowPoly.mesh(body,BikeForms.plate(Vector3(.275,.175,.046),.045),Vector3(side*.565,.685,rear+.026),Color("a85848"))
		LowPoly.mesh(body,BikeForms.plate(Vector3(.22,.037,.006),.012),Vector3(side*.565,.662,rear+.052),Color("e1c9a1"))
	LowPoly.box(body,Vector3(0,.775,rear+.016),Vector3(.22,.025,.028),trim)

func _wheel(side: int, z: float) -> void:
	var wheel := Node3D.new()
	wheel.name = ("Left" if side < 0 else "Right")+("FrontWheel" if z < 0 else "RearWheel")
	add_child(wheel)
	wheel.position = Vector3(side*.775,TIRE_RADIUS,z)
	wheels.append(wheel)
	var tire := LowPoly.mesh(wheel,BikeForms.lathe([Vector2(.24,-.10),Vector2(.297,-.091),Vector2(.32,-.064),Vector2(.32,.064),Vector2(.297,.091),Vector2(.24,.10)],28),Vector3.ZERO,Color("353d37"))
	tire.rotation.y = PI/2
	var rim := LowPoly.cylinder(wheel,Vector3(side*.102,0,0),.218,.012,Color("aab4a7"),-1,24)
	rim.rotation.z = PI/2
	var dish := LowPoly.cylinder(wheel,Vector3(side*.11,0,0),.166,.013,Color("65766d"),-1,24)
	dish.rotation.z = PI/2
	for i in range(6):
		var a := TAU*i/6
		LowPoly.beam(wheel,Vector3(side*.12,.043*cos(a),.043*sin(a)),Vector3(side*.12,.186*cos(a+.09),.186*sin(a+.09)),.022,Color("aab4a7"))
	var cap := LowPoly.cylinder(wheel,Vector3(side*.126,0,0),.048,.016,Color("aab4a7"),-1,16)
	cap.rotation.z = PI/2
	LowPoly.bake(wheel,260)

func roll(distance: float) -> void:
	for wheel in wheels: wheel.rotation.x = fposmod(wheel.rotation.x-distance/TIRE_RADIUS,TAU)
