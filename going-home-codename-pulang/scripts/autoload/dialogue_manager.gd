extends Node

signal line_changed(line: Dictionary)
signal dialogue_finished(id: String)
var content: Dictionary = {}
var active_id: String = ""
var current: Dictionary = {}
var choices: Array = []

func _ready() -> void:
	content = JSON.parse_string(FileAccess.get_file_as_string("res://data/dialogue/slice.json"))

func start(id: String) -> void:
	if not content.has(id):
		push_error("DialogueManager: missing dialogue " + id)
		return
	active_id = id
	_show("start")

func matches(conditions: Dictionary) -> bool:
	for key in conditions:
		if GameState.flags.get(key, false) != conditions[key]:
			return false
	return true

func _show(id: String) -> void:
	if id == "end":
		var finished_id := active_id
		GameState.dialogue_states[finished_id] = "complete"
		active_id = ""
		dialogue_finished.emit(finished_id)
		return
	current = content[active_id].nodes[id]
	GameState.dialogue_states[active_id] = id
	for key in current.get("set", {}):
		GameState.set_flag(key, current.set[key])
	choices.clear()
	for choice in current.get("choices", []):
		if matches(choice.get("conditions", {})):
			choices.append(choice)
	var presented := current.duplicate(true)
	presented["choices"] = choices.duplicate(true)
	line_changed.emit(presented)

func advance(index: int = -1) -> void:
	if active_id.is_empty():
		return
	if not choices.is_empty():
		if index < 0 or index >= choices.size():
			return
		var choice: Dictionary = choices[index]
		for key in choice.get("set", {}):
			GameState.set_flag(key, choice.set[key])
		_show(choice.get("next", "end"))
	else:
		_show(current.get("next", "end"))
