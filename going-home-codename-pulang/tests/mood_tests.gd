extends "res://tests/test_runner.gd"

func _ready() -> void:
	visual_test = "--visual" in OS.get_cmdline_user_args()
	Engine.max_fps = (30 if "--limit-30" in OS.get_cmdline_user_args() else 60) if visual_test else 0
	GameState.new_journey()
	GameState.settings.quality = 1
	GameState.settings.touch = false
	InputModeManager.touch_mode = false
	SaveManager.save_game()
	var save_before := FileAccess.get_file_as_string(SaveManager.SAVE_PATH)
	var state_before := GameState.snapshot()
	app = preload("res://scenes/practice/RidingPractice.tscn").instantiate()
	add_child(app)
	await frames(4)
	check(app.world.profiles.size() == 8, "Eight authored mood resources load")
	for id in WeatherProfile.IDS:
		var profile: WeatherProfile = app.world.profiles[id]
		check(profile != null and profile.fog_density >= 0 and profile.rainfall >= 0 and profile.rainfall <= 1, "Valid profile resource: " + id)
		check(app.world.set_weather_profile(id, true), "Profile can be applied: " + id)
		await frames(3)
		check(app.world.environment.sky.sky_material.sky_top_color.is_equal_approx(profile.sky_top) and is_equal_approx(app.world.sun.light_energy, profile.sun_energy) and is_equal_approx(app.world.rain_amount, profile.rainfall), "Sky, sunlight and rain agree: " + id)
	check(app.bike.headlight.light_energy > 2 and app.world.practical_lights[0].light_energy > 2, "Night enables motorcycle beam and warm stop light")
	check(AudioManager.night_target == 1 and AudioManager.insects.stream != null, "Night selects original insect ambience")
	check(not app.world.set_weather_profile("missing") and app.world.current_profile == "night", "Unknown profile leaves active mood intact")
	var road_color: Color = app.world.road_material.albedo_color
	app.world.set_weather_profile("morning")
	check(app.world.road_material.albedo_color == road_color, "Profile transition starts without a material snap")
	await frames(50)
	app._pause()
	var sun_energy: float = app.world.sun.light_energy
	await frames(40)
	check(is_equal_approx(app.world.sun.light_energy, sun_energy), "Pausing freezes environment transition")
	app._resume()
	app.world.set_weather_profile("heavy_rain")
	await frames(25)
	app.world.set_weather_profile("golden_hour")
	await frames(210)
	check(is_equal_approx(app.world.sun.light_energy, app.world.profiles.golden_hour.sun_energy) and app.world.rain_amount < 0.001, "Rapid profile changes cancel the previous transition")
	check(app.world.road_material.roughness > 0.9, "Dry profile restores matte road surface")
	app.world.set_weather_profile("heavy_rain", true)
	await frames(3)
	var heavy_count: int = app.ui.weather.drop_count()
	var heavy_volume := AudioManager.rain_volume_target()
	check(app.world.road_material.roughness < 0.4, "Rain darkens and smooths the road material")
	app.world.set_weather_profile("drizzle", true)
	await frames(3)
	check(app.ui.weather.drop_count() < heavy_count and AudioManager.rain_volume_target() < heavy_volume, "Drizzle has fewer drops and quieter ambience than heavy rain")
	GameState.settings.quality = 0
	app.world.set_weather_profile("heavy_rain", true)
	await frames(3)
	check(app.ui.weather.drop_count() <= 44 and not app.world.sun.shadow_enabled, "Low quality bounds rain count and disables sun shadows")
	app._on_action("atmosphere")
	check(app.ui.mode == "atmosphere" and get_tree().paused, "Practice mood chooser pauses the ride")
	await capture("mood_chooser")
	app._on_action("atmosphere:night")
	await frames(210)
	check(app.ui.mode == "riding" and not get_tree().paused and app.world.current_profile == "night", "Choosing Night resumes practice and blends mood")
	app._on_action("report")
	check(app.metrics.snapshot().weather_profile == "night", "Local practice report records selected profile")
	check(GameState.snapshot() == state_before and FileAccess.get_file_as_string(SaveManager.SAVE_PATH) == save_before, "Mood comparisons and reports preserve story state and save")
	app.queue_free()
	await frames(4)
	check(AudioManager.rain_target == 0 and AudioManager.night_target == 0, "Leaving practice clears rain and night audio targets")
	GameState.settings.quality = 1
	app = preload("res://scenes/boot/Boot.tscn").instantiate()
	add_child(app)
	await frames(4)
	app.set_process(false)
	await app._start_road(1100, false)
	check(app.world.current_profile == "rain", "Checkpoint placement restores authored road weather")
	var previous_distance := -1.0
	for entry in app.chapter_data.atmosphere:
		check(entry.distance >= previous_distance and app.world.profiles.has(entry.profile), "Valid ordered chapter atmosphere cue: " + entry.profile)
		previous_distance = entry.distance
	check(app._road_profile(940) == "drizzle" and app._road_profile(1280) == "heavy_rain" and app._road_profile(1500) == "golden_hour", "Road progression selects drizzle, heavy rain and golden hour")
	for id in WeatherProfile.IDS:
		app.world.set_weather_profile(id, true)
		app.ui.update_hud(0, 1100, "", false, false)
		app.ui.weather.intensity = app.world.rain_amount
		app.ui.weather.rain = app.world.rain_amount > 0
		app.ui.weather.queue_redraw()
		app.bike.headlight.light_energy = app.world.night_amount * 2.5
		await frames(3)
		await capture("mood_" + id)
		if id == "night":
			app.bike.headlight.light_energy = 0
			await capture("mood_night_beam_off")
	GameState.checkpoint = "complete"
	app._restore_checkpoint()
	await frames(6)
	await settle()
	check(app.state == "complete" and app.world.current_profile == "night", "Continue restores night at the completed chapter")
	app._return_to_menu()
	check(app.world.current_profile == "morning" and AudioManager.night_target == 0, "Returning to title clears the night profile")
	app.queue_free()
	await frames(4)
	print("MOOD TEST RESULT: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)
