class_name RoadMarkings
extends RefCounted

const CHUNK_LENGTH := 96.0

static func build(parent: Node3D, transforms: Array[Transform3D], size: Vector3, color: Color, distance: float, kind: String) -> Array[MultiMeshInstance3D]:
	var groups := {}
	for pose in transforms:
		var chunk := floori(-pose.origin.z / CHUNK_LENGTH)
		if not groups.has(chunk):
			groups[chunk] = []
		groups[chunk].append(pose)
	var mesh := BoxMesh.new()
	mesh.size = size
	var result: Array[MultiMeshInstance3D] = []
	for chunk in groups:
		var poses: Array = groups[chunk]
		var origin := Vector3.ZERO
		for pose in poses:
			origin += pose.origin
		origin /= poses.size()
		var instances := MultiMesh.new()
		instances.transform_format = MultiMesh.TRANSFORM_3D
		instances.mesh = mesh
		instances.instance_count = poses.size()
		for i in range(poses.size()):
			var local: Transform3D = poses[i]
			local.origin -= origin
			instances.set_instance_transform(i, local)
		var node := MultiMeshInstance3D.new()
		node.name = kind + "_" + str(chunk)
		node.set_meta("marking_kind", kind)
		node.position = origin
		node.multimesh = instances
		node.material_override = LowPoly.material(color)
		# Culling is per chunk. Extra distance prevents a nearby individual mark
		# disappearing because its chunk's center is farther from the camera.
		node.visibility_range_end = distance + CHUNK_LENGTH
		parent.add_child(node)
		result.append(node)
	return result
