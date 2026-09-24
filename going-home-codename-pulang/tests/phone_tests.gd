extends "res://tests/test_runner.gd"

func press_button(prefix: String) -> void:
	for button in app.ui.screen.find_children("*", "Button", true, false):
		if button.text.begins_with(prefix):
			button.pressed.emit()
			return
	check(false, "Missing phone button: " + prefix)

func back() -> void:
	var event := InputEventAction.new()
	event.action = "pause"
	event.pressed = true
	app._unhandled_input(event)

func _ready() -> void:
	visual_test = "--visual" in OS.get_cmdline_user_args()
	Engine.max_fps = (30 if "--limit-30" in OS.get_cmdline_user_args() else 60) if visual_test else 0
	GameState.new_journey()
	var service := PhoneDataService.new()
	add_child(service)
	check(service.call_history().is_empty(), "New journey exposes no future call history")
	var ids: Array = []
	for call in service.calls:
		check(call.id not in ids and DialogueManager.content.has(call.dialogue) and DialogueManager.content[call.dialogue].nodes.has(call.remembered_node), "Unique call ID with valid dialogue reference: " + call.id)
		ids.append(call.id)
	GameState.set_flag("story.prologue.called_mom")
	GameState.dialogue_states.mother = "key"
	check(service.call_history().is_empty(), "Final-line flag alone cannot reveal an unfinished call")
	for branch in [0, 1]:
		GameState.new_journey()
		DialogueManager.start("mother")
		complete_dialogue(branch)
		check(service.call_history().size() == 1 and service.call_history()[0].remembered_line == DialogueManager.content.mother.nodes.home.text, "Completed mother-call branch unlocks the same shared memory: " + str(branch))
	var history := service.call_history()
	history[0].note = "Changed outside service"
	check(service.call_history()[0].note != history[0].note, "Call UI receives independent data copies")
	SaveManager.save_game(false)
	var snapshot := GameState.snapshot()
	var saved := FileAccess.get_file_as_string(SaveManager.SAVE_PATH)
	service.call_history()
	service.call_history()
	check(GameState.snapshot() == snapshot and FileAccess.get_file_as_string(SaveManager.SAVE_PATH) == saved and DialogueManager.active_id.is_empty(), "Reading calls cannot replay dialogue, change flags or write saves")
	check(SaveManager.load_game() and service.call_history().size() == 1, "Call history derives from the existing saved completion state")
	GameState.new_journey()
	check(service.call_history().is_empty(), "New journey clears call history without a schema migration")
	service.free()
	app = preload("res://scenes/boot/Boot.tscn").instantiate()
	add_child(app)
	await frames(4)
	app.set_process(false)
	await app._start_road(1100, false)
	GameState.set_flag("story.prologue.laid_off")
	GameState.set_flag("story.prologue.departed")
	app.phone_service.advance(8, true, false)
	check(app.phone_service.unread_count("Messages") == 2 and app.phone_service.unread_count("Email") == 1, "Separate channels count only their delivered unread messages")
	check(app.phone_service.received_messages("Email")[0].id == "recruiter" and app.phone_service.received_messages("Messages").size() == 2, "Email and Messages filter the existing authored types")
	var read_before: Array = GameState.phone.read.duplicate()
	app.phone_service.mark_inbox_read("invalid")
	check(GameState.phone.read == read_before, "Unknown category does not mark other content read")
	saved = FileAccess.get_file_as_string(SaveManager.SAVE_PATH)
	app._on_action("phone")
	check(get_tree().paused and app.ui.phone_section == "Home" and app.phone_service.unread_count() == 3, "Phone home pauses riding without marking unseen messages read")
	check(FileAccess.get_file_as_string(SaveManager.SAVE_PATH) == saved, "Opening phone home does not write a save")
	await capture("phone_home")
	press_button("Messages")
	check(app.ui.phone_section == "Messages" and app.phone_service.unread_count() == 1 and app.phone_service.unread_count("Email") == 1, "Messages button marks only its own section read")
	check(SaveManager.read_save().phone.read.size() == 2, "Channel read status saves immediately")
	await capture("phone_messages")
	back()
	check(app.ui.phone_section == "Home" and get_tree().paused, "Back from Messages returns to phone without resuming ride")
	press_button("Email")
	check(app.ui.phone_section == "Email" and app.phone_service.unread_count() == 0, "Email button opens the separate inbox and clears its badge")
	press_button("Reply:")
	check(app.ui.phone_section == "Email" and GameState.phone.replies.has("recruiter"), "Authored email reply remains inside Email")
	check(SaveManager.load_game() and app.phone_service.unread_count() == 0 and GameState.phone.replies.has("recruiter"), "Channel reads and replies survive existing save/load")
	await capture("phone_email")
	back()
	press_button("Calls")
	check(app.ui.phone_section == "Calls" and app.phone_service.call_history().is_empty(), "Calls page handles empty history")
	GameState.dialogue_states.mother = "complete"
	SaveManager.save_game(false)
	app.ui.show_phone("Calls")
	snapshot = GameState.snapshot()
	saved = FileAccess.get_file_as_string(SaveManager.SAVE_PATH)
	app.ui.show_phone("Calls")
	check(GameState.snapshot() == snapshot and FileAccess.get_file_as_string(SaveManager.SAVE_PATH) == saved and DialogueManager.active_id.is_empty(), "Call page refresh is read-only and cannot restart Mom's call")
	await capture("phone_calls")
	press_button("Back to phone")
	for shortcut in ["Route", "Journal"]:
		press_button(shortcut)
		check(app.ui.phone_origin and get_tree().paused, "Phone shortcut stays paused: " + shortcut)
		back()
		check(app.ui.mode == "phone" and app.ui.phone_section == "Home" and get_tree().paused, "Shortcut Back restores phone home: " + shortcut)
	check(FileAccess.get_file_as_string(SaveManager.SAVE_PATH) == saved, "Browsing Route, Journal and Calls preserves checkpoint file")
	back()
	check(not get_tree().paused and app.ui.mode == "riding", "Back from phone home resumes riding")
	app._on_action("map")
	back()
	check(not get_tree().paused and app.ui.mode == "riding", "Direct map shortcut retains its original resume behavior")
	app.state = "cutscene"
	app._on_action("phone")
	check(app.ui.mode != "phone", "Phone remains blocked by cinematic story lock")
	app.state = "riding"
	app._on_action("phone")
	var position: Vector3 = app.bike.position
	Input.action_press("accelerate")
	await frames(15)
	Input.action_release("accelerate")
	check(app.bike.position == position and get_tree().paused, "Phone navigation cannot move the motorcycle")
	app.ui.show_phone("invalid")
	check(app.ui.phone_section == "Home", "Unknown phone page returns safely to home")
	GameState.new_journey()
	app.ui.show_phone()
	check(app.phone_service.call_history().is_empty() and app.phone_service.unread_count() == 0, "New journey removes old calls and badges from live phone")
	get_tree().paused = false
	app.queue_free()
	await frames(4)
	print("PHONE TEST RESULT: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)
