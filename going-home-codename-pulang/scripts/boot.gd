extends Node

var world: RoadWorld
var bike: BikeMotorController
var ui: GameUI
var director: CutsceneDirector
var scanner: InteractionScanner
var flow: SceneFlow
var phone_service: PhoneDataService
var overview: Camera3D
var state: String = "menu"
var commute: bool = false
var pending_encounter: String = ""
var elapsed: float = 0
var chapter_data: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	chapter_data = JSON.parse_string(FileAccess.get_file_as_string("res://data/chapters/karawang.json"))
	_build_world(false)
	bike = preload("res://scenes/bike/BikePlayer.tscn").instantiate()
	bike.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(bike)
	bike.teleport(1100, -6)
	overview = Camera3D.new()
	add_child(overview)
	overview.fov = 52
	_set_overview(1100)
	scanner = InteractionScanner.new()
	add_child(scanner)
	director = CutsceneDirector.new()
	director.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(director)
	phone_service = PhoneDataService.new()
	add_child(phone_service)
	ui = GameUI.new()
	ui.phone_service = phone_service
	add_child(ui)
	flow = SceneFlow.new()
	add_child(flow)
	ui.action_requested.connect(_on_action)
	ui.journal_selected.connect(_journal_selected)
	director.caption_changed.connect(ui.show_cinematic)
	director.finished.connect(_cutscene_finished)
	DialogueManager.dialogue_finished.connect(_dialogue_finished)
	SaveManager.save_completed.connect(func(): ui.toast("Checkpoint saved"))
	SaveManager.save_failed.connect(func(reason: String): ui.toast(reason))
	ui.main_menu()

func _build_world(city: bool) -> void:
	if is_instance_valid(world):
		world.free()
	var scene: PackedScene = preload("res://scenes/chapters/Chapter_Prologue.tscn") if city else preload("res://scenes/chapters/Chapter_Karawang.tscn")
	world = scene.instantiate()
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(world)
	world.build(city)

func _set_overview(distance: float) -> void:
	var center := RoadWorld.center(distance)
	overview.position = center + Vector3(11, 5, 12)
	overview.look_at(center + Vector3(-7, 1, -10))
	overview.make_current()

func _on_action(action: String) -> void:
	if flow.busy:
		return
	AudioManager.unlock()
	match action:
		"new":
			if SaveManager.has_save():
				ui.confirm_new()
			else:
				_start_new()
		"new_confirmed": _start_new()
		"practice":
			if state == "menu":
				get_tree().change_scene_to_file("res://scenes/practice/RidingPractice.tscn")
		"continue":
			if SaveManager.load_game():
				_restore_checkpoint()
		"pause": _pause()
		"story_debug":
			if ui.story_debug_available():
				get_tree().paused = true
				InputModeManager.release_riding()
				AudioManager.engine_active = false
				ui.show_story_debug()
		"resume": _resume()
		"phone", "journal", "map":
			if state not in ["riding", "complete", "scenic"]:
				return
			get_tree().paused = true
			InputModeManager.release_riding()
			AudioManager.engine_active = false
			if action == "phone": ui.show_phone()
			elif action == "journal": ui.show_journal()
			else: ui.show_map()
		"back":
			if state == "menu":
				get_tree().paused = false
				ui.main_menu()
			else: ui.show_pause()
		"interact": _interact()
		"skip": director.finish()
		"menu": _return_to_menu()
		"recover":
			if state == "riding":
				bike.recover_to_road()
			_resume()
		"quit": get_tree().quit()

func _start_new() -> void:
	get_tree().paused = false
	GameState.new_journey()
	SaveManager.save_game()
	_play_cutscene("morning")

func _play_cutscene(id: String) -> void:
	bike.stop()
	state = "transition"
	await flow.fade_out()
	state = "cutscene"
	director.play(id)
	await flow.fade_in()

func _cutscene_finished(id: String) -> void:
	match id:
		"morning": _start_commute()
		"office":
			state = "dialogue"
			DialogueManager.start("layoff")
		"night":
			state = "dialogue"
			DialogueManager.start("mother")
		"departure": _start_road()

func _start_commute() -> void:
	state = "transition"
	await flow.fade_out()
	director.clear_room()
	_build_world(true)
	commute = true
	GameState.chapter = "prologue"
	GameState.checkpoint = "commute"
	SaveManager.save_game()
	bike.route_limit = 335
	bike.teleport(12)
	state = "riding"
	bike.enabled = true
	bike.engine_on = true
	bike.camera.make_current()
	ui.riding()
	ui.toast("Use RIDE and BRAKE · Keep left" if InputModeManager.touch_mode or GameState.settings.touch else "%s to ride · %s to brake · Keep left" % [InputModeManager.key_label("accelerate"), InputModeManager.key_label("brake")])
	await flow.fade_in()

func _start_road(distance: float = 12.0, save: bool = true) -> void:
	state = "transition"
	await flow.fade_out()
	director.clear_room()
	_build_world(false)
	commute = false
	GameState.chapter = "karawang"
	if save:
		GameState.checkpoint = "road_start"
		SaveManager.save_game()
	bike.route_limit = 1735
	bike.teleport(distance)
	bike.enabled = true
	bike.engine_on = true
	bike.camera.make_current()
	state = "riding"
	ui.riding()
	ui.toast("Jakarta → Karawang · Take your time. Stop wherever you like.")
	if distance > chapter_data.weather_at_distance and distance < chapter_data.weather_end_distance:
		world.set_weather(true)
	await flow.fade_in()

func _dialogue_finished(id: String) -> void:
	match id:
		"layoff": _play_cutscene("night")
		"mother":
			GameState.checkpoint = "departure"
			SaveManager.save_game()
			_play_cutscene("departure")
		"warung":
			GameState.checkpoint = "warung"
			SaveManager.save_game()
			_resume_ride()
		"fuel":
			GameState.bike.fuel = 12.0
			GameState.bike.condition = 1.0
			SaveManager.save_game()
			ui.toast("Tank filled · Tire pressure checked")
			_resume_ride()
		"guesthouse":
			GameState.checkpoint = "rest"
			SaveManager.save_game()
			state = "reflection"
			ui.show_journal(true)

func _interact() -> void:
	if state != "riding" or commute or not scanner.can_interact(bike):
		return
	var stop := scanner.candidate
	var id: String = stop.id
	if id == "rest" and not GameState.flags.get("story.karawang.sheltered", false):
		ui.toast("Stop at Sari's warung first. It's back along the road.")
		bike.teleport(1095)
		return
	bike.stop()
	pending_encounter = id
	var center := RoadWorld.center(stop.distance)
	if id == "scenic":
		state = "scenic"
		overview.position = center + Vector3(-8, 2.0, 2)
		overview.look_at(center + Vector3(-100, 0, -75))
		overview.make_current()
		ui.show_scenic()
	else:
		state = "dialogue"
		overview.position = center + Vector3(-9, 2.3, 10)
		overview.look_at(center + Vector3(-16, 1.4, 1))
		overview.make_current()
		DialogueManager.start("guesthouse" if id == "rest" else id)

func _journal_selected(id: String, text: String) -> void:
	var key: String = chapter_data.journal.id
	GameState.journal[key] = {"chapter_id": "karawang", "selected_option_id": id, "text": text, "unlocked_at": Time.get_unix_time_from_system()}
	GameState.set_flag("story.karawang.complete")
	GameState.checkpoint = "complete"
	SaveManager.save_game()
	state = "complete"
	ui.show_end()

func _restore_checkpoint() -> void:
	get_tree().paused = false
	match GameState.checkpoint:
		"morning": _play_cutscene("morning")
		"commute": _start_commute()
		"departure": _play_cutscene("departure")
		"road_start": _start_road(12, false)
		"warung": _start_road(1165, false)
		"rest", "complete":
			await _start_road(1690, false)
			bike.stop()
			_set_overview(1700)
			if GameState.checkpoint == "rest":
				state = "reflection"
				ui.show_journal(true)
			else:
				state = "complete"
				ui.show_end()

func _pause() -> void:
	if state in ["menu", "transition", "reflection", "complete"]:
		return
	get_tree().paused = true
	InputModeManager.release_riding()
	AudioManager.engine_active = false
	ui.show_pause()

func _resume_ride() -> void:
	state = "riding"
	bike.engine_on = true
	bike.enabled = true
	bike.camera.make_current()
	ui.riding()

func _resume() -> void:
	get_tree().paused = false
	if state in ["riding", "scenic"]:
		_resume_ride()
	elif state == "complete":
		ui.show_end()
	elif state == "dialogue":
		var line := DialogueManager.current.duplicate(true)
		line["choices"] = DialogueManager.choices
		ui.show_dialogue(line)
	elif state == "cutscene":
		var data: Dictionary = director.definitions[director.active_id]
		ui.show_cinematic(data.title, data.subtitle, data.shots[director.shot_index].text)

func _return_to_menu() -> void:
	get_tree().paused = false
	state = "menu"
	director.active_id = ""
	DialogueManager.active_id = ""
	bike.stop()
	director.clear_room()
	_set_overview(1100)
	world.set_weather(false)
	ui.main_menu()

func _unhandled_input(event: InputEvent) -> void:
	if flow.busy or event.is_echo():
		return
	if event.is_action_pressed("pause"):
		if ui.mode in ["settings", "controls", "credits", "confirm_new", "story_debug"]:
			_on_action("back")
		elif get_tree().paused:
			_resume()
		else:
			_pause()
		get_viewport().set_input_as_handled()
	elif state == "riding" and not get_tree().paused:
		for pair in [["open_phone", "phone"], ["open_journal", "journal"], ["open_map", "map"], ["interact", "interact"], ["recover", "recover"]]:
			if event.is_action_pressed(pair[0]):
				_on_action(pair[1])
				get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	elapsed += delta
	if not is_instance_valid(ui):
		return
	ui.weather.rain = world.wet and state == "riding" and not get_tree().paused
	ui.weather.queue_redraw()
	if state != "riding" or get_tree().paused or flow.busy:
		_advance_phone(delta)
		return
	var distance := -bike.position.z
	if commute:
		ui.update_hud(bike.speed_mps * 3.6, distance, "Ride to the office · Keep left", false, true)
		if distance > 305:
			_play_cutscene("office")
		_advance_phone(delta)
		return
	scanner.scan(bike, world.stops)
	ui.update_hud(bike.speed_mps * 3.6, distance, scanner.get_interaction_label(bike), scanner.can_interact(bike), false)
	if distance > chapter_data.weather_at_distance and distance < chapter_data.weather_end_distance and not world.wet:
		world.set_weather(true)
		ui.toast("Rain ahead · There's a warung by the road")
	elif distance > chapter_data.weather_end_distance and world.wet:
		world.set_weather(false)
	_advance_phone(delta)

func _advance_phone(delta: float) -> void:
	# Evaluate after road events: a weather toast or new cutscene owns this frame first.
	var delivery_allowed := state in ["riding", "scenic", "complete"] and ui.mode in ["riding", "scenic", "complete"] and not get_tree().paused and not flow.busy
	var notice := phone_service.advance(delta, delivery_allowed, ui.toast_timer <= 0)
	if not notice.is_empty():
		ui.toast("%s · %s · %s to open Phone when you're ready" % [notice.from, notice.type, InputModeManager.prompt_for("open_phone")], true)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		if is_instance_valid(ui) and state != "menu" and not get_tree().paused:
			_pause()

func _exit_tree() -> void:
	LowPoly.materials.clear()
