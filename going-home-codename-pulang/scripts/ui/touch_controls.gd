class_name TouchControls
extends Control

var fingers: Dictionary = {}
var zones: Dictionary = {}
var owned_actions: Array[String] = []
var labels := {"steer_left": "LEFT", "steer_right": "RIGHT", "brake": "BRAKE", "accelerate": "RIDE"}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_layout_zones)
	_layout_zones()
	visibility_changed.connect(func():
		if not is_visible_in_tree() and not fingers.is_empty():
			release_all())

func _layout_zones() -> void:
	# Anchored to the safe UI rectangle; resizing invalidates finger positions.
	release_all()
	var width := minf(108, (size.x - 72) / 4.0)
	var height := minf(100, size.y * 0.2)
	var y := size.y - height - 24
	zones = {"steer_left": Rect2(18, y, width, height), "steer_right": Rect2(30 + width, y, width, height), "brake": Rect2(size.x - 30 - width * 2, y, width, height), "accelerate": Rect2(size.x - 18 - width, y, width, height)}
	queue_redraw()

func _draw() -> void:
	for action in zones:
		var rect: Rect2 = zones[action]
		draw_style_box(_style(Input.is_action_pressed(action)), rect)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, rect.size.y / 2 + 7), labels[action], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 18, Color("f2e7ce"))

func _style(pressed: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.32, 0.29, 0.85 if pressed else 0.55)
	style.border_color = Color(0.9, 0.85, 0.68, 0.45)
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	return style

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			_update_finger(event.index, get_global_transform_with_canvas().affine_inverse() * event.position)
		else:
			fingers.erase(event.index)
			_sync()
	elif event is InputEventScreenDrag:
		if fingers.has(event.index):
			_update_finger(event.index, get_global_transform_with_canvas().affine_inverse() * event.position)

func _update_finger(index: int, point: Vector2) -> void:
	var tracking := fingers.has(index)
	fingers.erase(index)
	for action in zones:
		if zones[action].has_point(point):
			fingers[index] = action
			break
	if tracking and not fingers.has(index):
		fingers[index] = ""
	_sync()

func _sync() -> void:
	for action in labels:
		if action in fingers.values():
			Input.action_press(action)
			if action not in owned_actions:
				owned_actions.append(action)
		elif action in owned_actions:
			Input.action_release(action)
			owned_actions.erase(action)
	queue_redraw()

func release_all() -> void:
	fingers.clear()
	for action in owned_actions:
		Input.action_release(action)
	owned_actions.clear()
	queue_redraw()

func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED]:
		release_all()

func _exit_tree() -> void:
	release_all()
