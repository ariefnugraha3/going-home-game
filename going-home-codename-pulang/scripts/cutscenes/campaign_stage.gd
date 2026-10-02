class_name CampaignStage
extends Node3D

# Reusable blocking stage; all animation is sampled by the host's paused clock.
var actors: Array[CinematicActor] = []
var actor_positions: Array[Vector3] = []
var actor_rotations: Array[float] = []
var chapter_id := ""
var shots: Array = []
var home := false
var parked: BikeVisual
var cloth: MeshInstance3D

func build(data: Dictionary) -> void:
	chapter_id = data.chapter_id
	home = chapter_id in ["banyuwangi", "epilogue"]
	shots = data.get("arrival_shots", [])
	LowPoly.box(self, Vector3(0, -.06, 0), Vector3(14, .12, 16), Color("b5ad91"))
	var quiet := chapter_id in ["salatiga", "lumajang", "ngawi"]
	if home:
		LowPoly.house(self, Vector3(0, 0, -5), Color("c7be9b"))
		# Open, dark doorway conceals the last walking step without a fade in space.
		LowPoly.box(self, Vector3(0, 1.45, -2.31), Vector3(1.22, 2.5, .04), Color("33463c"))
		for side in [-1, 1]:
			LowPoly.planter(self,Vector3(side*3.1,0,-1.8))
	elif not quiet:
		CozyDressing.shelter(self,chapter_id)
		# Open-front shelter keeps both actors and the interview laptop visible.
		LowPoly.box(self, Vector3(0, 3.2, -1), Vector3(9, .2, 8), Color("61776c"))
		for x in [-4, 4]:
			LowPoly.cylinder(self, Vector3(x, 1.6, 2), .09, 3.2, Color("806b50"))
		LowPoly.box(self, Vector3(0, .78, 0), Vector3(2.7, .12, 1.2), Color("916f51"))
		for x in [-1.1, 1.1]:
			for z in [-.43, .43]: LowPoly.box(self, Vector3(x, .36, z), Vector3(.10, .72, .10), Color("745a44"))
		for x in [-.8, .8]:
			LowPoly.cup(self, Vector3(x, .98, 0), .1, .25, Color("c7b489"))
	if chapter_id == "kediri":
		LowPoly.box(self, Vector3(0, 1.6, -3), Vector3(8, 3.2, .15), Color("a29b83"))
		LowPoly.box(self, Vector3(-4, 1.6, -.5), Vector3(.15, 3.2, 5), Color("b6ab91"))
		LowPoly.box(self, Vector3(-3.9, 1.9, -.7), Vector3(.08, 1.3, 1.6), Color("344a55"))
		var laptop := CinematicLaptop.new()
		add_child(laptop)
		laptop.build()
		laptop.position = Vector3(0,.87,0)
		laptop.screen.text = "INTERVIEW"
	if chapter_id == "pekalongan":
		for i in range(4):
			LowPoly.box(self, Vector3(2.7, .25 + i * .23, -.8), Vector3(1.4, .22, .8), Color("b48e74") if i % 2 else Color("667f8e"))
	if chapter_id == "tegal":
		LowPoly.box(self, Vector3(2, .5, -1), Vector3(1.5, 1, .6), Color("896852"))
		for i in range(3):
			LowPoly.beam(self, Vector3(1.5 + i * .3, 1.03, -1.2), Vector3(1.5 + i * .3, 1.03, -.8), .02, Color("afbab5"))
	_add_actor(Vector3(0 if chapter_id == "kediri" else -.9, 0, 1.7), Color("637b76"))
	if data.encounter_speaker not in ["Raka", "Interviewer", "Mom"] or home:
		_add_actor(Vector3(.9, 0, 1.7), Color("a18c6b"))
	if home:
		_add_actor(Vector3(0, .20, -1.7), Color("a17763"),true)
		actors[1].older()
		actors[2].older()
		LowPoly.sphere(actors[2].head, Vector3(0, .24, .19), Vector3(.2, .17, .15), Color("62675d"))
		actor_rotations[2] = PI
		if chapter_id == "epilogue":
			actor_rotations[0] = -PI / 2
			actor_rotations[1] = PI / 2
	if chapter_id == "ngawi": actors[1].older()
	if chapter_id == "semarang":
		actors[1].add_glasses()
		actor_positions[0] = Vector3(0, 0, 1.12)
		actor_positions[1] = Vector3(0, 0, -1.12)
		actor_rotations[1] = PI
		for side in [-1, 1]:
			LowPoly.cylinder(self, Vector3(0, .86, side * .38), .23, .025, Color("d8d1ac"))
			LowPoly.sphere(self, Vector3(0, .9, side * .38), Vector3(.24, .075, .20), Color("b9a16e"))
			LowPoly.box(self, Vector3(0, .42, side * 1.22), Vector3(.75, .12, .65), Color("8d7759"))
			for x in [-.25, .25]:
				for z in [-.2, .2]: LowPoly.box(self, Vector3(x, .18, side * 1.22 + z), Vector3(.08, .36, .08), Color("725b45"))
			LowPoly.box(self, Vector3(0, .8, side * 1.56), Vector3(.75, .64, .09), Color("8d7759"))
		LowPoly.box(self, Vector3(.65, .866, 0), Vector3(.17, .022, .28), Color("31423c"))
		LowPoly.box(self, Vector3(.65, .879, 0), Vector3(.135, .003, .23), Color("96a99c"))
	if chapter_id in ["salatiga", "ngawi", "lumajang"]:
		for i in range(actor_rotations.size()): actor_rotations[i] = -.7
	parked = BikeVisual.new()
	parked.show_rider_arms = false
	parked.position = Vector3(3, 0, 3)
	add_child(parked)
	parked.visible = chapter_id != "kediri"
	parked.luggage.visible = chapter_id != "epilogue"
	cloth = LowPoly.box(self, Vector3.ZERO, Vector3(.14, .015, .14), Color("d1c4a4"))
	cloth.visible = false
	if chapter_id == "ngawi":
		var second := BikeVisual.new()
		second.show_rider_arms = false
		second.position = Vector3(-3, 0, 3)
		add_child(second)
	if chapter_id not in ["semarang", "banyuwangi"]:
		LowPoly.box(self, Vector3(0, .42, 1.8), Vector3(3.5, .12, .65), Color("8d7759"))
		for x in [-1.4, 1.4]:
			for z in [1.57, 2.03]: LowPoly.box(self, Vector3(x, .18, z), Vector3(.12, .36, .12), Color("725b45"))

func _add_actor(pos: Vector3, shirt: Color, female: bool = false) -> void:
	var actor := CinematicActor.new()
	add_child(actor)
	actor.build(shirt,female)
	actor.position = pos
	actors.append(actor)
	actor_positions.append(pos)
	actor_rotations.append(0)

func sample(camera: Camera3D, shot: Dictionary, progress: float) -> void:
	var start := _vector(shot.camera)
	var end := _vector(shot.get("camera_end", shot.camera))
	camera.global_position = to_global(start.lerp(end, smoothstep(0, 1, progress)))
	camera.look_at(to_global(_vector(shot.target)))
	parked.position = Vector3(3, 0, 3)
	parked.rotation = Vector3.ZERO
	cloth.visible = false
	for i in range(actors.size()):
		actors[i].position = actor_positions[i]
		actors[i].rotation = Vector3(0, actor_rotations[i], 0)
		actors[i].sample("listen" if i else "rest", progress)
		actors[i].visible = true
		if home and (chapter_id == "banyuwangi" or i == 2):
			_stand(actors[i])
		else:
			actors[i].body.position.y = -.15
			actors[i].seated_legs.scale.y = .8
	if chapter_id == "jember": actors[0].sample("phone", .7)
	if home and shot.get("action", "") == "enter":
		for i in range(actors.size()):
			# Mom goes first; each actor clears the doorway before the next arrives.
			var order := 0 if i == 2 else i + 1
			var walk := clampf((progress - order * .17) / .55, 0, 1)
			var from := actor_positions[i]
			var to := Vector3(0, 0, -2.85)
			actors[i].rotation.y = atan2(-(to.x - from.x), -(to.z - from.z))
			actors[i].sample("walk", fposmod(walk * 3, 1))
			actors[i].position = from.lerp(to, walk)
			actors[i].visible = walk < 1
	elif home and shot.get("action", "") in ["bike", "bike_approach", "odometer", "hold"]:
		_pose_father(shot.get("action", ""), progress)
	elif home and shot.get("action", "") in ["approach", "park"]:
		var p := smoothstep(0, 1, progress)
		parked.position.z = lerpf(9, 3, p)
		CinematicMount.sample(actors[0], parked, 1)
	elif home and shot.get("action", "") == "engine_off":
		CinematicMount.sample(actors[0], parked, 1)
		actors[0].reach_hand(false, parked.to_global(BikeVisual.IGNITION))
	elif home and shot.get("action", "") == "mother":
		actors[2].position = Vector3(0, 0, -2.7).lerp(actor_positions[2], smoothstep(0, 1, progress))
		actors[2].sample("walk", progress)
		actors[2].rotation.y = PI
	if home:
		# The house foundation and its two steps are raised above the courtyard.
		# Resolve feet against those visible surfaces, not the flat stage floor.
		for actor in actors:
			if not actor.visible or not actor.walking_legs.visible: continue
			actor.position.y = maxf(actor.position.y,_porch_height(actor.position))
			for side in range(2):
				var shoe := actor.shoes[side]
				var ankle := to_local(shoe.global_position + actor.global_basis * Vector3(0,.02,.055))
				var required := _porch_height(ankle) + .095
				for x in [-.08,.08]:
					for z in [-.16,.13]:
						required = maxf(required,_porch_height(to_local(shoe.to_global(Vector3(x,0,z))))+.095)
				if ankle.y < required:
					ankle.y = required
					actor.reach_foot(side == 0,to_global(ankle),Vector3(0,0,-1))

func _porch_height(point: Vector3) -> float:
	var height := .16 if absf(point.x) < 4.25 and point.z <= .1 and point.z >= -6.9 else 0.0
	if absf(point.x) < 1.05 and point.z < -1.525 and point.z > -2.075: height = .20
	if absf(point.x) < 3.8 and point.z <= -1.95 and point.z >= -3.25: height = .36
	return height

func _pose_father(action: String, progress: float) -> void:
	var father := actors[1]
	var destination := Vector3(2.40, 0, 3.05)
	if action == "bike_approach":
		father.position = actor_positions[1].lerp(destination, smoothstep(0, 1, progress))
		father.sample("walk", fposmod(progress * 2, 1))
		father.rotation.y = atan2(-(destination.x - actor_positions[1].x), -(destination.z - actor_positions[1].z))
		return
	father.position = destination
	father.rotation = Vector3.ZERO
	father.sample("rest", .5)
	_stand(father)
	if chapter_id == "epilogue":
		father.position = Vector3(2.55, 0, 3.0)
		# A light wipe follows the curved tank; the same sampled time drives
		# both the hand and cloth, including Pause, Skip and backward sampling.
		var z := -.20 * cos(TAU * progress)
		var unit := Vector3(-.65, sqrt(1 - .65 * .65 - z * z), z)
		var contact_frame := BikeForms.tank_contact(parked.tank,unit)
		var point := contact_frame.origin
		var normal := contact_frame.basis.y
		father.reach_hand(false, point + normal * .065)
		cloth.global_position = point + normal * .01
		cloth.global_basis = Basis(Quaternion(Vector3.UP, normal))
		cloth.visible = true
	else:
		father.reach_hand(false, parked.to_global(BikeVisual.hand_grip(-1)))

func frame_dialogue(camera: Camera3D, speaker: String) -> void:
	var position := Vector3(3.8, 1.95, 5.3)
	var target := Vector3(0, 1.35, 1.5)
	if chapter_id == "semarang":
		position = Vector3(1.8, 1.8, -1.3 if speaker == "Raka" else 1.3)
		target = Vector3(0, 1.35, 1.12 if speaker == "Raka" else -1.12)
	elif chapter_id == "kediri":
		position = Vector3(-2.7, 1.8, 1.4)
		target = Vector3(0, 1.2, .7)
	elif home:
		position = Vector3(-3, 1.95, -.6) if speaker == "Raka" else Vector3(2.3, 1.9, 4.5)
		target = Vector3(-.9, 1.5, 1.7) if speaker == "Raka" else Vector3(0, 1.5, -1.7) if speaker == "Mom" else Vector3(.9, 1.25, 1.7)
		if chapter_id == "epilogue": position = Vector3(1.8 if speaker == "Raka" else -1.8, 1.85, 4)
	# Keep faces above the dialogue panel, which occupies the lower half.
	camera.fov = 52
	sample(camera, {"camera": [position.x, position.y, position.z], "target": [target.x, target.y - .65, target.z], "action": "hold" if chapter_id == "banyuwangi" else ""}, .5)

func _stand(actor: CinematicActor) -> void:
	actor.body.position.y = .28
	actor.walking_legs.visible = true
	actor.seated_legs.visible = false
	actor.left_arm.rotation = Vector3(.06, 0, .05)
	actor.right_arm.rotation = Vector3(.06, 0, -.05)
	actor.left_forearm.rotation = Vector3(.12, 0, 0)
	actor.right_forearm.rotation = Vector3(.12, 0, 0)

func _vector(value: Array) -> Vector3:
	return Vector3(value[0], value[1], value[2])
