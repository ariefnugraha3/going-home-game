extends "res://tests/test_runner.gd"

func key_event(key: int, pressed: bool = true) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.keycode = key
	event.pressed = pressed
	return event

func press_key(key: int) -> void:
	Input.parse_input_event(key_event(key))
	await frames(2)
	Input.parse_input_event(key_event(key, false))
	await frames(2)

func touch_event(index: int, point: Vector2, pressed: bool = true) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.index = index
	# parse_input_event takes window pixels; the viewport applies its stretch transform.
	event.position = get_viewport().get_screen_transform() * point
	event.pressed = pressed
	return event

func find_button(node: Node, prefix: String) -> Button:
	if node is Button and node.text.begins_with(prefix):
		return node
	for child in node.get_children():
		var result := find_button(child, prefix)
		if result != null:
			return result
	return null

func _ready() -> void:
	visual_test = "--visual" in OS.get_cmdline_user_args()
	var target_fps := 30 if "--limit-30" in OS.get_cmdline_user_args() else 60
	GameState.settings.fps_limit = target_fps
	Engine.max_fps = target_fps if visual_test else 0
	GameState.settings.touch = false
	InputModeManager.reset_bindings()
	GameState.new_journey()
	SaveManager.save_game()
	var save_before := FileAccess.get_file_as_string(SaveManager.SAVE_PATH)
	check(InputModeManager.key_label("accelerate") == "W / Up", "Default throttle exposes both physical shortcuts")
	check(InputModeManager.rebind("accelerate", KEY_I).is_empty(), "Throttle accepts a free key")
	check(InputMap.event_is_action(key_event(KEY_I), "accelerate") and not InputMap.event_is_action(key_event(KEY_W), "accelerate"), "Remapping replaces old shortcuts")
	check(not InputModeManager.rebind("brake", KEY_I).is_empty(), "Duplicate custom key is rejected")
	check(not InputModeManager.rebind("brake", KEY_W).is_empty(), "Another action's default remains reserved")
	check(not InputModeManager.rebind("accelerate", KEY_ESCAPE).is_empty(), "Escape cannot be taken from navigation")
	check(not InputModeManager.rebind("accelerate", KEY_F5).is_empty(), "Browser function shortcut is rejected")
	check(not InputModeManager.rebind("pause", KEY_X).is_empty(), "Fixed pause control cannot be changed")
	check(InputModeManager.rebind("brake", KEY_SPACE).is_empty(), "Brake retains intentional cinematic Space sharing")
	GameState.settings.key_bindings = {}
	SaveManager.load_settings()
	InputModeManager.apply_bindings()
	check(InputModeManager.key_label("accelerate") == "I", "Keyboard preference survives settings reload")
	GameState.new_journey()
	check(InputModeManager.key_label("accelerate") == "I", "New journey preserves keyboard preferences")
	GameState.settings.key_bindings = {"accelerate": "invalid", "brake": KEY_I, "pause": KEY_X, "unknown": KEY_Z, "interact": KEY_ESCAPE}
	InputModeManager.apply_bindings()
	check(InputModeManager.key_label("accelerate") == "W / Up" and InputModeManager.key_label("pause") == "Escape", "Malformed overrides fall back safely")
	check(GameState.settings.key_bindings == {"brake": KEY_I}, "Invalid entries are removed while valid preference is retained")
	InputModeManager.reset_bindings()
	check(InputMap.action_get_events("brake").size() == 3, "Reset restores all brake alternatives without duplicates")
	check(FileAccess.get_file_as_string(SaveManager.SAVE_PATH) == save_before, "Input settings never modify story save")
	app = preload("res://scenes/practice/RidingPractice.tscn").instantiate()
	add_child(app)
	await frames(5)
	app._pause()
	app.ui.show_controls()
	await frames(3)
	var button := find_button(app.ui.screen, "Accelerate:")
	check(button != null, "Controls menu exposes throttle binding")
	button.pressed.emit()
	await press_key(KEY_S)
	check(app.ui.capture_action == "accelerate" and InputModeManager.key_label("accelerate") == "W / Up", "Conflict leaves capture open without changing controls")
	await press_key(KEY_ESCAPE)
	check(app.ui.capture_action.is_empty() and app.ui.mode == "controls" and get_tree().paused, "Escape cancels capture without resuming ride")
	button.pressed.emit()
	var modified := key_event(KEY_I)
	modified.ctrl_pressed = true
	Input.parse_input_event(modified)
	await frames(2)
	Input.parse_input_event(key_event(KEY_I, false))
	check(app.ui.capture_action == "accelerate", "Modified shortcut cannot become a plain key binding")
	await press_key(KEY_I)
	check(app.ui.capture_action.is_empty() and button.text == "Accelerate: I", "Physical key capture works while paused and updates button")
	await capture("input_controls")
	await press_key(KEY_ESCAPE)
	check(app.ui.mode == "pause" and get_tree().paused, "Escape returns from practice controls to pause menu")
	app._resume()
	Input.parse_input_event(key_event(KEY_W))
	await frames(30)
	Input.parse_input_event(key_event(KEY_W, false))
	check(app.bike.speed_mps < 0.1, "Old throttle key no longer drives motorcycle")
	Input.parse_input_event(key_event(KEY_I))
	await frames(90)
	Input.parse_input_event(key_event(KEY_I, false))
	check(app.bike.speed_mps > 2.0, "Remapped physical key drives the shared controller")
	InputModeManager.rebind("interact", KEY_F)
	var scanner := InteractionScanner.new()
	scanner.candidate = {"label": "Rest"}
	app.bike.speed_mps = 0
	InputModeManager.touch_mode = false
	check(scanner.get_interaction_label(app.bike).begins_with("F"), "Stop prompt follows remapped interaction key")
	GameState.settings.touch = true
	check(scanner.get_interaction_label(app.bike).begins_with("Tap"), "Stop prompt switches to touch instruction")
	scanner.free()
	app.bike.stop()
	await frames(3)
	var touch: TouchControls = app.ui.touch
	check(touch.visible, "Touch preference enables overlay")
	var throttle: Vector2 = touch.get_global_transform_with_canvas() * touch.zones.accelerate.get_center()
	var left: Vector2 = touch.get_global_transform_with_canvas() * touch.zones.steer_left.get_center()
	Input.parse_input_event(touch_event(1, throttle))
	Input.parse_input_event(touch_event(2, left))
	await frames(2)
	check(Input.is_action_pressed("accelerate") and Input.is_action_pressed("steer_left"), "Screen touch events drive throttle and steering simultaneously")
	Input.parse_input_event(touch_event(1, throttle, false))
	await frames(2)
	check(not Input.is_action_pressed("accelerate") and Input.is_action_pressed("steer_left"), "Lifting one finger preserves the other control")
	var drag := InputEventScreenDrag.new()
	drag.index = 2
	drag.position = get_viewport().get_screen_transform() * Vector2(640, 360)
	Input.parse_input_event(drag)
	await frames(2)
	check(not Input.is_action_pressed("steer_left"), "Dragging outside a zone releases steering")
	drag.position = get_viewport().get_screen_transform() * left
	Input.parse_input_event(drag)
	await frames(2)
	check(Input.is_action_pressed("steer_left"), "Same finger can reenter a riding zone")
	app._pause()
	check(touch.fingers.is_empty() and not Input.is_action_pressed("steer_left"), "Pause clears touch ownership")
	Input.parse_input_event(touch_event(3, throttle))
	await frames(2)
	check(not Input.is_action_pressed("accelerate") and touch.fingers.is_empty(), "Hidden HUD cannot capture menu touches")
	app._resume()
	app.bike.stop()
	await frames(2)
	Input.action_press("look_up")
	Input.action_press("look_down")
	InputModeManager.notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(not Input.is_action_pressed("look_up") and not Input.is_action_pressed("look_down"), "Focus loss releases vertical glance actions too")
	touch._update_finger(4, touch.zones.accelerate.get_center())
	touch.notification(NOTIFICATION_APPLICATION_PAUSED)
	check(touch.fingers.is_empty() and not Input.is_action_pressed("accelerate"), "Backgrounding clears held touches")
	Input.action_press("brake")
	touch._input(touch_event(99, Vector2.ZERO, false))
	check(Input.is_action_pressed("brake"), "Unrelated touch release does not clear keyboard brake")
	Input.action_release("brake")
	app.start_section("stop")
	app.bike.teleport(680)
	await frames(3)
	# Simulated logical safe rectangles cover 16:9, 20:9, and 4:3 plus cutout insets.
	for dimensions in [Vector2(1280, 720), Vector2(1600, 720), Vector2(1280, 960)]:
		get_viewport().size = Vector2i(dimensions)
		await frames(3)
		var bounds := Rect2(Vector2(64, 24), get_viewport().get_visible_rect().size - Vector2(96, 48))
		app.ui.apply_safe_area(bounds)
		await frames(3)
		check(app.ui.root.get_rect().is_equal_approx(bounds), "UI root respects simulated safe insets at %s" % dimensions)
		var contained := true
		var disjoint := true
		for action in touch.zones:
			var rect: Rect2 = touch.zones[action]
			contained = contained and Rect2(Vector2.ZERO, touch.size).encloses(rect)
			for other in touch.zones:
				if other != action:
					disjoint = disjoint and not rect.intersects(touch.zones[other])
		check(contained and disjoint, "Touch zones remain inside safe area without overlap at %s" % dimensions)
		check(not app.ui.prompt.get_rect().intersects(touch.zones.accelerate), "Interaction stays above riding controls at %s" % dimensions)
		if dimensions == Vector2(1600, 720):
			await capture("input_touch_safe_area")
	await touch_size_checks(save_before)
	InputModeManager.reset_bindings()
	GameState.settings.touch = false
	SaveManager.save_settings()
	get_tree().paused = false
	app.queue_free()
	await frames(3)
	print("INPUT TEST RESULT: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)

func touch_size_checks(save_before: String) -> void:
	get_viewport().size = Vector2i(1280, 720)
	await frames(3)
	app._pause()
	app.ui.show_settings()
	await frames(3)
	var picker: OptionButton = app.ui.screen.find_child("TouchSize", true, false)
	var preview: TouchControls = app.ui.screen.find_child("TouchPreview", true, false)
	check(picker != null and preview != null and not preview.interactive, "Settings exposes three touch sizes with a noninteractive preview")
	picker.select(2)
	picker.item_selected.emit(2)
	await frames(3)
	check(is_equal_approx(GameState.settings.touch_scale, 1.5) and is_equal_approx(app.ui.touch.requested_scale, 1.5), "Selecting Largest applies to the paused riding controls immediately")
	check(is_equal_approx(preview.zones.accelerate.size.y, 150), "Settings preview reflects selected button height")
	Input.parse_input_event(touch_event(51, preview.get_global_transform_with_canvas() * preview.zones.accelerate.get_center()))
	await frames(2)
	check(not Input.is_action_pressed("accelerate") and preview.fingers.is_empty(), "Preview touches cannot accelerate the paused motorcycle")
	Input.parse_input_event(touch_event(51, Vector2.ZERO, false))
	await capture("input_touch_size_settings")
	GameState.settings.touch_scale = 1.0
	SaveManager.load_settings()
	check(is_equal_approx(GameState.settings.touch_scale, 1.5), "Touch size survives settings reload")
	GameState.new_journey()
	check(is_equal_approx(GameState.settings.touch_scale, 1.5), "New journey preserves the preferred touch size")
	var config := ConfigFile.new()
	config.load(SaveManager.SETTINGS_PATH)
	config.erase_section_key("settings", "touch_scale")
	config.save(SaveManager.SETTINGS_PATH)
	SaveManager.load_settings()
	check(is_equal_approx(GameState.settings.touch_scale, 1.0), "Older settings without touch size restore the standard layout")
	config.set_value("settings", "touch_scale", "bad value")
	config.save(SaveManager.SETTINGS_PATH)
	GameState.settings.touch_scale = 1.5
	SaveManager.load_settings()
	check(is_equal_approx(GameState.settings.touch_scale, 1.0), "Malformed saved touch size falls back instead of retaining stale preference")
	for entry in [[-4.0, 1.0], [9.0, 1.5], [NAN, 1.0], [INF, 1.0], [1.28, 1.25]]:
		GameState.settings.touch_scale = entry[0]
		SaveManager.save_settings()
		GameState.settings.touch_scale = 1.0
		SaveManager.load_settings()
		check(is_equal_approx(GameState.settings.touch_scale, entry[1]), "Touch size normalizes before persistence: " + str(entry[0]))
	app._resume()
	app.bike.stop()
	var touch: TouchControls = app.ui.touch
	for dimensions in [Vector2(1280, 720), Vector2(1600, 720), Vector2(960, 540)]:
		get_viewport().size = Vector2i(dimensions)
		await frames(3)
		app.ui.apply_safe_area(Rect2(Vector2(64, 24), get_viewport().get_visible_rect().size - Vector2(96, 48)))
		for scale_value in [1.0, 1.25, 1.5]:
			GameState.settings.touch_scale = scale_value
			SaveManager.save_settings()
			await frames(3)
			var contained := true
			var disjoint := true
			var prompt_clear := true
			for action in touch.zones:
				var rect: Rect2 = touch.zones[action]
				contained = contained and Rect2(Vector2.ZERO, touch.size).encloses(rect)
				prompt_clear = prompt_clear and not app.ui.prompt.get_rect().intersects(rect)
				for other in touch.zones:
					if other != action:
						disjoint = disjoint and not rect.intersects(touch.zones[other])
			check(contained and disjoint and prompt_clear, "Scaled controls fit safe area and leave interaction clear: %s / %.0f%%" % [dimensions, scale_value * 100])
			var throttle: Vector2 = touch.get_global_transform_with_canvas() * touch.zones.accelerate.get_center()
			var left: Vector2 = touch.get_global_transform_with_canvas() * touch.zones.steer_left.get_center()
			Input.parse_input_event(touch_event(61, throttle))
			Input.parse_input_event(touch_event(62, left))
			await frames(2)
			check(Input.is_action_pressed("accelerate") and Input.is_action_pressed("steer_left"), "Scaled screen coordinates retain simultaneous throttle/steering: %s / %.0f%%" % [dimensions, scale_value * 100])
			touch.release_all()
			app.bike.stop()
			if scale_value == 1.5:
				await capture("input_touch_largest_%d" % dimensions.x)
	# canvas_items keeps logical coordinates at the project's baseline even
	# when the native window is smaller. Constrain logical bounds explicitly.
	app.ui.apply_safe_area(Rect2(Vector2(64, 24), Vector2(640, 400)))
	await frames(3)
	check(touch.effective_scale < touch.requested_scale and is_equal_approx(GameState.settings.touch_scale, 1.5) and Rect2(Vector2.ZERO, touch.size).encloses(touch.zones.accelerate), "Constrained logical safe area fits controls without overwriting size preference")
	touch._update_finger(71, touch.zones.accelerate.get_center())
	GameState.settings.sfx = 0.4
	SaveManager.save_settings()
	check(Input.is_action_pressed("accelerate"), "Unrelated settings changes do not drop held touch input")
	GameState.settings.touch_scale = 1.0
	SaveManager.save_settings()
	check(touch.fingers.is_empty() and not Input.is_action_pressed("accelerate"), "Changing touch size releases stale finger ownership")
	check(FileAccess.get_file_as_string(SaveManager.SAVE_PATH) == save_before, "Touch preferences and preview never modify the story checkpoint")
	GameState.settings.sfx = GameState.DEFAULT_SETTINGS.sfx
