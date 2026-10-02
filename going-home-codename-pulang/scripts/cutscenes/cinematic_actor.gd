class_name CinematicActor
extends Node3D

# Stylized articulated actor. AnimationPlayer is sampled by the shot director,
# so no independent animation clock can continue through pause or scene skips.
const CLIPS := ["rest", "listen", "phone", "pack", "ride", "passenger", "walk", "wake"]
var animator: AnimationPlayer
var body: Node3D
var seated_legs: Node3D
var walking_legs: Node3D
var shoes: Array[MeshInstance3D] = []
var bare_feet: Array[MeshInstance3D] = []
var head: Node3D
var left_arm: Node3D
var right_arm: Node3D
var left_forearm: Node3D
var right_forearm: Node3D
var handset: MeshInstance3D
var helmet: MeshInstance3D
var chin_strap: CinematicChinStrap
var shoulder_bridges: Array[MeshInstance3D] = []
var active_clip: String = "rest"
var hair: MeshInstance3D
var brows: Array[MeshInstance3D] = []
var female: bool = false

func build(shirt: Color, is_female: bool = false) -> void:
	female = is_female
	body = _joint(self, "Body", Vector3.ZERO)
	seated_legs = _joint(self, "SeatedLegs", Vector3.ZERO)
	walking_legs = _joint(self, "WalkingLegs", Vector3.ZERO)
	LowPoly.mesh(body, CozyForms.loft([Vector4(.175,.66,.125,0),Vector4(.19,.78,.15,0),Vector4(.23,1.10,.155,0),Vector4(.225,1.19,.13,0),Vector4(.105,1.26,.085,0)],12), Vector3.ZERO, shirt)
	if female:
		# Tailored blouse panels, not a scaled copy of the male head or skeleton.
		for side in [-1,1]:
			var lapel := LowPoly.box(body,Vector3(side*.096,1.14,-.139),Vector3(.075,.19,.018),shirt.lightened(.18))
			lapel.rotation.z = side*.28
	LowPoly.cylinder(body, Vector3(0, 1.285, 0), 0.075, 0.18, Color("b87f55"))
	head = _joint(body, "Head", Vector3(0, 1.28, 0))
	CharacterForms.face(head,female)
	hair = LowPoly.mesh(head, CozyForms.loft([Vector4(.14,.25,.133,.014),Vector4(.153,.30,.137,.016),Vector4(.123,.352,.115,.022),Vector4(.045,.375,.055,.024)],16), Vector3.ZERO, Color("40372f"))
	if female:
		# Tucked bob with a clear jaw and neck, and an asymmetric side part.
		LowPoly.mesh(hair,CozyForms.loft([Vector4(.13,.065,.065,.087),Vector4(.16,.19,.078,.08),Vector4(.15,.29,.09,.044)],12),Vector3.ZERO,Color("40372f"))
		for side in [-1,1]:
			var lock := LowPoly.sphere(hair,Vector3(side*.142,.195,.033),Vector3(.074,.24,.18),Color("493b32"))
			lock.rotation.z = side*.08
		LowPoly.sphere(hair,Vector3(-.059,.295,-.089),Vector3(.19,.092,.092),Color("493b32"))
	else:
		LowPoly.sphere(hair,Vector3(-.036,.306,-.07),Vector3(.23,.094,.14),Color("493b32"))
	for side in [-1,1]:
		var brow := LowPoly.beam(head,Vector3(side*.038,.253,-.12),Vector3(side*.088,.247,-.108),.006 if female else .008,Color("594534"))
		brows.append(brow)
	LowPoly.box(body, Vector3(0, 1.04, -.16), Vector3(.018, .34, .012), shirt.lightened(.14))
	LowPoly.box(body, Vector3(-.12, 1.06, -.15), Vector3(.11, .12, .025), shirt.lightened(.1))
	for y in [.92,1.04,1.16]: LowPoly.sphere(body,Vector3(0,y,-.172),Vector3(.018,.018,.012),Color("d2c2a0"))
	for side in [-1,1]:
		var collar := LowPoly.box(body,Vector3(side*.065,1.205,-.103),Vector3(.105,.11,.045),shirt.lightened(.16))
		collar.rotation.z = side * -.35
	LowPoly.mesh(body,CozyForms.loft([Vector4(.17,.64,.13,0),Vector4(.185,.73,.14,0),Vector4(.173,.80,.13,0)],12),Vector3.ZERO,Color("394653"))
	helmet = LowPoly.mesh(head,CharacterForms.helmet_shell(),Vector3(0,.26,.015),Color("d1c7a3"))
	helmet.visible = false
	chin_strap = CinematicChinStrap.new()
	head.add_child(chin_strap)
	chin_strap.build()
	for side in [-1, 1]:
		CharacterForms.limb(seated_legs, Vector3(side * 0.13, 0.7, 0), Vector3(side * 0.18, 0.6, -0.42), Vector3(.115,.108,.081), Color("394653"))
		CharacterForms.limb(seated_legs, Vector3(side * 0.18, 0.6, -0.42), Vector3(side * 0.18, 0.12, -0.4), Vector3(.083,.095,.058), Color("394653"))
		CharacterForms.shoe(seated_legs, Vector3(side * 0.18, 0.08, -0.45))
		var hip := _joint(walking_legs, "LeftHip" if side == -1 else "RightHip", Vector3(side * 0.13, 0.98, 0))
		CharacterForms.limb(hip, Vector3.ZERO, Vector3(0, -0.43, 0), Vector3(.112,.11,.079), Color("394653"))
		var knee := _joint(hip, "Knee", Vector3(0, -0.43, 0))
		CharacterForms.limb(knee, Vector3.ZERO, Vector3(0, -0.45, 0), Vector3(.081,.092,.055), Color("394653"))
		LowPoly.sphere(knee,Vector3.ZERO,Vector3(.158,.15,.145),Color("394653"))
		shoes.append(CharacterForms.shoe(knee, Vector3(0, -0.47, -0.055)))
		var bare := LowPoly.mesh(knee,CozyForms.loft([Vector4(.065,-.045,.104,-.01),Vector4(.07,-.005,.11,-.01),Vector4(.055,.04,.055,.04)],12),Vector3(0,-.48,-.045),Color("bc8968"))
		for toe in range(5): LowPoly.sphere(bare,Vector3((toe-2)*.024,-.011,-.102),Vector3(.025,.034,.035),Color("bc8968"))
		bare_feet.append(bare)
		var arm := _joint(body, "LeftArm" if side == -1 else "RightArm", Vector3(side * 0.24, 1.15, 0))
		shoulder_bridges.append(LowPoly.cylinder(body, Vector3.ZERO, 0.08, 1.0, shirt))
		CharacterForms.limb(arm, Vector3(0,.025,0), Vector3(0, -.25, 0), Vector3(.079,.081,.062), shirt)
		LowPoly.sphere(arm,Vector3.ZERO,Vector3(.166,.17,.16),shirt)
		var forearm := _joint(arm, "Forearm", Vector3(0, -0.27, 0))
		CharacterForms.limb(forearm, Vector3.ZERO, Vector3(0, -.255, 0), Vector3(.053,.057,.034), Color("bc8968"))
		LowPoly.sphere(forearm,Vector3.ZERO,Vector3(.108,.10,.104),Color("bc8968"))
		CharacterForms.hand(forearm,side)
		if side == -1:
			left_arm = arm
			left_forearm = forearm
			handset = LowPoly.box(forearm, Vector3(0, -0.3, -0.01), Vector3(0.085, 0.16, 0.025), Color("253a3b"))
			LowPoly.box(handset,Vector3(0,0,-.013),Vector3(.072,.132,.002),Color("6f958a"))
			LowPoly.box(handset,Vector3(0,-.069,-.015),Vector3(.025,.003,.001),Color("d4d9bc"))
			LowPoly.sphere(handset,Vector3(-.019,.059,.014),Vector3(.016,.016,.004),Color("131f23"))
			handset.visible = false
		else:
			right_arm = arm
			right_forearm = forearm
	animator = AnimationPlayer.new()
	animator.name = "Performance"
	add_child(animator)
	animator.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	var library := AnimationLibrary.new()
	for clip in CLIPS:
		library.add_animation(clip, _clip(clip))
	animator.add_animation_library("", library)
	sample("rest", 0)

func older() -> void:
	hair.material_override = LowPoly.material(Color("92978b"))
	for brow in brows: brow.material_override = LowPoly.material(Color("656c62"))
	for side in [-1, 1]:
		LowPoly.box(head, Vector3(side * .10, .14, -.181), Vector3(.05, .005, .008), Color("9b6a4c"))

func add_glasses() -> void:
	for side in [-1, 1]:
		for y in [.208, .239]: LowPoly.box(head, Vector3(side * .063, y, -.138), Vector3(.068, .006, .008), Color("46534a"))
		for x in [side * .03, side * .097]: LowPoly.box(head, Vector3(x, .224, -.138), Vector3(.006, .035, .008), Color("46534a"))
	LowPoly.box(head, Vector3(0, .228, -.145), Vector3(.06, .006, .008), Color("46534a"))

func _joint(parent: Node3D, label: String, pos: Vector3) -> Node3D:
	var joint := Node3D.new()
	joint.name = label
	joint.position = pos
	parent.add_child(joint)
	return joint

func _track(animation: Animation, path: String, values: Array) -> void:
	var index := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(index, NodePath(path))
	for i in range(values.size()):
		animation.track_insert_key(index, float(i) / (values.size() - 1), values[i])

func _clip(id: String) -> Animation:
	var clip := Animation.new()
	clip.length = 1.0
	var left := [Vector3(0.6, 0, 0), Vector3(0.6, 0, 0), Vector3(0.6, 0, 0)]
	var right := left.duplicate()
	var elbow_left := [Vector3(1.0, 0, 0), Vector3(1.0, 0, 0), Vector3(1.0, 0, 0)]
	var elbow_right := elbow_left.duplicate()
	var nod := [Vector3.ZERO, Vector3.ZERO, Vector3.ZERO]
	match id:
		"listen": nod[1] = Vector3(0.08, -0.035, 0)
		"phone":
			left = [Vector3(0.6, 0, 0), Vector3(1.9, 0, -0.1), Vector3(1.9, 0, -0.1)]
			elbow_left = [Vector3(0.9, 0, 0), Vector3(1.8, 0, 0), Vector3(1.8, 0, 0)]
			nod = [Vector3.ZERO, Vector3(0.02, 0.04, -0.04), Vector3(0.02, 0.04, -0.04)]
		"pack":
			left[1] = Vector3(1.2, -0.15, 0)
			elbow_left[1] = Vector3(0.1, 0, 0)
			nod[1] = Vector3(0.12, 0, 0)
		"ride":
			left.fill(Vector3(0.9, -0.25, 0))
			right.fill(Vector3(0.9, 0.25, 0))
			elbow_left.fill(Vector3(0.55, 0, 0))
			elbow_right.fill(Vector3(0.55, 0, 0))
		"passenger":
			left.fill(Vector3(1.25, -0.3, 0))
			right.fill(Vector3(1.25, 0.3, 0))
			elbow_left.fill(Vector3(0.15, 0, 0))
			elbow_right.fill(Vector3(0.15, 0, 0))
		"wake":
			var angles := [PI / 2, PI / 2, 1.05, 0.25, 0.0]
			var rotations := []
			var positions := []
			var hip := Vector3(0, 0.7, 0)
			for angle in angles:
				rotations.append(Vector3(angle, 0, 0))
				positions.append(hip - Basis(Vector3.RIGHT, angle) * hip)
			_track(clip, "Body:rotation", rotations)
			_track(clip, "Body:position", positions)
			_track(clip, "Body/Head:position", [Vector3(0, 1.28, -0.14), Vector3(0, 1.28, -0.14), Vector3(0, 1.28, -0.06), Vector3(0, 1.28, 0), Vector3(0, 1.28, 0)])
			for side in ["LeftHip", "RightHip"]:
				# Keep shins above the mattress until the root has moved knees
				# beyond its foot edge; bending earlier cuts through the bed.
				_track(clip, "WalkingLegs/" + side + ":rotation", [Vector3(PI / 2, 0, 0), Vector3(PI / 2, 0, 0), Vector3(PI / 2, 0, 0), Vector3(PI / 2, 0, 0), Vector3(PI / 2, 0, 0), Vector3(1.48, 0, 0), Vector3(1.34, 0, 0), Vector3(1.34, 0, 0), Vector3(1.34, 0, 0)])
				_track(clip, "WalkingLegs/" + side + "/Knee:rotation", [Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, Vector3(-0.4, 0, 0), Vector3(-1.0, 0, 0), Vector3(-1.25, 0, 0), Vector3(-1.34, 0, 0)])
			left = [Vector3(0.05, 0, 0.1), Vector3(0.2, 0, 0.15), Vector3(-0.3, 0, 0.1), Vector3(-0.1, 0, 0), Vector3(0.45, 0, 0)]
			right = [Vector3(0.05, 0, -0.1), Vector3(0.2, 0, -0.15), Vector3(-0.3, 0, -0.1), Vector3(-0.1, 0, 0), Vector3(0.45, 0, 0)]
			elbow_left = [Vector3(0.2, 0, 0), Vector3(0.25, 0, 0), Vector3(0.1, 0, 0), Vector3(0.2, 0, 0), Vector3(0.8, 0, 0)]
			elbow_right = elbow_left.duplicate()
			nod = [Vector3.ZERO, Vector3(0.04, 0.08, 0), Vector3(0.1, 0, 0), Vector3(0.08, 0, 0), Vector3(0.04, 0, 0)]
		"walk":
			left.clear()
			right.clear()
			var hips_left := []
			var hips_right := []
			var knees_left := []
			var knees_right := []
			for step in range(9):
				var swing := sin(float(step) / 8 * TAU)
				left.append(Vector3(-swing * 0.18, 0, 0))
				right.append(Vector3(swing * 0.18, 0, 0))
				hips_left.append(Vector3(swing * 0.3, 0, 0))
				hips_right.append(Vector3(-swing * 0.3, 0, 0))
				knees_left.append(Vector3(-maxf(0, swing) * 0.4, 0, 0))
				knees_right.append(Vector3(-maxf(0, -swing) * 0.4, 0, 0))
			elbow_left.fill(Vector3(0.12, 0, 0))
			elbow_right.fill(Vector3(0.12, 0, 0))
			_track(clip, "WalkingLegs/LeftHip:rotation", hips_left)
			_track(clip, "WalkingLegs/RightHip:rotation", hips_right)
			_track(clip, "WalkingLegs/LeftHip/Knee:rotation", knees_left)
			_track(clip, "WalkingLegs/RightHip/Knee:rotation", knees_right)
	_track(clip, "Body/LeftArm:rotation", left)
	_track(clip, "Body/RightArm:rotation", right)
	_track(clip, "Body/LeftArm/Forearm:rotation", elbow_left)
	_track(clip, "Body/RightArm/Forearm:rotation", elbow_right)
	_track(clip, "Body/Head:rotation", nod)
	return clip

func sample(id: String, progress: float) -> bool:
	if id not in CLIPS:
		return false
	active_clip = id
	if animator.current_animation != id:
		animator.play(id)
	# Wake animates the torso around the hip and raises the head onto a pillow.
	# Reset these channels before seeking any clip, including backwards seeks.
	body.position = Vector3(0, 0.28, 0) if id == "walk" else Vector3.ZERO
	body.rotation = Vector3.ZERO
	head.position = Vector3(0, 1.28, 0)
	left_arm.position = Vector3(-0.24, 1.15, 0)
	right_arm.position = Vector3(0.24, 1.15, 0)
	# IK writes a full basis; clear its numerical scale/shear before authored
	# rotation tracks so direct seeks and Skip produce identical transforms.
	for joint in [left_arm,right_arm,left_forearm,right_forearm]: joint.basis = Basis.IDENTITY
	helmet.position = Vector3(0, 0.26, 0.015)
	for bridge in shoulder_bridges:
		bridge.visible = false
		bridge.transform = Transform3D.IDENTITY
	walking_legs.position.y = -0.28 if id == "wake" else 0.0
	animator.seek(clampf(progress, 0, 1), true)
	walking_legs.visible = id in ["walk", "wake"]
	seated_legs.visible = not walking_legs.visible
	for shoe in shoes:
		shoe.visible = id != "wake"
		shoe.transform = Transform3D(Basis.IDENTITY, Vector3(0, -0.47, -0.055))
	for foot in bare_feet:
		foot.visible = id == "wake"
	handset.visible = id == "phone" and progress >= 0.3
	helmet.visible = id in ["ride", "passenger"]
	hair.visible = not helmet.visible
	chin_strap.position = Vector3.ZERO
	chin_strap.visible = helmet.visible
	chin_strap.sample(1)
	return true

func ground_gait(phase: float, stride: float) -> void:
	# During stance, local foot travel cancels root travel exactly. Swing lifts
	# the toe and flexes the knee forward; soles stay level through leg IK.
	stride = clampf(stride,.2,.9)
	walking_legs.position.y = -.035
	body.position.y = .245
	for side in [-1,1]:
		var t := fposmod(phase + (0.0 if side == -1 else .5),1.0)
		var z := (t-.3)*stride
		var lift := 0.0
		if t > .6:
			var swing := (t-.6)/.4
			z = lerpf(.3*stride,-.3*stride,smoothstep(0,1,swing))
			lift = sin(swing*PI)*.115
		reach_foot(side == -1,to_global(Vector3(side*.13,.095+lift,z)),Vector3(0,0,-1))

func raise_shoulders(height: float, forward: float) -> void:
	for i in range(2):
		var arm := left_arm if i == 0 else right_arm
		var origin := Vector3(-0.24 if i == 0 else 0.24, 1.15, 0)
		var offset := Vector3(0, height, -forward)
		arm.position = origin + offset
		var bridge := shoulder_bridges[i]
		bridge.visible = offset.length() > 0.001
		if bridge.visible:
			var basis := Basis(Quaternion(Vector3.UP, offset.normalized()))
			# Scale the local cylinder axis, preserving its fixed cross section.
			basis.y *= offset.length()
			bridge.transform = Transform3D(basis, origin + offset * 0.5)

func reach_hand(left: bool, world_target: Vector3) -> void:
	# Two-bone analytic reach for the blocking mesh (upper arm .27, hand .29).
	# Solve from rest transforms each sample; unreachable targets clamp safely.
	var arm := left_arm if left else right_arm
	var forearm := left_forearm if left else right_forearm
	arm.rotation = Vector3.ZERO
	forearm.rotation = Vector3.ZERO
	var target := body.to_local(world_target) - arm.position
	var distance := clampf(target.length(), 0.13, 0.559)
	var direction := target.normalized()
	var pole := Vector3(-1 if left else 1, -0.4, 0)
	var bend := (pole - direction * pole.dot(direction)).normalized()
	var along := (0.27 * 0.27 - 0.29 * 0.29 + distance * distance) / (2 * distance)
	var elbow := direction * along + bend * sqrt(maxf(0, 0.27 * 0.27 - along * along))
	# Align the upper-arm hinge axis with the solved elbow plane. The elbow
	# then flexes about one axis instead of twisting independently in 3D.
	var axis := elbow.cross(direction * distance - elbow).normalized()
	if axis.length_squared() < .5: axis = Vector3.RIGHT
	var down := -elbow.normalized()
	arm.basis = Basis(axis,down,axis.cross(down).normalized()).orthonormalized()
	var lower := arm.basis.inverse() * (direction * distance - elbow)
	forearm.rotation.x = atan2(-lower.z,-lower.y)

func reach_foot(left: bool, world_target: Vector3, pole: Vector3) -> void:
	var hip: Node3D = walking_legs.get_node("LeftHip" if left else "RightHip")
	var knee: Node3D = hip.get_node("Knee")
	hip.rotation = Vector3.ZERO
	knee.rotation = Vector3.ZERO
	var target := walking_legs.to_local(world_target) - hip.position
	var distance := clampf(target.length(), 0.025, 0.879)
	var direction := target.normalized()
	var bend := (pole - direction * pole.dot(direction)).normalized()
	var along := (0.43 * 0.43 - 0.45 * 0.45 + distance * distance) / (2 * distance)
	var joint := direction * along + bend * sqrt(maxf(0, 0.43 * 0.43 - along * along))
	hip.quaternion = Quaternion(Vector3.DOWN, joint.normalized())
	knee.quaternion = Quaternion(Vector3.DOWN, (hip.basis.inverse() * (direction * distance - joint)).normalized())
	# Keep shoe soles level independently of shin articulation.
	var shoe: MeshInstance3D = shoes[0 if left else 1]
	shoe.global_basis = global_basis
	shoe.global_position = knee.to_global(Vector3(0, -0.45, 0)) + global_basis * Vector3(0, -0.02, -0.055)

func pose_snapshot() -> Array:
	var pose := [body.transform, head.transform, left_arm.transform, right_arm.transform, left_forearm.transform, right_forearm.transform, handset.visible, helmet.visible, walking_legs.visible, seated_legs.visible]
	pose.append(helmet.transform)
	pose.append(hair.visible)
	pose.append(chin_strap.snapshot())
	for bridge in shoulder_bridges:
		pose.append([bridge.visible, bridge.transform])
	# Hidden gait joints are excluded: previous walks must not affect comparison
	# of a seated dialogue or the deterministic final riding pose after Skip.
	if walking_legs.visible:
		pose.append(walking_legs.transform)
		pose.append(bare_feet[0].visible)
		for hip in walking_legs.get_children():
			pose.append(hip.transform)
			pose.append(hip.get_node("Knee").transform)
		for shoe in shoes:
			pose.append(shoe.transform)
	return pose
