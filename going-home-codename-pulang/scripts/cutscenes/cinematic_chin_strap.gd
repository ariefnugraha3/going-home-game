class_name CinematicChinStrap
extends Node3D

# Reusable blocking webbing and two buckle halves, in head coordinates.
const WORN := Vector3(0, 0.26, 0.015)
var bands: Array[MeshInstance3D] = []
var buckles: Array[MeshInstance3D] = []
var tail: MeshInstance3D
var ends: Array[Vector3] = [Vector3.ZERO, Vector3.ZERO]
var tail_end := Vector3.ZERO

func build() -> void:
	for i in range(2):
		for segment in range(3):
			bands.append(LowPoly.cylinder(self, Vector3.ZERO, 0.012, 1, Color("29312e"), -1, 6))
		buckles.append(LowPoly.box(self, Vector3.ZERO, Vector3(0.032, 0.035, 0.024), Color("a9b5b0")))
	tail = LowPoly.cylinder(self, Vector3.ZERO, 0.009, 1, Color("29312e"), -1, 6)
	sample(1)

func sample(closure: float, pull: float = 0) -> void:
	for i in range(2):
		var side := -1.0 if i == 0 else 1.0
		ends[i] = Vector3(side * 0.20, -0.17, -0.24).lerp(Vector3(side * 0.016, -0.035, -0.20), closure)
		var points := [Vector3(side * 0.19, 0.23, 0.015), Vector3(side * 0.20, 0.065, -0.07), Vector3(side * 0.16, -0.025, -0.19).lerp(Vector3(side * 0.11, -0.04, -0.18), closure), ends[i]]
		for segment in range(3):
			_segment(bands[i * 3 + segment], points[segment], points[segment + 1])
		buckles[i].position = ends[i]
	tail_end = ends[1] + Vector3(0.045 + pull * 0.08, -0.06 - pull * 0.035, 0)
	_segment(tail, ends[1], tail_end)

func _segment(mesh: MeshInstance3D, from: Vector3, to: Vector3) -> void:
	var direction := to - from
	var basis := Basis(Quaternion(Vector3.UP, direction.normalized()))
	basis.y *= direction.length()
	mesh.transform = Transform3D(basis, (from + to) * 0.5)

func sample_resting(unfold: float) -> void:
	# Keep loose webbing folded above the seat until the lifted helmet clears it.
	sample(0)
	for band in bands:
		var from := band.transform * Vector3(0, -0.5, 0)
		var to := band.transform * Vector3(0, 0.5, 0)
		_segment(band, _fold(from, unfold), _fold(to, unfold))
	for i in range(2):
		ends[i] = _fold(ends[i], unfold)
		buckles[i].position = ends[i]
	tail_end = _fold(tail_end, unfold)
	_segment(tail, ends[1], tail_end)

func _fold(point: Vector3, unfold: float) -> Vector3:
	return Vector3(point.x, maxf(point.y, 0.16), point.z).lerp(point, unfold)

func snapshot() -> Array:
	var state := [transform, visible, ends.duplicate(), tail_end]
	for band in bands:
		state.append(band.transform)
	for buckle in buckles:
		state.append(buckle.transform)
	state.append(tail.transform)
	return state

static func pose_actor(actor: CinematicActor, bike: Node3D, progress: float) -> void:
	var p := clampf(progress, 0, 1)
	CinematicMount.sample(actor, bike, 0)
	var strap := actor.chin_strap
	var resting := [actor.left_forearm.to_global(Vector3(0, -0.29, 0)), actor.right_forearm.to_global(Vector3(0, -0.29, 0))]
	var pull := smoothstep(0.54, 0.66, p) * (1.0 - smoothstep(0.70, 0.82, p))
	strap.sample(smoothstep(0.25, 0.50, p), pull)
	if p > 0 and p < 1:
		for i in range(2):
			var target: Vector3 = strap.ends[i]
			if i == 1:
				target = target.lerp(strap.tail_end, smoothstep(0.50, 0.54, p))
			var hand: Vector3 = resting[i].lerp(strap.to_global(target), smoothstep(0.06, 0.25, p))
			actor.reach_hand(i == 0, hand.lerp(resting[i], smoothstep(0.82, 1.0, p)))
