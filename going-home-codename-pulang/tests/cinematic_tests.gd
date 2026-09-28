extends "res://tests/test_runner.gd"

var completions: Array[String] = []

func _ready() -> void:
	visual_test = "--visual" in OS.get_cmdline_user_args()
	# Headless defaults to a square window; use the same authored landscape
	# viewport as native capture for camera projection assertions.
	get_window().size = Vector2i(1280, 720)
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
			if shot.get("performance", "rest") == "walk":
				valid = valid and shot.actor_from.size() == 3 and shot.actor_to.size() == 3 and shot.actor_from != shot.actor_to and shot.walk_cycles >= 1 and shot.walk_cycles <= 8 and int(shot.walk_cycles) == shot.walk_cycles
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
		var final_props := director.room.prop_snapshot()
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
			check(director.room.prop_snapshot() == final_props, "Skip restores final packing and luggage props: " + data.shots[i].shot_id)
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
	await _test_walk(director, "morning", "parking", "walker")
	await _test_walk(director, "office", "walk_to_meeting", "raka")
	await _test_wake(director)
	await _test_pack(director)
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

func _test_walk(director: CutsceneDirector, sequence: String, shot_id: String, actor_id: String) -> void:
	GameState.settings.reduced_motion = false
	director.play(sequence)
	for index in range(director.definitions[sequence].shots.size()):
		if director.definitions[sequence].shots[index].shot_id == shot_id:
			director.shot_index = index
	director._show_shot()
	var shot: Dictionary = director.definitions[sequence].shots[director.shot_index]
	var actor: CinematicActor = director.room.props[actor_id]
	var start := Vector3(shot.actor_from[0], shot.actor_from[1], shot.actor_from[2])
	var end := Vector3(shot.actor_to[0], shot.actor_to[1], shot.actor_to[2])
	check(actor.position.is_equal_approx(start) and actor.visible and actor.walking_legs.visible and not actor.seated_legs.visible, "Walking begins standing at its authored start: " + shot_id)
	check(not actor.helmet.visible and not actor.handset.visible, "Walking has no riding helmet or duplicate phone: " + shot_id)
	if actor_id == "walker":
		check(not director.room.props.rider.visible and director.room.props.bike.position == Vector3.ZERO, "Approach hides seated rider and leaves motorcycle parked")
	_check_walk_framing(director.camera, actor, shot_id + " start")
	await capture("walk_" + shot_id + "_start")
	var initial := actor.pose_snapshot()
	director._apply_shot(0.4)
	var progress := smoothstep(0.0, 1.0, 0.4)
	check(actor.position.is_equal_approx(start.lerp(end, progress)) and actor.pose_snapshot() != initial, "Root travel and articulated gait advance together: " + shot_id)
	check((-actor.basis.z).dot((end - start).normalized()) > 0.99, "Walking faces its authored travel direction: " + shot_id)
	_check_walk_framing(director.camera, actor, shot_id + " middle")
	await capture("walk_" + shot_id + "_middle")
	var held := director.room.actor_snapshot()
	get_tree().paused = true
	director.set_process(true)
	await frames(10)
	check(director.room.actor_snapshot() == held, "Pause freezes walking root and leg joints: " + shot_id)
	get_tree().paused = false
	director.set_process(false)
	GameState.settings.reduced_motion = true
	director._apply_shot(0.4)
	check(director.room.actor_snapshot() == held, "Reduced camera motion retains story actor movement: " + shot_id)
	director._apply_shot(0.85)
	director._apply_shot(0.4)
	check(director.room.actor_snapshot() == held, "Seeking backwards restores walking root and gait deterministically: " + shot_id)
	director._apply_shot(1)
	check(actor.position.is_equal_approx(end) and actor.pose_snapshot() == initial, "Walking lands at its endpoint with a neutral stance: " + shot_id)
	_check_walk_framing(director.camera, actor, shot_id + " end")
	await capture("walk_" + shot_id + "_end")
	director.shot_index += 1
	director._show_shot()
	if actor_id == "walker":
		check(not actor.visible and director.room.props.rider.visible, "Cluster cut restores the seated rider without a duplicate Raka")
	else:
		check(actor.seated_legs.visible and not actor.walking_legs.visible and actor.position == Vector3(0, 0, 0.45) and actor.body.position == Vector3.ZERO, "Meeting cut restores original seated proportions and placement")

func _check_walk_framing(camera: Camera3D, actor: CinematicActor, label: String) -> void:
	var size := get_viewport().get_visible_rect().size
	var visible := true
	for height in [0.015, 1.82]:
		var point := actor.global_position + Vector3(0, height, 0)
		var screen := camera.unproject_position(point)
		var fits := not camera.is_position_behind(point) and screen.x > 0 and screen.x < size.x and screen.y > size.y * 0.15 and screen.y < size.y * 0.78
		if not fits:
			print("Framing sample: ", label, " height=", height, " screen=", screen, " viewport=", size)
		visible = visible and fits
	check(visible, "Walking head and feet stay between cinematic caption bars: " + label)

func _test_wake(director: CutsceneDirector) -> void:
	var saved := GameState.snapshot()
	GameState.settings.reduced_motion = false
	director.play("morning")
	check(director.room.props.phone_body.position == Vector3(1.5, 0.75, -1.75), "Morning alarm sits on the bedside table")
	await capture("wake_alarm")
	director.shot_index = 1
	director._show_shot()
	var actor: CinematicActor = director.room.props.raka
	check(actor.active_clip == "wake" and actor.position == Vector3(2.5, 0.13, -1.05), "Waking starts with Raka on the bed")
	check(absf(actor.body.basis.y.dot(Vector3.UP)) < 0.001 and actor.walking_legs.visible and not actor.seated_legs.visible, "Waking begins with a horizontal torso and extended articulated legs")
	check(actor.bare_feet.all(func(foot): return foot.visible) and actor.shoes.all(func(shoe): return not shoe.visible) and not actor.helmet.visible and not actor.handset.visible, "Bed pose has bare feet and no phone or helmet props")
	var initial := director.room.actor_snapshot()
	await capture("wake_lying")
	director._apply_shot(0.5)
	check(actor.pose_snapshot() != initial.raka[2] and actor.body.basis.y.dot(Vector3.UP) > 0.2, "Waking lifts the torso and moves toward the bed edge")
	await capture("wake_rising")
	var middle := director.room.actor_snapshot()
	var clock_before := director.elapsed
	get_tree().paused = true
	director.set_process(true)
	await frames(10)
	check(director.room.actor_snapshot() == middle and director.elapsed == clock_before, "Pause freezes waking torso, legs, root and clock")
	get_tree().paused = false
	AudioManager.focus_suspended = true
	await frames(10)
	check(director.room.actor_snapshot() == middle and director.elapsed == clock_before, "Background audio focus freezes waking animation")
	AudioManager.focus_suspended = false
	director.set_process(false)
	GameState.settings.reduced_motion = true
	director._apply_shot(0.5)
	check(director.room.actor_snapshot() == middle, "Reduced camera motion preserves the waking performance")
	director._apply_shot(1)
	check(actor.position.is_equal_approx(Vector3(2.5, 0, 0.2)) and actor.body.rotation.is_zero_approx(), "Waking finishes upright at the foot of the bed")
	await capture("wake_seated")
	director._apply_shot(0.5)
	check(director.room.actor_snapshot() == middle, "Backward seeking restores the same mid-wake pose")
	director._apply_shot(0)
	check(director.room.actor_snapshot() == initial, "Rewinding waking restores the original lying pose")
	var legs_clear := true
	for step in range(41):
		director._apply_shot(float(step) / 40)
		for hip in actor.walking_legs.get_children():
			var knee: Node3D = hip.get_node("Knee")
			for fraction in [0.0, 0.5, 1.0]:
				var point := director.room.to_local(knee.to_global(Vector3(0, -0.48 * fraction, 0)))
				if point.z < 0.39 and point.z > -2.3:
					legs_clear = legs_clear and point.y > 0.66
	check(legs_clear, "Waking shins clear the foot edge before bending below the mattress")
	director.shot_index = 2
	director._show_shot()
	check(not actor.visible and actor.body.rotation.is_zero_approx() and actor.body.position == Vector3.ZERO and actor.head.position == Vector3(0, 1.28, 0), "Coffee insert clears waking torso/head offsets and hides Raka")
	check(actor.seated_legs.visible and not actor.walking_legs.visible and actor.bare_feet.all(func(foot): return not foot.visible), "Ordinary clips restore seated geometry and hide bare feet")
	check(director.room.props.phone_body.position == Vector3(0.86, 0.925, -0.45), "Following shots restore the desk phone placement")
	check(GameState.snapshot() == saved, "Waking performance and seeking leave journey state unchanged")

func _test_pack(director: CutsceneDirector) -> void:
	var saved := GameState.snapshot()
	director.play("departure")
	for index in range(director.definitions.departure.shots.size()):
		if director.definitions.departure.shots[index].shot_id == "packing":
			director.shot_index = index
	director._show_shot()
	var stage := director.room
	var packing: PackingProps = stage.props.bag
	var actor: CinematicActor = stage.props.raka
	var shot: Dictionary = director.definitions.departure.shots[director.shot_index]
	var initial := stage.prop_snapshot()
	var nodes := get_tree().get_node_count()
	check(packing.visible and packing.raincoat.position == PackingProps.START and packing.flap.rotation.x > 1.5, "Packing starts with a raincoat beside an open bag")
	check(not stage.props.badge.visible and not stage.props.badge_text.visible and not stage.props.lanyard.visible, "Packing hides the complete office badge prop")
	await capture("pack_ready")
	stage.pose(shot, 0.37)
	check(packing.raincoat.position.y > 1.25, "Packing lifts the raincoat above the bag rim")
	await capture("pack_lift")
	var held_props := stage.prop_snapshot()
	var held_actor := stage.actor_snapshot()
	var clock_before := director.elapsed
	get_tree().paused = true
	director.set_process(true)
	await frames(10)
	check(stage.prop_snapshot() == held_props and stage.actor_snapshot() == held_actor and director.elapsed == clock_before, "Pause freezes packing hands, raincoat and flap")
	get_tree().paused = false
	AudioManager.focus_suspended = true
	await frames(10)
	check(stage.prop_snapshot() == held_props and stage.actor_snapshot() == held_actor, "Background focus freezes packing props and hands")
	AudioManager.focus_suspended = false
	director.set_process(false)
	stage.pose(shot, 1)
	stage.pose(shot, 0.37)
	check(stage.prop_snapshot() == held_props and stage.actor_snapshot() == held_actor, "Backward seeking restores packing contact and props")
	var left_contact := true
	var right_contact := true
	var clearance := true
	var framed := true
	var viewport_size := get_viewport().get_visible_rect().size
	for step in range(101):
		var weight := float(step) / 100
		stage.pose(shot, weight)
		if weight >= 0.16 and weight <= 0.59:
			left_contact = left_contact and actor.left_forearm.to_global(Vector3(0, -0.29, 0)).distance_to(packing.raincoat.to_global(Vector3(0, 0.06, 0))) < 0.002
		if weight >= 0.72 and weight <= 0.90:
			right_contact = right_contact and actor.right_forearm.to_global(Vector3(0, -0.29, 0)).distance_to(packing.flap.to_global(Vector3(0.10, 0.025, -0.18))) < 0.002
		if packing.raincoat.position.x > -0.37 and weight < 0.44:
			clearance = clearance and packing.raincoat.position.y - 0.05 > 1.14
		var points: Array[Vector3] = []
		for x in [-0.12, 0.12]:
			for y in [-0.05, 0.06]:
				for z in [-0.09, 0.09]:
					points.append(packing.raincoat.to_global(Vector3(x, y, z)))
		for x in [-0.30, 0.30]:
			for z in [0.0, -0.46]:
				points.append(packing.flap.to_global(Vector3(x, 0.025, z)))
		for point in points:
			var pixel := director.camera.unproject_position(point)
			framed = framed and not director.camera.is_position_behind(point) and pixel.x > 0 and pixel.x < viewport_size.x and pixel.y > viewport_size.y * 0.15 and pixel.y < viewport_size.y * 0.78
	check(left_contact, "Raincoat grip remains within 2 mm throughout pickup and placement")
	check(right_contact, "Right hand follows the flap throughout closure")
	check(clearance, "Raincoat clears the bag wall before crossing into its opening")
	check(framed, "Raincoat and flap stay between caption bars throughout packing")
	check(get_tree().get_node_count() == nodes, "Packing sampling never duplicates props or creates animation nodes")
	stage.pose(shot, 0.65)
	check(packing.raincoat.position == PackingProps.INSIDE and packing.flap.rotation.x > 1.5, "Raincoat settles inside before the flap closes")
	await capture("pack_placed")
	stage.pose(shot, 0.81)
	await capture("pack_closing")
	stage.pose(shot, 1)
	check(is_zero_approx(packing.flap.rotation.x) and packing.raincoat.position == PackingProps.INSIDE, "Packing ends with a closed flap and the raincoat retained inside")
	await capture("pack_closed")
	var final_props := stage.prop_snapshot()
	stage.pose(shot, 0)
	check(stage.prop_snapshot() == initial, "Rewinding packing restores the open bag and unpacked raincoat")
	director._apply_shot(0.5)
	held_props = stage.prop_snapshot()
	held_actor = stage.actor_snapshot()
	GameState.settings.reduced_motion = not GameState.settings.reduced_motion
	director._apply_shot(0.5)
	check(stage.prop_snapshot() == held_props and stage.actor_snapshot() == held_actor, "Reduced camera motion preserves packing movement")
	director.shot_index += 1
	director._show_shot()
	check(stage.prop_snapshot() == final_props, "Route insert retains the packed bag when entered directly")
	check(actor.body.position == Vector3.ZERO and not actor.visible, "Route insert clears the packing lean and actor")
	check(GameState.snapshot() == saved, "Packing animation leaves journey state unchanged")
	director.play("morning")
	check(not director.room.props.bag.visible and director.room.props.badge_text.visible and director.room.props.lanyard.visible, "Replaying morning hides luggage and restores the complete badge")
