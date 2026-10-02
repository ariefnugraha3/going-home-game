class_name CinematicMount
extends RefCounted

# Authored blocking in motorcycle coordinates; no second clock or physics state.
const SEAT := Vector3(0, 0.17, 0.30)

static func sample(actor: CinematicActor, bike: Node3D, progress: float) -> void:
	var p := clampf(progress, 0, 1)
	actor.sample("ride", p)
	var cross := smoothstep(0.35, 0.75, p)
	var settle := smoothstep(0.55, 0.9, p)
	var root := Vector3(lerpf(-0.58, 0, cross), lerpf(0, SEAT.y, settle), lerpf(0.40, SEAT.z, settle))
	root.y -= 0.14 * smoothstep(0.12, 0.35, p) * (1.0 - settle)
	actor.global_transform = bike.global_transform * Transform3D(Basis.IDENTITY, root)
	actor.body.position = Vector3(0, lerpf(0.28, 0, settle), -0.16 * settle)
	actor.walking_legs.position.y = -0.28 * settle
	actor.walking_legs.visible = true
	actor.seated_legs.visible = false
	var left := Vector3(-0.71, 0.10, 0.40).lerp(BikeVisual.foot_anchor(-1), smoothstep(0.55, 0.9, p))
	var right := Vector3(-0.45, 0.10, 0.40).lerp(Vector3(-0.43, 1.25, 0.40), smoothstep(0.08, 0.35, p))
	right = right.lerp(Vector3(0.36, 1.25, 0.40), smoothstep(0.35, 0.62, p))
	right = right.lerp(BikeVisual.foot_anchor(1), smoothstep(0.62, 0.9, p))
	actor.reach_foot(true, bike.to_global(left), Vector3(-1, 0, -0.25))
	actor.reach_foot(false, bike.to_global(right), Vector3(lerpf(-1, 1, smoothstep(0.35, 0.62, p)), 0, -0.4))
	# Brace beside the seat, then reach both grips as the torso settles forward.
	for side in [-1, 1]:
		var support := Vector3(-0.34 if side == -1 else -0.12, 1.04, 0.29)
		var grip := BikeVisual.hand_grip(side)
		actor.reach_hand(side == -1, bike.to_global(support.lerp(grip, smoothstep(0.55, 0.9, p))))
