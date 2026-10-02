extends "res://tests/test_runner.gd"

func _ready() -> void:
	visual_test = "--visual" in OS.get_cmdline_user_args()
	Engine.max_fps = 30 if visual_test else 0
	GameState.settings.quality = 1
	var before := GameState.snapshot()
	var camera := Camera3D.new()
	add_child(camera)
	camera.make_current()
	var ui := GameUI.new()
	add_child(ui)
	var signatures := {}
	for id in Campaign.CHAPTERS.slice(1):
		var data := Campaign.chapter(id)
		var route := RidingRoute.new()
		route.profile = data.road_shape
		var signature := str(route.sample(480)) + str(route.sample(960))
		check(not signatures.has(signature), id + " has a distinct authored road")
		signatures[signature] = true
		var smooth := true
		for d in range(0, 1800, 2):
			var tangent := route.sample(d + 1) - route.sample(d)
			smooth = smooth and tangent.is_finite() and absf(tangent.y) < .04 and absf(route.heading(d + 1) - route.heading(d)) < .02
		check(smooth, id + " has bounded continuous grades and steering curvature")
	if visual_test:
		for id in Campaign.CHAPTERS:
			var world := RoadWorld.new()
			world.chapter_data = Campaign.chapter(id)
			add_child(world)
			world.build()
			world.set_weather_profile("morning", true)
			var landmark: Node3D = world.get_node("RegionalLandmark")
			camera.global_position = landmark.to_global(Vector3(10, 6, 12))
			camera.look_at(landmark.to_global(Vector3(0, 1.5, 0)))
			ui.show_cinematic(world.chapter_data.end_location, "Roadside environment review", "")
			await capture("regional_" + id)
			world.queue_free()
			await frames(3)
	for id in ["semarang", "ngawi", "kediri", "banyuwangi", "epilogue"]:
		var data := Campaign.chapter(id)
		var world := RoadWorld.new()
		world.chapter_data = data
		add_child(world)
		world.build()
		world.set_weather_profile(data.atmosphere[0].profile, true)
		var stage := world.encounter_stage
		check(stage.parked.luggage.visible == (id != "epilogue"), id + " preserves the travel bag through the home arrival")
		var contact_ok := true
		for shot in data.arrival_shots:
			for step in range(21):
				stage.sample(camera, shot, step / 20.0)
				var action: String = shot.get("action", "")
				if id == "banyuwangi" and action in ["bike", "odometer", "engine_off"]:
					var actor: CinematicActor = stage.actors[0 if action == "engine_off" else 1]
					var expected := stage.parked.to_global(BikeVisual.IGNITION if action == "engine_off" else BikeVisual.hand_grip(-1))
					contact_ok = contact_ok and actor.right_forearm.to_global(Vector3(0, -.29, 0)).distance_to(expected) < .002
				if id == "epilogue" and action == "bike":
					var hand: Vector3 = stage.actors[1].right_forearm.to_global(Vector3(0, -.29, 0))
					contact_ok = contact_ok and hand.distance_to(stage.cloth.global_position + stage.cloth.global_basis.y * .055) < .002
			if visual_test and (id in ["semarang", "kediri"] or shot.get("action", "") in ["engine_off", "bike", "mother"]):
				stage.sample(camera, shot, .6)
				ui.show_cinematic(data.end_location, data.display_name, shot.text)
				await capture("staging_%s_%d" % [id, data.arrival_shots.find(shot)])
		check(contact_ok, id + " keeps ignition, grip and wiping contact within two millimeters")
		if stage.home:
			var soles_clear := true
			var home_shots: Array = data.arrival_shots.duplicate()
			home_shots.append_array(data.get("closing_shots",[]))
			for shot in home_shots:
				for step in range(21):
					stage.sample(camera,shot,step/20.0)
					for actor in stage.actors:
						if not actor.visible or not actor.walking_legs.visible: continue
						for shoe in actor.shoes:
							var p := stage.to_local(shoe.global_position)
							var height := .16 if absf(p.x) < 4.25 and p.z <= .1 and p.z >= -6.9 else 0.0
							if absf(p.x) < 1.05 and p.z < -1.525 and p.z > -2.075: height = .20
							if absf(p.x) < 3.8 and p.z <= -1.95 and p.z >= -3.25: height = .36
							soles_clear = soles_clear and p.y-.07 >= height-.003
			check(soles_clear,id + " standing and entering soles clear the raised porch and steps")
		var stage_nodes := stage.find_children("*", "", true, false).size()
		stage.sample(camera, data.arrival_shots.front(), 0)
		for shot in data.arrival_shots: stage.sample(camera, shot, .5)
		check(stage.find_children("*", "", true, false).size() == stage_nodes, id + " never allocates extra animation props while sampling")
		if data.has("closing_shots"):
			stage.sample(camera, data.closing_shots.back(), 1)
			check(stage.actors.all(func(actor: CinematicActor): return not actor.visible), id + " family clears the doorway before the final still")
			stage.sample(camera, data.arrival_shots.front(), 0)
			check(stage.actors.all(func(actor: CinematicActor): return actor.visible) and not stage.cloth.visible, id + " backward sampling restores actors and hides the cleaning cloth")
		for speaker in [data.encounter_speaker, "Raka"]:
			stage.frame_dialogue(camera, speaker)
			var actor_index := 0 if speaker == "Raka" or id == "kediri" else 2 if speaker == "Mom" else 1
			var face: Vector3 = stage.actors[actor_index].head.to_global(Vector3(0, .15, -.1))
			var point := camera.unproject_position(face) / get_viewport().get_visible_rect().size
			check(not camera.is_position_behind(face) and point.x > .05 and point.x < .95 and point.y > .06 and point.y < .49, id + " dialogue keeps " + speaker + " above the caption panel")
			ui.show_dialogue({"speaker": speaker, "text": "A quiet moment before the next turn.", "choices": []})
			if visual_test: await capture("staging_%s_dialogue_%s" % [id, speaker.to_lower().replace(" ", "_")])
		world.queue_free()
		await frames(4)
		LowPoly.materials.clear()
	check(GameState.snapshot() == before, "Staging review never changes the player's journey")
	ui.queue_free()
	camera.queue_free()
	await frames(3)
	print("CAMPAIGN STAGING RESULT: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)
