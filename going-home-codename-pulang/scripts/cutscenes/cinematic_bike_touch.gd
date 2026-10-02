class_name CinematicBikeTouch
extends Node3D

var tank: MeshInstance3D
var cloth: Node3D
var surface_point := Vector3.ZERO
var surface_normal := Vector3.UP

func build(tank_mesh: MeshInstance3D) -> void:
	tank = tank_mesh
	cloth = Node3D.new()
	add_child(cloth)
	LowPoly.box(cloth, Vector3.ZERO, Vector3(0.16, 0.012, 0.14), Color("d6c7a5"))
	LowPoly.box(cloth, Vector3(0, 0.008, 0), Vector3(0.025, 0.004, 0.14), Color("a89979"))
	reset()

func reset() -> void:
	cloth.visible = false
	cloth.transform = Transform3D.IDENTITY
	surface_point = Vector3.ZERO
	surface_normal = Vector3.UP

func sample(actor: CinematicActor, weight: float) -> void:
	var p := clampf(weight, 0, 1)
	actor.position = Vector3(0, 0, 0.50)
	actor.rotation = Vector3.ZERO
	actor.sample("walk", 0)
	# Follow the sculpted tank triangles, away from its cap.
	# The rigid cloth is blocking geometry, not simulated or deforming fabric.
	var z := -0.30 * cos(TAU * smoothstep(0.22, 0.70, p))
	var q := Vector3(0.72, sqrt(1 - 0.72 * 0.72 - z * z), z)
	var contact_frame := BikeForms.tank_contact(tank,q)
	surface_point = contact_frame.origin
	surface_normal = contact_frame.basis.y
	var rest := actor.right_forearm.to_global(Vector3(0, -0.29, 0))
	var contact := smoothstep(0.06, 0.22, p) * (1 - smoothstep(0.82, 1, p))
	var hand := rest.lerp(surface_point + surface_normal * 0.065, contact)
	actor.reach_hand(false, hand)
	cloth.visible = true
	var normal := global_basis.inverse() * surface_normal
	cloth.transform = Transform3D(Basis(Quaternion(Vector3.UP, normal.normalized())), to_local(hand - surface_normal * 0.055))

func pose_snapshot() -> Array:
	return [cloth.visible, cloth.transform]
