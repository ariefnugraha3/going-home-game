extends "res://tests/test_runner.gd"

const VALIDATOR = preload("res://tools/authoring/template_validator.gd")
const PREVIEW = preload("res://tools/authoring/EncounterPreview.tscn")

func _ready() -> void:
	var story := GameState.snapshot()
	check(not SaveManager.development_available() and not SaveManager.begin_development_session(), "Development sessions require explicit editor opt-in")
	check(not SaveManager.development_active, "Ordinary launch keeps normal persistence enabled")
	var rain := AudioManager.rain_target
	var count := int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
	_scan("res://scenes/templates")
	_scan("res://tools/authoring")
	var cases: Array[Callable] = [
		func(s: Node): s.get_node("Chapter/NPC/DialogueAnchor").free(),
		func(s: Node): s.get_node("Chapter/Markers/Weather").free(),
		func(s: Node): s.get_node("Chapter").checkpoint_distance = 2000,
		func(s: Node): s.get_node("Chapter").arrival_weather = "missing",
		func(s: Node): s.get_node("Chapter").arrival_ambience = "missing",
		func(s: Node): s.get_node("Chapter/NPC").dialogue_id = "missing",
		func(s: Node): s.get_node("Chapter/NPC").interaction_radius = NAN,
		func(s: Node): s.arrival_id = "missing",
		func(s: Node): s.dialogue_file = "res://missing.json",
		func(s: Node): s.get_node("Cutscene").definitions_path = "res://missing.json",
		func(s: Node): s.get_node("Cutscene").write_story_state = true,
		func(s: Node): s.get_node("Cutscene").position.x = 1,
		func(s: Node): s.get_node("Cutscene/Shots/arrival").name = "typo",
		func(s: Node): s.get_node("Cutscene/Shots/arrival/Target").free(),
		func(s: Node): s.get_node("Cutscene/Shots/arrival/Camera").position = s.get_node("Cutscene/Shots/arrival/Target").position,
		func(s: Node): s.get_node("Cutscene/Shots/arrival/End").position = s.get_node("Cutscene/Shots/arrival/Target").position,
	]
	for index in range(cases.size()):
		var scene := PREVIEW.instantiate()
		cases[index].call(scene)
		check(not VALIDATOR.new().validate(scene).is_empty(), "Static template fault %d is rejected" % index)
		scene.free()
	var json_only := PREVIEW.instantiate()
	json_only.get_node("Cutscene/Shots/arrival").free()
	check(VALIDATOR.new().validate(json_only).is_empty(), "JSON-only framing remains valid without optional shot markers")
	json_only.free()
	check(GameState.snapshot() == story and AudioManager.rain_target == rain, "Static checks leave gameplay and weather unchanged")
	check(int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)) == count, "Static validation releases all off-tree scene instances")
	_test_localization()
	print("TOOLKIT RESULT: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)

func _scan(path: String) -> void:
	var directory := DirAccess.open(path)
	check(directory != null, "Authoring directory exists: " + path)
	if directory == null:
		return
	for file in directory.get_files():
		if file.ends_with(".tscn"):
			var packed := load(path + "/" + file) as PackedScene
			check(packed != null and packed.can_instantiate(), "Scene resource parses: " + file)
			if packed == null or not packed.can_instantiate():
				continue
			var scene := packed.instantiate()
			var errors: PackedStringArray = VALIDATOR.new().validate(scene)
			check(errors.is_empty(), file + " static contract: " + "; ".join(errors))
			scene.free()
	for folder in directory.get_directories():
		_scan(path + "/" + folder)

func _test_localization() -> void:
	var source := {"text": "Inline fallback", "next": "end", "text_keys": {"text": "test.line"}, "choices": [{"text": "Choice", "text_keys": {"text": "test.choice"}}]}
	var original := source.duplicate(true)
	var result: Dictionary = ContentText.resolve(source, {"test.line": "Catalog line", "test.choice": "Catalog choice"})
	check(result.text == "Catalog line" and result.choices[0].text == "Catalog choice", "Nested narrative text resolves from stable catalog keys")
	check(source == original and result.next == "end", "Resolution preserves source objects and progression IDs")
	check(ContentText.resolve(source, {}).text == "Inline fallback", "Missing authoring catalog key uses source fallback")
	check(ContentText.resolve(source, {"test.line": 5}).text == "Inline fallback", "Malformed translation uses source fallback")
	for file in ["dialogue/slice", "dialogue/authoring_example", "cutscenes/opening", "cutscenes/authoring_example", "chapters/karawang", "chapters/practice", "phone/messages", "phone/calls", "phone/photos"]:
		var path: String = "res://data/" + file + ".json"
		var inline_data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		check(ContentText.load_bundle(path) == inline_data, "English catalog preserves current content: " + file)
	var manager := preload("res://scripts/autoload/dialogue_manager.gd").new()
	manager.write_story_state = false
	var key: String = DialogueManager.content.mother.nodes.home.text_keys.text
	var original_line: String = ContentText.english[key]
	ContentText.english[key] = "Catalog loader sentinel"
	add_child(manager)
	check(manager.content.mother.nodes.home.text == "Catalog loader sentinel", "Dialogue loader consumes the catalog rather than inline text")
	ContentText.english[key] = original_line
	manager.free()
