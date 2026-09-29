extends RefCounted

# Inspect instantiated PackedScenes without adding them to SceneTree. No _ready,
# generated geometry, audio, gameplay signals or save writes are executed.
var errors := PackedStringArray()
var components := 0

func validate(scene: Node) -> PackedStringArray:
	errors.clear()
	components = 0
	_walk(scene, ".")
	_expect(components > 0, ".", "No supported authoring component found")
	return errors.duplicate()

func _expect(valid: bool, at: String, message: String) -> void:
	if not valid:
		errors.append(at + ": " + message)

func _node(root: Node, path: String, type: String, at: String) -> Node:
	var child := root.get_node_or_null(path)
	_expect(child != null and child.is_class(type), at + "/" + path, "Missing or wrong node type; expected " + type)
	return child

func _json(path: String, at: String) -> Dictionary:
	if not path.begins_with("res://") or not FileAccess.file_exists(path):
		_expect(false, at, "Missing project JSON resource: " + path)
		return {}
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK or not parser.data is Dictionary:
		_expect(false, at, "Expected a JSON object: " + path)
		return {}
	return parser.data

func _walk(node: Node, at: String) -> void:
	if node is EncounterChapter:
		components += 1
		_expect(is_finite(node.route_length) and node.route_length >= 120 and node.route_length <= 1800, at, "Invalid route length")
		for field in ["npc_distance", "weather_distance", "ambience_distance", "checkpoint_distance"]:
			var distance: float = node.get(field)
			_expect(is_finite(distance) and distance >= 0 and distance <= node.route_length, at + "/" + field, "Event outside road")
		_expect(not node.checkpoint_id.strip_edges().is_empty(), at, "Missing checkpoint ID")
		_expect(node.arrival_weather in ["morning", "overcast", "drizzle", "rain", "heavy_rain", "golden_hour", "mist", "night"] and ResourceLoader.exists("res://data/weather/" + node.arrival_weather + ".tres"), at, "Unknown weather profile")
		var sound := _json("res://data/audio/soundscape.json", at)
		_expect(sound.get("zones", {}) is Dictionary and sound.get("zones", {}).has(node.arrival_ambience), at, "Unknown ambience zone")
		_expect(node.get_node_or_null("NPC") is EncounterNPC, at, "Chapter needs an EncounterNPC child named NPC")
		for name in ["Weather", "Ambience", "Checkpoint"]:
			_node(node, "Markers/" + name, "Marker3D", at)
	elif node is EncounterNPC:
		components += 1
		_node(node, "Visual", "Node3D", at)
		_node(node, "DialogueAnchor", "Marker3D", at)
		_node(node, "InteractionAnchor", "Marker3D", at)
		_expect(not node.dialogue_id.strip_edges().is_empty(), at, "Missing dialogue ID")
		_expect(not node.display_name.strip_edges().is_empty() and not node.interaction_label.strip_edges().is_empty(), at, "Missing NPC display text")
		_expect(is_finite(node.interaction_radius) and node.interaction_radius >= 1 and node.interaction_radius <= 10, at, "Invalid interaction radius")
	elif node is EncounterCutscene:
		components += 1
		_cutscene(node, at)
	elif node.get_script() != null and node.get_script().resource_path == "res://tools/authoring/encounter_preview.gd":
		components += 1
		_node(node, "Camera", "Camera3D", at)
		var chapter := node.get_node_or_null("Chapter")
		var director := node.get_node_or_null("Cutscene")
		_expect(chapter is EncounterChapter and director is EncounterCutscene, at, "Preview needs Chapter and Cutscene components")
		var dialogues := _json(node.dialogue_file, at)
		if chapter is EncounterChapter:
			var npc := chapter.get_node_or_null("NPC")
			if npc is EncounterNPC:
				_expect(dialogues.has(npc.dialogue_id), at, "NPC dialogue ID missing from selected bundle")
		if director is EncounterCutscene:
			var definitions := _json(director.definitions_path, at)
			_expect(definitions.has(node.arrival_id), at, "Arrival ID missing from selected bundle")
			_expect(not director.write_story_state, at, "Preview cutscene must disable story writes")
	for child in node.get_children():
		_walk(child, at + "/" + child.name)

func _cutscene(node: EncounterCutscene, at: String) -> void:
	_expect(node.transform.is_equal_approx(Transform3D.IDENTITY), at, "Cutscene root must keep identity transform")
	var tracks := _node(node, "Shots", "Node3D", at)
	var definitions := _json(node.definitions_path, at)
	var ids := {}
	for sequence in definitions.values():
		if not sequence is Dictionary or not sequence.get("shots") is Array:
			_expect(false, at, "Missing shot track")
			continue
		for shot in sequence.shots:
			if not shot is Dictionary or not shot.get("shot_id") is String:
				_expect(false, at, "Shot needs a stable ID")
				continue
			ids[shot.shot_id] = true
			var group := node.get_node_or_null("Shots/" + shot.shot_id)
			if group == null:
				continue # Valid JSON-only framing is supported by the director.
			var camera := _node(group, "Camera", "Marker3D", at + "/Shots/" + shot.shot_id) as Marker3D
			var target := _node(group, "Target", "Marker3D", at + "/Shots/" + shot.shot_id) as Marker3D
			if camera != null and target != null:
				_expect(camera.position.is_finite() and target.position.is_finite() and not camera.position.is_equal_approx(target.position), at, "Camera and target must be finite and distinct")
			var end := group.get_node_or_null("End")
			if end != null:
				_expect(end is Marker3D, at, "End must be a Marker3D")
				if end is Marker3D and target != null:
					_expect(end.position.is_finite() and not end.position.is_equal_approx(target.position), at, "Camera end and target must be finite and distinct")
	if tracks != null:
		for group in tracks.get_children():
			_expect(ids.has(str(group.name)), at + "/Shots/" + group.name, "Marker group has no matching shot ID")
