extends Node

signal mode_changed(touch: bool)
signal bindings_changed
var touch_mode: bool = false
const BINDINGS := {
	"accelerate": [KEY_W, KEY_UP], "brake": [KEY_S, KEY_DOWN, KEY_SPACE],
	"steer_left": [KEY_A, KEY_LEFT], "steer_right": [KEY_D, KEY_RIGHT],
	"look_left": [KEY_Q], "look_right": [KEY_R], "look_up": [KEY_PAGEUP], "look_down": [KEY_PAGEDOWN],
	"interact": [KEY_E], "confirm": [KEY_ENTER], "cancel": [KEY_ESCAPE],
	"open_phone": [KEY_TAB], "open_journal": [KEY_J], "open_map": [KEY_M],
	"pause": [KEY_ESCAPE], "photo_mode": [KEY_P], "skip_cutscene": [KEY_SPACE], "recover": [KEY_BACKSPACE]
}
const REMAPPABLE := {
	"accelerate": "Accelerate", "brake": "Brake", "steer_left": "Steer left", "steer_right": "Steer right",
	"look_left": "Glance left", "look_right": "Glance right", "look_up": "Look up", "look_down": "Look down",
	"interact": "Interact", "open_phone": "Phone", "open_journal": "Journal", "open_map": "Route", "recover": "Return to road"
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	apply_bindings()
	touch_mode = OS.has_feature("android") or DisplayServer.is_touchscreen_available()

func apply_bindings() -> void:
	var requested: Dictionary = GameState.settings.key_bindings.duplicate()
	GameState.settings.key_bindings = {}
	for action in BINDINGS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		InputMap.action_erase_events(action)
		for key in BINDINGS[action]:
			_add_key(action, key)
	# Validate against defaults too: overrides cannot take another action's fallback.
	for action in requested:
		if action is String and requested[action] is int and binding_error(action, requested[action]).is_empty():
			_set_binding(action, requested[action])
	bindings_changed.emit()

func _add_key(action: String, key: int) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	InputMap.action_add_event(action, event)

func binding_error(action: String, key: int) -> String:
	if not REMAPPABLE.has(action):
		return "This control stays fixed."
	if not (key >= KEY_A and key <= KEY_Z or key >= KEY_0 and key <= KEY_9 or key in [KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_SPACE, KEY_TAB, KEY_BACKSPACE, KEY_PAGEUP, KEY_PAGEDOWN]):
		return "Choose a letter, number, arrow, Space, Tab, Backspace, Page Up or Page Down."
	for other in BINDINGS:
		if other == action:
			continue
		# Space is intentionally shared by braking and cinematic skipping.
		if action == "brake" and other == "skip_cutscene" and key == KEY_SPACE:
			continue
		if key in BINDINGS[other] or GameState.settings.key_bindings.get(other, 0) == key:
			return "%s is reserved for %s." % [OS.get_keycode_string(key), REMAPPABLE.get(other, other.replace("_", " "))]
	return ""

func _set_binding(action: String, key: int) -> void:
	Input.action_release(action)
	InputMap.action_erase_events(action)
	_add_key(action, key)
	GameState.settings.key_bindings[action] = key

func rebind(action: String, key: int) -> String:
	var error := binding_error(action, key)
	if not error.is_empty():
		return error
	_set_binding(action, key)
	var saved := SaveManager.save_settings()
	bindings_changed.emit()
	return "" if saved else "Control applied for this session, but settings could not be saved."

func reset_bindings() -> bool:
	GameState.settings.key_bindings = {}
	release_riding()
	apply_bindings()
	return SaveManager.save_settings()

func key_label(action: String) -> String:
	var names := PackedStringArray()
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			names.append(OS.get_keycode_string(event.physical_keycode))
	return " / ".join(names)

func prompt_for(action: String) -> String:
	return "Tap" if touch_mode or GameState.settings.touch else key_label(action)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and not touch_mode:
		touch_mode = true
		mode_changed.emit(true)
	elif event is InputEventKey and touch_mode and not OS.has_feature("android"):
		touch_mode = false
		mode_changed.emit(false)

func release_riding() -> void:
	for action in ["accelerate", "brake", "steer_left", "steer_right", "look_left", "look_right", "look_up", "look_down"]:
		Input.action_release(action)

func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED]:
		release_riding()
