class_name CinematicHelmet
extends RefCounted

const PARKED := Vector3(0, 0.965, 0.20)

static func pickup(actor: CinematicActor, bike: Node3D, progress: float) -> void:
	var p := clampf(progress, 0, 1)
	if p >= 1:
		sample(actor, bike, 0) # Exact handoff into the existing donning shot.
		return
	CinematicMount.sample(actor, bike, 0)
	actor.body.position = Vector3(0.24, 0.10, -0.12).lerp(Vector3(0, 0.28, 0), smoothstep(0.35, 0.85, p))
	var held := Vector3(-0.58, 1.26, -0.04)
	var point := PARKED.lerp(Vector3(0, 1.26, PARKED.z), smoothstep(0.30, 0.50, p))
	point = point.lerp(held, smoothstep(0.50, 0.90, p))
	actor.helmet.position = actor.head.to_local(bike.to_global(point))
	actor.chin_strap.position = actor.helmet.position - CinematicChinStrap.WORN
	actor.chin_strap.sample_resting(smoothstep(0.90, 1.0, p))
	for i in range(2):
		var rest := bike.to_global(Vector3(-0.62 if i == 0 else -0.30, 1.05, -0.02))
		var rim := actor.head.to_global(actor.helmet.position + Vector3(-0.18 if i == 0 else 0.18, -0.07, 0))
		actor.reach_hand(i == 0, rest.lerp(rim, smoothstep(0.04, 0.28, p)))

# The existing helmet stays attached to the head node; only its local offset
# changes. The mounting pose provides an identical final handoff and foot plant.
static func sample(actor: CinematicActor, bike: Node3D, progress: float) -> void:
	var p := clampf(progress, 0, 1)
	CinematicMount.sample(actor, bike, 0)
	var resting_hands := [actor.left_forearm.to_global(Vector3(0, -0.29, 0)), actor.right_forearm.to_global(Vector3(0, -0.29, 0))]
	var held := Vector3(0, -0.30, -0.44)
	var lifted := Vector3(0, 0.51, -0.44)
	var above := Vector3(0, 0.51, 0.015)
	var worn := Vector3(0, 0.26, 0.015)
	actor.helmet.position = held.lerp(lifted, smoothstep(0.12, 0.36, p))
	actor.helmet.position = actor.helmet.position.lerp(above, smoothstep(0.36, 0.56, p))
	actor.helmet.position = actor.helmet.position.lerp(worn, smoothstep(0.56, 0.74, p))
	if p >= 0.74:
		actor.helmet.position = worn
	actor.chin_strap.position = actor.helmet.position - CinematicChinStrap.WORN
	actor.chin_strap.sample(0)
	var shrug := 0.17 * smoothstep(0.12, 0.36, p) * (1.0 - smoothstep(0.56, 0.84, p))
	actor.raise_shoulders(shrug, 0.08 * shrug / 0.17)
	if p < 1.0:
		for i in range(2):
			var rim := actor.head.to_global(actor.helmet.position + Vector3(-0.18 if i == 0 else 0.18, -0.07, 0))
			actor.reach_hand(i == 0, rim.lerp(resting_hands[i], smoothstep(0.80, 1.0, p)))
