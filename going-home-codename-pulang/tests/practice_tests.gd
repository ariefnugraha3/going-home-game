extends "res://tests/test_runner.gd"

func _ready() -> void:
	visual_test = "--visual" in OS.get_cmdline_user_args()
	var target_fps := 30 if "--limit-30" in OS.get_cmdline_user_args() else 60
	Engine.max_fps = target_fps if visual_test else 0
	GameState.settings.fps_limit = target_fps
	GameState.new_journey()
	GameState.settings.riding_assist = true
	GameState.settings.reduced_motion = true
	GameState.set_flag("test.practice.preserved", true)
	SaveManager.save_game()
	var before := GameState.snapshot()
	var file_before := FileAccess.get_file_as_string(SaveManager.SAVE_PATH)
	app = preload("res://scenes/practice/RidingPractice.tscn").instantiate()
	add_child(app)
	await frames(5)
	check(app.bike.route.practice, "Practice bike uses the authored practice route")
	check(app.world.definition.sections.size() == 7, "All seven riding sections are available")
	check(app.world.route.sample(450).y > 3.9, "Track has a physical four-meter rise")
	check(app.world.route.sample(554).y > 0.1, "Track includes authored small bumps")
	check(absf(app.world.route.heading(255)) > 0.5, "Tighter bend has a distinct steering angle")
	await capture("practice_start")
	# Drive every meter under physics, rather than jumping between story stops.
	Input.action_press("accelerate", 0.45)
	var max_offset := 0.0
	var finite := true
	var max_height_error := 0.0
	var budget := 15000
	var captured_curve := false
	while -app.bike.position.z < 680 and budget > 0:
		await get_tree().physics_frame
		budget -= 1
		var center: Vector3 = app.world.route.sample(-app.bike.position.z)
		max_offset = maxf(max_offset, absf(app.bike.position.x - center.x))
		max_height_error = maxf(max_height_error, absf(app.bike.position.y - center.y))
		finite = finite and app.bike.position.is_finite() and is_finite(app.bike.speed_mps)
		if visual_test and not captured_curve and -app.bike.position.z > 245:
			captured_curve = true
			await capture("practice_curve")
	Input.action_release("accelerate")
	check(budget > 0, "Continuous assisted ride reaches the stop area")
	check(finite, "All physics state stays finite through the full track")
	check(max_offset < 4.8, "Assisted bike follows bends inside the paved road")
	check(max_height_error < 0.6, "Bike follows rise, descent and bumps without a large jump")
	check(app.metrics.recoveries == 0, "Full-track ride needs no automatic recovery")
	check(app.metrics.max_roll_degrees == 0, "Reduced motion keeps camera roll at zero")
	Input.action_press("brake")
	await frames(150)
	Input.action_release("brake")
	check(app.bike.speed_mps < 0.1, "Bike brakes to a complete stop near the shelter")
	await get_tree().process_frame
	app._on_action("interact")
	check(app.resting and not app.bike.enabled, "Stop interaction switches engine off")
	await capture("practice_rest")
	app.start_section("tight_curve")
	check(not app.resting and app.bike.enabled, "Section selection restores riding after a rest")
	var before_jump: float = app.metrics.distance_meters
	app.start_section("slope")
	await frames(4)
	check(app.metrics.distance_meters - before_jump < 1, "Section jumps are excluded from ridden distance")
	app._pause()
	var paused_seconds: float = app.metrics.riding_seconds
	var paused_position: Vector3 = app.bike.position
	Input.action_press("accelerate")
	await frames(20)
	check(app.bike.position == paused_position and app.metrics.riding_seconds == paused_seconds, "Pause freezes physics and session timing")
	app._resume()
	check(not Input.is_action_pressed("accelerate"), "Resume releases stale throttle input")
	# Deliberately approach the solid barrier in the right lane.
	GameState.settings.riding_assist = false
	app.bike.teleport(641, 3)
	app.metrics.reset_position()
	Input.action_press("accelerate")
	await frames(300)
	Input.action_release("accelerate")
	check(app.metrics.contacts >= 1, "Solid obstacle reports contact")
	check(app.bike.position.z > -650 and app.bike.speed_mps < 1, "Collision stops bike without tunneling or continued road speed")
	app._on_action("recover")
	check(app.bike.speed_mps == 0 and app.bike.steering == 0, "Recovery clears speed and steering")
	check(absf(app.bike.position.x - app.world.route.sample(-app.bike.position.z).x + 2.5) < 0.01, "Recovery returns to the left lane of the active track")
	app.bike.position.y = -8
	await frames(3)
	check(app.bike.position.y > -1, "Fallen bike recovers safely")
	GameState.settings.riding_assist = false
	GameState.settings.reduced_motion = false
	app.start_section("straight")
	Input.action_press("accelerate")
	await frames(180)
	Input.action_press("steer_right")
	await frames(25)
	InputModeManager.release_riding()
	check(app.bike.rotation.y < -0.05, "Steering works with riding assist disabled")
	check(absf(app.bike.lean.rotation.z) < 0.03, "Normal camera lean remains limited")
	app._pause()
	app.ui.show_settings()
	await capture("practice_settings")
	app._on_action("weather")
	await frames(180)
	check(app.world.wet and AudioManager.rain_target == 1, "Practice weather switch controls rain and ambience")
	app._pause()
	app.ui.show_sections()
	await capture("practice_sections")
	app._resume()
	GameState.settings.touch = true
	await frames(4)
	await capture("practice_touch")
	GameState.settings.touch = false
	app.bike.stop()
	var report_path: String = app.metrics.save_report()
	check(not report_path.is_empty() and FileAccess.file_exists(report_path), "Local playtest report is written")
	var report: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(report_path))
	check(report.distance_meters > 650 and report.recent_frame_count <= 900, "Report captures ridden distance with bounded frame samples")
	check(report.human_comfort_review == "Not assessed by this report", "Report distinguishes metrics from human comfort review")
	check(GameState.snapshot() == before, "Practice never changes story, journal, phone or bike save state")
	check(FileAccess.get_file_as_string(SaveManager.SAVE_PATH) == file_before, "Practice never overwrites the journey save file")
	get_tree().paused = false
	app.queue_free()
	await frames(3)
	check(not AudioManager.engine_active and AudioManager.rain_target == 0, "Leaving practice clears engine and weather audio state")
	# Keep the test harness alive while exercising actual scene replacements.
	get_tree().current_scene = null
	var menu := preload("res://scenes/boot/Boot.tscn").instantiate()
	get_tree().root.add_child(menu)
	get_tree().current_scene = menu
	await frames(3)
	await capture("practice_menu_entry")
	menu._on_action("practice")
	var current: Node = await wait_for_scene("res://scenes/practice/RidingPractice.tscn")
	if current == null:
		return
	check(current.scene_file_path == "res://scenes/practice/RidingPractice.tscn", "Title menu opens the practice scene")
	current._pause()
	current._on_action("menu")
	current = await wait_for_scene("res://scenes/boot/Boot.tscn")
	if current == null:
		return
	check(current.scene_file_path == "res://scenes/boot/Boot.tscn" and not get_tree().paused, "Leaving paused practice restores the title menu")
	check(FileAccess.get_file_as_string(SaveManager.SAVE_PATH) == file_before and SaveManager.has_save(), "Journey remains available after a complete menu round trip")
	get_tree().current_scene = null
	current.queue_free()
	await frames(3)
	print("PRACTICE RESULT: %d checks, %d failures" % [checks, failures])
	print("TRACK METRICS: max lateral offset %.3f m; max height error %.3f m" % [max_offset, max_height_error])
	get_tree().quit(1 if failures else 0)

func wait_for_scene(path: String) -> Node:
	# Scene replacement completes at a render-frame boundary, not after a fixed
	# number of physics ticks (there can be several ticks per frame at 30 FPS).
	for step in range(120):
		await get_tree().process_frame
		var current := get_tree().current_scene
		if is_instance_valid(current) and current.scene_file_path == path:
			return current
	check(false, "Scene replacement completes: " + path)
	get_tree().quit(1)
	return null
