extends Node3D

@export_file("*.json") var dialogue_file := "res://data/dialogue/authoring_example.json"
@export var arrival_id := "authoring.arrival"
var dialogue: Node
var distance := 0.0
var mode := "road"
var checkpoint := "None (preview only)"
var status: Label
var caption: Label
var choices: VBoxContainer
var saved_audio: Dictionary
@onready var chapter: EncounterChapter = $Chapter
@onready var npc: EncounterNPC = $Chapter/NPC
@onready var director: EncounterCutscene = $Cutscene
@onready var camera: Camera3D = $Camera

func _enter_tree() -> void:
	saved_audio = {"rain": AudioManager.rain_target, "night": AudioManager.night_target,
		"context": AudioManager.context, "sheltered": AudioManager.sheltered}

func _ready() -> void:
	# A separate instance keeps flags, conditions and dialogue progress local.
	dialogue = preload("res://scripts/autoload/dialogue_manager.gd").new()
	dialogue.content_path = dialogue_file
	dialogue.write_story_state = false
	add_child(dialogue)
	director.write_story_state = false
	_build_ui()
	npc.dialogue_requested.connect(_encounter)
	director.dialogue_requested.connect(_begin_dialogue)
	director.caption_changed.connect(func(title: String, _subtitle: String, line: String): caption.text = title + "\n" + line)
	dialogue.line_changed.connect(_line)
	dialogue.dialogue_finished.connect(_end_dialogue)
	chapter.checkpoint_requested.connect(func(id: String): checkpoint = id + " (preview only)")
	chapter.ambience_changed.connect(func(id: String): AudioManager.set_context(id))
	var errors := chapter.configuration_errors()
	if not dialogue.content.has(npc.dialogue_id):
		errors.append("NPC dialogue ID is missing from the selected bundle")
	if not director.definitions.has(arrival_id):
		errors.append("Arrival ID is missing from the selected cutscene bundle")
	if not errors.is_empty():
		mode = "invalid"
		caption.text = "Configuration errors:\n" + "\n".join(errors)
		_refresh()
		return
	reset_preview()

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(24, 24)
	panel.custom_minimum_size = Vector2(475, 0)
	layer.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)
	var title := Label.new()
	title.text = "ENCOUNTER AUTHORING PREVIEW"
	title.add_theme_font_size_override("font_size", 21)
	box.add_child(title)
	status = Label.new()
	box.add_child(status)
	var travel := HBoxContainer.new()
	box.add_child(travel)
	_button(travel, "Back 20 m", func(): move_to(distance - 20))
	_button(travel, "Forward 20 m", func(): move_to(distance + 20))
	_button(travel, "Go to host", func(): move_to(chapter.npc_distance))
	_button(box, npc.interaction_label, talk)
	_button(box, "Skip arrival scene", func(): director.finish())
	_button(box, "Restart preview", reset_preview)
	caption = Label.new()
	caption.custom_minimum_size.x = 435
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(caption)
	choices = VBoxContainer.new()
	box.add_child(choices)

func _button(parent: Node, text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 38
	button.pressed.connect(action)
	parent.add_child(button)

func _refresh() -> void:
	status.text = "%d / %d m | %s\nWeather: %s | Ambience: %s\nCheckpoint: %s" % [distance, chapter.route_length, mode, chapter.current_profile, chapter.ambience, checkpoint]

func move_to(value: float) -> void:
	if mode != "road" or get_tree().paused or AudioManager.focus_suspended:
		return
	distance = clampf(value, 0, chapter.route_length)
	chapter.sample_distance(distance)
	var at := chapter.to_global(RoadWorld.center(distance))
	camera.global_position = at + Vector3(-15, 6, 12)
	camera.look_at(at + Vector3(-3, 1, -6))
	camera.make_current()
	_refresh()

func talk() -> void:
	if mode != "road":
		return
	AudioManager.unlock()
	var viewer := chapter.to_global(RoadWorld.center(distance) + Vector3(-7, 0, 2))
	if not npc.interact(viewer):
		caption.text = "Move near the host at %d m, then try again." % chapter.npc_distance

func _encounter(id: String) -> void:
	mode = "cutscene"
	director.dialogue_after = id
	director.play(arrival_id)
	_refresh()

func _begin_dialogue(id: String) -> void:
	director.clear_room()
	mode = "dialogue"
	var anchor: Vector3 = npc.get_node("DialogueAnchor").global_position
	camera.global_position = anchor + Vector3(1.5, 0.4, -4)
	camera.look_at(anchor + Vector3(0.7, 0, 0))
	camera.make_current()
	dialogue.start(id)
	_refresh()

func _clear_choices() -> void:
	for child in choices.get_children():
		choices.remove_child(child)
		child.queue_free()

func _line(line: Dictionary) -> void:
	caption.text = line.get("speaker", "") + "\n" + line.text
	_clear_choices()
	if line.choices.is_empty():
		_button(choices, "Continue", func(): dialogue.advance())
	else:
		for index in range(line.choices.size()):
			_button(choices, line.choices[index].text, func(): dialogue.advance(index))

func _end_dialogue(_id: String) -> void:
	_clear_choices()
	npc.release()
	mode = "road"
	caption.text = "Encounter complete. Local flags: " + str(dialogue.local_flags)
	move_to(distance)

func reset_preview() -> void:
	if mode == "invalid":
		return
	director.clear_room()
	dialogue.active_id = ""
	dialogue.local_flags.clear()
	_clear_choices()
	chapter.reset_preview()
	AudioManager.set_context("fields")
	checkpoint = "None (preview only)"
	mode = "road"
	caption.text = "Advance to the roadside host. Events use authored distance markers.\nThis preview never saves campaign progress."
	move_to(0)

func _exit_tree() -> void:
	AudioManager.rain_target = saved_audio.rain
	AudioManager.night_target = saved_audio.night
	AudioManager.set_context(saved_audio.context, saved_audio.sheltered)
