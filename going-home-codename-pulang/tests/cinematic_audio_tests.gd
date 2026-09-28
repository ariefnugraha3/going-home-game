extends "res://tests/test_runner.gd"

var events: Array[String] = []
var offsets: Array[float] = []

func _ready() -> void:
	visual_test = "--visual" in OS.get_cmdline_user_args()
	Engine.max_fps = (30 if "--limit-30" in OS.get_cmdline_user_args() else 60) if visual_test else 0
	GameState.new_journey()
	GameState.settings = GameState.DEFAULT_SETTINGS.duplicate(true)
	AudioManager.focus_suspended = false
	SaveManager.save_game()
	var saved := FileAccess.get_file_as_string(SaveManager.SAVE_PATH)
	var snapshot := GameState.snapshot()
	var director := CutsceneDirector.new()
	add_child(director)
	director.set_process(false)
	var sound := director.sound
	sound.cue_started.connect(func(id: String, offset: float):
		events.append(id)
		offsets.append(offset))
	check(sound.voices.size() == 2 and sound.voices.all(func(p): return p.bus == "SFX" and p.max_polyphony == 1), "Two bounded cinematic voices route through SFX")
	for id in sound.bank:
		var stream: AudioStreamWAV = sound.streams[id]
		check(stream != null and stream.loop_mode == AudioStreamWAV.LOOP_DISABLED and stream.get_length() > 0 and stream.get_length() <= 4.0, "Cinematic asset is short and nonlooping: " + id)
	var count := 0
	for id in director.definitions:
		var valid := true
		for shot in director.definitions[id].shots:
			var previous := -1.0
			for event in shot.get("audio", []):
				valid = valid and sound.bank.has(event.cue) and event.at >= 0 and event.at < shot.duration and event.at >= previous
				previous = event.at
				count += 1
		check(valid, "Authored cues reference bank and ordered in-shot times: " + id)
	check(count == 9, "Opening contains nine sparse authored sound events")
	director.play("morning")
	director._process(.2)
	check(events.is_empty() and sound.pending.is_empty(), "Before activation an elapsed cue is consumed silently")
	AudioManager.unlock()
	director._process(.2)
	check(events.is_empty(), "Activation never replays an already elapsed cue")
	director.play("morning")
	director._process(.1)
	check(events.is_empty(), "Alarm waits for authored offset")
	director._process(.1)
	check(events == ["alarm"] and is_equal_approx(offsets.back(), .05), "Crossing the offset starts alarm at the matching playback position")
	director._process(.1)
	check(events.size() == 1, "A cue starts once across subsequent frames")
	director.finish()
	check(sound.remaining == [0.0, 0.0] and sound.pending.is_empty() and events.size() == 1, "Skip clears sound and never triggers final-shot cues")
	director.play("morning")
	director._process(3)
	check(events.size() == 1 and director.shot_index == 1, "Large frame discards a cue that would already have ended")
	director._process(1.5)
	check(events.size() == 1, "Waking fabric waits for the movement cue")
	director._process(.2)
	check(events.size() == 2 and events.back() == "fabric" and is_equal_approx(offsets.back(), .1), "Waking movement triggers its fabric cue once at the authored offset")
	director.finish()
	check(sound.remaining == [0.0, 0.0] and sound.pending.is_empty(), "Skipping the waking shot clears its fabric sound")
	director.play("morning")
	director._process(.2)
	director.play("office")
	check(sound.remaining == [0.0, 0.0] and sound.pending.size() == 1, "Replacing a sequence clears previous voices and schedules only new cues")
	director.clear_room()
	check(sound.pending.is_empty() and sound.voices.all(func(p): return p.stream == null), "Cancellation releases streams and pending events")
	for key in ["master", "sfx"]:
		var before := events.size()
		GameState.settings[key] = 0.0
		director.play("morning")
		director._process(.2)
		check(events.size() == before and sound.remaining == [0.0, 0.0], "Muted cinematic event is dropped: " + key)
		GameState.settings[key] = GameState.DEFAULT_SETTINGS[key]
		director._process(.2)
		check(events.size() == before, "Unmute cannot replay elapsed cue: " + key)
	AudioManager.update_mix(0)
	director.play("departure")
	director.shot_index = _shot_index(director, "straps")
	director._show_shot()
	director._process(4.5)
	check(events.back() == "memory_motor" and is_equal_approx(sound.remaining[0], 3.9), "Memory sound begins before the visual cut")
	director._process(.5)
	check(director.stage_id == "memory" and is_equal_approx(sound.remaining[0], 3.4), "Sound tail survives the cut into memory")
	var before := events.size()
	director._process(2)
	check(director.stage_id == "parking" and is_equal_approx(sound.remaining[0], 1.4) and events.size() == before, "Same sound bridges memory back to present without restarting")
	director._process(1.5)
	check(sound.remaining == [0.0, 0.0], "Memory bridge ends in silence during title reveal")
	director._process(4.5)
	check(director.active_id.is_empty() and sound.pending.is_empty(), "Natural completion clears the audio timeline")
	# Pause/focus freeze both the director's clock and an in-flight native voice.
	director.play("departure")
	director.shot_index = _shot_index(director, "straps")
	director._show_shot()
	director._process(4.5)
	if visual_test:
		director.set_process(true)
		await frames(4)
		director.set_process(false)
		check(sound.voices[0].playing and sound.voices[0].get_playback_position() > .1, "Native cinematic playback advances after authored start")
		check(AudioServer.get_bus_peak_volume_left_db(AudioServer.get_bus_index("SFX"), 0) > -60, "Native cinematic samples reach the SFX bus")
	var held_time := director.elapsed
	var held_remaining := sound.remaining.duplicate()
	get_tree().paused = true
	sound._process(0)
	director._process(1)
	check(director.elapsed == held_time and sound.remaining == held_remaining, "Pause freezes picture and sound clocks together")
	if visual_test:
		check(sound.voices[0].stream_paused, "Native cinematic voice pauses in menus")
		var position := sound.voices[0].get_playback_position()
		await frames(6)
		check(absf(sound.voices[0].get_playback_position() - position) < .06, "Native playback position holds during pause")
	get_tree().paused = false
	AudioManager._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	sound._process(0)
	director._process(2)
	AudioManager.update_mix(0)
	check(director.elapsed == held_time and sound.remaining == held_remaining and AudioServer.is_bus_mute(0), "Background freezes cue and shot clocks and mutes master")
	if visual_test:
		check(sound.voices[0].stream_paused, "Native voice stays suspended while backgrounded")
	AudioManager._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
	AudioManager.update_mix(0)
	sound._process(0)
	director._process(.1)
	check(director.elapsed > held_time and sound.remaining[0] < held_remaining[0], "Focus return resumes existing cue without retrigger")
	if visual_test:
		check(sound.voices[0].playing and not sound.voices[0].stream_paused, "Native voice resumes rather than restarting")
	director.finish()
	check(sound.voices.all(func(p): return not p.playing and p.stream == null), "Skip stops all active native voices")
	# Multiple authored events, capacity, and unknown references are safe.
	sound.begin_shot([{"cue": "alarm", "at": 0}, {"cue": "phone", "at": 0}, {"cue": "memory_motor", "at": 0}])
	check(sound.remaining[0] > 0 and sound.remaining[1] > 0 and sound.voices.size() == 2, "Overlapping cues cannot allocate more than two voices")
	sound.stop()
	before = events.size()
	sound.begin_shot([{"cue": "unknown", "at": 0}])
	check(events.size() == before and sound.pending.is_empty(), "Unknown sound reference is discarded safely")
	director.play("departure")
	director.shot_index = 1
	director._show_shot()
	director._process(1.7)
	director._process(1.7)
	check(events.slice(before) == ["fabric", "fabric"], "Packing plays both authored fabric gestures once")
	director.shot_index = _shot_index(director, "laptop_packing")
	director._show_shot()
	before = events.size()
	director._process(3.1)
	director._process(3.6)
	check(events.slice(before) == ["fabric", "fabric"], "Laptop pickup and final flap closure each trigger one fabric cue")
	director.finish()
	check(sound.remaining == [0.0, 0.0] and sound.pending.is_empty(), "Skipping laptop packing clears fabric voices and future events")
	director.clear_room()
	# The departure flag belongs to the director; the sound component adds no state.
	GameState.flags = snapshot.flags.duplicate(true)
	check(GameState.snapshot() == snapshot and FileAccess.get_file_as_string(SaveManager.SAVE_PATH) == saved, "Cinematic audio has no save fields or checkpoint writes")
	director.queue_free()
	await frames(3)
	check(not is_instance_valid(sound), "Freeing director also frees cinematic audio pool")
	GameState.settings = GameState.DEFAULT_SETTINGS.duplicate(true)
	print("CINEMATIC AUDIO TEST RESULT: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)

func _shot_index(director: CutsceneDirector, id: String) -> int:
	for index in range(director.definitions.departure.shots.size()):
		if director.definitions.departure.shots[index].shot_id == id:
			return index
	return -1
