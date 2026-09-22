class_name TouchControls
extends Control

var fingers: Dictionary = {}
var zones: Dictionary = {}
var labels := {"steer_left": "LEFT", "steer_right": "RIGHT", "brake": "BRAKE", "accelerate": "RIDE"}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visibility_changed.connect(func():
		if not visible and not fingers.is_empty():
			release_all())

func _draw() -> void:
	var y := size.y - 130
	zones = {"steer_left": Rect2(36, y, 92, 92), "steer_right": Rect2(145, y, 92, 92), "brake": Rect2(size.x - 254, y, 92, 92), "accelerate": Rect2(size.x - 145, y, 108, 92)}
	for action in zones:
		var rect: Rect2 = zones[action]
		draw_style_box(_style(Input.is_action_pressed(action)), rect)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(16, 53), labels[action], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("f2e7ce"))

func _style(pressed: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.32, 0.29, 0.85 if pressed else 0.55)
	style.border_color = Color(0.9, 0.85, 0.68, 0.45)
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	return style

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			_update_finger(event.index, get_global_transform_with_canvas().affine_inverse() * event.position)
		else:
			fingers.erase(event.index)
			_sync()
	elif event is InputEventScreenDrag:
		_update_finger(event.index, get_global_transform_with_canvas().affine_inverse() * event.position)

func _update_finger(index: int, point: Vector2) -> void:
	fingers.erase(index)
	for action in zones:
		if zones[action].has_point(point):
			fingers[index] = action
			break
	_sync()

func _sync() -> void:
	for action in labels:
		if action in fingers.values():
			Input.action_press(action)
		else:
			Input.action_release(action)
	queue_redraw()

func release_all() -> void:
	fingers.clear()
	for action in labels:
		Input.action_release(action)
	queue_redraw()
