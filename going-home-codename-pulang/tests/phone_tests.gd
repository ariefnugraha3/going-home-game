extends "res://tests/test_runner.gd"

func press_button(prefix: String) -> void:
	for button in app.ui.screen.find_children("*", "Button", true, false):
		if button.text.begins_with(prefix):
			check(not button.disabled, "Phone button is enabled: " + prefix)
			if button.disabled:
				return
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
	var photo_ids: Array = []
	for photo in service.photos:
		check(photo.id not in photo_ids and photo.condition in ["", "story.prologue.departed", "story.karawang.sheltered"], "Unique photo ID and valid story condition: " + photo.id)
		photo_ids.append(photo.id)
		var texture := load(photo.image) as Texture2D
		check(texture != null and texture.get_size() == Vector2(960, 540), "Authored photo imports at the intended resolution: " + photo.id)
	check(service.available_photos().size() == 1 and service.available_photos()[0].id == "with_dad", "Family album is available before the journey")
	check(service.photo_by_id("leaving_jakarta").is_empty() and service.photo_by_id("unknown").is_empty(), "Locked and unknown photo IDs expose no content")
	GameState.set_flag("story.prologue.departed")
	check(service.available_photos().size() == 2 and service.photo_by_id("saris_warung").is_empty(), "Departure unlocks only its own photo")
	GameState.set_flag("story.karawang.sheltered")
	check(service.available_photos().map(func(photo): return photo.id) == photo_ids, "Shelter completes the album in authored order")
	var photo_copy := service.photo_by_id("with_dad")
	photo_copy.caption = "External edit"
	check(service.photo_by_id("with_dad").caption != photo_copy.caption, "Photo lookup returns independent content copies")
	SaveManager.save_game(false)
	snapshot = GameState.snapshot()
	saved = FileAccess.get_file_as_string(SaveManager.SAVE_PATH)
	service.available_photos()
	service.photo_by_id("with_dad")
	check(GameState.snapshot() == snapshot and FileAccess.get_file_as_string(SaveManager.SAVE_PATH) == saved, "Album queries do not mutate state or checkpoint files")
	GameState.new_journey()
	check(service.available_photos().size() == 1, "New journey removes trip photos and retains the family album")
	check(SaveManager.load_game() and service.available_photos().size() == 3, "Existing saved flags restore the album without a schema migration")
	GameState.new_journey()
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
	snapshot = GameState.snapshot()
	press_button("Photos")
	check(app.ui.phone_section == "Photos" and app.ui.phone_photo_id.is_empty() and get_tree().paused, "Photos opens the album while riding stays paused")
	press_button("Dad and me")
	check(app.ui.phone_photo_id == "with_dad", "Album thumbnail button opens the selected photo")
	check(photo_button_disabled("Previous") and not photo_button_disabled("Next"), "First photo has only a forward step")
	await capture("phone_photo_family")
	press_button("Next")
	check(app.ui.phone_photo_id == "leaving_jakarta" and photo_button_disabled("Next"), "Next cannot reach the locked shelter photo")
	await capture("phone_photo_departure")
	press_button("Previous")
	check(app.ui.phone_photo_id == "with_dad", "Previous returns to the preceding unlocked photo")
	back()
	check(app.ui.phone_section == "Photos" and app.ui.phone_photo_id.is_empty() and get_tree().paused, "Escape from photo returns to album without resuming")
	back()
	check(app.ui.phone_section == "Home" and get_tree().paused, "Escape from album returns to phone home")
	app.ui.show_phone("Photos", "saris_warung")
	check(app.ui.phone_photo_id.is_empty(), "Direct locked photo request returns to album")
	app.ui.show_phone("Photos", "unknown")
	check(app.ui.phone_photo_id.is_empty(), "Unknown photo request returns to album")
	var authored_photos: Array = app.phone_service.photos
	app.phone_service.photos = []
	app.ui.show_phone("Photos")
	check(has_photo_label("No photos yet."), "Empty photo data shows an explanatory message")
	app.phone_service.photos = authored_photos.duplicate(true)
	app.phone_service.photos[0].image = "res://assets/photos/missing.png"
	app.ui.show_phone("Photos", "with_dad")
	check(has_photo_label("Photo unavailable.") and not photo_button_disabled("Next"), "Missing image retains readable detail and navigation")
	app.phone_service.photos = authored_photos
	check(GameState.snapshot() == snapshot and FileAccess.get_file_as_string(SaveManager.SAVE_PATH) == saved and app.phone_service.unread_count() == 3, "Photo browsing preserves unread messages, story state and save bytes")
	GameState.set_flag("story.karawang.sheltered")
	app.ui.show_phone("Photos")
	await capture("phone_photos")
	press_button("A place out of the rain")
	check(app.ui.phone_photo_id == "saris_warung" and photo_button_disabled("Next"), "Shelter photo becomes available through its story condition")
	await capture("phone_photo_warung")
	press_button("Back to album")
	check(app.ui.phone_photo_id.is_empty() and app.ui.phone_section == "Photos", "Back to album button clears the detail selection")
	press_button("Back to phone")
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
	app.ui.show_phone("Photos", "saris_warung")
	check(app.ui.phone_photo_id.is_empty() and app.phone_service.available_photos().size() == 1, "New journey cannot reopen a stale trip photo")
	app.ui.show_phone("Photos", "with_dad")
	check(photo_button_disabled("Previous") and photo_button_disabled("Next"), "Single-photo album disables both navigation edges")
	app.ui.show_phone()
	check(app.phone_service.call_history().is_empty() and app.phone_service.unread_count() == 0, "New journey removes old calls and badges from live phone")
	get_tree().paused = false
	app.queue_free()
	await frames(4)
	print("PHONE TEST RESULT: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)

func photo_button_disabled(title: String) -> bool:
	for button in app.ui.screen.find_children("*", "Button", true, false):
		if button.text == title:
			return button.disabled
	check(false, "Missing photo navigation: " + title)
	return false

func has_photo_label(text: String) -> bool:
	for label in app.ui.screen.find_children("*", "Label", true, false):
		if label.text == text:
			return true
	return false
