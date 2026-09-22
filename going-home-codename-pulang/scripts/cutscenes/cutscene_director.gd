class_name CutsceneDirector
extends Node3D

signal caption_changed(title: String, subtitle: String, text: String)
signal finished(id: String)
var definitions: Dictionary = {}
var camera: Camera3D
var room: Node3D
var active_id: String = ""
var shot_index: int = 0
var elapsed: float = 0
var skip_held: float = 0
var origin := Vector3(3000, 0, 0)

func _ready() -> void:
	definitions = JSON.parse_string(FileAccess.get_file_as_string("res://data/cutscenes/opening.json"))
	camera = Camera3D.new()
	camera.fov = 52
	add_child(camera)

func play(id: String) -> void:
	active_id = id
	shot_index = 0
	skip_held = 0
	_build_room(definitions[id].location)
	camera.make_current()
	_show_shot()

func _build_room(location: String) -> void:
	if is_instance_valid(room):
		room.free()
	room = Node3D.new()
	room.position = origin
	add_child(room)
	LowPoly.box(room, Vector3(0, -0.1, 0), Vector3(10, 0.2, 10), Color("9c9279"))
	LowPoly.box(room, Vector3(0, 2, -3), Vector3(10, 4, 0.2), Color("c7c6ae"))
	LowPoly.box(room, Vector3(-4, 2, 0), Vector3(0.2, 4, 6), Color("929f93"))
	LowPoly.box(room, Vector3(-1.9, 2.15, -2.86), Vector3(2.4, 1.8, 0.08), Color("63868d"))
	LowPoly.box(room, Vector3(-1.9, 2.15, -2.8), Vector3(0.08, 1.8, 0.09), Color("d9c6a5"))
	LowPoly.box(room, Vector3(-1.9, 2.15, -2.8), Vector3(2.4, 0.08, 0.09), Color("d9c6a5"))
	LowPoly.box(room, Vector3(0, 0.83, -0.6), Vector3(2.9, 0.12, 1.2), Color("80634a"))
	for x in [-1.25, 1.25]:
		LowPoly.box(room, Vector3(x, 0.4, -0.6), Vector3(0.1, 0.8, 1), Color("5c5041"))
	LowPoly.box(room, Vector3(0.2, 0.93, -0.75), Vector3(0.65, 0.05, 0.45), Color("374443"))
	LowPoly.box(room, Vector3(0.2, 1.16, -0.96), Vector3(0.65, 0.45, 0.04), Color("3e555a"))
	LowPoly.cylinder(room, Vector3(-0.8, 1, -0.6), 0.12, 0.25, Color("eee0b5"))
	LowPoly.box(room, Vector3(0.86, 0.925, -0.45), Vector3(0.16, 0.025, 0.31), Color("253a3b"))
	LowPoly.box(room, Vector3(0.86, 0.941, -0.45), Vector3(0.13, 0.008, 0.24), Color("96b7ad"))
	if location == "office":
		LowPoly.person(room, Vector3(0, 0, -1.8), Color("677c7c"))
		LowPoly.label(room, "MEETING ROOM 03", Vector3(1.3, 2.65, -2.8), 25)
	else:
		LowPoly.box(room, Vector3(2.5, 0.35, -1), Vector3(1.4, 0.65, 2.6), Color("4e6e68"))
		LowPoly.box(room, Vector3(2.5, 0.72, -1.85), Vector3(1.1, 0.2, 0.55), Color("ddd3b5"))
		LowPoly.box(room, Vector3(-2.6, 0.8, 0.2), Vector3(0.65, 0.08, 0.6), Color("665b47"))
		LowPoly.box(room, Vector3(-2.6, 1.2, -0.08), Vector3(0.65, 0.8, 0.08), Color("665b47"))
		LowPoly.box(room, Vector3(-2.6, 1.22, -0.01), Vector3(0.55, 0.6, 0.14), Color("698174"))
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0, 2.8, 0)
	lamp.light_color = Color("ffdeb0")
	lamp.light_energy = 0.55
	lamp.light_cull_mask = 2
	lamp.omni_range = 9
	room.add_child(lamp)
	for child in room.find_children("*", "GeometryInstance3D", true, false):
		child.layers = 2

func _show_shot() -> void:
	elapsed = 0
	var data: Dictionary = definitions[active_id]
	var shot: Dictionary = data.shots[shot_index]
	camera.position = origin + _vector(shot.camera)
	camera.look_at(origin + _vector(shot.target))
	caption_changed.emit(data.title, data.subtitle, shot.text)

func _vector(values: Array) -> Vector3:
	return Vector3(values[0], values[1], values[2])

func _process(delta: float) -> void:
	if active_id.is_empty():
		return
	elapsed += delta
	if Input.is_action_pressed("skip_cutscene"):
		skip_held += delta
		if skip_held > 0.8:
			finish()
			return
	else:
		skip_held = 0
	var shots: Array = definitions[active_id].shots
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
	for flag in definitions[id].flags:
		GameState.set_flag(flag, definitions[id].flags[flag])
	active_id = ""
	finished.emit(id)

func clear_room() -> void:
	if is_instance_valid(room):
		room.queue_free()
