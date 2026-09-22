extends Node

signal mode_changed(touch: bool)
var touch_mode: bool = false
const BINDINGS := {
	"accelerate": [KEY_W, KEY_UP], "brake": [KEY_S, KEY_DOWN, KEY_SPACE],
	"steer_left": [KEY_A, KEY_LEFT], "steer_right": [KEY_D, KEY_RIGHT],
	"look_left": [KEY_Q], "look_right": [KEY_R], "look_up": [KEY_PAGEUP], "look_down": [KEY_PAGEDOWN],
	"interact": [KEY_E], "confirm": [KEY_ENTER], "cancel": [KEY_ESCAPE],
	"open_phone": [KEY_TAB], "open_journal": [KEY_J], "open_map": [KEY_M],
	"pause": [KEY_ESCAPE], "photo_mode": [KEY_P], "skip_cutscene": [KEY_SPACE], "recover": [KEY_BACKSPACE]
}

func _ready() -> void:
	for action in BINDINGS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in BINDINGS[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)
	touch_mode = OS.has_feature("android") or DisplayServer.is_touchscreen_available()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and not touch_mode:
		touch_mode = true
		mode_changed.emit(true)
	elif event is InputEventKey and touch_mode and not OS.has_feature("android"):
		touch_mode = false
		mode_changed.emit(false)

func release_riding() -> void:
	for action in ["accelerate", "brake", "steer_left", "steer_right", "look_left", "look_right"]:
		Input.action_release(action)
