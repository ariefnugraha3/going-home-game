class_name CinematicActor
extends Node3D

# Articulated blocking actor. AnimationPlayer is sampled by the shot director,
# so no independent animation clock can continue through pause or scene skips.
const CLIPS := ["rest", "listen", "phone", "pack", "ride", "passenger"]
var animator: AnimationPlayer
var head: Node3D
var left_arm: Node3D
var right_arm: Node3D
var left_forearm: Node3D
var right_forearm: Node3D
var handset: MeshInstance3D
var helmet: MeshInstance3D
var active_clip: String = "rest"

func build(shirt: Color) -> void:
	LowPoly.box(self, Vector3(0, 0.95, 0), Vector3(0.43, 0.58, 0.28), shirt)
	head = _joint(self, "Head", Vector3(0, 1.28, 0))
	LowPoly.sphere(head, Vector3(0, 0.15, -0.025), Vector3(0.37, 0.28, 0.36), Color("b87f55"))
	LowPoly.sphere(head, Vector3(0, 0.26, 0), Vector3(0.4, 0.1, 0.37), Color("29312e"))
	# A small nose makes the forward direction legible in profile.
	LowPoly.box(head, Vector3(0, 0.14, -0.2), Vector3(0.065, 0.07, 0.06), Color("b87f55"))
	helmet = LowPoly.sphere(head, Vector3(0, 0.26, 0.015), Vector3(0.46, 0.22, 0.45), Color("d1c7a3"))
	helmet.visible = false
	for side in [-1, 1]:
		LowPoly.beam(self, Vector3(side * 0.13, 0.7, 0), Vector3(side * 0.18, 0.6, -0.42), 0.105, Color("394653"))
		LowPoly.beam(self, Vector3(side * 0.18, 0.6, -0.42), Vector3(side * 0.18, 0.12, -0.4), 0.09, Color("394653"))
		LowPoly.box(self, Vector3(side * 0.18, 0.08, -0.45), Vector3(0.17, 0.13, 0.3), Color("29312e"))
		var arm := _joint(self, "LeftArm" if side == -1 else "RightArm", Vector3(side * 0.24, 1.15, 0))
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
	_track(clip, "LeftArm:rotation", left)
	_track(clip, "RightArm:rotation", right)
	_track(clip, "LeftArm/Forearm:rotation", elbow_left)
	_track(clip, "RightArm/Forearm:rotation", elbow_right)
	_track(clip, "Head:rotation", nod)
	return clip

func sample(id: String, progress: float) -> bool:
	if id not in CLIPS:
		return false
	active_clip = id
	if animator.current_animation != id:
		animator.play(id)
	animator.seek(clampf(progress, 0, 1), true)
	handset.visible = id == "phone" and progress >= 0.3
	helmet.visible = id in ["ride", "passenger"]
	return true

func pose_snapshot() -> Array:
	return [head.transform, left_arm.transform, right_arm.transform, left_forearm.transform, right_forearm.transform, handset.visible, helmet.visible]
