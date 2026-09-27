extends "res://tests/test_runner.gd"

func button_named(title: String) -> Button:
	for button in app.ui.screen.find_children("*", "Button", true, false):
		if button.text == title:
			return button
	return null

func horizontal_fit() -> bool:
	var bounds: Rect2 = app.ui.safe_bounds.grow(2)
	for control in app.ui.screen.find_children("*", "Control", true, false):
		if not control.is_visible_in_tree() or not (control is Label or control is BaseButton or control is TextureRect or control is RouteMap):
			continue
		var rect: Rect2 = control.get_global_transform_with_canvas() * Rect2(Vector2.ZERO, control.size)
		if rect.position.x < bounds.position.x or rect.end.x > bounds.end.x:
			print("Horizontal overflow: ", control, " ", rect, " safe ", bounds)
			return false
	return true

func _ready() -> void:
	visual_test = "--visual" in OS.get_cmdline_user_args()
	var target_fps := 30 if "--limit-30" in OS.get_cmdline_user_args() else 60
	GameState.settings = GameState.DEFAULT_SETTINGS.duplicate(true)
	GameState.settings.fps_limit = target_fps
	SaveManager.save_settings()
	Engine.max_fps = target_fps if visual_test else 0
	GameState.new_journey()
	SaveManager.save_game(false)
	var saved := FileAccess.get_file_as_string(SaveManager.SAVE_PATH)
	for entry in [[1.0, 1.0], [1.1, 1.1], [1.25, 1.25], [-1.0, 1.0], [9.0, 1.25], [NAN, 1.0], [INF, 1.0], [1.19, 1.25]]:
		GameState.settings.ui_scale = entry[0]
		SaveManager.save_settings()
		GameState.settings.ui_scale = 1.0
		SaveManager.load_settings()
		check(is_equal_approx(GameState.settings.ui_scale, entry[1]), "Interface preference normalizes and persists: " + str(entry[0]))
	var config := ConfigFile.new()
	config.load(SaveManager.SETTINGS_PATH)
	config.erase_section_key("settings", "ui_scale")
	config.save(SaveManager.SETTINGS_PATH)
	SaveManager.load_settings()
	check(is_equal_approx(GameState.settings.ui_scale, 1.0), "Older settings without UI scale use Standard")
	config.set_value("settings", "ui_scale", "invalid")
	config.save(SaveManager.SETTINGS_PATH)
	GameState.settings.ui_scale = 1.25
	SaveManager.load_settings()
	check(is_equal_approx(GameState.settings.ui_scale, 1.0), "Invalid saved UI scale discards stale preference")
	app = preload("res://scenes/boot/Boot.tscn").instantiate()
	add_child(app)
	await frames(4)
	app.set_process(false)
	app.ui.show_settings()
	var picker: OptionButton = app.ui.screen.find_child("InterfaceSize", true, false)
	check(picker != null and picker.selected == 0, "Settings exposes three interface sizes with Standard selected")
	picker.select(2)
	picker.item_selected.emit(2)
	await frames(4)
	check(is_equal_approx(app.ui.root.scale.x, 1.25) and app.ui.mode == "settings" and picker == app.ui.screen.find_child("InterfaceSize", true, false), "Selection resizes the live menu without rebuilding controls or losing its page")
	GameState.new_journey()
	check(is_equal_approx(GameState.settings.ui_scale, 1.25), "New journey preserves interface preference")
	var world_fov: float = app.bike.camera.fov
	var snapshot := GameState.snapshot()
	for scale_value in [1.0, 1.1, 1.25]:
		GameState.settings.ui_scale = scale_value
		SaveManager.save_settings()
		for dimensions in [Vector2i(1280, 720), Vector2i(1600, 720), Vector2i(1280, 960)]:
			get_viewport().size = dimensions
			await frames(3)
			var bounds := Rect2(Vector2(64, 24), get_viewport().get_visible_rect().size - Vector2(96, 48))
			app.ui.apply_safe_area(bounds)
			await frames(3)
			var transformed: Rect2 = app.ui.root.get_global_transform_with_canvas() * Rect2(Vector2.ZERO, app.ui.root.size)
			check(transformed.is_equal_approx(bounds) and app.ui.interface_scale <= scale_value, "Scaled UI fills safe bounds at %s / %.0f%%" % [dimensions, scale_value * 100])
	get_viewport().size = Vector2i(1280, 720)
	await frames(3)
	app.ui.apply_safe_area(get_viewport().get_visible_rect())
	await frames(3)
	for page in ["menu", "settings", "controls", "phone", "photos", "map", "journal", "dialogue", "cinematic", "complete"]:
		match page:
			"menu": app.ui.main_menu()
			"settings": app.ui.show_settings()
			"controls": app.ui.show_controls()
			"phone": app.ui.show_phone()
			"photos": app.ui.show_phone("Photos", "with_dad")
			"map": app.ui.show_map()
			"journal": app.ui.show_journal()
			"dialogue":
				GameState.settings.text_size = 28
				app.ui.show_dialogue({"speaker": "Sari", "text": "Take your time. The rain can wait, and so can the road. There is room for your bag under the roof.", "choices": [{"text": "Thank you. I think I will sit here for a while and wait for the rain to pass."}, {"text": "I have a long way to go, but there is no need to hurry today."}]})
			"cinematic":
				var longest := ""
				for definition in app.director.definitions.values():
					for shot in definition.shots:
						if shot.text.length() > longest.length(): longest = shot.text
				app.ui.show_cinematic("PULANG", "A long way home", longest)
			"complete": app.ui.show_end()
		await frames(4)
		check(horizontal_fit(), "Largest interface keeps page content inside horizontal safe bounds: " + page)
		if page in ["menu", "settings", "photos", "dialogue", "cinematic"]:
			await capture("interface_125_" + page)
		if page == "menu":
			var last := button_named("Quit")
			last.grab_focus()
			await frames(3)
			var scroll: ScrollContainer = last.get_parent().get_parent()
			var scroll_rect: Rect2 = scroll.get_global_transform_with_canvas() * Rect2(Vector2.ZERO, scroll.size)
			var last_rect: Rect2 = last.get_global_transform_with_canvas() * Rect2(Vector2.ZERO, last.size)
			# Integer scroll offsets round by up to one logical pixel (1.25
			# viewport pixels at Largest), including the button border.
			check(scroll_rect.grow(2).encloses(last_rect), "Title menu scroll brings the last button into view at Largest")
			await capture("interface_125_menu_bottom")
		if page in ["photos", "dialogue"]:
			var last: Button = button_named("Put the phone away") if page == "photos" else app.ui.dialogue_box.get_child(app.ui.dialogue_box.get_child_count() - 1)
			last.grab_focus()
			await frames(3)
			var scroll: ScrollContainer = last.get_parent().get_parent()
			var view: Rect2 = scroll.get_global_transform_with_canvas() * Rect2(Vector2.ZERO, scroll.size)
			var target: Rect2 = last.get_global_transform_with_canvas() * Rect2(Vector2.ZERO, last.size)
			check(view.grow(2).encloses(target), "Focus scrolling exposes the final action: " + page)
			await capture("interface_125_" + page + "_bottom")
		if page == "cinematic":
			var caption: Label = app.ui.subtitle_label
			var rect: Rect2 = caption.get_global_transform_with_canvas() * Rect2(Vector2.ZERO, caption.size)
			check(app.ui.safe_bounds.encloses(rect) and caption.get_visible_line_count() == caption.get_line_count(), "Largest dialogue text and UI scale keep the longest authored cinematic caption readable")
	check(GameState.snapshot() == snapshot and FileAccess.get_file_as_string(SaveManager.SAVE_PATH) == saved and is_equal_approx(app.bike.camera.fov, world_fov), "Resizing and read-only page previews preserve story memory, checkpoint bytes and world FOV")
	await app._start_road(1100, false)
	GameState.settings.touch = true
	GameState.settings.touch_scale = 1.5
	SaveManager.save_settings()
	app.ui.update_hud(0, 1100, "Take a break", true, false)
	await frames(4)
	var touch: TouchControls = app.ui.touch
	for action in ["accelerate", "steer_left"]:
		var event := InputEventScreenTouch.new()
		event.index = 81 if action == "accelerate" else 82
		event.pressed = true
		event.position = get_viewport().get_screen_transform() * (touch.get_global_transform_with_canvas() * touch.zones[action].get_center())
		Input.parse_input_event(event)
	await frames(2)
	check(Input.is_action_pressed("accelerate") and Input.is_action_pressed("steer_left"), "Scaled UI and Largest touch size retain two-finger screen-coordinate input")
	check(not app.ui.prompt.get_rect().intersects(touch.zones.accelerate) and not app.ui.prompt.get_rect().intersects(touch.zones.steer_left), "Scaled interaction prompt remains above the fitted touch buttons")
	await capture("interface_125_touch")
	GameState.settings.ui_scale = 1.1
	SaveManager.save_settings()
	check(touch.fingers.is_empty() and not Input.is_action_pressed("accelerate"), "Changing interface size releases old touch ownership immediately")
	app.ui.apply_safe_area(Rect2(64, 24, 1024, 540))
	await frames(3)
	check(is_equal_approx(app.ui.interface_scale, 1.0) and is_equal_approx(GameState.settings.ui_scale, 1.1), "Constrained safe bounds limit enlargement without overwriting the preference")
	get_tree().paused = false
	app.queue_free()
	await frames(3)
	GameState.settings = GameState.DEFAULT_SETTINGS.duplicate(true)
	SaveManager.save_settings()
	print("INTERFACE TEST RESULT: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)
