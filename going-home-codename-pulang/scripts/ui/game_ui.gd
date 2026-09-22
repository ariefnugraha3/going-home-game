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
var messages: Array

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	chapter_data = JSON.parse_string(FileAccess.get_file_as_string("res://data/chapters/karawang.json"))
	messages = JSON.parse_string(FileAccess.get_file_as_string("res://data/phone/messages.json"))
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
	_button(box, "Controls", show_controls)
	_button(box, "Credits", show_credits)
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
	var toolbar := HBoxContainer.new()
	hud.add_child(toolbar)
	toolbar.anchor_left = 1
	toolbar.anchor_right = 1
	toolbar.offset_left = -428
	toolbar.offset_right = -30
	toolbar.offset_top = 28
	for item in [["Phone", "phone"], ["Journal", "journal"], ["Route", "map"], ["Ⅱ", "pause"]]:
		_button(toolbar, item[0], func(): action_requested.emit(item[1]))
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
	speed_label.visible = not touch.visible
	status_label.visible = not touch.visible

func show_pause() -> void:
	_clear("pause")
	var box := _panel("A moment by the road", "Your journey waits for you.")
	_button(box, "Continue riding", func(): action_requested.emit("resume")).grab_focus()
	_button(box, "Settings & accessibility", show_settings)
	_button(box, "Controls", show_controls)
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
	for entry in [["Field of view", "fov", 55.0, 85.0, 1.0], ["Master volume", "master", 0.0, 1.0, 0.05], ["Motorcycle volume", "vehicle", 0.0, 1.0, 0.05], ["Ambience volume", "ambience", 0.0, 1.0, 0.05]]:
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
	_button(box, "Back", func(): action_requested.emit("back"))

func show_controls() -> void:
	_clear("controls")
	var box := _panel("No need to hurry", "Keep left. Brake near a roadside sign, then interact.")
	for text in ["W / ↑   Accelerate        S / ↓ / Space   Brake", "A / D or ← / →   Steer        Q / R   Glance", "E   Interact when stopped        Enter   Advance dialogue", "Tab   Phone        J   Journal        M   Route", "Esc   Pause / Back        Backspace   Return to road", "Hold Space   Skip a cinematic", "Touch: left/right steering areas, RIDE and BRAKE. Use the large interaction button when stopped."]:
		_paragraph(box, text, 20)
	_paragraph(box, "Stop at Sari's warung before resting at the guesthouse. Fuel and scenic stops are optional. You can take your time.", 20, GOLD)
	_button(box, "Back", func(): action_requested.emit("back"))

func show_credits() -> void:
	_clear("credits")
	var box := _panel("PULANG", "A long ride home across Java.")
	_paragraph(box, "Based on the PULANG GDD v2, TDD v1, and Development Roadmap v1.\n\nBuilt with Godot Engine 4.7.2.\nOriginal low-poly geometry and synthesized placeholder audio created for this project.\nGodot's bundled font: Noto Sans.\n\nMotorcycle design reference: Suzuki Thunder 250 (2000). No affiliation or endorsement.\n\nThis playable development slice follows Raka from Jakarta to his first night in Karawang. The remaining journey is still in development.", 22)
	_button(box, "Back", func(): action_requested.emit("back"))

func show_phone() -> void:
	_clear("phone")
	var box := _panel("Your phone", "MESSAGES & EMAIL   /   Read when you're ready.")
	var any := false
	for message in messages:
		if not GameState.flags.get(message.condition, false):
			continue
		any = true
		_label(box, message.from + "  ·  " + message.type, 21, GOLD)
		_paragraph(box, message.text, 21)
		if message.id not in GameState.phone.read:
			GameState.phone.read.append(message.id)
		if GameState.phone.replies.has(message.id):
			_paragraph(box, "You: " + GameState.phone.replies[message.id], 20, MUTED)
		else:
			_button(box, "Reply: " + message.reply, func():
				GameState.phone.replies[message.id] = message.reply
				GameState.set_flag("phone." + message.id + ".replied")
				SaveManager.save_game()
				show_phone())
		box.add_child(HSeparator.new())
	if not any:
		_paragraph(box, "No new messages. A quiet morning.", 22, MUTED)
	_button(box, "Put the phone away", func(): action_requested.emit("resume"))

func show_map() -> void:
	_clear("map")
	var box := _panel("A long way east", "JAKARTA → BANYUWANGI   /   Your journey across Java")
	box.add_child(RouteMap.new())
	_paragraph(box, "Today: Jakarta → Karawang", 28, GOLD)
	_paragraph(box, "Fuel station  ·  Rice-field turnout  ·  Sari's warung  ·  Guesthouse\n\nStop by the warung when the rain comes. The guesthouse is just beyond the fields.", 22)
	_paragraph(box, "Beyond this chapter\n" + "  →  ".join(chapter_data.route.slice(2)), 18, MUTED)
	_button(box, "Fold the map", func(): action_requested.emit("resume"))

func show_journal(write: bool = false) -> void:
	_clear("reflection" if write else "journal")
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

func toast(text: String) -> void:
	toast_label.text = text
	toast_timer = 5

func _process(delta: float) -> void:
	toast_timer = maxf(0, toast_timer - delta)
	toast_label.visible = toast_timer > 0
