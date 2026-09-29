extends CanvasLayer

const DESTINATIONS := [
	["Prologue / Morning cinematic", "prologue", "morning"],
	["Prologue / Commute", "prologue", "commute"],
	["Prologue / Departure cinematic", "prologue", "departure"],
	["Karawang / Road start", "karawang", "road_start"],
	["Karawang / Warung checkpoint", "karawang", "warung"],
	["Karawang / Guesthouse reflection", "karawang", "rest"],
	["Karawang / Chapter complete", "karawang", "complete"]
]
const PROFILES := ["automatic", "morning", "overcast", "drizzle", "rain", "heavy_rain", "golden_hour", "mist", "night"]
var host: Node
var opened := false
var was_paused := false
var panel: Control
var scroll: ScrollContainer
var badge: Button
var performance_label: Label
var notice: Label
var flags_label: Label
var destination: OptionButton
var weather: OptionButton
var distance: SpinBox
var flag_name: LineEdit
var flag_value: LineEdit
var show_performance := false
var performance_toggle: CheckButton
var sample_clock := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 40
	if not SaveManager.development_available():
		queue_free()
		return
	badge = Button.new()
	badge.position = Vector2(12, 12)
	badge.pressed.connect(toggle)
	add_child(badge)
	performance_label = Label.new()
	performance_label.position = Vector2(12, 58)
	performance_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	performance_label.add_theme_constant_override("shadow_offset_x", 2)
	performance_label.add_theme_constant_override("shadow_offset_y", 2)
	performance_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(performance_label)
	_build_panel()
	get_viewport().size_changed.connect(_layout)
	_layout()
	_update_badge()

func _build_panel() -> void:
	panel = ColorRect.new()
	panel.color = Color(0.035, 0.06, 0.05, 0.97)
	panel.theme = host.ui.root.theme
	add_child(panel)
	panel.hide()
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	margin.add_child(column)
	_label(column, "DEVELOPMENT — temporary test session", 24)
	_label(column, "Journey saves are disabled until End test session. Only implemented chapters are listed.", 16)
	scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)
	_label(content, "Chapter / checkpoint")
	destination = OptionButton.new()
	for entry in DESTINATIONS:
		destination.add_item(entry[0])
	content.add_child(destination)
	_button(content, "Load test checkpoint", func(): jump(destination.selected))
	_label(content, "Weather / time preset")
	weather = OptionButton.new()
	for profile in PROFILES:
		weather.add_item(profile.capitalize())
	content.add_child(weather)
	weather.item_selected.connect(func(index: int): set_weather(PROFILES[index]))
	_label(content, "Teleport along current road (meters; riding state only)", 18)
	distance = SpinBox.new()
	distance.min_value = 0
	distance.step = 1
	content.add_child(distance)
	_button(content, "Teleport and stop", func(): teleport(distance.value))
	_label(content, "Story flag (JSON boolean, string or number)", 18)
	flag_name = LineEdit.new()
	flag_name.placeholder_text = "story.karawang.sheltered"
	content.add_child(flag_name)
	flag_value = LineEdit.new()
	flag_value.placeholder_text = "true"
	flag_value.text = "true"
	content.add_child(flag_value)
	var actions := HBoxContainer.new()
	content.add_child(actions)
	_button(actions, "Set flag", func(): set_flag(flag_name.text, flag_value.text))
	_button(actions, "Unset flag", func(): unset_flag(flag_name.text))
	flags_label = _label(content, "", 16)
	performance_toggle = CheckButton.new()
	performance_toggle.text = "Live performance overlay"
	performance_toggle.toggled.connect(func(value: bool): show_performance = value; _sample_performance())
	content.add_child(performance_toggle)
	notice = _label(column, "", 16)
	var footer := HBoxContainer.new()
	column.add_child(footer)
	_button(footer, "Close / F8", close_panel)
	_button(footer, "End test session → title", end_session)

func _label(parent: Node, text: String, size: int = 20) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
	return label

func _button(parent: Node, text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.pressed.connect(action)
	parent.add_child(button)

func _layout() -> void:
	var bounds := get_viewport().get_visible_rect().size
	panel.position = Vector2(maxf(12, (bounds.x - 820) / 2), 12)
	panel.size = Vector2(minf(820, bounds.x - 24), bounds.y - 24)
	badge.position = Vector2(maxf(12, (bounds.x - 340) / 2), 12)
	performance_label.position = Vector2(maxf(12, (bounds.x - 400) / 2), 52)

func _allowed() -> bool:
	return SaveManager.development_available() and not host.flow.busy and host.state != "transition" and not AudioManager.focus_suspended

func toggle() -> void:
	if opened:
		close_panel()
	else:
		open_panel()

func open_panel() -> bool:
	if opened or not _allowed() or not host.ui.capture_action.is_empty():
		return false
	if not SaveManager.begin_development_session():
		return false
	was_paused = get_tree().paused
	get_tree().paused = true
	InputModeManager.release_riding()
	AudioManager.engine_active = false
	host.ui.visible = false
	opened = true
	panel.show()
	distance.max_value = host.bike.route_limit
	distance.value = clampf(-host.bike.position.z, 0, distance.max_value)
	weather.select(maxi(0, PROFILES.find(host.development_weather)))
	for index in range(DESTINATIONS.size()):
		if DESTINATIONS[index][1] == GameState.chapter and DESTINATIONS[index][2] == GameState.checkpoint:
			destination.select(index)
	notice.text = "State: %s | %s / %s" % [host.state, GameState.chapter, GameState.checkpoint]
	_refresh_flags()
	_update_badge()
	destination.grab_focus()
	return true

func close_panel() -> void:
	if not opened or AudioManager.focus_suspended:
		return
	opened = false
	panel.hide()
	host.ui.visible = true
	get_tree().paused = was_paused
	InputModeManager.release_riding()
	_update_badge()

func _mutable() -> bool:
	return opened and SaveManager.development_active and _allowed()

func jump(index: int) -> bool:
	if not _mutable() or index < 0 or index >= DESTINATIONS.size():
		return false
	close_panel()
	get_tree().paused = false
	host.bike.stop()
	host.director.clear_room()
	DialogueManager.active_id = ""
	DialogueManager.choices.clear()
	host.pending_encounter = ""
	host.development_weather = ""
	AudioManager.reset_scene_audio()
	GameState.new_journey()
	var entry: Array = DESTINATIONS[index]
	GameState.chapter = entry[1]
	GameState.checkpoint = entry[2]
	if index >= 2:
		GameState.set_flag("story.prologue.laid_off")
		GameState.set_flag("story.prologue.called_mom")
	if index >= 3:
		GameState.set_flag("story.prologue.departed")
	if index >= 4:
		GameState.set_flag("story.karawang.sheltered")
	if index == 6:
		var journal: Dictionary = host.chapter_data.journal
		var option: Dictionary = journal.options[0]
		GameState.journal[journal.id] = {"chapter_id": "karawang", "selected_option_id": option.id, "text": option.text, "unlocked_at": 0}
		GameState.set_flag("story.karawang.complete")
	host._restore_checkpoint()
	return true

func set_weather(profile: String) -> bool:
	if not _mutable() or profile not in PROFILES or host.state not in ["riding", "scenic", "reflection", "complete", "menu"]:
		return false
	host.development_weather = "" if profile == "automatic" else profile
	var selected: String = profile
	if profile == "automatic":
		selected = "morning" if host.commute or host.state == "menu" else ("night" if host.state in ["reflection", "complete"] else host._road_profile(-host.bike.position.z))
	host.world.set_weather_profile(selected, true)
	weather.select(PROFILES.find(profile))
	notice.text = "Weather/time: " + selected + (" (authored route)" if profile == "automatic" else " (override)")
	return true

func teleport(value: float) -> bool:
	if not _mutable() or host.state != "riding" or not is_finite(value):
		return false
	var target := clampf(value, 0, host.bike.route_limit)
	host.bike.teleport(target)
	host.scanner.candidate = {}
	notice.text = "Teleported to %.0f m. Close the menu to ride." % target
	return true

func _valid_flag(id: String) -> bool:
	var pattern := RegEx.new()
	pattern.compile("^story\\.[a-z0-9_]+(?:\\.[a-z0-9_]+)*$")
	return pattern.search(id) != null

func set_flag(id: String, json_value: String) -> bool:
	if not _mutable():
		return false
	var parsed := JSON.new()
	if not _valid_flag(id) or parsed.parse(json_value) != OK or typeof(parsed.data) not in [TYPE_BOOL, TYPE_STRING, TYPE_FLOAT, TYPE_INT]:
		notice.text = "Use a story.* ID and a JSON boolean, string or finite number."
		return false
	if parsed.data is float and not is_finite(parsed.data):
		return false
	GameState.set_flag(id, parsed.data)
	notice.text = "Set " + id + " (temporary)"
	_refresh_flags()
	return true

func unset_flag(id: String) -> bool:
	if not _mutable() or not _valid_flag(id):
		return false
	GameState.flags.erase(id)
	GameState.flag_changed.emit(id, false)
	notice.text = "Unset " + id + " (temporary)"
	_refresh_flags()
	return true

func _refresh_flags() -> void:
	flags_label.text = JSON.stringify(GameState.flags, "  ")

func end_session() -> bool:
	if not _mutable():
		return false
	close_panel()
	host.development_weather = ""
	host._return_to_menu()
	SaveManager.end_development_session()
	host.ui.main_menu()
	_update_badge()
	return true

func _update_badge() -> void:
	badge.text = "F8 · TEST SESSION · Journey saves disabled" if SaveManager.development_active else "F8 · Development"
	badge.visible = not opened
	_sample_performance()

func _sample_performance() -> void:
	performance_label.visible = show_performance and not opened
	performance_label.text = "FPS %d | CPU frame %.2f ms\nDraw calls %d | Objects %d | Nodes %d" % [Engine.get_frames_per_second(), Performance.get_monitor(Performance.TIME_PROCESS) * 1000, Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME), Performance.get_monitor(Performance.OBJECT_COUNT), Performance.get_monitor(Performance.OBJECT_NODE_COUNT)]

func _process(delta: float) -> void:
	sample_clock += delta
	if sample_clock >= 0.5:
		sample_clock = 0
		_sample_performance()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F8 or (opened and event.keycode == KEY_ESCAPE):
			toggle()
			get_viewport().set_input_as_handled()
