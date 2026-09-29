extends "res://tests/test_runner.gd"

var dev: Node
var baseline: Dictionary
var save_bytes: Dictionary
var save_notices := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visual_test = "--visual" in OS.get_cmdline_user_args()
	Engine.max_fps = 30 if visual_test else 0
	GameState.new_journey()
	GameState.set_flag("story.test.original", true)
	check(SaveManager.save_game() and SaveManager.save_game(), "Prepare isolated primary and backup save sentinels")
	_save_fingerprints()
	app = preload("res://scenes/boot/Boot.tscn").instantiate()
	add_child(app)
	await frames(6)
	baseline = GameState.snapshot()
	dev = app.development_menu
	check(dev != null and SaveManager.development_available(), "Explicit editor opt-in creates the development menu")
	check(not SaveManager.development_active, "Opt-in alone does not replace normal save behavior")
	SaveManager.save_completed.connect(func(): save_notices += 1)
	Input.action_press("accelerate")
	check(dev.open_panel(), "Development panel opens from title")
	check(get_tree().paused and not Input.is_action_pressed("accelerate") and not app.ui.visible, "Opening pauses gameplay, releases riding input and hides underlying UI")
	check(SaveManager.development_active and not SaveManager.has_save() and not SaveManager.load_game(), "Test session prevents Continue from replacing test state")
	check(not dev.jump(-1) and not dev.jump(20), "Only implemented chapter/checkpoint destinations are accepted")
	check(not dev.teleport(120), "Teleport is blocked outside riding")
	check(not dev.set_flag("schema_version", "2") and not dev.set_flag("story.bad", "{broken") and not dev.set_flag("story.bad", "[]") and not dev.set_flag("story.bad", "null"), "Invalid flag names, JSON and structured values are rejected")
	check(dev.set_flag("story.test.flag", "true") and GameState.flags["story.test.flag"] == true, "Boolean flag edits apply to test state")
	check(dev.set_flag("story.test.flag", '"hello"') and GameState.flags["story.test.flag"] == "hello", "String flag edits apply to test state")
	check(dev.set_flag("story.test.flag", "12") and GameState.flags["story.test.flag"] == 12, "Numeric flag edits apply to test state")
	check(dev.unset_flag("story.test.flag") and not GameState.flags.has("story.test.flag"), "Unset removes a test flag")
	check(SaveManager.save_game() and save_notices == 0 and _saves_unchanged(), "Suppressed checkpoints produce no save toast or file changes")
	dev.close_panel()
	check(not get_tree().paused and app.ui.visible and SaveManager.development_active, "Closing returns to previous UI while the test session remains isolated")
	check(not dev.set_flag("story.test.hidden", "true"), "Hidden development controls cannot mutate state")
	await _press_key(KEY_F8)
	check(dev.opened and get_tree().paused, "F8 opens the modal development panel through input dispatch")
	await _press_key(KEY_ESCAPE)
	check(not dev.opened and not get_tree().paused, "Escape closes development without opening the game pause menu")
	for index in range(dev.DESTINATIONS.size()):
		check(dev.open_panel(), "Open menu for destination %d" % index)
		check(dev.jump(index), "Jump to destination %d" % index)
		check(not dev.open_panel(), "Cannot interrupt checkpoint transition %d" % index)
		await settle()
		var entry: Array = dev.DESTINATIONS[index]
		check(GameState.chapter == entry[1] and GameState.checkpoint == entry[2], "Destination %d restores chapter and checkpoint" % index)
		var expected := "cutscene" if index in [0, 2] else ("reflection" if index == 5 else ("complete" if index == 6 else "riding"))
		check(app.state == expected, "Destination %d enters canonical state" % index)
		check(_saves_unchanged(), "Destination %d leaves all journey files untouched" % index)
		if index == 4:
			check(GameState.flags.get("story.karawang.sheltered", false), "Warung fixture includes the prerequisite story flag")
		if index == 6:
			check(not GameState.journal.is_empty() and GameState.flags.get("story.karawang.complete", false), "Complete fixture supplies a journal and completion flag")
	dev.open_panel()
	dev.jump(3)
	await settle()
	app._pause()
	dev.open_panel()
	dev.close_panel()
	check(get_tree().paused and app.ui.mode == "pause", "Closing over pause preserves the original pause screen")
	app._resume()
	dev.open_panel()
	check(dev.teleport(9999) and is_equal_approx(-app.bike.position.z, app.bike.route_limit), "Teleport clamps to the current route end")
	check(dev.teleport(-10) and is_zero_approx(-app.bike.position.z), "Teleport clamps negative distance to zero")
	check(not dev.teleport(NAN), "Teleport rejects non-finite input")
	app.bike.speed_mps = 12
	check(dev.teleport(600) and app.bike.speed_mps == 0 and app.bike.velocity == Vector3.ZERO, "Teleport stops velocity and speed")
	check(dev.set_weather("night") and app.world.current_profile == "night", "Time preset changes weather and lighting")
	dev.close_panel()
	await frames(5)
	check(app.world.current_profile == "night", "Weather override survives the normal road update")
	dev.open_panel()
	check(dev.set_weather("automatic") and app.development_weather.is_empty() and app.world.current_profile == app._road_profile(600), "Automatic restores the authored route profile")
	check(not dev.set_weather("missing"), "Unknown weather/time preset is rejected")
	AudioManager.focus_suspended = true
	check(not dev.teleport(100) and not dev.set_flag("story.test.focus", "true"), "Unfocused development controls cannot mutate gameplay")
	AudioManager.focus_suspended = false
	dev.performance_toggle.button_pressed = true
	dev._sample_performance()
	check(dev.performance_label.text.contains("Draw calls"), "Live performance overlay exposes runtime counters")
	await capture("development_menu")
	dev.scroll.scroll_vertical = 10000
	await capture("development_flags")
	dev.close_panel()
	check(dev.performance_label.visible, "Performance overlay is visible in gameplay without covering the modal")
	await capture("development_overlay")
	# Complete a real encounter through the existing story/save paths in sandbox.
	app.bike.teleport(1130)
	# Native rendering may execute several physics ticks in one drawn frame.
	# Allow the process-driven scanner to observe the new position before E.
	for frame in range(3):
		await get_tree().process_frame
	app._interact()
	check(app.state == "dialogue", "Test session can play a real road encounter")
	dev.open_panel()
	dev.close_panel()
	check(app.state == "dialogue" and not DialogueManager.active_id.is_empty(), "Inspecting dialogue preserves the active conversation")
	complete_dialogue(0)
	check(GameState.checkpoint == "warung" and _saves_unchanged(), "Normal encounter checkpoint remains transient")
	dev.open_panel()
	check(dev.end_session(), "End session returns to the title")
	check(app.state == "menu" and not get_tree().paused and not SaveManager.development_active, "Ending restores normal game mode")
	check(GameState.snapshot() == baseline and _saves_unchanged(), "Ending restores original session state and preserves save/backup/temp files")
	check(SaveManager.has_save() and SaveManager.load_game(), "Continue is available after the test session ends")
	check(SaveManager.save_game() and save_notices == 1, "Normal persistence resumes after development session")
	baseline = GameState.snapshot()
	_save_fingerprints()
	dev.open_panel()
	dev.set_flag("story.test.exit", "true")
	app.queue_free()
	await frames(6)
	check(not SaveManager.development_active and not get_tree().paused, "Scene teardown ends development isolation and clears pause")
	check(GameState.snapshot() == baseline and _saves_unchanged(), "Scene teardown restores original state without saving test flags")
	print("DEVELOPMENT RESULT: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)

func _save_fingerprints() -> void:
	save_bytes.clear()
	for suffix in ["", ".bak", ".tmp"]:
		var path: String = SaveManager.SAVE_PATH + suffix
		save_bytes[path] = FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null

func _saves_unchanged() -> bool:
	for path in save_bytes:
		var bytes: Variant = FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null
		if bytes != save_bytes[path]:
			return false
	return true

func _press_key(key: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = key
	event.pressed = true
	Input.parse_input_event(event)
	await frames(1)
	event = InputEventKey.new()
	event.keycode = key
	event.pressed = false
	Input.parse_input_event(event)
