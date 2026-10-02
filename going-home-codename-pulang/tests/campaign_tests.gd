extends "res://tests/test_runner.gd"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visual_test = "--visual" in OS.get_cmdline_user_args()
	Engine.max_fps = 30 if visual_test else 0
	GameState.settings.fps_limit = 30
	GameState.settings.quality = 0
	app = preload("res://scenes/boot/Boot.tscn").instantiate()
	add_child(app)
	await frames(3)
	for branch in range(1 if visual_test else 2):
		GameState.new_journey()
		GameState.chapter = "karawang"
		GameState.checkpoint = "complete"
		GameState.set_flag("story.karawang.sheltered")
		GameState.set_flag("story.karawang.complete")
		check(SaveManager.save_game(), "Original Karawang checkpoint remains writable")
		app._on_action("continue")
		await settle()
		check(app.state == "complete", "Original Karawang save opens chapter completion")
		for id in Campaign.CHAPTERS.slice(1):
			var previous_world: WeakRef = weakref(app.world)
			app._on_action("next_chapter")
			await settle()
			check(GameState.chapter == id and app.state == "riding", "%s reachable through normal chapter action" % id)
			check(previous_world.get_ref() == null, "%s releases previous chapter world" % id)
			check(app.ui.chapter_data.chapter_id == id and app.world.chapter_data.chapter_id == id, "%s UI and world use current chapter" % id)
			var start_bytes := FileAccess.get_file_as_string(SaveManager.SAVE_PATH)
			app._return_to_menu()
			app._on_action("continue")
			await settle()
			check(GameState.chapter == id and FileAccess.get_file_as_string(SaveManager.SAVE_PATH) == start_bytes, "%s Continue preserves chapter and save bytes" % id)
			await _visit(1700)
			check(app.state == "riding" and -app.bike.position.z < 1130, "%s cannot bypass mandatory encounter" % id)
			await _visit(1130)
			check(app.state == "campaign_scene", "%s starts its authored sequence" % id)
			var time: float = app.campaign_time
			app._pause()
			await frames(5)
			check(app.campaign_time == time, "%s scene clock freezes while paused" % id)
			app._resume()
			if visual_test and id in ["pekalongan", "semarang", "salatiga", "kediri", "banyuwangi", "epilogue"]:
				await capture("campaign_" + id)
			if branch == 0:
				app._on_action("skip")
			else:
				for shot in app.campaign_shots.duplicate():
					if app.state == "campaign_scene": app._tick_campaign_scene(float(shot.duration))
			check(app.state == "dialogue" and DialogueManager.active_id == "campaign_" + id, "%s Skip/natural playback hands off exactly once" % id)
			complete_dialogue(branch)
			check(GameState.flags.get(Campaign.encounter_flag(id), false), "%s both choice branches commit the encounter" % id)
			check(SaveManager.read_save().chapter == id, "%s encounter saves current chapter" % id)
			if app.state == "campaign_scene":
				app._on_action("skip")
			else:
				await _visit(1700)
			check(app.state == "reflection", "%s reaches reflection" % id)
			if app.state != "reflection":
				print("Unexpected state: ", app.state, "; paused: ", get_tree().paused)
				get_tree().quit(1)
				return
			app._return_to_menu()
			app._on_action("continue")
			await settle()
			check(app.state == "reflection" and GameState.chapter == id, "%s restores unfinished journal" % id)
			var option: Dictionary = app.chapter_data.journal.options[branch]
			app._journal_selected(option.id, option.text)
			check(GameState.checkpoint == "complete" and app.state == "complete", "%s reflection completes chapter" % id)
			check(GameState.journal[app.chapter_data.journal.id].chapter_id == id, "%s journal persists correct chapter" % id)
			app._return_to_menu()
			app._on_action("continue")
			await settle()
			check(app.state == "complete" and GameState.chapter == id, "%s restores completed chapter" % id)
		check(GameState.journal.size() == 14, "All new chapter reflections survive the campaign")
		app._on_action("next_chapter")
		check(GameState.chapter == "epilogue" and app.state == "complete", "Epilogue is terminal")
	var invalid := GameState.snapshot()
	invalid.checkpoint = "morning"
	check(not SaveManager.validate(invalid), "Reject prologue checkpoint paired with epilogue")
	invalid.chapter = "unknown"
	check(not SaveManager.validate(invalid), "Reject unknown campaign chapters")
	app.queue_free()
	await frames(3)
	print("CAMPAIGN RESULT: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)

func _visit(distance: float) -> void:
	app.bike.teleport(distance)
	await frames(3)
	app._on_action("interact")
