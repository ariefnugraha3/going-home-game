extends "res://tests/test_runner.gd"

var vehicle_events: Array[String] = []
var ui_events: Array[String] = []

func _ready() -> void:
	visual_test = "--visual" in OS.get_cmdline_user_args()
	var target_fps := 30 if "--limit-30" in OS.get_cmdline_user_args() else 60
	Engine.max_fps = target_fps if visual_test else 0
	AudioManager.set_process(false)
	AudioManager.focus_suspended = false
	GameState.new_journey()
	GameState.settings = GameState.DEFAULT_SETTINGS.duplicate(true)
	GameState.settings.fps_limit = target_fps
	SaveManager.save_game()
	var saved := FileAccess.get_file_as_string(SaveManager.SAVE_PATH)
	check(not AudioManager.unlocked and not AudioManager.traffic.playing, "No audio playback before user activation")
	check(not AudioManager.play_music_cue("first_night") and not AudioManager.vehicle_event("start"), "Music and ignition require activation")
	check(not AudioManager.ui_event("select") and not AudioManager.ui_player.playing, "UI cue cannot start before user activation")
	AudioManager.unlock()
	AudioManager.vehicle_cue_played.connect(func(id: String): vehicle_events.append(id))
	AudioManager.ui_cue_played.connect(func(id: String): ui_events.append(id))
	for id in ["select", "confirm", "back"]:
		var stream: AudioStreamWAV = AudioManager.ui_streams[id]
		check(stream != null and stream.loop_mode == AudioStreamWAV.LOOP_DISABLED and stream.get_length() > 0 and stream.get_length() <= 0.2, "UI cue is short and nonlooping: " + id)
	check(AudioManager.ui_player.bus == "UI" and AudioServer.get_bus_send(AudioServer.get_bus_index("UI")) == "SFX" and AudioManager.ui_player.max_polyphony == 1, "UI routes through SFX with a single playback voice")
	var state_before := GameState.snapshot()
	check(not AudioManager.ui_event("missing") and ui_events.is_empty(), "Unknown UI event remains silent")
	get_tree().paused = true
	check(AudioManager.ui_event("confirm") and ui_events == ["confirm"], "UI confirmation is allowed while the game is paused")
	if visual_test:
		check(AudioManager.ui_player.playing and not AudioManager.ui_player.stream_paused, "Native mixer plays UI feedback in a paused menu")
		await frames(2)
		check(AudioManager.ui_player.get_playback_position() > 0, "Native UI playback clock advances while gameplay is paused")
		check(AudioServer.get_bus_peak_volume_left_db(AudioServer.get_bus_index("SFX"), 0) > -60, "Native UI samples actually reach the SFX bus")
	check(not AudioManager.ui_event("select") and ui_events.size() == 1, "Rapid UI requests cannot layer or retrigger the tone")
	AudioManager.update_mix(0.1)
	check(AudioManager.ui_event("back") and ui_events.back() == "back", "UI feedback becomes available again after the short interval")
	AudioManager._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(not AudioManager.ui_event("select") and not AudioManager.ui_player.playing, "Focus loss stops current UI sound and rejects further events")
	AudioManager._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
	AudioManager.update_mix(0.2)
	check(ui_events.size() == 2 and not AudioManager.ui_player.playing, "Focus return never replays a background UI request")
	for key in ["sfx", "master"]:
		var previous: float = GameState.settings[key]
		GameState.settings[key] = 0.0
		check(not AudioManager.ui_event("select") and ui_events.size() == 2, "Zero volume drops rather than queues UI feedback: " + key)
		GameState.settings[key] = previous
		AudioManager.update_mix(0.2)
	check(GameState.snapshot() == state_before and FileAccess.get_file_as_string(SaveManager.SAVE_PATH) == saved, "UI audio leaves story memory and checkpoint bytes unchanged")
	get_tree().paused = false
	for player in AudioManager.ambient_players():
		check(player.stream is AudioStreamWAV and player.stream.loop_mode != AudioStreamWAV.LOOP_DISABLED, "Ambient stream loops: " + player.stream.resource_path.get_file())
	check(AudioManager.ignition.stream.loop_mode == AudioStreamWAV.LOOP_DISABLED and AudioManager.cooldown.stream.loop_mode == AudioStreamWAV.LOOP_DISABLED, "Ignition and cooldown do not loop")
	check(AudioManager.road_context(20) == "city" and AudioManager.road_context(300) == "roadside" and AudioManager.road_context(620) == "fields" and AudioManager.road_context(1100) == "warung" and AudioManager.road_context(1500, true) == "city", "Authored road regions respect boundaries and commute override")
	AudioManager.set_context("city")
	AudioManager.update_mix(10)
	var city_volume := AudioManager.traffic.volume_db
	AudioManager.set_context("fields")
	AudioManager.update_mix(0)
	check(is_equal_approx(city_volume, AudioManager.traffic.volume_db), "Zone switch has no instant volume jump")
	AudioManager.update_mix(10)
	check(AudioManager.traffic.volume_db < city_volume - 10 and AudioManager.traffic.volume_db >= -60, "Field traffic fades down without overshoot on long frames")
	check(not AudioManager.set_context("unknown") and AudioManager.context == "fields", "Unknown zone preserves current mix")
	AudioManager.set_context("warung", true)
	AudioManager.rain_target = 1
	AudioManager.update_mix(10)
	check(AudioManager.warung.volume_db > -23 and AudioManager.roof.volume_db > -24, "Wet shelter brings in crockery and roof rain")
	AudioManager.set_context("fields")
	AudioManager.update_mix(10)
	check(AudioManager.roof.volume_db < -59 and AudioManager.warung.volume_db < -59, "Leaving shelter fades out roof and crockery")
	AudioManager.set_context("warung", true)
	AudioManager.rain_target = 0
	AudioManager.update_mix(10)
	check(AudioManager.roof.volume_db < -59, "Dry shelter has no roof rain")
	AudioManager.bike_speed = 1
	AudioManager.engine_active = true
	AudioManager.update_mix(10)
	check(AudioManager.wind.volume_db > -20 and AudioManager.load_loop.volume_db > -18, "Riding enables wind and engine load")
	AudioManager.engine_active = false
	AudioManager.update_mix(10)
	check(AudioManager.wind.volume_db < -59 and AudioManager.idle.volume_db < -59, "Stopped engine also silences riding wind")
	for key in ["music", "sfx", "master"]:
		GameState.settings[key] = 0.0
	AudioManager.update_mix(0)
	check(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")) and AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")) and AudioServer.is_bus_mute(0), "Zero sliders actually mute Music, SFX and Master")
	check(not AudioServer.is_bus_mute(AudioServer.get_bus_index("Ambience")) and not AudioServer.is_bus_mute(AudioServer.get_bus_index("Vehicle")), "Individual bus settings remain independent")
	GameState.settings.music = 0.35
	GameState.settings.sfx = 0.45
	GameState.settings.master = 0.75
	check(SaveManager.save_settings(), "New audio preferences save")
	GameState.settings.music = 1.0
	GameState.settings.sfx = 1.0
	SaveManager.load_settings()
	AudioManager.update_mix(0)
	check(is_equal_approx(GameState.settings.music, 0.35) and is_equal_approx(GameState.settings.sfx, 0.45) and not AudioServer.is_bus_mute(0), "Music and SFX preferences restore and unmute")
	check(FileAccess.get_file_as_string(SaveManager.SAVE_PATH) == saved, "Audio preferences leave journey save untouched")
	check(not AudioManager.play_music_cue("missing") and AudioManager.play_music_cue("first_night"), "Only authored music cue starts")
	check(is_equal_approx(AudioManager.cue_remaining, 24) and AudioManager.music.stream.loop_mode == AudioStreamWAV.LOOP_DISABLED, "First-night phrase is 24 seconds and does not loop")
	AudioManager.update_mix(2)
	check(not AudioManager.play_music_cue("first_night") and is_equal_approx(AudioManager.cue_remaining, 22), "Duplicate cue request cannot restart the phrase")
	get_tree().paused = true
	AudioManager.update_mix(3)
	check((not visual_test or AudioManager.music.stream_paused) and is_equal_approx(AudioManager.cue_remaining, 22) and not AudioManager.vehicle_event("start"), "Pause freezes music and prevents vehicle events")
	get_tree().paused = false
	AudioManager._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	AudioManager.update_mix(3)
	check(AudioServer.is_bus_mute(0) and (not visual_test or AudioManager.traffic.stream_paused) and is_equal_approx(AudioManager.cue_remaining, 22), "Background suspends loops and cue clock and mutes output")
	AudioManager._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
	AudioManager.update_mix(1)
	check(not AudioServer.is_bus_mute(0) and not AudioManager.music.stream_paused and is_equal_approx(AudioManager.cue_remaining, 21), "Foreground resumes the same phrase")
	if visual_test:
		await frames(20)
		var position := AudioManager.traffic.get_playback_position()
		AudioManager.set_context("city")
		AudioManager.unlock()
		check(AudioManager.traffic.playing and AudioManager.traffic.get_playback_position() >= position, "Native zone change and repeated activation preserve loop position")
		check(AudioManager.music.playing, "Native mixer plays the music stream")
	AudioManager.update_mix(25)
	check(AudioManager.current_cue.is_empty() and AudioManager.music.stream == null, "Finished phrase releases its stream and returns to silence")
	AudioManager.update_mix(60)
	check(AudioManager.current_cue.is_empty(), "Silence does not automatically start more music")
	await ui_feedback_checks(saved)
	AudioManager.set_process(true)
	app = preload("res://scenes/boot/Boot.tscn").instantiate()
	add_child(app)
	await frames(4)
	await app._start_road(720, false)
	check(vehicle_events == ["start"], "Entering story road triggers ignition once")
	AudioManager.update_mix(0.1)
	var event := InputEventAction.new()
	event.action = "pause"
	event.pressed = true
	app._unhandled_input(event)
	check(get_tree().paused and ui_events.back() == "select", "Story pause shortcut uses selection feedback")
	AudioManager.update_mix(0.1)
	app._unhandled_input(event)
	check(not get_tree().paused and ui_events.back() == "back", "Story return shortcut uses back feedback without a duplicate button event")
	app._pause()
	await frames(3)
	app._resume()
	await frames(3)
	check(vehicle_events == ["start"], "Pause and resume do not restart ignition")
	app.bike.teleport(730)
	await frames(4)
	# Use the authored stop position rather than a synthetic interaction.
	for stop in app.world.stops:
		if stop.id == "scenic": app.bike.teleport(stop.distance)
	await frames(4)
	app._interact()
	check(app.state == "scenic" and vehicle_events.back() == "stop", "Scenic stop plays engine cooldown")
	app._resume_ride()
	check(vehicle_events.back() == "start" and vehicle_events.size() == 3, "Leaving a real stop restarts the engine")
	GameState.set_flag("story.karawang.sheltered")
	app.bike.teleport(1700)
	await frames(4)
	app._interact()
	complete_dialogue(0)
	await frames(3)
	check(app.state == "reflection" and AudioManager.current_cue == "first_night" and AudioManager.context == "indoors", "Guesthouse reflection starts the first-night phrase indoors")
	app._journal_selected("test", "A quiet first night.")
	check(AudioManager.current_cue == "first_night", "Journal completion retains the active phrase")
	app._return_to_menu()
	check(AudioManager.current_cue.is_empty() and not AudioManager.ignition.playing and not AudioManager.cooldown.playing, "Title clears music and vehicle one-shots")
	var event_count := vehicle_events.size()
	app._restore_checkpoint()
	await frames(6)
	await settle()
	check(app.state == "complete" and AudioManager.current_cue.is_empty() and vehicle_events.size() == event_count, "Continue at rest avoids ignition and music replay")
	app.ui.show_settings()
	await frames(3)
	for scroll in app.ui.find_children("*", "ScrollContainer", true, false):
		scroll.scroll_vertical = 220
	await capture("audio_settings")
	app.queue_free()
	await frames(4)
	var practice := preload("res://scenes/practice/RidingPractice.tscn").instantiate()
	add_child(practice)
	await frames(4)
	check(AudioManager.current_cue.is_empty() and vehicle_events.size() == event_count + 1 and vehicle_events.back() == "start", "Practice starts with ignition and no story music")
	event_count = vehicle_events.size()
	practice._pause()
	practice._resume()
	check(vehicle_events.size() == event_count, "Practice pause does not replay ignition")
	practice.bike.teleport(680)
	practice._on_action("interact")
	practice._on_action("interact")
	await frames(3)
	check(practice.resting and AudioManager.sheltered and vehicle_events.size() == event_count + 1 and vehicle_events.back() == "stop", "Repeated shelter interaction plays cooldown once")
	practice.start_section("straight")
	check(vehicle_events.size() == event_count + 2 and vehicle_events.back() == "start", "Repeating practice after rest starts engine once")
	practice.queue_free()
	await frames(4)
	GameState.settings = GameState.DEFAULT_SETTINGS.duplicate(true)
	SaveManager.save_settings()
	print("AUDIO TEST RESULT: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)

func ui_feedback_checks(saved: String) -> void:
	var ui := GameUI.new()
	add_child(ui)
	var actions: Array[String] = []
	ui.action_requested.connect(func(action: String): actions.append(action))
	ui_events.clear()
	ui.main_menu()
	ui.show_settings()
	ui.main_menu()
	await frames(3)
	check(ui_events.is_empty(), "Building menus and moving initial focus do not play UI sounds")
	AudioManager.unlocked = false
	AudioManager.update_mix(0.1)
	var settings := ui_button(ui, "Settings & accessibility")
	settings.grab_focus()
	var key := InputEventKey.new()
	key.keycode = KEY_ENTER
	key.physical_keycode = KEY_ENTER
	key.pressed = true
	Input.parse_input_event(key)
	await frames(3)
	key = key.duplicate()
	key.pressed = false
	Input.parse_input_event(key)
	await frames(3)
	check(AudioManager.unlocked and ui.mode == "settings" and ui_events == ["select"], "Keyboard activation unlocks audio and opens Settings with one selection cue")
	AudioManager.update_mix(0.1)
	var picker: OptionButton = ui.screen.find_child("TouchSize", true, false)
	picker.select(1)
	picker.item_selected.emit(1)
	check(ui_events.back() == "select" and ui_events.size() == 2 and is_equal_approx(GameState.settings.touch_scale, 1.25), "Settings selector feedback preserves its preference callback")
	AudioManager.update_mix(0.1)
	ui_button(ui, "Back").pressed.emit()
	check(ui_events.back() == "back" and actions == ["back"], "Back button emits the return tone and original action exactly once")
	ui.confirm_new()
	AudioManager.update_mix(0.1)
	ui_button(ui, "Begin a new journey").pressed.emit()
	check(ui_events.back() == "confirm" and actions.back() == "new_confirmed", "Explicit confirmation button uses its authored cue")
	AudioManager.update_mix(0.1)
	var count := ui_events.size()
	ui_button(ui, "Keep my journey").pressed.emit()
	ui.show_credits()
	ui_button(ui, "Back").pressed.emit()
	check(ui_events.size() == count + 1 and actions.back() == "back", "Rate limiting suppresses sound only, never the button action")
	check(FileAccess.get_file_as_string(SaveManager.SAVE_PATH) == saved, "Menu sound and settings callbacks preserve the journey file")
	ui.queue_free()
	await frames(3)
	GameState.settings.touch_scale = 1.0
	SaveManager.save_settings()

func ui_button(ui: GameUI, title: String) -> Button:
	for button in ui.screen.find_children("*", "Button", true, false):
		if button.text == title:
			return button
	check(false, "Missing UI audio test button: " + title)
	return null
