extends "res://tests/test_runner.gd"

const BOOT := "res://scenes/boot/Boot.tscn"
const PRACTICE := "res://scenes/practice/RidingPractice.tscn"
var readings: Array[Dictionary] = []
var retained: Array[WeakRef] = []
var cycles := 3

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visual_test = "--visual" in OS.get_cmdline_user_args()
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--soak-cycles="):
			cycles = clampi(argument.get_slice("=", 1).to_int(), 1, 100)
	GameState.settings = GameState.DEFAULT_SETTINGS.duplicate(true)
	GameState.settings.touch = true
	GameState.settings.fps_limit = 30
	Engine.max_fps = 30 if visual_test else 0
	GameState.new_journey()
	SaveManager.save_game()
	# Keep this harness outside current_scene while the real application replaces it.
	get_tree().current_scene = null
	await _drain()
	var baseline := _sample(-1, "empty")
	for cycle in range(cycles):
		GameState.settings.quality = cycle % 2
		check(get_tree().change_scene_to_file(BOOT) == OK, "Boot scene can be loaded")
		app = await _wait_scene(BOOT)
		if app == null:
			break
		if not await _practice_round_trip():
			break
		await _story_round_trip()
		# Exercise a genuine scene replacement after story completion, not just
		# a manually constructed world. All watched story resources must expire.
		if not await _practice_round_trip():
			break
		check(retained.all(func(reference: WeakRef): return reference.get_ref() == null), "Replaced story worlds, cinematic stages, UI and marking meshes are released")
		retained.clear()
		_sample(cycle, "menu")
		_watch_scene()
		get_tree().current_scene = null
		app.queue_free()
		app = null
		await _drain()
		var after := _sample(cycle, "empty")
		check(after.nodes == baseline.nodes and after.orphan_nodes == baseline.orphan_nodes, "Cycle %d returns live and orphan node counts to baseline" % cycle)
		check(after.connections == baseline.connections, "Cycle %d releases singleton and viewport signal subscriptions" % cycle)
		check(after.material_cache == 0 and retained.all(func(reference: WeakRef): return reference.get_ref() == null), "Cycle %d releases scene resources and the procedural material cache" % cycle)
		check(after.audio_players == baseline.audio_players and after.audio_buses == baseline.audio_buses, "Cycle %d retains only the original shared audio pool" % cycle)
		check(_input_clear() and not get_tree().paused and not AudioManager.engine_active and AudioManager.current_cue.is_empty(), "Cycle %d leaves no held controls, pause, engine or music cue" % cycle)
		retained.clear()
	var file := FileAccess.open("user://lifecycle_report.json", FileAccess.WRITE)
	check(file != null, "Lifecycle report opens in isolated test storage")
	if file != null:
		var report := {"engine": Engine.get_version_info().string, "backend": DisplayServer.get_name(), "native_rendering": visual_test, "cycles": cycles, "checks": checks, "failures": failures, "samples": readings, "scope": "Accelerated scene-transition regression; memory counters are observations, not OS/GPU leak or target-platform acceptance."}
		file.store_string(JSON.stringify(report, "\t"))
		file.close()
	print("LIFECYCLE RESULT: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)

func _practice_round_trip() -> bool:
	var checkpoint := FileAccess.get_file_as_string(SaveManager.SAVE_PATH)
	var snapshot := GameState.snapshot()
	var old_scene: WeakRef = weakref(app)
	app._on_action("practice")
	app = await _wait_scene(PRACTICE)
	if app == null:
		return false
	check(old_scene.get_ref() == null, "Practice replaces and frees the story root")
	var old_world: WeakRef = weakref(app.world)
	var old_mesh: WeakRef = weakref(app.world.marking_batches[0].multimesh)
	app._on_action("atmosphere:heavy_rain")
	app.start_section("tight_curve")
	await _drain()
	app.ui.touch._update_finger(0, app.ui.touch.zones.accelerate.get_center())
	app.ui.touch._update_finger(1, app.ui.touch.zones.steer_left.get_center())
	check(Input.is_action_pressed("accelerate") and Input.is_action_pressed("steer_left"), "Practice receives two held riding touches before backgrounding")
	get_tree().root.propagate_notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	await _drain()
	check(get_tree().paused and _input_clear() and AudioManager.focus_suspended, "Backgrounding practice pauses, suspends audio and releases riding controls")
	get_tree().root.propagate_notification(NOTIFICATION_APPLICATION_FOCUS_IN)
	check(get_tree().paused and not AudioManager.focus_suspended, "Foregrounding restores audio focus while awaiting explicit Resume")
	app._resume()
	app._pause()
	app.ui.show_settings()
	await _drain()
	app._on_action("menu")
	app = await _wait_scene(BOOT)
	if app == null:
		return false
	check(old_world.get_ref() == null and old_mesh.get_ref() == null, "Leaving paused practice releases its world and MultiMesh")
	check(not get_tree().paused and app.state == "menu" and _input_clear(), "Practice returns to an unpaused title with released input")
	check(GameState.snapshot() == snapshot and FileAccess.get_file_as_string(SaveManager.SAVE_PATH) == checkpoint, "Practice and settings round trip preserve story memory and checkpoint bytes")
	return true

func _story_round_trip() -> void:
	_watch_scene()
	app._on_action("new_confirmed")
	await settle()
	_watch_stage()
	app._pause()
	app._on_action("menu")
	await _drain()
	check(app.state == "menu" and not get_tree().paused and app.director.room == null and app.director.sound.pending.is_empty(), "Returning from a paused opening clears the stage and cinematic audio")
	app._on_action("continue")
	await settle()
	check(app.director.active_id == "morning", "Continue replays the stable opening checkpoint after interruption")
	_watch_stage()
	app._on_action("skip")
	await settle()
	check(app.state == "riding" and app.commute, "Opening skip hands off to the city world")
	_watch_world()
	app.bike.teleport(310)
	await settle()
	check(app.director.active_id == "office", "Commute arrival opens the meeting stage")
	_watch_stage()
	app._on_action("skip")
	complete_dialogue(0)
	await settle()
	check(app.director.active_id == "signout", "Meeting dialogue hands off to sign-out")
	_watch_stage()
	app._on_action("skip")
	await settle()
	check(app.director.active_id == "night", "Sign-out hands off to the apartment")
	_watch_stage()
	app._on_action("skip")
	complete_dialogue(1)
	await settle()
	check(app.director.active_id == "departure", "Mother's call hands off to departure")
	_watch_stage()
	app._on_action("skip")
	await settle()
	check(app.state == "riding" and not app.commute and app.director.room == null, "Departure frees the cinematic stage and opens Karawang")
	_watch_world()
	app.bike.teleport(1130)
	await _drain()
	app._on_action("interact")
	complete_dialogue(0)
	check(GameState.checkpoint == "warung", "Shelter commits a stable checkpoint")
	app._on_action("phone")
	await _drain()
	check(get_tree().paused and app.ui.mode == "phone", "Phone can open after all scene handoffs")
	app._resume()
	app.bike.teleport(1700)
	await _drain()
	app._on_action("interact")
	complete_dialogue(0)
	check(app.state == "reflection" and AudioManager.current_cue == "first_night", "Guesthouse opens reflection and first-night music")
	app._journal_selected("tea", "Someone made tea. I didn't have to explain much.")
	var checkpoint := FileAccess.get_file_as_string(SaveManager.SAVE_PATH)
	app._on_action("menu")
	check(AudioManager.current_cue.is_empty(), "Returning to the title stops first-night music")
	app._on_action("continue")
	await settle()
	await _drain()
	check(app.state == "complete" and not app.bike.enabled and AudioManager.current_cue.is_empty(), "Continue restores the ending without riding or replaying music")
	check(FileAccess.get_file_as_string(SaveManager.SAVE_PATH) == checkpoint, "Completed checkpoint restore leaves save bytes unchanged")
	_watch_world()
	app._on_action("menu")
	await _drain()

func _watch_scene() -> void:
	retained.append(weakref(app))
	retained.append(weakref(app.ui))
	retained.append(weakref(app.bike))
	retained.append(weakref(app.director))
	_watch_world()

func _watch_world() -> void:
	retained.append(weakref(app.world))
	retained.append(weakref(app.world.marking_batches[0].multimesh))
	retained.append(weakref(app.world.marking_batches[0].multimesh.mesh))

func _watch_stage() -> void:
	retained.append(weakref(app.director.room))
	var meshes: Array[Node] = app.director.room.find_children("*", "MeshInstance3D", true, false)
	if not meshes.is_empty():
		retained.append(weakref(meshes[0].mesh))

func _input_clear() -> bool:
	for action in ["accelerate", "brake", "steer_left", "steer_right", "look_left", "look_right", "look_up", "look_down"]:
		if Input.is_action_pressed(action):
			return false
	return true

func _drain() -> void:
	# Flush deferred UI deletion and allow native sky/mesh initialization before
	# disposal. Fixed physics ticks alone may all occur in a single render frame.
	for step in range(6):
		await get_tree().process_frame
	if visual_test:
		await RenderingServer.frame_post_draw

func _wait_scene(path: String) -> Node:
	for step in range(120):
		await get_tree().process_frame
		var current := get_tree().current_scene
		if is_instance_valid(current) and current.scene_file_path == path:
			await _drain()
			return current
	check(false, "Scene replacement completes: " + path)
	return null

func _sample(cycle: int, phase: String) -> Dictionary:
	var connections := {}
	for owner in [GameState, SaveManager, InputModeManager, AudioManager, DialogueManager, get_viewport()]:
		for signal_info in owner.get_signal_list():
			var count: int = owner.get_signal_connection_list(signal_info.name).size()
			if count > 0:
				connections[str(owner.name) + "." + str(signal_info.name)] = count
	var sample := {"cycle": cycle, "phase": phase, "quality": GameState.settings.quality, "nodes": get_tree().get_node_count(), "orphan_nodes": int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)), "objects": int(Performance.get_monitor(Performance.OBJECT_COUNT)), "resources": int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)), "static_memory_bytes": OS.get_static_memory_usage(), "material_cache": LowPoly.materials.size(), "connections": connections, "audio_players": AudioManager.get_child_count(), "audio_buses": AudioServer.bus_count}
	# Native Compatibility counters can be unavailable/zero; do not interpret
	# them as OS working-set or as a portable GPU memory budget.
	if visual_test:
		sample["renderer_video_memory_bytes"] = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED)
	readings.append(sample)
	return sample
