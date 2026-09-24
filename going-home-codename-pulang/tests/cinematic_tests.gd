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
			valid = valid and shot.get("performance", "rest") in CinematicActor.CLIPS and shot.get("npc_performance", "listen") in CinematicActor.CLIPS
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
		var final_actors := director.room.actor_snapshot()
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
			check(director.room.actor_snapshot() == final_actors, "Skip restores the final actor poses: " + data.shots[i].shot_id)
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
	director.shot_index = director.definitions.departure.shots.size() - 1
	director._show_shot()
	director._process(3)
	check(director.room.props.bike.position.x > 1 and director.room.props.bike.position.x == director.room.props.rider.position.x, "Departure moves motorcycle and rider together")
	check(director.room.props.luggage.visible and director.audio_context() == "city", "Departure carries luggage and uses parking ambience")
	check(not director.room.props.bike.show_rider_arms and director.room.props.rider.helmet.visible, "Cinematic rider wears helmet without duplicate cockpit arms")
	await capture("cinematic_departure_midpoint")
	director.play("night")
	director.shot_index = director.definitions.night.shots.size() - 1
	director._show_shot()
	var actor: CinematicActor = director.room.props.raka
	check(actor.animator.callback_mode_process == AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL, "Actor AnimationPlayer uses the director's clock")
	var initial_pose := actor.pose_snapshot()
	director._process(2)
	check(actor.pose_snapshot() != initial_pose and actor.handset.visible and not director.room.props.phone_body.visible, "Phone gesture moves joints and transfers visible handset off the desk")
	await capture("performance_phone")
	var held_pose := actor.pose_snapshot()
	await frames(12)
	check(actor.pose_snapshot() == held_pose, "Actor cannot advance independently of the director")
	get_tree().paused = true
	director.set_process(true)
	await frames(12)
	check(actor.pose_snapshot() == held_pose, "Pause freezes actor joints and handset state")
	get_tree().paused = false
	director.set_process(false)
	director.finish()
	check(actor.handset.visible and actor.active_clip == "phone", "Mother dialogue handoff retains the phone pose")
	for clip in CinematicActor.CLIPS:
		check(actor.sample(clip, 0.5), "Authored performance can be sampled: " + clip)
		var middle := actor.pose_snapshot()
		actor.sample(clip, 1)
		actor.sample(clip, 0.5)
		check(actor.pose_snapshot() == middle, "Seeking is deterministic: " + clip)
	held_pose = actor.pose_snapshot()
	check(not actor.sample("missing", 0.5) and actor.pose_snapshot() == held_pose, "Unknown clip preserves the current actor pose")
	director.play("departure")
	director.shot_index = 1
	director._show_shot()
	director._process(2.5)
	check(director.room.props.raka.active_clip == "pack" and director.room.props.raka.visible, "Packing insert shows its authored hand gesture")
	await capture("performance_pack")
	director.shot_index = director.definitions.departure.shots.size() - 2
	director._show_shot()
	check(director.stage_id == "memory" and director.room.props.young_raka.scale.x < 1 and director.room.props.young_raka.position.x < director.room.props.rider.position.x, "Memory places young Raka behind father")
	check(director.room.props.young_raka.active_clip == "passenger" and director.room.props.young_raka.helmet.visible and director.room.props.rider.helmet.visible and not director.room.props.luggage.visible, "Memory uses helmeted father/passenger poses without departure luggage")
	check(director.audio_context() == "fields", "Memory uses quiet exterior ambience")
	await capture("performance_memory")
	director._process(2)
	check(director.stage_id == "parking" and not director.room.props.has("young_raka") and director.room.props.luggage.visible, "Memory returns cleanly to present-day departure")
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
