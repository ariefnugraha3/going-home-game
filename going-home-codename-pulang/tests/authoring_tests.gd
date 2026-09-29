extends "res://tests/test_runner.gd"

var checkpoints: Array[String] = []
var dialogue_ends: Array[String] = []

func _ready() -> void:
	visual_test = "--visual" in OS.get_cmdline_user_args()
	Engine.max_fps = 30 if visual_test else 0
	GameState.new_journey()
	GameState.set_flag("test.authoring_sentinel", true)
	check(SaveManager.save_game(), "Create isolated save sentinel")
	var saved := FileAccess.get_file_as_bytes(SaveManager.SAVE_PATH)
	var story := GameState.snapshot()
	var old_context := AudioManager.context
	var old_rain := AudioManager.rain_target
	app = preload("res://tools/authoring/EncounterPreview.tscn").instantiate()
	add_child(app)
	app.director.set_process(false)
	await frames(3)
	check(app.mode == "road" and app.chapter.configuration_errors().is_empty(), "Template preview starts with valid configuration")
	check(app.chapter.get_node("Road").get_child(0) is StaticBody3D, "Authored road includes rideable collision")
	check(app.npc.actor.animator.has_animation("walk") and app.npc.has_node("DialogueAnchor"), "NPC visual, animation controller and dialogue anchor exist")
	check(app.chapter.get_node("Markers/Checkpoint").position == RoadWorld.center(100), "Checkpoint debug marker uses authored distance")
	app.chapter.checkpoint_requested.connect(func(id: String): checkpoints.append(id))
	app.dialogue.dialogue_finished.connect(func(id: String): dialogue_ends.append(id))
	app.talk()
	check(app.mode == "road" and not app.npc.busy, "Distant host cannot be activated")
	app.move_to(49)
	check(app.chapter.current_profile == "morning" and app.chapter.ambience == "fields", "Events remain inactive before thresholds")
	app.move_to(50)
	check(app.chapter.current_profile == "overcast", "Weather begins exactly at authored threshold")
	app.move_to(65)
	check(AudioManager.context == "warung", "Audio zone signal selects authored ambience")
	app.move_to(120)
	app.move_to(100)
	check(checkpoints == ["authoring.roadside"], "Checkpoint crossing fires once even on repeated samples")
	app.move_to(0)
	check(app.chapter.current_profile == "morning" and AudioManager.context == "fields", "Backtracking restores earlier weather and ambience")
	app.move_to(80)
	await capture("authoring_road")
	var near: Vector3 = app.npc.get_node("InteractionAnchor").global_position
	check(not app.npc.interact(near, 8) and not app.npc.interact(near, -8), "Moving interaction rejects both forward and reverse speed")
	get_tree().paused = true
	check(not app.npc.interact(near), "Paused interaction is blocked")
	app.move_to(0)
	check(app.distance == 80, "Paused preview cannot travel")
	get_tree().paused = false
	AudioManager.focus_suspended = true
	check(not app.npc.interact(near), "Unfocused interaction is blocked")
	AudioManager.focus_suspended = false
	app.talk()
	check(app.mode == "cutscene" and app.director.active_id == "authoring.arrival", "NPC signal starts configured arrival sequence")
	var head_before: float = app.npc.actor.head.rotation.x
	app.npc._process(0.5)
	check(app.npc.actor.head.rotation.x != head_before, "Conversation animates the standing actor")
	AudioManager.focus_suspended = true
	var clock_before: float = app.npc.clock
	app.npc._process(1)
	check(app.npc.clock == clock_before, "Conversation animation freezes while unfocused")
	AudioManager.focus_suspended = false
	check(not app.npc.interact(near), "Busy host cannot start duplicate encounter")
	app.move_to(0)
	check(app.distance == 80, "Travel stays locked during cutscene")
	var elapsed_before: float = app.director.elapsed
	get_tree().paused = true
	app.director._process(1)
	check(app.director.elapsed == elapsed_before, "Shot clock freezes during pause")
	get_tree().paused = false
	AudioManager.focus_suspended = true
	app.director._process(1)
	check(app.director.elapsed == elapsed_before, "Shot clock freezes when unfocused")
	AudioManager.focus_suspended = false
	await capture("authoring_cutscene")
	app.director.finish()
	check(app.mode == "dialogue" and app.dialogue.active_id == "authoring.greeting", "Skip hands off to local dialogue")
	app.director.finish()
	check(app.dialogue.choices.size() == 2 and app.choices.get_child_count() == 2, "Repeated Skip leaves one dialogue and its two choices")
	await capture("authoring_dialogue")
	app.dialogue.advance(0)
	check(app.dialogue.local_flags.get("authoring.accepted", false), "Dialogue choice commits preview-local flag")
	check(app.dialogue.matches({"authoring.accepted": true}), "Preview conditions read local flags")
	check(not app.dialogue.matches({"test.authoring_sentinel": true}), "Preview conditions do not leak campaign flags")
	app.dialogue.advance()
	check(app.mode == "road" and not app.npc.busy and dialogue_ends.size() == 1, "Dialogue releases host and returns control exactly once")
	app.reset_preview()
	check(app.distance == 0 and app.dialogue.local_flags.is_empty(), "Restart clears local choices and distance")
	app.move_to(100)
	check(checkpoints.size() == 2, "Restart rearms chapter checkpoint")
	app.move_to(80)
	app.talk()
	app.director._process(3.1)
	check(app.mode == "dialogue", "Natural sequence completion has the same dialogue handoff")
	app.dialogue.advance(1)
	app.dialogue.advance()
	check(dialogue_ends.size() == 2 and app.dialogue.local_flags.is_empty(), "Quiet branch finishes without first-branch flag")
	app.talk()
	app.reset_preview()
	check(app.director.active_id.is_empty() and app.director.room == null and not app.npc.busy, "Restart safely tears down an active cinematic")
	check(GameState.snapshot() == story, "Preview leaves all campaign state unchanged")
	check(FileAccess.get_file_as_bytes(SaveManager.SAVE_PATH) == saved, "Preview leaves on-disk save byte-for-byte unchanged")
	check(DialogueManager.active_id.is_empty() and DialogueManager.content_path.ends_with("slice.json"), "Global story dialogue loader remains independent")
	var preview_ref: WeakRef = weakref(app)
	app.queue_free()
	await frames(3)
	check(preview_ref.get_ref() == null, "Preview releases its scene tree")
	check(AudioManager.context == old_context and AudioManager.rain_target == old_rain, "Preview exit restores surrounding audio context")
	await _test_authored_variant()
	await _test_invalid_configuration()
	check(GameState.snapshot() == story and FileAccess.get_file_as_bytes(SaveManager.SAVE_PATH) == saved, "Authored variant also preserves story and save")
	print("AUTHORING RESULT: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)

func _test_authored_variant() -> void:
	# Author new IDs/text and scene properties only; reuse the unchanged host/core.
	var bundle := {"authoring.new_host": {"nodes": {
		"start": {"speaker": "Workshop host", "text": "The shade is cooler here.", "next": "end", "set": {"authoring.new_visit": true}}
	}}}
	var file := FileAccess.open("user://authoring_variant.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(bundle))
	file.close()
	app = preload("res://tools/authoring/EncounterPreview.tscn").instantiate()
	app.dialogue_file = "user://authoring_variant.json"
	app.get_node("Chapter").npc_distance = 40
	app.get_node("Chapter").arrival_weather = "rain"
	app.get_node("Chapter/NPC").dialogue_id = "authoring.new_host"
	app.get_node("Chapter/NPC").display_name = "Workshop host"
	app.get_node("Cutscene/Shots/arrival/Camera").position = Vector3(4, 2, 5)
	add_child(app)
	app.director.set_process(false)
	await _drain_render()
	check(app.npc.position == RoadWorld.center(40) + Vector3(-7, 0, 0), "New host placement comes from chapter Inspector properties")
	check(app.director.definitions["authoring.arrival"].shots[0].camera == [4.0, 2.0, 5.0], "Camera marker overrides bundle coordinates")
	app.move_to(60)
	check(app.chapter.current_profile == "rain", "Variant weather is configured without core changes")
	app.move_to(40)
	app.talk()
	var reduced: bool = GameState.settings.reduced_motion
	GameState.settings.reduced_motion = true
	app.director._apply_shot(1)
	check(app.director.camera.position == app.director.origin + Vector3(4, 2, 5), "Marker framing respects reduced-motion camera lock")
	GameState.settings.reduced_motion = reduced
	app.director.finish()
	check(app.dialogue.active_id == "authoring.new_host" and app.caption.text.contains("The shade is cooler here."), "New bundle and NPC ID are playable through unchanged preview host")
	check(app.dialogue.local_flags.get("authoring.new_visit", false), "Node-level flags are isolated as well as choice flags")
	app.dialogue.advance()
	app.chapter.checkpoint_distance = 1810
	check(not app.chapter.configuration_errors().is_empty(), "Invalid chapter event distance is reported")
	app.queue_free()
	await frames(3)
	await _drain_render()

func _test_invalid_configuration() -> void:
	app = preload("res://tools/authoring/EncounterPreview.tscn").instantiate()
	app.arrival_id = "missing.sequence"
	app.get_node("Chapter/NPC").dialogue_id = "missing.dialogue"
	app.get_node("Chapter").checkpoint_id = ""
	add_child(app)
	await _drain_render()
	check(app.mode == "invalid" and app.caption.text.contains("NPC dialogue ID") and app.caption.text.contains("Arrival ID"), "Missing encounter references stop preview with readable diagnostics")
	app.talk()
	app.move_to(80)
	app.reset_preview()
	check(app.mode == "invalid" and app.director.active_id.is_empty(), "Invalid preview cannot start or reset into a broken encounter")
	app.chapter.arrival_weather = "missing.weather"
	app.chapter.arrival_ambience = "missing.ambience"
	check(app.chapter.configuration_errors().size() == 3, "Chapter reports missing checkpoint, weather and audio zone")
	app.queue_free()
	await frames(3)
	await _drain_render()

func _drain_render() -> void:
	# Let native sky resources initialize and finish queued release operations.
	for step in range(6):
		await get_tree().process_frame
	if visual_test:
		await RenderingServer.frame_post_draw
