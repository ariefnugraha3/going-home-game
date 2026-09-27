extends "res://tests/test_runner.gd"

func _ready() -> void:
	visual_test = "--visual" in OS.get_cmdline_user_args()
	Engine.max_fps = 30 if visual_test else 0
	GameState.settings = GameState.DEFAULT_SETTINGS.duplicate(true)
	GameState.new_journey()
	SaveManager.save_game()
	var saved := FileAccess.get_file_as_string(SaveManager.SAVE_PATH)
	var readings := []
	var camera := Camera3D.new()
	camera.fov = 70
	camera.rotation.x = -.14
	add_child(camera)
	camera.make_current()
	for practice in [false, true]:
		var world: RoadWorld = PracticeWorld.new() if practice else RoadWorld.new()
		add_child(world)
		world.build(false)
		world.set_process(false)
		_verify_markings(world, practice)
		var resource: WeakRef = weakref(world.marking_batches[0].multimesh)
		for quality in [0, 1]:
			GameState.settings.quality = quality
			world._process(0)
			await frames(4)
			check(world.sun.shadow_enabled == (quality > 0), "Render probe applies requested quality")
			for distance in ([20.0, 260.0, 650.0] if practice else [20.0, 650.0, 1100.0]):
				var route := RidingRoute.new()
				route.practice = practice
				camera.position = route.sample(distance) + Vector3(-2.5, 1.75, .4)
				camera.rotation.y = route.heading(distance)
				await frames(4)
				if visual_test:
					await RenderingServer.frame_post_draw
					var calls := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
					readings.append({"practice": practice, "quality": quality, "distance": distance, "draw_calls": calls})
					check(calls > 0, "Native renderer measured draw calls: " + str(readings.back()))
					await capture("road_render_%s_%d_%d" % ["practice" if practice else "story", quality, int(distance)])
		world.queue_free()
		await frames(4)
		check(not is_instance_valid(world), "World is released after render probes")
		check(resource.get_ref() == null, "Unloading world releases its MultiMesh resource")
		LowPoly.materials.clear()
	var baseline_nodes := get_tree().get_node_count()
	for cycle in range(4):
		var world: RoadWorld = PracticeWorld.new() if cycle % 2 == 0 else RoadWorld.new()
		add_child(world)
		world.build(false)
		var mesh: WeakRef = weakref(world.marking_batches[0].multimesh.mesh)
		var batch: WeakRef = weakref(world.marking_batches[0].multimesh)
		# Let the native renderer finish sky/resource initialization before
		# disposing a newly constructed world, as an actual scene visit does.
		await frames(4)
		if visual_test:
			await RenderingServer.frame_post_draw
		world.queue_free()
		await frames(4)
		if visual_test:
			await RenderingServer.frame_post_draw
		LowPoly.materials.clear()
		check(get_tree().get_node_count() == baseline_nodes and mesh.get_ref() == null and batch.get_ref() == null, "Repeated world disposal restores node count and frees marking resources: " + str(cycle))
	if visual_test:
		var file := FileAccess.open("user://road_render.json", FileAccess.WRITE)
		file.store_string(JSON.stringify(readings, "\t"))
		file.close()
	check(FileAccess.get_file_as_string(SaveManager.SAVE_PATH) == saved, "Rendering probes leave story checkpoint unchanged")
	camera.queue_free()
	await frames(2)
	print("ROAD RENDER TEST RESULT: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)

func _verify_markings(world: RoadWorld, practice: bool) -> void:
	var expected := {"CenterMarkings": [], "EdgeMarkings": []}
	if practice:
		var route := RidingRoute.new()
		route.practice = true
		for d in range(0, 720, 8):
			expected.CenterMarkings.append(Transform3D(Basis(Vector3.UP, route.heading(d)), route.sample(d) + Vector3(0, .025, -1)))
	else:
		for i in range(-2, 154):
			var d := i * 12.0
			expected.CenterMarkings.append(Transform3D(Basis(Vector3.UP, RoadWorld.heading(d)), RoadWorld.center(d) + Vector3(0, .026, -2.5)))
			for side in [-1, 1]:
				expected.EdgeMarkings.append(Transform3D(Basis(Vector3.UP, RoadWorld.heading(d)), RoadWorld.center(d) + Vector3(side * 4.6, .022, -6)))
	var count := 0
	var geometry_matches := true
	var culling_safe := true
	var dimensions_match := true
	var meshes := {}
	for batch in world.marking_batches:
		var kind: String = batch.get_meta("marking_kind")
		var mesh: BoxMesh = batch.multimesh.mesh
		var size := Vector3(.12, .02, 2) if practice else (Vector3(.13, .016, 4) if kind == "CenterMarkings" else Vector3(.13, .014, 12.3))
		dimensions_match = dimensions_match and mesh.size.is_equal_approx(size)
		if meshes.has(kind):
			dimensions_match = dimensions_match and meshes[kind] == mesh
		meshes[kind] = mesh
		count += batch.multimesh.instance_count
		# The headless Dummy backend returns identity instance transforms.
		# GPU-buffer readback and culling extents require the native suite.
		if not visual_test:
			continue
		for i in range(batch.multimesh.instance_count):
			var local := batch.multimesh.get_instance_transform(i)
			var pose := batch.transform * local
			var found := false
			for j in range(expected[kind].size()):
				if pose.is_equal_approx(expected[kind][j]):
					expected[kind].remove_at(j)
					found = true
					break
			geometry_matches = geometry_matches and found
			culling_safe = culling_safe and local.origin.length() <= RoadMarkings.CHUNK_LENGTH and batch.visibility_range_end >= (180 if practice else 220) + local.origin.length()
	check(count == (90 if practice else 468), "Batching retains every authored marking exactly once")
	if visual_test:
		check(geometry_matches and expected.CenterMarkings.is_empty() and expected.EdgeMarkings.is_empty(), "All marking transforms match original placement, including slopes and bends")
	check(dimensions_match, "Instances share meshes while preserving original box dimensions")
	check(world.marking_batches.size() == (8 if practice else 42), "Marking render nodes reduce to bounded 96-meter chunks")
	if visual_test:
		check(culling_safe, "Chunk visibility margin protects original per-mark visibility range")
	check(world.marking_batches.all(func(batch): return batch.get_child_count() == 0), "Visual marking batches add no collision objects")
