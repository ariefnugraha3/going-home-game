class_name PackingProps
extends Node3D

# A sampled blocking performance: no tweens, reparenting or physics clocks.
const START := Vector3(-0.55, 0.95, -0.05)
const LIFT := Vector3(-0.45, 1.30, -0.08)
const ABOVE := Vector3(-0.05, 1.30, -0.13)
const INSIDE := Vector3(-0.05, 1.02, -0.13)
const SUPPLY_START := [Vector3(-0.72, 0.915, -0.38), Vector3(0.66, 0.935, -0.35), Vector3(0.66, 0.93, -0.09)]
const SUPPLY_INSIDE := [Vector3(-0.15, 0.97, -0.355), Vector3(0.28, 0.99, -0.36), Vector3(0.27, 0.99, -0.17)]
const SUPPLY_SIZE := [Vector3(0.24, 0.05, 0.26), Vector3(0.12, 0.09, 0.14), Vector3(0.14, 0.08, 0.16)]
const PICKUP_OFFSET := Vector3(0, 0.21, 0.38)
const PICKUP_GRIPS := [Vector3(-0.37, 1.12, -0.26), Vector3(0.47, 1.12, -0.26)]
var supplies: Array[Node3D] = []
var raincoat: Node3D
var flap: Node3D

func build() -> void:
	var bag := Node3D.new()
	add_child(bag)
	bag.position = Vector3(0.05, 0.92, -0.26)
	LowPoly.box(bag, Vector3.ZERO, Vector3(0.78, 0.05, 0.52), Color("46523f"))
	for x in [-0.375, 0.375]:
		LowPoly.box(bag, Vector3(x, 0.12, 0), Vector3(0.03, 0.24, 0.52), Color("66735b"))
	for z in [-0.245, 0.245]:
		LowPoly.box(bag, Vector3(0, 0.12, z), Vector3(0.78, 0.24, 0.03), Color("66735b"))
	for i in range(3):
		var item := Node3D.new()
		add_child(item)
		supplies.append(item)
		LowPoly.box(item, Vector3.ZERO, SUPPLY_SIZE[i], [Color("bdad8a"), Color("344347"), Color("8b6149")][i])
	# Fold edges, a bundled charging lead, and the tool roll's two retaining bands.
	for z in [-0.10, 0.10]:
		LowPoly.box(supplies[0], Vector3(0, 0.018, z), Vector3(0.23, 0.012, 0.02), Color("d1c4a5"))
	for x in [-0.04, 0.04]:
		LowPoly.box(supplies[1], Vector3(x, 0.044, 0), Vector3(0.009, 0.008, 0.10), Color("86928d"))
	for z in [-0.045, 0.045]:
		LowPoly.box(supplies[1], Vector3(0, 0.044, z), Vector3(0.08, 0.008, 0.009), Color("86928d"))
	for x in [-0.045, 0.045]:
		LowPoly.box(supplies[2], Vector3(x, 0.038, 0), Vector3(0.014, 0.008, 0.16), Color("453e32"))
	flap = Node3D.new()
	bag.add_child(flap)
	flap.position = Vector3(0, 0.25, 0.26)
	LowPoly.box(flap, Vector3(0, 0, -0.26), Vector3(0.78, 0.025, 0.52), Color("758365"))
	for x in [-0.18, 0.18]:
		LowPoly.box(flap, Vector3(x, 0.02, -0.26), Vector3(0.055, 0.025, 0.52), Color("343d35"))
	raincoat = Node3D.new()
	add_child(raincoat)
	LowPoly.box(raincoat, Vector3.ZERO, Vector3(0.24, 0.10, 0.18), Color("bb974f"))
	LowPoly.box(raincoat, Vector3(0, 0.054, 0), Vector3(0.04, 0.008, 0.18), Color("e2cf8c"))
	sample(0)

func sample(weight: float) -> void:
	var p := clampf(weight, 0, 1)
	position = Vector3.ZERO
	for i in range(supplies.size()):
		supplies[i].position = SUPPLY_INSIDE[i]
	if p < 0.30:
		raincoat.position = START.lerp(LIFT, smoothstep(0.16, 0.30, p))
	elif p < 0.44:
		raincoat.position = LIFT.lerp(ABOVE, smoothstep(0.30, 0.44, p))
	else:
		raincoat.position = ABOVE.lerp(INSIDE, smoothstep(0.44, 0.59, p))
	flap.rotation.x = lerpf(1.85, 0, smoothstep(0.72, 0.90, p))

func sample_supplies(actor: CinematicActor, index: int, weight: float) -> void:
	# Each insert samples every item, including already packed and waiting supplies.
	sample(0)
	var active := clampi(index, 0, 2)
	var p := clampf(weight, 0, 1)
	var progress := active + p
	for i in range(3):
		var t := clampf(progress - i, 0, 1)
		var start: Vector3 = SUPPLY_START[i]
		var end: Vector3 = SUPPLY_INSIDE[i]
		var lifted := Vector3(start.x, 1.34, start.z)
		var above := Vector3(end.x, 1.34, end.z)
		var point := start.lerp(lifted, smoothstep(0.18, 0.35, t))
		point = point.lerp(above, smoothstep(0.35, 0.60, t))
		supplies[i].position = point.lerp(end, smoothstep(0.60, 0.78, t))
	actor.sample("rest", 0)
	# Editorial seat changes keep the head beside the upright flap and grips in reach.
	actor.position = Vector3(-0.65 if active == 0 else 0.72, 0, 0.25)
	actor.body.position = Vector3(0, 0, -0.24)
	var hand: Node3D = actor.right_forearm if active == 0 else actor.left_forearm
	var rest := hand.to_global(Vector3(0, -0.29, 0))
	var grip := supplies[active].to_global(Vector3(0, SUPPLY_SIZE[active].y * 0.5 + 0.006, 0))
	var contact := smoothstep(0, 0.18, p) * (1 - smoothstep(0.78, 0.94, p))
	actor.reach_hand(active != 0, rest.lerp(grip, contact))

func sample_pickup(actor: CinematicActor, laptop: CinematicLaptop, weight: float) -> void:
	var p := clampf(weight, 0, 1)
	sample(1)
	# Lift vertically before drawing the closed bag past the table edge.
	position = Vector3(0, PICKUP_OFFSET.y * smoothstep(0.28, 0.50, p), PICKUP_OFFSET.z * smoothstep(0.52, 0.75, p))
	laptop.position = CinematicLaptop.INSIDE + position
	laptop.lid.rotation.x = PI / 2
	laptop.screen.visible = false
	actor.position = Vector3(0.05, 0, 0.6)
	actor.rotation = Vector3.ZERO
	actor.sample("walk", 0)
	var reach := smoothstep(0, 0.22, p)
	var upright := smoothstep(0.52, 0.75, p)
	actor.body.position.z = -0.18 * reach * (1 - upright)
	actor.raise_shoulders(0, lerpf(0.27, 0.05, upright) * reach)
	for i in range(2):
		var hand := actor.left_forearm if i == 0 else actor.right_forearm
		var rest := hand.to_global(Vector3(0, -0.29, 0))
		actor.reach_hand(i == 0, rest.lerp(to_global(PICKUP_GRIPS[i]), reach))

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
	return [transform, visible, raincoat.transform, flap.transform, supplies.map(func(item): return item.transform)]
