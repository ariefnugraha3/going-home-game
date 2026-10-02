class_name CinematicLuggage
extends Node3D

# Luggage placement and webbing sampled by the director, without physics/tweens.
const STRAP_Z := [0.16, -0.16]
const SEAT := Vector3(0, 0.995, 0.82)
const CARRY_FROM := Vector3(-0.82, 0, 1.9)
const CARRY_TO := Vector3(-0.82, 0, 0.75)
const LOAD_GRIPS := [Vector3(0, 0.08, 0.28), Vector3(0, 0.08, -0.28)]
var rigging: Node3D
var bands: Array = []
var tails: Array[MeshInstance3D] = []
var grips: Array[Vector3] = []
var tensions: Array[float] = []
var threaded: Array[bool] = [true, true]

func build() -> void:
	position = SEAT
	LowPoly.box(self, Vector3.ZERO, Vector3(0.78, 0.28, 0.52), Color("66735b"))
	LowPoly.box(self, Vector3(0, 0.145, 0), Vector3(0.78, 0.025, 0.52), Color("758365"))
	rigging = Node3D.new()
	add_child(rigging)
	for z in STRAP_Z:
		var segments: Array[MeshInstance3D] = []
		for i in range(7):
			segments.append(LowPoly.box(rigging, Vector3.ZERO, Vector3.ONE, Color("343d35")))
		bands.append(segments)
		tails.append(LowPoly.box(rigging, Vector3.ZERO, Vector3.ONE, Color("343d35")))
		LowPoly.box(rigging, Vector3(0.41, 0.07, z), Vector3(0.035, 0.07, 0.065), Color("b1b6a0"))
		grips.append(Vector3.ZERO)
		tensions.append(0.0)
	sample(1)

func _segment(mesh: MeshInstance3D, a: Vector3, b: Vector3) -> void:
	var delta := b - a
	# Assign a fresh basis: setting rotation then scale separately decomposes
	# the previous nonuniform basis and accumulates drift on repeated seeks.
	var orientation := Basis(Quaternion(Vector3.UP, delta.normalized()))
	var shape := Basis(orientation.x * 0.032, orientation.y * delta.length(), orientation.z * 0.018)
	mesh.transform = Transform3D(shape, (a + b) * 0.5)

func sample(weight: float) -> void:
	var p := clampf(weight, 0, 1)
	position = SEAT
	rigging.visible = true
	for i in range(2):
		threaded[i] = true
		tails[i].visible = true
		var start := 0.12 if i == 0 else 0.48
		var pull := smoothstep(start, start + 0.12, p)
		var tuck := smoothstep(start + 0.24, start + 0.28, p)
		var z: float = STRAP_Z[i]
		tensions[i] = pull
		var slack := 0.065 * (1 - pull)
		var points := [Vector3(-0.245, -0.24, z), Vector3(-0.405, -0.14, z), Vector3(-0.405, 0.165, z), Vector3(0, 0.165 + slack, z), Vector3(0.405, 0.165, z), Vector3(0.41, 0.07, z), Vector3(0.405, -0.14, z), Vector3(0.245, -0.24, z)]
		for j in range(7):
			_segment(bands[i][j], points[j], points[j + 1])
		grips[i] = Vector3(0.46, 0.01, z).lerp(Vector3(0.52, 0.18, z), pull).lerp(Vector3(0.43, 0, z), tuck)
		_segment(tails[i], Vector3(0.43, 0.07, z), grips[i])

func pose_actor(actor: CinematicActor, weight: float) -> void:
	var p := clampf(weight, 0, 1)
	actor.position = Vector3(-0.82, 0, 0.75)
	actor.rotation = Vector3.ZERO
	actor.sample("walk", 0)
	# Neutral standing legs stay planted while the arms reach the strap tails.
	for i in range(2):
		var forearm := actor.left_forearm if i == 0 else actor.right_forearm
		var rest := forearm.to_global(Vector3(0, -0.29, 0))
		var start := 0.12 if i == 0 else 0.48
		var contact := smoothstep(start - 0.08, start, p) * (1 - smoothstep(start + 0.28, start + 0.36, p))
		actor.reach_hand(i == 0, rest.lerp(to_global(grips[i]), contact))

func sample_loading(actor: CinematicActor, weight: float) -> void:
	var p := clampf(weight, 0, 1)
	sample(0)
	rigging.visible = false
	var walk := smoothstep(0, 0.45, p)
	actor.position = CARRY_TO if walk >= 1 else CARRY_FROM.lerp(CARRY_TO, walk)
	actor.rotation = Vector3.ZERO
	actor.sample("walk", fposmod(walk * 2, 1.0))
	actor.body.position.z = -0.18 * smoothstep(0.45, 0.68, p) * (1 - smoothstep(0.86, 1, p))
	actor.raise_shoulders(0, 0.18 * (1 - smoothstep(0.86, 1, p)))
	var stage: Node3D = actor.get_parent()
	var bike: Node3D = get_parent()
	var carried := stage.to_global(actor.position + Vector3(0, 1.25, -0.58))
	var above := bike.to_global(SEAT + Vector3(0, 0.255, 0))
	var point := carried.lerp(above, smoothstep(0.48, 0.68, p))
	point = point.lerp(bike.to_global(SEAT), smoothstep(0.68, 0.82, p))
	# Avoid a global-coordinate round trip once the bag reaches its stable anchor.
	position = SEAT if p >= 0.82 else bike.to_local(point)
	for i in range(2):
		var hand := actor.left_forearm if i == 0 else actor.right_forearm
		var rest := hand.to_global(Vector3(0, -0.29, 0))
		actor.reach_hand(i == 0, to_global(LOAD_GRIPS[i]).lerp(rest, smoothstep(0.84, 0.96, p)))

func sample_threading(actor: CinematicActor, weight: float) -> void:
	var p := clampf(weight, 0, 1)
	sample(0)
	if p >= 1:
		pose_actor(actor, 0)
		return
	actor.position = CARRY_TO
	actor.rotation = Vector3.ZERO
	actor.sample("walk", 0)
	for i in range(2):
		var t := clampf(p * 2 - i, 0, 1)
		var z: float = STRAP_Z[i]
		var guide := Vector3(0.43, 0.07, z)
		var feed := smoothstep(0.50, 0.75, t)
		var end := Vector3(0.52, 0.25, z).lerp(guide, smoothstep(0.15, 0.50, t))
		grips[i] = end.lerp(Vector3(0.46, 0.01, z), feed)
		# The upper webbing approaches the buckle; the tail emerges only after insertion.
		_segment(bands[i][4], Vector3(0.405, 0.165, z), end.lerp(Vector3(0.41, 0.07, z), feed))
		tails[i].visible = feed > 0.001
		if tails[i].visible:
			_segment(tails[i], guide, grips[i])
		threaded[i] = t >= 0.75
		var hand := actor.left_forearm if i == 0 else actor.right_forearm
		var rest := hand.to_global(Vector3(0, -0.29, 0))
		var contact := smoothstep(0, 0.15, t) * (1 - smoothstep(0.75, 0.95, t))
		actor.reach_hand(i == 0, rest.lerp(to_global(grips[i]), contact))

func pose_snapshot() -> Array:
	var result := [transform, visible, rigging.visible, grips.duplicate(), tensions.duplicate(), threaded.duplicate()]
	for segments in bands:
		for segment in segments:
			result.append(segment.transform)
	for tail in tails:
		result.append([tail.transform, tail.visible])
	return result
