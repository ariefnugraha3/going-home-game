extends "res://tests/test_runner.gd"

# Acceptance automation uses the public menu buttons and riding input. It does
# not place the bike at stops, skip cinematics or assign campaign checkpoints.
var visited := {}
var completed: Array[String] = []
var recovered_count := 0
var contact_count := 0
var chapter_metrics := {}
var seconds := 0.0
var action_delay := 0.0
var last_chapter := ""
var last_progress := 0.0
var stagnant_seconds := 0.0
var native_frame_ms: Array[float] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visual_test = "--visual" in OS.get_cmdline_user_args()
	GameState.settings = GameState.DEFAULT_SETTINGS.duplicate(true)
	GameState.settings.riding_assist = true
	GameState.settings.reduced_motion = true
	GameState.settings.fps_limit = 30
	GameState.settings.quality = 1 if visual_test else 0
	Engine.max_fps = 30 if visual_test else 0
	app = preload("res://scenes/boot/Boot.tscn").instantiate()
	add_child(app)
	await frames(5)
	app.bike.recovered.connect(func(): recovered_count += 1)
	app.bike.obstacle_contact.connect(func(): contact_count += 1)
	check(app.development_menu == null, "Normal desktop launch has no development menu")
	_click("Begin a new journey")
	await frames(2)
	if app.ui.mode == "confirm_new": _click("Begin a new journey")
	var done := false
	while seconds < 7200 and failures == 0 and not done:
		await get_tree().physics_frame
		var delta := 1.0 / Engine.physics_ticks_per_second
		seconds += delta
		action_delay = maxf(0, action_delay - delta)
		if app.flow.busy: continue
		if GameState.chapter != last_chapter:
			last_chapter = GameState.chapter
			last_progress = -app.bike.position.z
			stagnant_seconds = 0
			chapter_metrics[last_chapter] = {"seconds": 0.0, "max_lane_offset": 0.0, "max_ground_error": 0.0}
			print("JOURNEY: entered ", last_chapter, " at ", snappedf(seconds, .1), " simulated seconds")
		chapter_metrics[last_chapter].seconds += delta
		if get_tree().paused:
			# A real focus-loss pause is not a failed ride. Resume through its UI.
			if action_delay <= 0: _click("Continue riding")
			continue
		match app.state:
			"riding":
				_drive(delta)
			"dialogue":
				if action_delay <= 0:
					if DialogueManager.choices.is_empty(): _click("Continue  >")
					else: _click(DialogueManager.choices[completed.size() % DialogueManager.choices.size()].text)
			"scenic":
				if action_delay <= 0: _click("Start the engine when you're ready")
			"reflection":
				if action_delay <= 0: _click(app.chapter_data.journal.options[completed.size() % 2].text)
			"complete":
				if action_delay > 0: continue
				check(GameState.checkpoint == "complete" and SaveManager.read_save().chapter == last_chapter, "Normal ride and journal persist " + last_chapter)
				completed.append(last_chapter)
				if last_chapter == "epilogue":
					done = true
				else:
					_click("The next morning" if last_chapter == "banyuwangi" else "Continue the journey")
	InputModeManager.release_riding()
	check(done and completed == Campaign.CHAPTERS, "New Game reaches every chapter and ending without test teleports or Skip")
	check(recovered_count == 0, "Complete assisted journey needs no automatic recovery")
	check(contact_count == 0, "Complete normal ride has no blocking obstacle contacts")
	check(GameState.bike.distance > 23, "Odometer confirms physical travel across the complete route")
	check(GameState.journal.size() == Campaign.CHAPTERS.size(), "All fifteen reflections persist from a fresh journey")
	for id in chapter_metrics:
		check(chapter_metrics[id].max_lane_offset < 2.0 and chapter_metrics[id].max_ground_error < .35, id + " stays on its lane and follows the ground through the entire ride")
	var report := {"checks": checks, "failures": failures, "simulated_seconds": seconds, "native_rendered": visual_test, "kilometers": GameState.bike.distance, "recoveries": recovered_count, "contacts": contact_count, "chapters": chapter_metrics}
	if not native_frame_ms.is_empty():
		native_frame_ms.sort()
		report["riding_frame_ms"] = {"frames": native_frame_ms.size(), "median": native_frame_ms[native_frame_ms.size() / 2], "p95": native_frame_ms[int(native_frame_ms.size() * .95)], "worst": native_frame_ms.back()}
	var report_path := "user://native_journey_%s_report.json" % ("visual" if visual_test else "headless")
	var file := FileAccess.open(report_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	if visual_test: await capture("native_journey_ending")
	app.queue_free()
	await frames(4)
	print("NATIVE JOURNEY RESULT: %d checks, %d failures" % [checks, failures])
	print("JOURNEY METRICS: ", JSON.stringify(report))
	get_tree().quit(1 if failures else 0)

func _process(delta: float) -> void:
	if visual_test and is_instance_valid(app) and app.state == "riding" and not app.flow.busy and not get_tree().paused:
		native_frame_ms.append(delta * 1000.0)

func _drive(delta: float) -> void:
	var distance: float = -app.bike.position.z
	var center: Vector3 = app.bike.route.sample(distance)
	var metrics: Dictionary = chapter_metrics[last_chapter]
	metrics.max_lane_offset = maxf(metrics.max_lane_offset, absf(app.bike.position.x - center.x + 2.5))
	metrics.max_ground_error = maxf(metrics.max_ground_error, absf(app.bike.position.y - center.y))
	if not app.bike.position.is_finite() or not is_finite(app.bike.speed_mps):
		check(false, "Finite physics state in " + last_chapter)
		return
	if absf(distance - last_progress) > .25:
		last_progress = distance
		stagnant_seconds = 0
	else:
		stagnant_seconds += delta
	if stagnant_seconds > 30:
		check(false, "Journey must keep progressing in %s at %.1f m" % [last_chapter, distance])
		return
	if app.commute:
		Input.action_press("accelerate", .7)
		return
	var target: Dictionary = {}
	for stop in app.world.stops:
		if not visited.has(last_chapter + "/" + stop.id) and (last_chapter != "epilogue" or stop.id == "encounter"):
			target = stop
			break
	if target.is_empty(): return
	var remaining: float = target.distance - distance
	var braking_distance: float = app.bike.speed_mps * app.bike.speed_mps / 13.0 + 14.0
	if remaining <= braking_distance:
		Input.action_release("accelerate")
		Input.action_press("brake")
		if app.bike.speed_mps < 1.5 and remaining < 25:
			Input.action_release("brake")
			app.scanner.scan(app.bike, app.world.stops)
			if app.scanner.candidate.get("id", "") != target.id:
				check(false, "Roadside interaction is reachable for " + last_chapter + "/" + target.id)
				return
			visited[last_chapter + "/" + target.id] = true
			var event := InputEventAction.new()
			event.action = "interact"
			event.pressed = true
			Input.parse_input_event(event)
			event = InputEventAction.new()
			event.action = "interact"
			Input.parse_input_event(event)
			action_delay = 1.0
			stagnant_seconds = 0
	else:
		Input.action_release("brake")
		Input.action_press("accelerate", .7)

func _click(text: String) -> void:
	for child in app.ui.screen.find_children("*", "Button", true, false):
		if child.text == text and child.is_visible_in_tree() and not child.disabled:
			child.pressed.emit()
			action_delay = 1.0
			return
	check(false, "Visible enabled button: " + text)
