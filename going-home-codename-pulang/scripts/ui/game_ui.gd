class_name GameUI
extends CanvasLayer

signal action_requested(action: String)
signal journal_selected(id: String, text: String)
const CREAM := Color("f0e7d2")
const MUTED := Color("b4c1ae")
const GOLD := Color("dcb57a")
var root: Control
var screen: Control
var hud: Control
var speed_label: Label
var route_label: Label
var prompt: Button
var toast_label: Label
var status_label: Label
var touch: TouchControls
var weather: AtmosphereOverlay
var mode: String = "menu"
var toast_timer: float = 0
var subtitle_label: Label
var dialogue_label: Label
var dialogue_box: VBoxContainer
var chapter_data: Dictionary
var phone_section: String = "Home"
var phone_photo_id: String = ""
var phone_origin: bool = false
var phone_service: PhoneDataService
var phone_button: Button
var phone_toast: bool = false
var toolbar: HBoxContainer
var capture_action: String = ""
var capture_button: Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	chapter_data = JSON.parse_string(FileAccess.get_file_as_string("res://data/chapters/karawang.json"))
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	root.theme = _theme()
	weather = AtmosphereOverlay.new()
	root.add_child(weather)
	weather.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_hud()
	screen = Control.new()
	root.add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_label = _label(root, "", 18, GOLD)
	toast_label.anchor_left = 0.5
	toast_label.anchor_right = 0.5
	toast_label.offset_left = -280
	toast_label.offset_right = 280
	toast_label.offset_top = 116
	toast_label.offset_bottom = 176
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_label.add_theme_color_override("font_shadow_color", Color("14251d"))
	toast_label.add_theme_constant_override("shadow_offset_x", 1)
	toast_label.add_theme_constant_override("shadow_offset_y", 2)
	DialogueManager.line_changed.connect(show_dialogue)
	if is_instance_valid(phone_service):
		phone_service.inbox_changed.connect(_update_phone_badge)
		_update_phone_badge()
	get_viewport().size_changed.connect(_update_safe_area)
	_update_safe_area()

func _update_safe_area() -> void:
	var bounds := get_viewport().get_visible_rect()
	if OS.has_feature("android"):
		var safe := Rect2(DisplayServer.get_display_safe_area())
		if safe.has_area():
			bounds = (get_viewport().get_screen_transform().affine_inverse() * safe).intersection(bounds)
	apply_safe_area(bounds)

func apply_safe_area(bounds: Rect2) -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	root.offset_left = bounds.position.x
	root.offset_top = bounds.position.y
	root.offset_right = bounds.end.x - viewport_size.x
	root.offset_bottom = bounds.end.y - viewport_size.y

func _theme() -> Theme:
	var theme := Theme.new()
	theme.default_font_size = 20
	theme.set_color("font_color", "Label", CREAM)
	theme.set_color("font_color", "Button", CREAM)
	theme.set_color("font_hover_color", "Button", Color("fff7e8"))
	theme.set_color("font_disabled_color", "Button", Color("82917f"))
	theme.set_stylebox("normal", "Button", _style(Color(0.13, 0.22, 0.19, 0.93), Color("526554")))
	theme.set_stylebox("hover", "Button", _style(Color("395343"), GOLD))
	theme.set_stylebox("pressed", "Button", _style(Color("52705a"), GOLD))
	theme.set_stylebox("focus", "Button", _style(Color(0, 0, 0, 0), GOLD))
	theme.set_stylebox("disabled", "Button", _style(Color(0.1, 0.17, 0.15, 0.65), Color("394b40")))
	theme.set_constant("separation", "VBoxContainer", 13)
	theme.set_constant("separation", "HBoxContainer", 12)
	return theme

func _style(color: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 11
	style.content_margin_bottom = 11
	return style

func _label(parent: Node, text: String, font_size: int = 22, color: Color = CREAM) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func _paragraph(parent: Node, text: String, font_size: int = 22, color: Color = CREAM) -> Label:
	var label := _label(parent, text, font_size, color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

func _button(parent: Node, title: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = title
	button.custom_minimum_size.y = 48
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	parent.add_child(button)
	button.pressed.connect(callback)
	return button

func _clear(next_mode: String) -> void:
	phone_origin = false
	capture_action = ""
	if phone_toast and next_mode not in ["riding", "scenic", "complete"]:
		toast_timer = 0
		toast_label.hide()
	mode = next_mode
	if is_instance_valid(toast_label):
		toast_label.anchor_top = 0 if next_mode == "riding" else 1
		toast_label.anchor_bottom = toast_label.anchor_top
		toast_label.offset_top = 116 if next_mode == "riding" else -48
		toast_label.offset_bottom = 176 if next_mode == "riding" else -4
	for child in screen.get_children():
		screen.remove_child(child)
		child.queue_free()
	hud.visible = next_mode == "riding"
	screen.visible = next_mode != "riding"
	touch.release_all()

func _shade(alpha: float = 0.6) -> void:
	var shade := ColorRect.new()
	shade.color = Color(0.035, 0.085, 0.07, alpha)
	screen.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _panel(title: String, subtitle: String = "") -> VBoxContainer:
	_shade()
	var panel := PanelContainer.new()
	screen.add_child(panel)
	panel.anchor_left = 0.16
	panel.anchor_right = 0.84
	panel.anchor_top = 0.08
	panel.anchor_bottom = 0.92
	panel.add_theme_stylebox_override("panel", _style(Color(0.075, 0.14, 0.115, 0.97), Color("526554")))
	var scroll := ScrollContainer.new()
	panel.add_child(scroll)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(box)
	_label(box, title, 36)
	if not subtitle.is_empty():
		_paragraph(box, subtitle, 18, MUTED)
	var line := HSeparator.new()
	box.add_child(line)
	return box

func main_menu() -> void:
	_clear("menu")
	_shade(0.28)
	var tint := ColorRect.new()
	tint.color = Color(0.06, 0.13, 0.1, 0.82)
	screen.add_child(tint)
	tint.anchor_right = 0.43
	tint.anchor_bottom = 1.0
	var box := VBoxContainer.new()
	screen.add_child(box)
	box.anchor_left = 0.055
	box.anchor_top = 0.11
	box.anchor_right = 0.375
	box.anchor_bottom = 0.91
	_label(box, "A QUIET JOURNEY ACROSS JAVA", 15, GOLD)
	_label(box, "PULANG", 80)
	_label(box, "For now, just go home.", 23, MUTED)
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 27
	box.add_child(spacer)
	var cont := _button(box, "Continue the journey", func(): action_requested.emit("continue"))
	cont.disabled = not SaveManager.has_save()
	_button(box, "Begin a new journey", func(): action_requested.emit("new"))
	_button(box, "Settings & accessibility", show_settings)
	var practice_row := HBoxContainer.new()
	box.add_child(practice_row)
	_button(practice_row, "Controls", show_controls).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_button(practice_row, "Practice ride", func(): action_requested.emit("practice")).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_button(box, "Credits", show_credits)
	if story_debug_available():
		_button(box, "Story debug", func(): action_requested.emit("story_debug"))
	if not OS.has_feature("web"):
		_button(box, "Quit", func(): action_requested.emit("quit"))
	var place := _label(screen, "01  /  THE FIRST STRETCH", 18, CREAM)
	place.anchor_left = 0.53
	place.anchor_top = 0.80
	var trip := _label(screen, "JAKARTA  —  KARAWANG", 30, CREAM)
	trip.anchor_left = 0.53
	trip.anchor_top = 0.845
	var caption := _label(screen, "A motorcycle. A little rain. A long way home.", 18, CREAM)
	caption.anchor_left = 0.53
	caption.anchor_top = 0.905
	(cont if not cont.disabled else box.get_child(5)).grab_focus()

func confirm_new() -> void:
	_clear("confirm_new")
	var box := _panel("Start again?", "Your current journey checkpoint will be replaced. Your settings will stay the same.")
	_button(box, "Begin a new journey", func(): action_requested.emit("new_confirmed"))
	_button(box, "Keep my journey", main_menu).grab_focus()

func _build_hud() -> void:
	hud = Control.new()
	root.add_child(hud)
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var top := PanelContainer.new()
	hud.add_child(top)
	top.position = Vector2(30, 25)
	top.size = Vector2(340, 85)
	top.add_theme_stylebox_override("panel", _style(Color(0.06, 0.13, 0.1, 0.74), Color(0.7, 0.8, 0.65, 0.18)))
	var info := VBoxContainer.new()
	top.add_child(info)
	_label(info, "P U L A N G    /    EASTBOUND", 15, GOLD)
	route_label = _label(info, "Jakarta → Karawang", 22)
	toolbar = HBoxContainer.new()
	toolbar.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	hud.add_child(toolbar)
	toolbar.anchor_left = 1
	toolbar.anchor_right = 1
	toolbar.offset_left = -428
	toolbar.offset_right = -30
	toolbar.offset_top = 28
	for item in [["Phone", "phone"], ["Journal", "journal"], ["Route", "map"], ["Ⅱ", "pause"]]:
		var button := _button(toolbar, item[0], func(): action_requested.emit(item[1]))
		if item[1] == "phone":
			phone_button = button
	speed_label = _label(hud, "00", 44)
	speed_label.add_theme_color_override("font_shadow_color", Color("14251d"))
	speed_label.add_theme_constant_override("shadow_offset_y", 2)
	speed_label.anchor_top = 1
	speed_label.anchor_bottom = 1
	speed_label.offset_left = 36
	speed_label.offset_top = -99
	status_label = _label(hud, "KM/H   ·   FUEL 12.0 L", 15, CREAM)
	status_label.anchor_top = 1
	status_label.offset_left = 38
	status_label.offset_top = -43
	prompt = _button(hud, "", func(): action_requested.emit("interact"))
	prompt.anchor_left = 0.5
	prompt.anchor_right = 0.5
	prompt.anchor_top = 1
	prompt.anchor_bottom = 1
	prompt.offset_left = -255
	prompt.offset_right = 255
	prompt.offset_top = -97
	prompt.offset_bottom = -43
	touch = TouchControls.new()
	hud.add_child(touch)
	touch.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func riding() -> void:
	_clear("riding")

func update_hud(kph: float, distance: float, context: String, can_interact: bool, commute: bool) -> void:
	speed_label.text = "%02d" % int(kph)
	status_label.text = "KM/H   ·   FUEL %.1f L" % GameState.bike.fuel
	route_label.text = "Jakarta · Morning commute" if commute else "Karawang    ·    %.1f km ahead" % (maxf(0, 1700 - distance) / 1000)
	prompt.text = context
	prompt.visible = not context.is_empty()
	prompt.disabled = not can_interact
	touch.visible = InputModeManager.touch_mode or GameState.settings.touch
	prompt.offset_top = -208 if touch.visible else -97
	prompt.offset_bottom = -154 if touch.visible else -43
	speed_label.visible = not touch.visible
	status_label.visible = not touch.visible

func show_pause() -> void:
	_clear("pause")
	var box := _panel("A moment by the road", "Your journey waits for you.")
	_button(box, "Continue riding", func(): action_requested.emit("resume")).grab_focus()
	_button(box, "Settings & accessibility", show_settings)
	_button(box, "Controls", show_controls)
	if story_debug_available():
		_button(box, "Story debug", func(): action_requested.emit("story_debug"))
	_button(box, "Return to the road safely", func(): action_requested.emit("recover"))
	_button(box, "Return to title", func(): action_requested.emit("menu"))
	_paragraph(box, "Progress saves at the departure, shelter, and rest checkpoints. Returning to the title resumes from your last checkpoint.", 18, MUTED)

func show_settings() -> void:
	_clear("settings")
	var box := _panel("Make yourself comfortable", "Settings are saved separately from your journey.")
	for entry in [["Reduced camera motion", "reduced_motion"], ["Gentle steering assist", "riding_assist"], ["Show touch controls", "touch"]]:
		var toggle := CheckButton.new()
		toggle.text = entry[0]
		toggle.custom_minimum_size.y = 42
		toggle.button_pressed = GameState.settings[entry[1]]
		box.add_child(toggle)
		toggle.toggled.connect(func(value: bool):
			GameState.settings[entry[1]] = value
			SaveManager.save_settings())
	for entry in [["Field of view", "fov", 55.0, 85.0, 1.0], ["Master volume", "master", 0.0, 1.0, 0.05], ["Motorcycle volume", "vehicle", 0.0, 1.0, 0.05], ["Ambience volume", "ambience", 0.0, 1.0, 0.05], ["Music volume", "music", 0.0, 1.0, 0.05], ["Sound effects volume", "sfx", 0.0, 1.0, 0.05]]:
		var row := HBoxContainer.new()
		box.add_child(row)
		_label(row, entry[0], 18).custom_minimum_size.x = 215
		var slider := HSlider.new()
		slider.min_value = entry[2]
		slider.max_value = entry[3]
		slider.step = entry[4]
		slider.value = GameState.settings[entry[1]]
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.custom_minimum_size.y = 38
		row.add_child(slider)
		var value_label := _label(row, "%.0f" % (slider.value if entry[1] == "fov" else slider.value * 100), 18)
		value_label.custom_minimum_size.x = 44
		slider.value_changed.connect(func(value: float):
			GameState.settings[entry[1]] = value
			value_label.text = "%.0f" % (value if entry[1] == "fov" else value * 100)
			SaveManager.save_settings())
	var quality := OptionButton.new()
	for name in ["Low · no shadows, fewer raindrops", "Medium · balanced", "High · full scene"]:
		quality.add_item(name)
	quality.selected = clampi(GameState.settings.quality, 0, 2)
	quality.custom_minimum_size.y = 44
	box.add_child(quality)
	quality.item_selected.connect(func(index: int):
		GameState.settings.quality = index
		SaveManager.save_settings())
	var limit := CheckButton.new()
	limit.text = "Limit to 30 FPS"
	limit.button_pressed = GameState.settings.fps_limit == 30
	box.add_child(limit)
	limit.toggled.connect(func(value: bool):
		GameState.settings.fps_limit = 30 if value else 60
		SaveManager.save_settings())
	var text_size := CheckButton.new()
	text_size.text = "Larger dialogue text"
	text_size.button_pressed = GameState.settings.text_size > 22
	box.add_child(text_size)
	text_size.toggled.connect(func(value: bool):
		GameState.settings.text_size = 28 if value else 22
		SaveManager.save_settings())
	_button(box, "Keyboard controls", show_controls)
	_button(box, "Back", func(): action_requested.emit("back"))

func show_controls() -> void:
	_clear("controls")
	var box := _panel("No need to hurry", "Keep left. Brake near a roadside sign, then interact.")
	_paragraph(box, "Select a control, then press a key to replace its shortcuts. Escape cancels. Controls use physical key positions. Other controls' default keys stay reserved.", 18, MUTED)
	for action in InputModeManager.REMAPPABLE:
		var button := _button(box, "%s: %s" % [InputModeManager.REMAPPABLE[action], InputModeManager.key_label(action)], func(): pass)
		button.pressed.connect(func(): _begin_binding(action, button))
		if action == "accelerate":
			button.grab_focus()
	_paragraph(box, "Fixed controls: Escape pauses / goes back. Enter activates the focused menu or dialogue button. Hold Space to skip a cinematic.\nTouch: use LEFT / RIGHT, RIDE / BRAKE and the interaction button above them.", 20)
	_paragraph(box, "Stop at Sari's warung before resting at the guesthouse. Fuel and scenic stops are optional. You can take your time.", 20, GOLD)
	_button(box, "Restore default keyboard controls", func():
		var saved := InputModeManager.reset_bindings()
		show_controls()
		toast("Default keyboard controls restored." if saved else "Defaults applied for this session, but settings could not be saved."))
	_button(box, "Back", func(): action_requested.emit("back"))

func _begin_binding(action: String, button: Button) -> void:
	if is_instance_valid(capture_button) and not capture_action.is_empty():
		capture_button.text = "%s: %s" % [InputModeManager.REMAPPABLE[capture_action], InputModeManager.key_label(capture_action)]
	capture_action = action
	capture_button = button
	button.text = "Press a key for %s (Escape to cancel)" % InputModeManager.REMAPPABLE[action]
	InputModeManager.release_riding()

func _input(event: InputEvent) -> void:
	if capture_action.is_empty() or not event is InputEventKey:
		return
	get_viewport().set_input_as_handled()
	if not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE or event.physical_keycode == KEY_ESCAPE:
		capture_button.text = "%s: %s" % [InputModeManager.REMAPPABLE[capture_action], InputModeManager.key_label(capture_action)]
		capture_action = ""
		return
	if event.ctrl_pressed or event.alt_pressed or event.meta_pressed or event.shift_pressed:
		toast("Choose one key without Ctrl, Alt, Command or Shift.")
		return
	var error := InputModeManager.rebind(capture_action, event.physical_keycode)
	if not error.is_empty():
		toast(error)
		return
	capture_button.text = "%s: %s" % [InputModeManager.REMAPPABLE[capture_action], InputModeManager.key_label(capture_action)]
	capture_action = ""
	toast("Keyboard control saved.")

func show_credits() -> void:
	_clear("credits")
	var box := _panel("PULANG", "A long ride home across Java.")
	_paragraph(box, "Based on the PULANG GDD v2, TDD v1, and Development Roadmap v1.\n\nBuilt with Godot Engine 4.7.2.\nOriginal low-poly geometry and synthesized placeholder audio created for this project.\nGodot's bundled font: Noto Sans.\n\nMotorcycle design reference: Suzuki Thunder 250 (2000). No affiliation or endorsement.\n\nThis playable development slice follows Raka from Jakarta to his first night in Karawang. The remaining journey is still in development.", 22)
	_button(box, "Back", func(): action_requested.emit("back"))

func show_phone(section: String = "Home", photo_id: String = "") -> void:
	if section not in ["Home", "Messages", "Email", "Calls", "Photos"]:
		section = "Home"
	_clear("phone")
	phone_section = section
	phone_photo_id = ""
	if section == "Photos" and is_instance_valid(phone_service) and not phone_service.photo_by_id(photo_id).is_empty():
		phone_photo_id = photo_id
	var subtitle := "Read when you're ready."
	if section == "Photos":
		subtitle = "A few moments to keep." if phone_photo_id.is_empty() else ""
	var box := _panel("Photos" if section == "Photos" else "Your phone", subtitle)
	if section == "Home":
		for channel in PhoneDataService.CHANNELS:
			var count: int = phone_service.unread_count(channel) if is_instance_valid(phone_service) else 0
			_button(box, "%s (%d unread)" % [channel, count], func(): show_phone(channel))
		var call_count: int = phone_service.call_history().size() if is_instance_valid(phone_service) else 0
		_button(box, "Calls (%d)" % call_count, func(): show_phone("Calls"))
		var photo_count: int = phone_service.available_photos().size() if is_instance_valid(phone_service) else 0
		_button(box, "Photos (%d)" % photo_count, func(): show_phone("Photos"))
		_button(box, "Route", func(): show_map(true))
		_button(box, "Journal", func(): show_journal(false, true))
	elif section == "Photos":
		if phone_photo_id.is_empty():
			_button(box, "Back to phone", func(): show_phone()).grab_focus()
		else:
			_button(box, "Back to album", func(): show_phone("Photos")).grab_focus()
		_show_photos(box)
	else:
		_button(box, "Back to phone", func(): show_phone()).grab_focus()
		_label(box, section, 27, GOLD)
		if section == "Calls":
			_show_calls(box)
		else:
			_show_inbox(box, section)
	_button(box, "Put the phone away", func(): action_requested.emit("resume"))

func _photo_image(parent: Control, path: String, minimum: Vector2) -> void:
	if not ResourceLoader.exists(path):
		_paragraph(parent, "Photo unavailable.", 18, MUTED)
		return
	var picture := TextureRect.new()
	picture.texture = load(path) as Texture2D
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.custom_minimum_size = minimum
	picture.size_flags_horizontal = Control.SIZE_EXPAND_FILL if minimum.x == 0 else Control.SIZE_SHRINK_CENTER
	parent.add_child(picture)

func _show_photos(box: VBoxContainer) -> void:
	var album: Array = phone_service.available_photos() if is_instance_valid(phone_service) else []
	if album.is_empty():
		_paragraph(box, "No photos yet.", 22, MUTED)
		return
	if phone_photo_id.is_empty():
		for photo in album:
			var row := HBoxContainer.new()
			box.add_child(row)
			_photo_image(row, photo.image, Vector2(160, 90))
			var details := VBoxContainer.new()
			details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(details)
			_button(details, photo.title, func(): show_phone("Photos", photo.id))
			_paragraph(details, photo.when, 18, MUTED)
		return
	for index in album.size():
		var photo: Dictionary = album[index]
		if photo.id != phone_photo_id:
			continue
		_paragraph(box, photo.title + " / " + photo.when, 20, GOLD)
		_photo_image(box, photo.image, Vector2(0, 230))
		_paragraph(box, photo.caption, 20)
		var navigation := HBoxContainer.new()
		box.add_child(navigation)
		var previous := _button(navigation, "Previous", func(): show_phone("Photos", album[index - 1].id))
		previous.disabled = index == 0
		_label(navigation, "%d / %d" % [index + 1, album.size()], 18, MUTED)
		var next := _button(navigation, "Next", func(): show_phone("Photos", album[index + 1].id))
		next.disabled = index == album.size() - 1
		return

func _show_inbox(box: VBoxContainer, channel: String) -> void:
	var inbox: Array = phone_service.received_messages(channel) if is_instance_valid(phone_service) else []
	if inbox.is_empty():
		_paragraph(box, "No email yet." if channel == "Email" else "No messages yet. A quiet moment.", 22, MUTED)
	for message in inbox:
		_label(box, message.from, 21, GOLD)
		_paragraph(box, message.text, 21)
		if GameState.phone.replies.has(message.id):
			_paragraph(box, "You: " + GameState.phone.replies[message.id], 20, MUTED)
		else:
			_button(box, "Reply: " + message.reply, func():
				phone_service.reply(message.id)
				show_phone(channel))
		box.add_child(HSeparator.new())
	if is_instance_valid(phone_service):
		phone_service.mark_inbox_read(channel)

func _show_calls(box: VBoxContainer) -> void:
	var history: Array = phone_service.call_history() if is_instance_valid(phone_service) else []
	if history.is_empty():
		_paragraph(box, "No completed calls yet.", 22, MUTED)
	for call in history:
		_label(box, call.from + " / " + call.direction, 21, GOLD)
		_paragraph(box, call.when, 18, MUTED)
		_paragraph(box, "What stayed with me", 20, GOLD)
		_paragraph(box, call.note, 21)
		_paragraph(box, call.from + ": " + call.remembered_line, 21)
		box.add_child(HSeparator.new())

func phone_back() -> bool:
	if mode == "phone" and phone_section == "Photos" and not phone_photo_id.is_empty():
		show_phone("Photos")
		return true
	if phone_origin or (mode == "phone" and phone_section != "Home"):
		show_phone()
		return true
	return false

func _update_phone_badge() -> void:
	if is_instance_valid(phone_button) and is_instance_valid(phone_service):
		var count := phone_service.unread_count()
		phone_button.text = "Phone (%d)" % count if count > 0 else "Phone"

func story_debug_available() -> bool:
	return OS.is_debug_build() and "--story-debug" in OS.get_cmdline_user_args() and is_instance_valid(phone_service)

func show_story_debug() -> void:
	if not story_debug_available():
		return
	_clear("story_debug")
	toast_timer = 0
	var box := _panel("Story debug", "Read-only session state. Refresh to inspect changes; nothing here edits or saves the journey.")
	_button(box, "Refresh", show_story_debug).grab_focus()
	_button(box, "Back", func(): action_requested.emit("back"))
	_paragraph(box, "Chapter: %s   /   Checkpoint: %s\nActive dialogue: %s" % [GameState.chapter, GameState.checkpoint, DialogueManager.active_id], 18, GOLD)
	var filter := LineEdit.new()
	filter.placeholder_text = "Filter flag names or values"
	filter.custom_minimum_size.y = 48
	box.add_child(filter)
	var flags_label := _paragraph(box, _debug_flags(""), 18)
	filter.text_changed.connect(func(query: String): flags_label.text = _debug_flags(query))
	_paragraph(box, "Dialogue states\n" + JSON.stringify(GameState.dialogue_states, "  "), 18)
	_paragraph(box, "Phone delivery state\n" + JSON.stringify(GameState.phone, "  "), 18)

func _debug_flags(query: String) -> String:
	var lines := PackedStringArray()
	var keys: Array = GameState.flags.keys()
	keys.sort()
	for key in keys:
		var line := "%s = %s" % [key, JSON.stringify(GameState.flags[key])]
		if query.is_empty() or line.to_lower().contains(query.to_lower()):
			lines.append(line)
	return "No matching flags." if lines.is_empty() else "\n".join(lines)

func show_map(from_phone: bool = false) -> void:
	_clear("map")
	phone_origin = from_phone
	var box := _panel("A long way east", "JAKARTA → BANYUWANGI   /   Your journey across Java")
	box.add_child(RouteMap.new())
	_paragraph(box, "Today: Jakarta → Karawang", 28, GOLD)
	_paragraph(box, "Fuel station  ·  Rice-field turnout  ·  Sari's warung  ·  Guesthouse\n\nStop by the warung when the rain comes. The guesthouse is just beyond the fields.", 22)
	_paragraph(box, "Beyond this chapter\n" + "  →  ".join(chapter_data.route.slice(2)), 18, MUTED)
	if from_phone:
		_button(box, "Back to phone", func(): show_phone())
	else:
		_button(box, "Fold the map", func(): action_requested.emit("resume"))

func show_journal(write: bool = false, from_phone: bool = false) -> void:
	_clear("reflection" if write else "journal")
	phone_origin = from_phone and not write
	var data: Dictionary = chapter_data.journal
	var box := _panel("The travel journal", "KARAWANG   /   The first night")
	if write:
		_paragraph(box, data.prompt, 27, GOLD)
		for option in data.options:
			_button(box, option.text, func(): journal_selected.emit(option.id, option.text))
	elif GameState.journal.has(data.id):
		_paragraph(box, data.prompt, 24, GOLD)
		_paragraph(box, GameState.journal[data.id].text, 26)
	else:
		_paragraph(box, "An empty page. I'll write something when I stop for the night.", 25, MUTED)
	if not write:
		if from_phone:
			_button(box, "Back to phone", func(): show_phone())
		else:
			_button(box, "Close the journal", func(): action_requested.emit("resume"))

func show_cinematic(title: String, subtitle: String, text: String) -> void:
	_clear("cinematic")
	for bottom in [false, true]:
		var bar := ColorRect.new()
		bar.color = Color(0.025, 0.05, 0.04, 0.95)
		screen.add_child(bar)
		bar.anchor_right = 1
		bar.anchor_top = 0.78 if bottom else 0
		bar.anchor_bottom = 1 if bottom else 0.15
	var title_label := _label(screen, title + "    /    " + subtitle, 18, GOLD)
	title_label.position = Vector2(45, 35)
	if title == "PULANG":
		var reveal := _label(screen, "PULANG", 56, CREAM)
		reveal.anchor_left = 0.2
		reveal.anchor_right = 0.8
		reveal.anchor_top = 0.2
		reveal.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label = _label(screen, text, GameState.settings.text_size)
	subtitle_label.anchor_left = 0.1
	subtitle_label.anchor_right = 0.9
	subtitle_label.anchor_top = 0.82
	subtitle_label.anchor_bottom = 0.94
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var skip := _button(screen, "Skip scene", func(): action_requested.emit("skip"))
	skip.anchor_left = 1
	skip.anchor_right = 1
	skip.offset_left = -170
	skip.offset_right = -30
	skip.offset_top = 22

func show_dialogue(line: Dictionary) -> void:
	_clear("dialogue")
	var panel := PanelContainer.new()
	screen.add_child(panel)
	panel.anchor_left = 0.1
	panel.anchor_right = 0.9
	panel.anchor_top = 0.53
	panel.anchor_bottom = 0.96
	panel.add_theme_stylebox_override("panel", _style(Color(0.055, 0.12, 0.095, 0.97), Color("7d8969")))
	var scroll := ScrollContainer.new()
	panel.add_child(scroll)
	dialogue_box = VBoxContainer.new()
	dialogue_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(dialogue_box)
	_label(dialogue_box, line.get("speaker", ""), 19, GOLD)
	dialogue_label = _paragraph(dialogue_box, line.get("text", ""), GameState.settings.text_size)
	if line.choices.is_empty():
		_button(dialogue_box, "Continue  →", func(): DialogueManager.advance()).grab_focus()
	else:
		for i in range(line.choices.size()):
			var button := _button(dialogue_box, line.choices[i].text, func(): DialogueManager.advance(i))
			button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			if i == 0:
				button.grab_focus()

func show_scenic() -> void:
	_clear("scenic")
	var box := VBoxContainer.new()
	screen.add_child(box)
	box.anchor_left = 0.25
	box.anchor_right = 0.75
	box.anchor_top = 0.78
	_label(box, "Just the fields. Just for a while.", 23).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_button(box, "Start the engine when you're ready", func(): action_requested.emit("resume"))

func show_end() -> void:
	_clear("complete")
	var box := _panel("One day closer to home", "KARAWANG   /   The first night")
	_paragraph(box, "The gloves hang by the window. The bike is under a roof.\n\nI tell Mom I've stopped for the night.\n\nTomorrow, east again.", 27)
	_paragraph(box, "End of the first playable chapter.\nRaka's journey continues toward Banyuwangi in the chapters to come.", 20, GOLD)
	_button(box, "Read the journal", func(): action_requested.emit("journal"))
	_button(box, "Return to title", func(): action_requested.emit("menu"))

func toast(text: String, is_phone_notice: bool = false) -> void:
	toast_label.text = text
	toast_timer = 5
	phone_toast = is_phone_notice

func _process(delta: float) -> void:
	toast_timer = maxf(0, toast_timer - delta)
	toast_label.visible = toast_timer > 0
