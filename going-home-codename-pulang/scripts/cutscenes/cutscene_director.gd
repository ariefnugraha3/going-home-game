class_name CutsceneDirector
extends Node3D

signal caption_changed(title: String, subtitle: String, text: String)
signal finished(id: String)
var definitions: Dictionary = {}
var camera: Camera3D
var room: CinematicStage
var active_id: String = ""
var shot_index: int = 0
var elapsed: float = 0
var skip_held: float = 0
var stage_id: String = ""
var origin := Vector3(3000, 0, 0)

func _ready() -> void:
	definitions = JSON.parse_string(FileAccess.get_file_as_string("res://data/cutscenes/opening.json"))
	camera = Camera3D.new()
	camera.fov = 52
	camera.cull_mask = 2
	add_child(camera)

func play(id: String) -> void:
	if not definitions.has(id):
		return
	active_id = id
	shot_index = 0
	skip_held = 0
	stage_id = ""
	camera.make_current()
	_show_shot()

func _build_room(location: String) -> void:
	if is_instance_valid(room):
		room.free()
	room = CinematicStage.new()
	room.position = origin
	add_child(room)
	room.build(location, active_id == "night")

func _show_shot() -> void:
	elapsed = 0
	var data: Dictionary = definitions[active_id]
	var shot: Dictionary = data.shots[shot_index]
	var location: String = shot.get("location", data.location)
	if stage_id != location:
		_build_room(location)
		stage_id = location
	room.configure(shot)
	_apply_shot(0)
	caption_changed.emit(shot.get("title", data.title), shot.get("subtitle", data.subtitle), shot.text)

func _apply_shot(progress: float) -> void:
	var shot: Dictionary = definitions[active_id].shots[shot_index]
	var weight := smoothstep(0.0, 1.0, progress)
	var start := _vector(shot.camera)
	var end := _vector(shot.get("camera_end", shot.camera))
	# Reduced motion keeps authored framing but disables camera travel.
	camera.position = origin + start.lerp(end, 0.0 if GameState.settings.reduced_motion else weight)
	camera.look_at(origin + _vector(shot.target))
	camera.fov = shot.get("fov", 52.0)
	room.pose(shot, weight)

func audio_context() -> String:
	if stage_id == "memory":
		return "fields"
	return "city" if stage_id == "parking" else "indoors"


func _vector(values: Array) -> Vector3:
	return Vector3(values[0], values[1], values[2])

func _process(delta: float) -> void:
	if active_id.is_empty():
		return
	elapsed += maxf(delta, 0)
	if Input.is_action_pressed("skip_cutscene"):
		skip_held += delta
		if skip_held > 0.8:
			finish()
			return
	else:
		skip_held = 0
	var shots: Array = definitions[active_id].shots
	_apply_shot(clampf(elapsed / shots[shot_index].duration, 0, 1))
	if elapsed >= shots[shot_index].duration:
		shot_index += 1
		if shot_index >= shots.size():
			finish()
		else:
			_show_shot()

func finish() -> void:
	if active_id.is_empty():
		return
	var id := active_id
	# Dialogue handoffs keep this stage visible, including when skipped early.
	shot_index = definitions[id].shots.size() - 1
	_show_shot()
	_apply_shot(1.0)
	for flag in definitions[id].flags:
		GameState.set_flag(flag, definitions[id].flags[flag])
	active_id = ""
	finished.emit(id)

func clear_room() -> void:
	if is_instance_valid(room):
		room.free()
	room = null
	stage_id = ""
	active_id = ""
	skip_held = 0
