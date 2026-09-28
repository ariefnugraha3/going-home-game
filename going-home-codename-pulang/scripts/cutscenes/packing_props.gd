class_name PackingProps
extends Node3D

# A sampled blocking performance: no tweens, reparenting or physics clocks.
const START := Vector3(-0.55, 0.95, -0.05)
const LIFT := Vector3(-0.45, 1.30, -0.08)
const ABOVE := Vector3(-0.05, 1.30, -0.22)
const INSIDE := Vector3(-0.05, 1.02, -0.22)
var raincoat: Node3D
var flap: Node3D

func build() -> void:
	var bag := Node3D.new()
	add_child(bag)
	bag.position = Vector3(0.05, 0.92, -0.26)
	LowPoly.box(bag, Vector3.ZERO, Vector3(0.60, 0.05, 0.46), Color("46523f"))
	for x in [-0.285, 0.285]:
		LowPoly.box(bag, Vector3(x, 0.10, 0), Vector3(0.03, 0.20, 0.46), Color("66735b"))
	for z in [-0.215, 0.215]:
		LowPoly.box(bag, Vector3(0, 0.10, z), Vector3(0.60, 0.20, 0.03), Color("66735b"))
	# Clothes, charger and toolkit are already inside; their placement is not animated.
	LowPoly.box(bag, Vector3(-0.18, 0.05, 0), Vector3(0.24, 0.05, 0.30), Color("bdad8a"))
	LowPoly.box(bag, Vector3(0.23, 0.07, -0.10), Vector3(0.12, 0.09, 0.14), Color("344347"))
	LowPoly.box(bag, Vector3(0.22, 0.07, 0.09), Vector3(0.14, 0.08, 0.16), Color("8b6149"))
	flap = Node3D.new()
	bag.add_child(flap)
	flap.position = Vector3(0, 0.21, 0.23)
	LowPoly.box(flap, Vector3(0, 0, -0.23), Vector3(0.60, 0.025, 0.46), Color("758365"))
	for x in [-0.18, 0.18]:
		LowPoly.box(flap, Vector3(x, 0.02, -0.23), Vector3(0.055, 0.025, 0.46), Color("343d35"))
	raincoat = Node3D.new()
	add_child(raincoat)
	LowPoly.box(raincoat, Vector3.ZERO, Vector3(0.24, 0.10, 0.18), Color("bb974f"))
	LowPoly.box(raincoat, Vector3(0, 0.054, 0), Vector3(0.04, 0.008, 0.18), Color("e2cf8c"))
	sample(0)

func sample(weight: float) -> void:
	var p := clampf(weight, 0, 1)
	if p < 0.30:
		raincoat.position = START.lerp(LIFT, smoothstep(0.16, 0.30, p))
	elif p < 0.44:
		raincoat.position = LIFT.lerp(ABOVE, smoothstep(0.30, 0.44, p))
	else:
		raincoat.position = ABOVE.lerp(INSIDE, smoothstep(0.44, 0.59, p))
	flap.rotation.x = lerpf(1.85, 0, smoothstep(0.72, 0.90, p))

func pose_actor(actor: CinematicActor, weight: float) -> void:
	var p := clampf(weight, 0, 1)
	# Lean over the near edge of the table, keeping the seated pelvis in place.
	actor.body.position.z = -0.19
	var rest := actor.left_forearm.to_global(Vector3(0, -0.29, 0))
	var grip := raincoat.to_global(Vector3(0, 0.06, 0))
	var hand := rest.lerp(grip, smoothstep(0, 0.16, p))
	if p >= 0.59:
		hand = grip.lerp(rest, smoothstep(0.59, 0.70, p))
	actor.reach_hand(true, hand)
	var right_rest := actor.right_forearm.to_global(Vector3(0, -0.29, 0))
	var edge := flap.to_global(Vector3(0.10, 0.025, -0.18))
	var contact := smoothstep(0.60, 0.72, p) * (1 - smoothstep(0.90, 1, p))
	actor.reach_hand(false, right_rest.lerp(edge, contact))

func pose_snapshot() -> Array:
	return [visible, raincoat.transform, flap.transform]
