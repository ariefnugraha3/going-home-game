class_name CinematicLuggage
extends Node3D

# Prethreaded luggage straps sampled from the director, without physics/tweens.
const STRAP_Z := [0.16, -0.16]
var bands: Array = []
var tails: Array[MeshInstance3D] = []
var grips: Array[Vector3] = []
var tensions: Array[float] = []

func build() -> void:
	position = Vector3(0, 0.995, 0.82)
	LowPoly.box(self, Vector3.ZERO, Vector3(0.78, 0.28, 0.52), Color("66735b"))
	LowPoly.box(self, Vector3(0, 0.145, 0), Vector3(0.78, 0.025, 0.52), Color("758365"))
	for z in STRAP_Z:
		var segments: Array[MeshInstance3D] = []
		for i in range(7):
			segments.append(LowPoly.box(self, Vector3.ZERO, Vector3.ONE, Color("343d35")))
		bands.append(segments)
		tails.append(LowPoly.box(self, Vector3.ZERO, Vector3.ONE, Color("343d35")))
		LowPoly.box(self, Vector3(0.41, 0.07, z), Vector3(0.035, 0.07, 0.065), Color("b1b6a0"))
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
	for i in range(2):
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

func pose_snapshot() -> Array:
	var result := [transform, visible, grips.duplicate(), tensions.duplicate()]
	for segments in bands:
		for segment in segments:
			result.append(segment.transform)
	for tail in tails:
		result.append(tail.transform)
	return result
