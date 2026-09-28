class_name CinematicLaptop
extends Node3D

const DESK := Vector3(0.2, 0.93, -0.75)
const START := Vector3(-0.68, 0.93, -0.20)
const LIFT := Vector3(-0.68, 1.36, -0.20)
const ABOVE := Vector3(0.05, 1.36, -0.26)
const INSIDE := Vector3(0.05, 1.10, -0.26)
var lid: Node3D
var screen: Label3D

func build() -> void:
	LowPoly.box(self, Vector3.ZERO, Vector3(0.65, 0.05, 0.45), Color("374443"))
	lid = Node3D.new()
	add_child(lid)
	lid.position = Vector3(0, 0.03, -0.21)
	LowPoly.box(lid, Vector3(0, 0.20, 0), Vector3(0.65, 0.40, 0.04), Color("283c40"))
	screen = LowPoly.label(lid, "", Vector3(0, 0.22, 0.028), 32)
	screen.pixel_size = 0.0009
	screen.no_depth_test = false
	reset_to_desk()

func reset_to_desk() -> void:
	position = DESK
	lid.rotation.x = 0
	screen.visible = true

func sample(weight: float, packing: PackingProps, actor: CinematicActor) -> void:
	var p := clampf(weight, 0, 1)
	# The editorial cut starts with the bag reopened and laptop pulled near.
	# Subsequent transforms are absolute, including backward/direct seeks.
	packing.sample(1)
	packing.flap.rotation.x = lerpf(1.85, 0, smoothstep(0.84, 0.96, p))
	lid.rotation.x = lerpf(0, PI / 2, smoothstep(0.08, 0.25, p))
	screen.visible = p < 0.25
	if p < 0.43:
		position = START.lerp(LIFT, smoothstep(0.32, 0.43, p))
	elif p < 0.62:
		position = LIFT.lerp(ABOVE, smoothstep(0.43, 0.62, p))
	else:
		position = ABOVE.lerp(INSIDE, smoothstep(0.62, 0.76, p))
	actor.position = Vector3(-0.35, 0, 0.25)
	actor.body.position = Vector3(0.30 * smoothstep(0.43, 0.62, p), 0, -0.20)
	var left_rest := actor.left_forearm.to_global(Vector3(0, -0.29, 0))
	var right_rest := actor.right_forearm.to_global(Vector3(0, -0.29, 0))
	var lid_grip := lid.to_global(Vector3(0, 0.22, 0.025))
	var left_grip := to_global(Vector3(-0.30, 0.03, 0))
	var right_grip := to_global(Vector3(0.30, 0.03, 0))
	var left_target := left_rest.lerp(lid_grip, smoothstep(0, 0.08, p))
	if p >= 0.25:
		left_target = lid_grip.lerp(left_grip, smoothstep(0.25, 0.32, p))
	var right_target := right_rest.lerp(right_grip, smoothstep(0.25, 0.32, p))
	if p >= 0.76:
		left_target = left_grip.lerp(left_rest, smoothstep(0.76, 0.83, p))
		var flap_grip := packing.flap.to_global(Vector3(0.10, 0.025, -0.18))
		right_target = right_grip.lerp(flap_grip, smoothstep(0.76, 0.84, p))
		if p >= 0.96:
			right_target = flap_grip.lerp(right_rest, smoothstep(0.96, 1, p))
	actor.reach_hand(true, left_target)
	actor.reach_hand(false, right_target)

func pose_snapshot() -> Array:
	return [transform, lid.transform, screen.visible]
