class_name CinematicActor
extends Node3D

# Articulated blocking actor. AnimationPlayer is sampled by the shot director,
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
var active_clip: String = "rest"

func build(shirt: Color) -> void:
	body = _joint(self, "Body", Vector3.ZERO)
	seated_legs = _joint(self, "SeatedLegs", Vector3.ZERO)
	walking_legs = _joint(self, "WalkingLegs", Vector3.ZERO)
	LowPoly.box(body, Vector3(0, 0.95, 0), Vector3(0.43, 0.58, 0.28), shirt)
	LowPoly.cylinder(body, Vector3(0, 1.285, 0), 0.075, 0.18, Color("b87f55"))
	head = _joint(body, "Head", Vector3(0, 1.28, 0))
	LowPoly.sphere(head, Vector3(0, 0.15, -0.025), Vector3(0.37, 0.28, 0.36), Color("b87f55"))
	LowPoly.sphere(head, Vector3(0, 0.26, 0), Vector3(0.4, 0.1, 0.37), Color("29312e"))
	# A small nose makes the forward direction legible in profile.
	LowPoly.box(head, Vector3(0, 0.14, -0.2), Vector3(0.065, 0.07, 0.06), Color("b87f55"))
	helmet = LowPoly.sphere(head, Vector3(0, 0.26, 0.015), Vector3(0.46, 0.22, 0.45), Color("d1c7a3"))
	helmet.visible = false
	for side in [-1, 1]:
		LowPoly.beam(seated_legs, Vector3(side * 0.13, 0.7, 0), Vector3(side * 0.18, 0.6, -0.42), 0.105, Color("394653"))
		LowPoly.beam(seated_legs, Vector3(side * 0.18, 0.6, -0.42), Vector3(side * 0.18, 0.12, -0.4), 0.09, Color("394653"))
		LowPoly.box(seated_legs, Vector3(side * 0.18, 0.08, -0.45), Vector3(0.17, 0.13, 0.3), Color("29312e"))
		var hip := _joint(walking_legs, "LeftHip" if side == -1 else "RightHip", Vector3(side * 0.13, 0.98, 0))
		LowPoly.beam(hip, Vector3.ZERO, Vector3(0, -0.43, 0), 0.105, Color("394653"))
		var knee := _joint(hip, "Knee", Vector3(0, -0.43, 0))
		LowPoly.beam(knee, Vector3.ZERO, Vector3(0, -0.45, 0), 0.09, Color("394653"))
		shoes.append(LowPoly.box(knee, Vector3(0, -0.47, -0.055), Vector3(0.17, 0.13, 0.3), Color("29312e")))
		bare_feet.append(LowPoly.box(knee, Vector3(0, -0.48, -0.045), Vector3(0.14, 0.09, 0.23), Color("b87f55")))
		var arm := _joint(body, "LeftArm" if side == -1 else "RightArm", Vector3(side * 0.24, 1.15, 0))
		LowPoly.beam(arm, Vector3.ZERO, Vector3(0, -0.27, 0), 0.075, shirt)
		var forearm := _joint(arm, "Forearm", Vector3(0, -0.27, 0))
		LowPoly.beam(forearm, Vector3.ZERO, Vector3(0, -0.27, 0), 0.06, Color("b87f55"))
		LowPoly.sphere(forearm, Vector3(0, -0.29, 0), Vector3(0.12, 0.075, 0.15), Color("b87f55"))
		if side == -1:
			left_arm = arm
			left_forearm = forearm
			handset = LowPoly.box(forearm, Vector3(0, -0.3, -0.01), Vector3(0.085, 0.16, 0.025), Color("253a3b"))
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
	var elbow_left := [Vector3(0.9, 0, 0), Vector3(0.9, 0, 0), Vector3(0.9, 0, 0)]
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
	return true

func reach_hand(left: bool, world_target: Vector3) -> void:
	# Two-bone analytic reach for the blocking mesh (upper arm .27, hand .29).
	# Solve from rest transforms each sample; unreachable targets clamp safely.
	var arm := left_arm if left else right_arm
	var forearm := left_forearm if left else right_forearm
	arm.rotation = Vector3.ZERO
	forearm.rotation = Vector3.ZERO
	var target := body.to_local(world_target) - arm.position
	var distance := clampf(target.length(), 0.025, 0.559)
	var direction := target.normalized()
	var pole := Vector3(-1 if left else 1, -0.4, 0)
	var bend := (pole - direction * pole.dot(direction)).normalized()
	var along := (0.27 * 0.27 - 0.29 * 0.29 + distance * distance) / (2 * distance)
	var elbow := direction * along + bend * sqrt(maxf(0, 0.27 * 0.27 - along * along))
	arm.quaternion = Quaternion(Vector3.DOWN, elbow.normalized())
	var lower := arm.basis.inverse() * (direction * distance - elbow)
	forearm.quaternion = Quaternion(Vector3.DOWN, lower.normalized())

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
