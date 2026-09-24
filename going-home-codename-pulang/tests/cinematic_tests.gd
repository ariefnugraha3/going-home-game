extends "res://tests/test_runner.gd"

var completions: Array[String] = []

func _ready() -> void:
	visual_test = "--visual" in OS.get_cmdline_user_args()
	Engine.max_fps = (30 if "--limit-30" in OS.get_cmdline_user_args() else 60) if visual_test else 0
	GameState.new_journey()
	GameState.settings.reduced_motion = false
	app = preload("res://scenes/boot/Boot.tscn").instantiate()
	add_child(app)
	await frames(4)
	app.set_process(false)
	var director: CutsceneDirector = app.director
	director.set_process(false)
	director.finished.disconnect(app._cutscene_finished)
	director.finished.connect(func(id: String): completions.append(id))
	check(director.definitions.size() == 5, "Five opening sequences include post-meeting sign-out")
	for id in director.definitions:
		var data: Dictionary = director.definitions[id]
		var ids: Array = []
		var valid: bool = not data.purpose.is_empty() and not data.audio_priority.is_empty()
		for shot in data.shots:
			valid = valid and not ids.has(shot.shot_id) and shot.duration >= 2 and shot.fov >= 30 and shot.fov <= 60 and shot.camera.size() == 3 and shot.target.size() == 3 and not shot.framing.is_empty()
			ids.append(shot.shot_id)
		check(valid, "Authored timing, framing and stable IDs: " + id)
		var before := completions.size()
		GameState.set_flag("story.prologue.departed", false)
		director.play(id)
		for i in range(data.shots.size()):
			var shot: Dictionary = data.shots[i]
			check(director.shot_index == i and director.stage_id == shot.get("location", data.location), "Timeline selects shot and set: " + shot.shot_id)
			await capture("cinematic_" + id + "_" + shot.shot_id)
			director._process(shot.duration)
		check(director.active_id.is_empty() and completions.size() == before + 1, "Natural completion emits exactly once: " + id)
		var expected_flags := GameState.flags.duplicate(true)
		var final_stage := director.stage_id
		var final_camera := director.camera.transform
		for i in range(data.shots.size()):
			GameState.set_flag("story.prologue.departed", false)
			director.play(id)
			director.shot_index = i
			director._show_shot()
			before = completions.size()
			director.finish()
			director.finish()
			check(GameState.flags == expected_flags and completions.size() == before + 1, "Skip matches final flags exactly once: " + data.shots[i].shot_id)
			check(director.stage_id == final_stage and director.camera.transform.is_equal_approx(final_camera), "Skip restores final set and framing: " + data.shots[i].shot_id)
	director.play("morning")
	director.shot_index = 1
	director._show_shot()
	var start := director.camera.position
	director._process(2.5)
	check(director.camera.position.distance_to(start) > 0.05, "Authored dolly moves the camera gently")
	GameState.settings.reduced_motion = true
	director._show_shot()
	start = director.camera.position
	director._process(2.5)
	check(director.camera.position.is_equal_approx(start), "Reduced motion preserves static shot framing")
	director.set_process(true)
	get_tree().paused = true
	var time := director.elapsed
	await frames(12)
	check(is_equal_approx(director.elapsed, time), "Pause freezes shot clock and camera")
	get_tree().paused = false
	director.set_process(false)
	director.play("departure")
	director.shot_index = 4
	director._show_shot()
	director._process(3)
	check(director.room.props.bike.position.x > 1 and director.room.props.bike.position.x == director.room.props.rider.position.x, "Departure moves motorcycle and rider together")
	check(director.room.props.luggage.visible and director.audio_context() == "city", "Departure carries luggage and uses parking ambience")
	await capture("cinematic_departure_midpoint")
	director.play("night")
	check(director.audio_context() == "indoors" and director.room.props.raka.visible, "Night restores apartment and seated Raka")
	var old_room := director.room
	director.play("office")
	check(not is_instance_valid(old_room), "Replacing a sequence frees its old stage immediately")
	old_room = director.room
	director.clear_room()
	check(not is_instance_valid(old_room) and director.active_id.is_empty() and director.room == null, "Cancellation clears stage and timeline together")
	director.play("unknown")
	check(director.active_id.is_empty(), "Unknown sequence leaves director idle")
	director.play("morning")
	Input.action_press("skip_cutscene")
	director._process(0.4)
	check(director.active_id == "morning", "Brief skip press does not end a sequence")
	director._process(0.41)
	Input.action_release("skip_cutscene")
	check(director.active_id.is_empty(), "Holding skip completes the sequence")
	director.finished.connect(app._cutscene_finished)
	director.set_process(true)
	app.set_process(true)
	GameState.checkpoint = "departure"
	app._restore_checkpoint()
	await settle()
	check(app.state == "cutscene" and director.active_id == "departure" and not app.bike.enabled, "Continue restores departure with riding locked")
	director.finish()
	await settle()
	check(app.state == "riding" and app.bike.enabled and app.bike.camera.is_current() and GameState.checkpoint == "road_start", "Departure skip restores camera, controls and stable checkpoint")
	app.queue_free()
	await frames(4)
	GameState.settings.reduced_motion = true
	print("CINEMATIC TEST RESULT: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)
