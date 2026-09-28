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
	await _test_laptop(director)
	await _test_straps(director)
	await _test_bike_touch(director)
	await _test_mount(director)
	await _test_helmet(director)
	await _test_chin_strap(director)
	director.play("departure")
	director.shot_index = director.definitions.departure.shots.size() - 1
	director._show_shot()
	director._process(3)
	check(director.room.props.bike.position.x > 1 and director.room.props.bike.to_local(director.room.props.rider.global_position).distance_to(CinematicMount.SEAT) < 0.002, "Departure moves motorcycle and rider together at the seat anchor")
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
	for i in range(director.definitions.departure.shots.size()):
		if director.definitions.departure.shots[i].shot_id == "father_memory":
			director.shot_index = i
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
		if packing.raincoat.position.x > -0.43 and weight < 0.44:
			clearance = clearance and packing.raincoat.position.y - 0.05 > 1.17
		var points: Array[Vector3] = []
		for x in [-0.12, 0.12]:
			for y in [-0.05, 0.06]:
				for z in [-0.09, 0.09]:
					points.append(packing.raincoat.to_global(Vector3(x, y, z)))
		for x in [-0.39, 0.39]:
			for z in [0.0, -0.52]:
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

func _test_laptop(director: CutsceneDirector) -> void:
	var saved := GameState.snapshot()
	director.play("departure")
	var index := 0
	for i in range(director.definitions.departure.shots.size()):
		if director.definitions.departure.shots[i].shot_id == "laptop_packing":
			index = i
	check(index > 0 and director.definitions.departure.shots[index - 1].shot_id == "route", "Laptop packing follows route planning")
	director.shot_index = index - 1
	director._show_shot()
	var stage := director.room
	var laptop: CinematicLaptop = stage.props.laptop
	var actor: CinematicActor = stage.props.raka
	var bag: PackingProps = stage.props.bag
	check(laptop.position == CinematicLaptop.DESK and laptop.screen.visible and laptop.screen.text.contains("Banyuwangi"), "Route planning retains the open desk laptop and route text")
	director.shot_index = index
	director._show_shot()
	var shot: Dictionary = director.definitions.departure.shots[index]
	var initial := stage.prop_snapshot()
	var nodes := get_tree().get_node_count()
	check(laptop.position == CinematicLaptop.START and laptop.screen.visible and is_zero_approx(laptop.lid.rotation.x) and bag.flap.rotation.x > 1.5, "Laptop insert begins with an open laptop beside the reopened bag")
	await capture("laptop_ready")
	var contacts := true
	var clearance := true
	var walls_clear := true
	var framed := true
	var size := get_viewport().get_visible_rect().size
	for step in range(101):
		var p := float(step) / 100
		stage.pose(shot, p)
		var left_hand := actor.left_forearm.to_global(Vector3(0, -0.29, 0))
		var right_hand := actor.right_forearm.to_global(Vector3(0, -0.29, 0))
		if p >= 0.08 and p <= 0.25:
			contacts = contacts and left_hand.distance_to(laptop.lid.to_global(Vector3(0, 0.22, 0.025))) < 0.002
		if p >= 0.32 and p <= 0.76:
			contacts = contacts and left_hand.distance_to(laptop.to_global(Vector3(-0.30, 0.03, 0))) < 0.002 and right_hand.distance_to(laptop.to_global(Vector3(0.30, 0.03, 0))) < 0.002
		if p >= 0.84 and p <= 0.96:
			contacts = contacts and right_hand.distance_to(bag.flap.to_global(Vector3(0.10, 0.025, -0.18))) < 0.002
		if p >= 0.43 and p <= 0.62:
			clearance = clearance and laptop.position.y - 0.025 > 1.17 and is_equal_approx(laptop.lid.rotation.x, PI / 2)
		var bounds := AABB(laptop.position - Vector3(0.325, 0.025, 0.225), Vector3(0.65, 0.075, 0.45))
		for wall in [AABB(Vector3(-0.34, 0.92, -0.52), Vector3(0.03, 0.24, 0.52)), AABB(Vector3(0.41, 0.92, -0.52), Vector3(0.03, 0.24, 0.52)), AABB(Vector3(-0.34, 0.92, -0.52), Vector3(0.78, 0.24, 0.03)), AABB(Vector3(-0.34, 0.92, -0.03), Vector3(0.78, 0.24, 0.03))]:
			walls_clear = walls_clear and not bounds.intersects(wall)
		for x in [-0.325, 0.325]:
			for z in [-0.225, 0.225]:
				var pixel := director.camera.unproject_position(laptop.to_global(Vector3(x, 0, z)))
				framed = framed and pixel.x > 0 and pixel.x < size.x and pixel.y > size.y * 0.15 and pixel.y < size.y * 0.78
			for y in [0.0, 0.40]:
				var pixel := director.camera.unproject_position(laptop.lid.to_global(Vector3(x, y, 0)))
				framed = framed and pixel.x > 0 and pixel.x < size.x and pixel.y > size.y * 0.15 and pixel.y < size.y * 0.78
	check(contacts, "Hands retain lid, two-handed laptop and flap contacts within 2 mm")
	check(clearance, "Laptop closes before lifting and clears the bag walls during transfer")
	check(walls_clear, "Laptop bounds never intersect bag walls during pickup, transfer or placement")
	check(framed, "Laptop base and lid stay between caption bars throughout the insert")
	check(get_tree().get_node_count() == nodes, "Laptop sampling retains a single prop without allocating nodes")
	stage.pose(shot, 0.27)
	check(not laptop.screen.visible and is_equal_approx(laptop.lid.rotation.x, PI / 2), "Closing the laptop hides the screen before pickup")
	await capture("laptop_closed")
	stage.pose(shot, 0.52)
	await capture("laptop_lift")
	var middle := stage.prop_snapshot()
	var pose := stage.actor_snapshot()
	var elapsed := director.elapsed
	director.set_process(true)
	get_tree().paused = true
	await frames(8)
	check(stage.prop_snapshot() == middle and stage.actor_snapshot() == pose and director.elapsed == elapsed, "Pause freezes laptop and both hands")
	get_tree().paused = false
	AudioManager.focus_suspended = true
	await frames(8)
	check(stage.prop_snapshot() == middle and stage.actor_snapshot() == pose, "Background freezes laptop packing")
	AudioManager.focus_suspended = false
	director.set_process(false)
	stage.pose(shot, 1)
	check(laptop.position == CinematicLaptop.INSIDE and is_zero_approx(bag.flap.rotation.x) and not laptop.screen.visible, "Laptop finishes inside the closed bag")
	check(laptop.position.x - 0.325 > -0.31 and laptop.position.x + 0.325 < 0.41 and laptop.position.z - 0.225 > -0.49 and laptop.position.z + 0.225 < -0.03 and laptop.position.y - 0.025 > bag.raincoat.position.y + 0.05 and laptop.position.y + 0.05 < 1.1575, "Packed laptop fits within the bag above the raincoat and below the flap")
	await capture("laptop_packed")
	stage.pose(shot, 0.52)
	check(stage.prop_snapshot() == middle and stage.actor_snapshot() == pose, "Backward seeking restores laptop and hand poses exactly")
	stage.pose(shot, 0)
	check(stage.prop_snapshot() == initial, "Rewinding restores laptop, bag and chair starting transforms")
	director._apply_shot(0.5)
	middle = stage.prop_snapshot()
	pose = stage.actor_snapshot()
	GameState.settings.reduced_motion = not GameState.settings.reduced_motion
	director._apply_shot(0.5)
	check(stage.prop_snapshot() == middle and stage.actor_snapshot() == pose, "Reduced camera motion preserves laptop action")
	director.shot_index = index - 1
	director._show_shot()
	check(laptop.position == CinematicLaptop.DESK and laptop.screen.visible and is_zero_approx(laptop.lid.rotation.x) and actor.body.position == Vector3.ZERO and stage.props.raka_chair.position == Vector3(0, 0, 0.45), "Returning to route restores the open desk laptop and clears packing placement")
	check(GameState.snapshot() == saved, "Laptop packing and seeking leave journey state unchanged")
	director.shot_index = index
	director._show_shot()
	director._process(8)
	check(director.stage_id == "parking" and director.room.props.luggage.visible and not is_instance_valid(laptop), "Laptop packing hands off to parking and frees the interior props")

func _test_straps(director: CutsceneDirector) -> void:
	var saved := GameState.snapshot()
	director.play("departure")
	for i in range(director.definitions.departure.shots.size()):
		if director.definitions.departure.shots[i].shot_id == "straps":
			director.shot_index = i
	director._show_shot()
	var stage := director.room
	var shot: Dictionary = director.definitions.departure.shots[director.shot_index]
	var luggage: CinematicLuggage = stage.props.luggage
	var actor: CinematicActor = stage.props.walker
	var bike: Node3D = stage.props.bike
	var nodes := get_tree().get_node_count()
	var initial := stage.prop_snapshot()
	var feet := [actor.walking_legs.get_child(0).global_transform, actor.walking_legs.get_child(1).global_transform]
	check(actor.visible and actor.walking_legs.visible and not actor.seated_legs.visible and not stage.props.rider.visible, "Strap check shows one standing Raka beside the parked motorcycle")
	check(not actor.helmet.visible and not actor.handset.visible and luggage.visible and luggage.tensions == [0.0, 0.0], "Strap check begins with two loose prethreaded bands and no phone/helmet props")
	await capture("straps_ready")
	stage.pose(shot, 0.24)
	check(luggage.tensions == [1.0, 0.0] and luggage.grips[0].y > 0.17, "First pull tightens only the first strap")
	await capture("straps_first_pull")
	stage.pose(shot, 0.60)
	check(is_equal_approx(luggage.tensions[1], 1) and luggage.grips[1].y > 0.17, "Second pull tightens the other strap")
	await capture("straps_second_pull")
	var held := stage.prop_snapshot()
	var held_actor := stage.actor_snapshot()
	var elapsed := director.elapsed
	get_tree().paused = true
	director.set_process(true)
	await frames(8)
	check(stage.prop_snapshot() == held and stage.actor_snapshot() == held_actor and director.elapsed == elapsed, "Pause freezes strap geometry and both hands")
	get_tree().paused = false
	AudioManager.focus_suspended = true
	await frames(8)
	check(stage.prop_snapshot() == held and stage.actor_snapshot() == held_actor, "Background freezes luggage tightening")
	AudioManager.focus_suspended = false
	director.set_process(false)
	stage.pose(shot, 1)
	stage.pose(shot, 0.60)
	check(stage.prop_snapshot() == held and stage.actor_snapshot() == held_actor, "Backward seeking restores strap shapes, tails and hand contact")
	var contact := true
	var torso_clear := true
	var planted := true
	var framed := true
	var anchored := true
	var size := get_viewport().get_visible_rect().size
	for step in range(101):
		var p := float(step) / 100
		stage.pose(shot, p)
		for i in range(2):
			var start := 0.12 if i == 0 else 0.48
			var forearm := actor.left_forearm if i == 0 else actor.right_forearm
			if p >= start and p <= start + 0.28:
				contact = contact and forearm.to_global(Vector3(0, -0.29, 0)).distance_to(luggage.to_global(luggage.grips[i])) < 0.002
				torso_clear = torso_clear and actor.to_local(luggage.to_global(luggage.grips[i])).z < -0.215
			planted = planted and actor.walking_legs.get_child(i).global_transform == feet[i]
			var first: MeshInstance3D = luggage.bands[i][0]
			var last: MeshInstance3D = luggage.bands[i][6]
			anchored = anchored and (first.transform * Vector3(0, -0.5, 0)).is_equal_approx(Vector3(-0.245, -0.24, CinematicLuggage.STRAP_Z[i]))
			anchored = anchored and (last.transform * Vector3(0, 0.5, 0)).is_equal_approx(Vector3(0.245, -0.24, CinematicLuggage.STRAP_Z[i]))
		var points := [luggage.to_global(luggage.grips[0]), luggage.to_global(luggage.grips[1])]
		for x in [-0.39, 0.39]:
			for z in [-0.26, 0.26]:
				for y in [-0.14, 0.16]:
					points.append(luggage.to_global(Vector3(x, y, z)))
		for point in points:
			var pixel := director.camera.unproject_position(point)
			framed = framed and not director.camera.is_position_behind(point) and pixel.x > 0 and pixel.x < size.x and pixel.y > size.y * 0.15 and pixel.y < size.y * 0.78
	check(contact, "Both strap grips retain hand contact within 2 mm through pull and release preparation")
	check(torso_clear, "Strap grips leave room for the hands in front of the torso")
	check(planted and bike.position == Vector3.ZERO, "Strap checking keeps both feet and the motorcycle stationary")
	check(anchored, "Both strap loops retain their frame attachment endpoints throughout tightening")
	check(framed, "Luggage and strap grips stay between caption bars throughout the shot")
	check(get_tree().get_node_count() == nodes, "Strap sampling changes transforms without allocating nodes")
	check(luggage.tensions == [1.0, 1.0] and luggage.grips[0].x < 0.45 and luggage.grips[1].x < 0.45, "Strap check ends with both bands taut and short secured tails")
	var final_luggage := luggage.pose_snapshot()
	await capture("straps_secured")
	stage.pose(shot, 0)
	check(stage.prop_snapshot() == initial, "Rewinding restores both loose strap shapes")
	director._apply_shot(0.5)
	held = stage.prop_snapshot()
	held_actor = stage.actor_snapshot()
	GameState.settings.reduced_motion = not GameState.settings.reduced_motion
	director._apply_shot(0.5)
	check(stage.prop_snapshot() == held and stage.actor_snapshot() == held_actor, "Reduced camera motion retains strap and actor movement")
	check(GameState.snapshot() == saved, "Strap action adds no journey fields or checkpoint changes")
	director._process(5)
	check(director.definitions.departure.shots[director.shot_index].shot_id == "bike_touch" and director.room.props.luggage.pose_snapshot() == final_luggage, "Strap check hands off to bike touch with secured luggage intact")
	director._process(5)
	check(director.stage_id == "memory" and not director.room.props.luggage.visible and not is_instance_valid(luggage), "Memory cut frees checked luggage and omits it from the past")
	director._process(2)
	check(director.room.props.luggage.pose_snapshot() == final_luggage and not director.room.props.walker.visible and director.room.props.rider.visible, "Present-day mounting restores the same secured luggage and a single rider")
	director._process(5)
	director._process(4)
	director._process(5)
	var departing: CinematicLuggage = director.room.props.luggage
	var position_before := departing.global_position
	director._process(3)
	check(departing.global_position.x > position_before.x + 1 and departing.pose_snapshot() == final_luggage, "Secured luggage moves rigidly with the departing motorcycle")
	director.play("morning")
	for i in range(director.definitions.morning.shots.size()):
		if director.definitions.morning.shots[i].shot_id == "parking":
			director.shot_index = i
	director._show_shot()
	check(not director.room.props.luggage.visible and director.room.props.walker.visible and not director.room.props.rider.visible, "Morning approach resets to walking without departure luggage")

func _test_helmet(director: CutsceneDirector) -> void:
	var saved := GameState.snapshot()
	director.play("departure")
	for i in range(director.definitions.departure.shots.size()):
		if director.definitions.departure.shots[i].shot_id == "helmet":
			director.shot_index = i
	var shots: Array = director.definitions.departure.shots
	check(shots[director.shot_index - 1].shot_id == "father_memory" and shots[director.shot_index + 1].shot_id == "chin_strap", "Helmet preparation connects memory to the strap check")
	director._show_shot()
	var stage := director.room
	var actor: CinematicActor = stage.props.rider
	var shot: Dictionary = shots[director.shot_index]
	var props := stage.prop_snapshot()
	var initial := stage.actor_snapshot()
	var feet := [actor.shoes[0].global_transform, actor.shoes[1].global_transform]
	var nodes := get_tree().get_node_count()
	check(actor.visible and actor.helmet.visible and not stage.props.walker.visible and actor.helmet.position.z < -0.4, "One standing Raka begins with the existing helmet held in front")
	await capture("helmet_held")
	stage.pose(shot, 0.36)
	await capture("helmet_lift")
	stage.pose(shot, 0.56)
	check(actor.helmet.position.y > 0.5 and absf(actor.helmet.position.z - 0.015) < 0.002, "Helmet moves above the head before lowering")
	await capture("helmet_above")
	var held := stage.actor_snapshot()
	get_tree().paused = true
	director.set_process(true)
	var elapsed := director.elapsed
	await frames(8)
	check(stage.actor_snapshot() == held and director.elapsed == elapsed, "Pause freezes helmet, hands and shared clock")
	get_tree().paused = false
	AudioManager.focus_suspended = true
	await frames(8)
	check(stage.actor_snapshot() == held, "Background freezes helmet preparation")
	AudioManager.focus_suspended = false
	director.set_process(false)
	stage.pose(shot, 1)
	stage.pose(shot, 0.56)
	check(stage.actor_snapshot() == held, "Rewind restores helmet offset and both arm poses")
	var contact := true
	var planted := true
	var framed := true
	var shoulders_joined := true
	var size := get_viewport().get_visible_rect().size
	for step in range(101):
		var p := float(step) / 100
		stage.pose(shot, p)
		for i in range(2):
			planted = planted and actor.shoes[i].global_transform.is_equal_approx(feet[i])
			var bridge: MeshInstance3D = actor.shoulder_bridges[i]
			var arm := actor.left_arm if i == 0 else actor.right_arm
			if bridge.visible:
				shoulders_joined = shoulders_joined and bridge.to_global(Vector3(0, 0.5, 0)).distance_to(arm.global_position) < 0.002
				shoulders_joined = shoulders_joined and bridge.to_global(Vector3(0, -0.5, 0)).distance_to(actor.body.to_global(Vector3(-0.24 if i == 0 else 0.24, 1.15, 0))) < 0.002
			if p <= 0.8:
				var hand := actor.left_forearm if i == 0 else actor.right_forearm
				var rim := actor.head.to_global(actor.helmet.position + Vector3(-0.18 if i == 0 else 0.18, -0.07, 0))
				contact = contact and hand.to_global(Vector3(0, -0.29, 0)).distance_to(rim) < 0.002
		for corner in [Vector3(-0.5, -0.5, -0.5), Vector3(0.5, 0.5, 0.5)]:
			var point := actor.helmet.to_global(corner)
			var pixel := director.camera.unproject_position(point)
			framed = framed and not director.camera.is_position_behind(point) and pixel.x > 0 and pixel.x < size.x and pixel.y > size.y * 0.15 and pixel.y < size.y * 0.78
	check(contact, "Both hands follow helmet rim targets within 2 mm until release")
	check(shoulders_joined, "Raised shoulder geometry stays joined to the torso and upper arms")
	check(planted and stage.props.bike.position == Vector3.ZERO, "Helmet preparation keeps shoes and motorcycle stationary")
	check(framed, "Held and raised helmet remain within caption-safe framing")
	check(stage.prop_snapshot() == props and get_tree().get_node_count() == nodes, "Helmet preparation preserves luggage without duplicate props or per-frame nodes")
	var final_pose := stage.actor_snapshot()
	await capture("helmet_worn")
	stage.pose(shot, 0)
	check(stage.actor_snapshot() == initial, "Rewinding restores the held helmet without a worn duplicate")
	director._apply_shot(0.5)
	held = stage.actor_snapshot()
	GameState.settings.reduced_motion = not GameState.settings.reduced_motion
	director._apply_shot(0.5)
	check(stage.actor_snapshot() == held and GameState.snapshot() == saved, "Reduced motion preserves helmet choreography and journey state")
	director._process(5)
	check(stage.actor_snapshot() == final_pose, "Strap check begins with the exact helmet, hand and standing pose")
	director.play("night")
	check(not director.room.props.raka.helmet.visible and director.room.props.raka.helmet.position == Vector3(0, 0.26, 0.015), "Other scenes restore the default hidden helmet position")

func _test_chin_strap(director: CutsceneDirector) -> void:
	var saved := GameState.snapshot()
	director.play("departure")
	for i in range(director.definitions.departure.shots.size()):
		if director.definitions.departure.shots[i].shot_id == "chin_strap":
			director.shot_index = i
	director._show_shot()
	var stage := director.room
	var shot: Dictionary = director.definitions.departure.shots[director.shot_index]
	var actor: CinematicActor = stage.props.rider
	var strap := actor.chin_strap
	var initial := stage.actor_snapshot()
	var feet := [actor.shoes[0].global_transform, actor.shoes[1].global_transform]
	var props := stage.prop_snapshot()
	var nodes := get_tree().get_node_count()
	check(strap.visible and strap.ends[0].distance_to(strap.ends[1]) > 0.39, "Chin strap starts with two separated buckle halves")
	await capture("chin_strap_loose")
	stage.pose(shot, 0.5)
	check(absf(strap.ends[0].distance_to(strap.ends[1]) - 0.032) < 0.001, "Buckle halves meet under the chin before tightening")
	await capture("chin_strap_joined")
	var short_tail := strap.tail_end
	stage.pose(shot, 0.68)
	check(strap.tail_end.distance_to(short_tail) > 0.08, "Right hand pulls the free tail after joining the buckle")
	await capture("chin_strap_pull")
	var held := stage.actor_snapshot()
	var elapsed := director.elapsed
	get_tree().paused = true
	director.set_process(true)
	await frames(8)
	check(stage.actor_snapshot() == held and director.elapsed == elapsed, "Pause freezes buckle, tail, hands and timeline")
	get_tree().paused = false
	AudioManager.focus_suspended = true
	await frames(8)
	check(stage.actor_snapshot() == held, "Background freezes chin-strap fastening")
	AudioManager.focus_suspended = false
	director.set_process(false)
	stage.pose(shot, 1)
	stage.pose(shot, 0.68)
	check(stage.actor_snapshot() == held, "Rewind restores webbing, buckle halves and both hands")
	var contact := true
	var anchored := true
	var planted := true
	var framed := true
	var buckle_clear := true
	var size := get_viewport().get_visible_rect().size
	for step in range(101):
		var p := float(step) / 100
		stage.pose(shot, p)
		for i in range(2):
			planted = planted and actor.shoes[i].global_transform.is_equal_approx(feet[i])
			var anchor := Vector3(-0.19 if i == 0 else 0.19, 0.23, 0.015)
			anchored = anchored and strap.bands[i * 3].to_global(Vector3(0, -0.5, 0)).distance_to(actor.head.to_global(anchor)) < 0.002
			if p >= 0.25 and p <= 0.82:
				var target: Vector3 = strap.ends[i]
				if i == 1:
					target = target.lerp(strap.tail_end, smoothstep(0.50, 0.54, p))
				var hand := actor.left_forearm if i == 0 else actor.right_forearm
				contact = contact and hand.to_global(Vector3(0, -0.29, 0)).distance_to(strap.to_global(target)) < 0.002
		for point in [strap.ends[0], strap.ends[1], strap.tail_end]:
			var torso := AABB(Vector3(-0.215, 0.66, -0.14), Vector3(0.43, 0.58, 0.28)).grow(0.018)
			buckle_clear = buckle_clear and not torso.has_point(actor.body.to_local(strap.to_global(point)))
			var pixel := director.camera.unproject_position(strap.to_global(point))
			framed = framed and pixel.x > 0 and pixel.x < size.x and pixel.y > size.y * 0.15 and pixel.y < size.y * 0.78
	check(contact, "Both hands follow buckle and tail targets within 2 mm during fastening")
	check(anchored, "Both strap roots remain attached to the helmet throughout the check")
	check(planted and stage.props.bike.position == Vector3.ZERO, "Strap check leaves feet and motorcycle stationary")
	check(framed, "Buckle halves and pulling tail remain inside caption-safe framing")
	check(buckle_clear, "Loose and closing buckle halves and tail stay clear of the torso")
	check(stage.prop_snapshot() == props and get_tree().get_node_count() == nodes, "Chin-strap sampling preserves luggage and allocates no nodes")
	var fastened := stage.actor_snapshot()
	await capture("chin_strap_secured")
	stage.pose(shot, 0)
	check(stage.actor_snapshot() == initial, "Rewinding restores the unfastened buckle")
	director._apply_shot(0.5)
	held = stage.actor_snapshot()
	GameState.settings.reduced_motion = not GameState.settings.reduced_motion
	director._apply_shot(0.5)
	check(stage.actor_snapshot() == held and GameState.snapshot() == saved, "Reduced motion preserves fastening without journey changes")
	director._process(4)
	check(stage.actor_snapshot() == fastened, "Mounting starts with the exact secured strap and released hands")
	director._process(5)
	check(actor.chin_strap.visible and actor.chin_strap.ends[0].distance_to(actor.chin_strap.ends[1]) < 0.033, "Departure retains the fastened helmet strap")
	director.play("night")
	check(not director.room.props.raka.chin_strap.visible, "Interior actors hide the helmet webbing with the helmet")

func _test_mount(director: CutsceneDirector) -> void:
	var saved := GameState.snapshot()
	director.play("departure")
	for i in range(director.definitions.departure.shots.size()):
		if director.definitions.departure.shots[i].shot_id == "mount":
			director.shot_index = i
	director._show_shot()
	var stage := director.room
	var shot: Dictionary = director.definitions.departure.shots[director.shot_index]
	var actor: CinematicActor = stage.props.rider
	var bike: Node3D = stage.props.bike
	var secured := stage.prop_snapshot()
	var nodes := get_tree().get_node_count()
	var initial := stage.actor_snapshot()
	check(actor.visible and actor.helmet.visible and actor.walking_legs.visible and not actor.seated_legs.visible and not stage.props.walker.visible, "Mount starts with one helmeted Raka standing beside the bike")
	check(bike.to_local(actor.global_position).x < -0.5 and bike.position == Vector3.ZERO, "Mount starts on the motorcycle's left side without travel")
	await capture("mount_ready")
	stage.pose(shot, 0.35)
	check(bike.to_local(actor.shoes[1].global_position).y > 1.1, "Right foot lifts above the seat before crossing")
	await capture("mount_lift")
	stage.pose(shot, 0.5)
	await capture("mount_cross")
	var held := stage.actor_snapshot()
	var elapsed := director.elapsed
	get_tree().paused = true
	director.set_process(true)
	await frames(8)
	check(stage.actor_snapshot() == held and director.elapsed == elapsed, "Pause freezes mounting joints and root")
	get_tree().paused = false
	AudioManager.focus_suspended = true
	await frames(8)
	check(stage.actor_snapshot() == held, "Background freezes the mounting performance")
	AudioManager.focus_suspended = false
	director.set_process(false)
	stage.pose(shot, 1)
	stage.pose(shot, 0.5)
	check(stage.actor_snapshot() == held, "Rewind restores the mounting pose exactly")
	var framed := true
	var planted := true
	var soles := true
	var clear := true
	var size := get_viewport().get_visible_rect().size
	var bag := AABB(Vector3(-0.39, 0.855, 0.56), Vector3(0.78, 0.30, 0.52))
	for step in range(101):
		var p := float(step) / 100
		stage.pose(shot, p)
		for shoe in actor.shoes:
			var point := shoe.global_position
			var pixel := director.camera.unproject_position(point)
			framed = framed and not director.camera.is_position_behind(point) and pixel.x > 0 and pixel.x < size.x and pixel.y < size.y * 0.78
			soles = soles and shoe.global_basis.y.is_equal_approx(Vector3.UP) and point.y > 0.06
			for x in [-0.085, 0.085]:
				for z in [-0.15, 0.15]:
					clear = clear and not bag.has_point(bike.to_local(shoe.to_global(Vector3(x, 0, z))))
		if p <= 0.55:
			planted = planted and bike.to_local(actor.shoes[0].global_position).distance_to(Vector3(-0.71, 0.08, 0.345)) < 0.002
		var head_point := actor.head.to_global(Vector3(0, 0.48, 0))
		framed = framed and director.camera.unproject_position(head_point).y > size.y * 0.15
	check(planted, "Left foot stays planted during the initial right-leg lift and crossing")
	check(soles, "Mounting shoes remain level and above the parking surface")
	check(clear, "Sampled shoe corners clear the secured luggage throughout mounting")
	check(framed, "Helmet and feet remain inside the shot's caption-safe framing")
	check(stage.prop_snapshot() == secured and bike.position == Vector3.ZERO and get_tree().get_node_count() == nodes, "Mount preserves luggage and stationary motorcycle without allocating nodes")
	check(bike.to_local(actor.global_position).distance_to(CinematicMount.SEAT) < 0.002, "Mount settles at the departure seat anchor")
	check(bike.to_local(actor.shoes[0].global_position).x < 0 and bike.to_local(actor.shoes[1].global_position).x > 0, "Seated feet finish on opposite sides of the motorcycle")
	for side in [-1, 1]:
		var hand := actor.left_forearm if side == -1 else actor.right_forearm
		check(hand.to_global(Vector3(0, -0.29, 0)).distance_to(bike.to_global(Vector3(side * 0.51, 1.165, -0.29))) < 0.002, "Seated hand reaches its handlebar grip: " + str(side))
	await capture("mount_seated")
	var seated := stage.actor_snapshot()
	stage.pose(shot, 0)
	check(stage.actor_snapshot() == initial, "Mount can rewind to its standing pose")
	director._apply_shot(0.5)
	held = stage.actor_snapshot()
	GameState.settings.reduced_motion = not GameState.settings.reduced_motion
	director._apply_shot(0.5)
	check(stage.actor_snapshot() == held, "Reduced camera motion preserves mounting choreography")
	check(GameState.snapshot() == saved, "Mounting does not change saves or checkpoints")
	director._process(5)
	check(stage.actor_snapshot() == seated and stage.prop_snapshot() == secured, "Natural departure starts with the exact seated pose and secured luggage")
	director._process(3)
	check(bike.position.x > 1 and bike.to_local(actor.global_position).distance_to(CinematicMount.SEAT) < 0.002, "Mounted rider follows the bike during departure")

func _test_bike_touch(director: CutsceneDirector) -> void:
	var saved := GameState.snapshot()
	director.play("departure")
	for i in range(director.definitions.departure.shots.size()):
		if director.definitions.departure.shots[i].shot_id == "bike_touch":
			director.shot_index = i
	var shots: Array = director.definitions.departure.shots
	check(shots[director.shot_index - 1].shot_id == "straps" and shots[director.shot_index + 1].shot_id == "father_memory", "Bike touch connects the luggage check to the father memory")
	director._show_shot()
	var stage := director.room
	var shot: Dictionary = shots[director.shot_index]
	var touch: CinematicBikeTouch = stage.props.bike_touch
	var actor: CinematicActor = stage.props.walker
	var initial := stage.prop_snapshot()
	var secured: Array = stage.props.luggage.pose_snapshot()
	var nodes := get_tree().get_node_count()
	var feet := [actor.walking_legs.get_child(0).global_transform, actor.walking_legs.get_child(1).global_transform]
	check(touch.cloth.visible and actor.visible and actor.walking_legs.visible and not stage.props.rider.visible and not actor.helmet.visible and not actor.handset.visible, "Bike touch shows one standing Raka holding a cloth")
	await capture("bike_touch_ready")
	stage.pose(shot, 0.22)
	var stroke_start := touch.cloth.global_position
	await capture("bike_touch_contact")
	stage.pose(shot, 0.46)
	check(touch.cloth.global_position.distance_to(stroke_start) > 0.15, "Cloth visibly travels along the tank")
	await capture("bike_touch_wipe")
	var held := stage.prop_snapshot()
	var held_actor := stage.actor_snapshot()
	var elapsed := director.elapsed
	get_tree().paused = true
	director.set_process(true)
	await frames(8)
	check(stage.prop_snapshot() == held and stage.actor_snapshot() == held_actor and director.elapsed == elapsed, "Pause freezes tank wipe and cloth together")
	get_tree().paused = false
	AudioManager.focus_suspended = true
	await frames(8)
	check(stage.prop_snapshot() == held and stage.actor_snapshot() == held_actor, "Background freezes the wipe without moving its props")
	AudioManager.focus_suspended = false
	director.set_process(false)
	stage.pose(shot, 1)
	stage.pose(shot, 0.46)
	check(stage.prop_snapshot() == held and stage.actor_snapshot() == held_actor, "Backward seeking restores the same wipe and hand pose")
	var contact := true
	var surface := true
	var unobstructed := true
	var planted := true
	var framed := true
	var size := get_viewport().get_visible_rect().size
	var radii := touch.tank.mesh.get_aabb().size * 0.5
	for step in range(101):
		var p := float(step) / 100
		stage.pose(shot, p)
		contact = contact and actor.right_forearm.to_global(Vector3(0, -0.29, 0)).distance_to(touch.cloth.to_global(Vector3(0, 0.055, 0))) < 0.002
		if p >= 0.22 and p <= 0.82:
			var q := touch.tank.to_local(touch.surface_point) / radii
			surface = surface and absf(q.length_squared() - 1) < 0.001 and touch.cloth.global_position.distance_to(touch.surface_point + touch.surface_normal * 0.01) < 0.002
			var on_bike: Vector3 = stage.props.bike.to_local(touch.cloth.global_position)
			surface = surface and on_bike.x > 0.20
			var torso := AABB(Vector3(-0.215, 0.66, -0.14), Vector3(0.43, 0.58, 0.28))
			unobstructed = unobstructed and torso.intersects_segment(actor.body.to_local(director.camera.global_position), actor.body.to_local(touch.cloth.global_position)) == null
		for i in range(2):
			planted = planted and actor.walking_legs.get_child(i).global_transform == feet[i]
		for x in [-0.08, 0.08]:
			for z in [-0.07, 0.07]:
				var point := touch.cloth.to_global(Vector3(x, 0, z))
				var pixel := director.camera.unproject_position(point)
				framed = framed and not director.camera.is_position_behind(point) and pixel.x > 0 and pixel.x < size.x and pixel.y > size.y * 0.15 and pixel.y < size.y * 0.78
	check(contact, "Right hand retains cloth contact within 2 mm through approach, wipe and withdrawal")
	check(surface, "Wipe tracks the tank ellipsoid on its side clear of the central fuel cap")
	check(unobstructed, "Actor torso never blocks the camera's view of the wiping cloth")
	check(planted and stage.props.bike.position == Vector3.ZERO, "Wiping keeps both feet and motorcycle stationary")
	check(framed, "Cloth remains between caption bars throughout the wipe")
	check(get_tree().get_node_count() == nodes and stage.props.luggage.pose_snapshot() == secured, "Wiping preserves secured luggage without allocating nodes")
	await capture("bike_touch_withdrawn")
	stage.pose(shot, 0.70)
	check(touch.cloth.global_position.distance_to(stroke_start) < 0.002, "Wipe returns along the tank before the reflective hold")
	stage.pose(shot, 0)
	check(stage.prop_snapshot() == initial, "Rewinding restores the cloth to the starting hand position")
	director._apply_shot(0.5)
	held = stage.prop_snapshot()
	held_actor = stage.actor_snapshot()
	GameState.settings.reduced_motion = not GameState.settings.reduced_motion
	director._apply_shot(0.5)
	check(stage.prop_snapshot() == held and stage.actor_snapshot() == held_actor, "Reduced camera motion preserves the bike-touch performance")
	check(GameState.snapshot() == saved, "Bike touch does not alter journey state or checkpoint")
	director._process(5)
	check(director.stage_id == "memory" and not is_instance_valid(touch) and not director.room.props.bike_touch.cloth.visible, "Memory frees the present-day cloth and never shows a duplicate")
	director._process(2)
	check(director.stage_id == "parking" and not director.room.props.bike_touch.cloth.visible and director.room.props.rider.visible and not director.room.props.walker.visible and director.room.props.luggage.pose_snapshot() == secured, "Mounting restores one rider and secured luggage without the wiping cloth")
	director.play("morning")
	for i in range(director.definitions.morning.shots.size()):
		if director.definitions.morning.shots[i].shot_id == "parking":
			director.shot_index = i
	director._show_shot()
	check(not director.room.props.bike_touch.cloth.visible and not director.room.props.luggage.visible, "Morning approach has no leftover wipe cloth or departure luggage")
