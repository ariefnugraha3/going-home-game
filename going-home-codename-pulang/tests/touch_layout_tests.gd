extends "res://tests/test_runner.gd"

func touch_event(index: int, point: Vector2) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = point
	event.pressed = true
	return event

func fits(touch: TouchControls) -> bool:
	for action in touch.zones:
		var rect: Rect2 = touch.zones[action]
		if not Rect2(Vector2.ZERO, touch.size).encloses(rect) or app.ui.prompt.get_rect().intersects(rect):
			return false
		for other in touch.zones:
			if action != other and rect.intersects(touch.zones[other]):
				return false
	return true

func _ready() -> void:
	visual_test = "--visual" in OS.get_cmdline_user_args()
	var fps := 30 if "--limit-30" in OS.get_cmdline_user_args() else 60
	GameState.settings = GameState.DEFAULT_SETTINGS.duplicate(true)
	GameState.settings.fps_limit = fps
	SaveManager.save_settings()
	Engine.max_fps = fps if visual_test else 0
	GameState.new_journey()
	SaveManager.save_game()
	var saved := FileAccess.get_file_as_string(SaveManager.SAVE_PATH)
	var custom := {"left_inset": .5, "right_inset": 1.0, "left_height": .75, "right_height": .25}
	GameState.settings.touch_layout = custom.duplicate()
	check(SaveManager.save_settings(), "Touch positions save separately from journey")
	GameState.settings.touch_layout = {}
	SaveManager.load_settings()
	check(GameState.settings.touch_layout == custom, "All four positions round-trip")
	GameState.new_journey()
	check(GameState.settings.touch_layout == custom, "New journey keeps touch placement")
	var config := ConfigFile.new()
	config.load(SaveManager.SETTINGS_PATH)
	config.erase_section_key("settings", "touch_layout")
	config.save(SaveManager.SETTINGS_PATH)
	SaveManager.load_settings()
	check(GameState.settings.touch_layout == GameState.DEFAULT_SETTINGS.touch_layout, "Legacy settings restore original edge layout")
	config.set_value("settings", "touch_layout", "invalid")
	config.save(SaveManager.SETTINGS_PATH)
	GameState.settings.touch_layout = custom.duplicate()
	SaveManager.load_settings()
	check(GameState.settings.touch_layout == GameState.DEFAULT_SETTINGS.touch_layout, "Malformed saved layout discards stale placement")
	GameState.settings.touch_layout = {"left_inset": -2, "right_inset": 9, "left_height": NAN, "right_height": INF, "extra": 8}
	SaveManager.save_settings()
	check(GameState.settings.touch_layout == {"left_inset": 0.0, "right_inset": 1.0, "left_height": 0.0, "right_height": 0.0}, "Bounds and nonfinite values normalize; unknown keys are dropped")
	GameState.settings.touch_layout = {"left_inset": .47, "right_height": "invalid"}
	SaveManager.save_settings()
	SaveManager.load_settings()
	check(is_equal_approx(GameState.settings.touch_layout.left_inset, .45) and GameState.settings.touch_layout.right_height == 0 and GameState.settings.touch_layout.left_height == 0, "Partial layouts normalize to five-percent steps and fill defaults")
	check(GameState.DEFAULT_SETTINGS.touch_layout.left_inset == 0, "Changing placement never mutates default settings")
	GameState.settings.touch_layout = GameState.DEFAULT_SETTINGS.touch_layout.duplicate()
	GameState.settings.touch = true
	SaveManager.save_settings()
	app = preload("res://scenes/practice/RidingPractice.tscn").instantiate()
	add_child(app)
	await frames(4)
	app.bike.stop()
	app._pause()
	app.ui.show_settings()
	await frames(4)
	var preview: TouchControls = app.ui.screen.find_child("TouchPreview", true, false)
	var original := preview.zones.duplicate(true)
	var sliders: Dictionary = {}
	for key in custom:
		sliders[key] = app.ui.screen.find_child("TouchPosition_" + key, true, false)
		check(sliders[key] is HSlider and sliders[key].step == 5, "Settings exposes keyboard/touch slider: " + key)
		sliders[key].value = custom[key] * 100
	check(GameState.settings.touch_layout == custom and preview.zones != original, "Real slider callbacks save layout and update preview in place")
	preview._input(touch_event(20, preview.get_global_transform_with_canvas() * preview.zones.accelerate.get_center()))
	check(not Input.is_action_pressed("accelerate") and preview.fingers.is_empty(), "Preview cannot drive the motorcycle")
	# Scroll to make controls and reset inspectable in native captures.
	sliders.left_inset.grab_focus()
	await capture("touch_layout_settings")
	var reset: Button = app.ui.screen.find_child("ResetTouchPositions", true, false)
	reset.pressed.emit()
	check(GameState.settings.touch_layout == GameState.DEFAULT_SETTINGS.touch_layout and sliders.values().all(func(slider): return slider.value == 0), "Reset restores all positions and existing slider values")
	check(preview.zones == original and GameState.settings.touch_scale == 1 and GameState.settings.ui_scale == 1, "Reset restores preview without changing touch/interface size")
	app._resume()
	app.bike.stop()
	var touch: TouchControls = app.ui.touch
	var patterns := [GameState.DEFAULT_SETTINGS.touch_layout.duplicate(), {"left_inset": 1.0, "right_inset": 1.0, "left_height": 1.0, "right_height": 1.0}, {"left_inset": .5, "right_inset": 1.0, "left_height": 0.0, "right_height": 1.0}]
	for dimensions in [Vector2i(1280, 720), Vector2i(1600, 720), Vector2i(960, 540)]:
		get_viewport().size = dimensions
		await frames(3)
		app.ui.apply_safe_area(Rect2(Vector2(48, 24), get_viewport().get_visible_rect().size - Vector2(96, 48)))
		GameState.settings.ui_scale = 1.25
		for size_value in [1.0, 1.25, 1.5]:
			GameState.settings.touch_scale = size_value
			for pattern in patterns:
				GameState.settings.touch_layout = pattern.duplicate()
				SaveManager.apply_settings()
				await frames(3)
				check(fits(touch), "Controls and interaction stay disjoint inside safe bounds: %s / %.0f%% / %s" % [dimensions, size_value * 100, str(pattern)])
				if size_value == 1.5:
					var throttle: Vector2 = touch.get_global_transform_with_canvas() * touch.zones.accelerate.get_center()
					var left: Vector2 = touch.get_global_transform_with_canvas() * touch.zones.steer_left.get_center()
					# Coordinates above are viewport-local. Native window stretch
					# must not convert them a second time on small windows.
					get_viewport().push_input(touch_event(31, throttle), true)
					get_viewport().push_input(touch_event(32, left), true)
					await frames(2)
					check(Input.is_action_pressed("accelerate") and Input.is_action_pressed("steer_left"), "Moved/scaled screen coordinates support two fingers: " + str(dimensions))
					touch.release_all()
			await capture("touch_layout_%d_%d" % [dimensions.x, roundi(size_value * 100)])
	GameState.settings.touch_layout = custom.duplicate()
	SaveManager.apply_settings()
	touch._update_finger(41, touch.zones.accelerate.get_center())
	GameState.settings.sfx = .4
	SaveManager.save_settings()
	check(Input.is_action_pressed("accelerate"), "Unrelated volume changes preserve held touch input")
	GameState.settings.touch_layout.right_height = .5
	SaveManager.save_settings()
	check(touch.fingers.is_empty() and not Input.is_action_pressed("accelerate"), "Placement changes release old finger ownership")
	touch._update_finger(42, touch.zones.steer_left.get_center())
	app.ui.apply_safe_area(Rect2(Vector2(48, 24), Vector2(640, 400)))
	await frames(3)
	check(fits(touch) and touch.fingers.is_empty() and GameState.settings.touch_layout.right_height == .5, "Constrained safe area fits placement and releases fingers without rewriting preference")
	check(FileAccess.get_file_as_string(SaveManager.SAVE_PATH) == saved, "Placement changes, reset and preview leave journey save bytes intact")
	var chosen: Dictionary = GameState.settings.touch_layout.duplicate()
	app.queue_free()
	await frames(4)
	app = preload("res://scenes/boot/Boot.tscn").instantiate()
	add_child(app)
	await frames(4)
	check(app.ui.touch.placement == chosen, "Story and practice share saved placement")
	app.queue_free()
	await frames(3)
	GameState.settings = GameState.DEFAULT_SETTINGS.duplicate(true)
	SaveManager.save_settings()
	print("TOUCH LAYOUT TEST RESULT: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)
