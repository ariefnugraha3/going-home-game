extends Node

signal save_completed
signal save_failed(reason: String)
const SAVE_PATH := "user://journey.json"
const SETTINGS_PATH := "user://settings.cfg"
var last_error: String = ""

func _ready() -> void:
	load_settings()

func validate(data: Variant) -> bool:
	if not data is Dictionary or data.get("schema_version", 0) != 1:
		return false
	if data.get("chapter", "") not in ["prologue", "karawang"]:
		return false
	if data.get("checkpoint", "") not in ["morning", "commute", "departure", "road_start", "warung", "rest", "complete"]:
		return false
	for key in ["flags", "bike", "journal", "phone"]:
		if not data.has(key) or not data[key] is Dictionary:
			return false
	if not data.get("dialogue_states", {}) is Dictionary:
		return false
	var saved_bike: Dictionary = data.get("bike", {})
	for key in ["fuel", "condition", "distance"]:
		if not saved_bike.get(key) is float and not saved_bike.get(key) is int:
			return false
		if not is_finite(float(saved_bike[key])) or saved_bike[key] < 0:
			return false
	if not data.phone.get("read", []) is Array or not data.phone.get("replies", {}) is Dictionary:
		return false
	for entry in data.journal.values():
		if not entry is Dictionary or not entry.get("text") is String:
			return false
	for reply in data.phone.get("replies", {}).values():
		if not reply is String:
			return false
	return true

func migrate(data: Dictionary) -> Dictionary:
	# v1 is the initial schema. Future migrations must preserve public IDs.
	if data.get("schema_version", 0) == 1:
		var result := data.duplicate(true)
		result.get_or_add("dialogue_states", {})
		result.phone.get_or_add("read", [])
		result.phone.get_or_add("replies", {})
		return result
	return {}

func read_save(path: String = SAVE_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK:
		return {}
	var raw: Variant = parser.data
	if not validate(raw):
		return {}
	return migrate(raw)

func has_save() -> bool:
	return not read_save().is_empty() or not read_save(SAVE_PATH + ".bak").is_empty()

func save_game() -> bool:
	var data := GameState.snapshot()
	if not validate(data):
		return _fail("The checkpoint could not be saved.")
	var file := FileAccess.open(SAVE_PATH + ".tmp", FileAccess.WRITE)
	if file == null:
		return _fail("Could not write the save. Please check available storage.")
	file.store_string(JSON.stringify(data, "\t"))
	file.flush()
	file.close()
	if read_save(SAVE_PATH + ".tmp").is_empty():
		return _fail("Save verification failed. Your previous checkpoint is safe.")
	var absolute := ProjectSettings.globalize_path(SAVE_PATH)
	if not read_save().is_empty():
		if DirAccess.copy_absolute(absolute, absolute + ".bak") != OK:
			return _fail("Could not back up your previous checkpoint.")
	if DirAccess.rename_absolute(absolute + ".tmp", absolute) != OK:
		return _fail("Could not finish saving. Your previous checkpoint is safe.")
	last_error = ""
	save_completed.emit()
	return true

func load_game() -> bool:
	var data := read_save()
	if data.is_empty():
		data = read_save(SAVE_PATH + ".bak")
		if data.is_empty():
			return _fail("No readable checkpoint was found.")
		last_error = "Recovered the previous checkpoint."
	GameState.restore(data)
	return true

func _fail(reason: String) -> bool:
	last_error = reason
	save_failed.emit(reason)
	return false

func save_settings() -> void:
	var config := ConfigFile.new()
	for key in GameState.settings:
		config.set_value("settings", key, GameState.settings[key])
	if config.save(SETTINGS_PATH) != OK:
		save_failed.emit("Settings could not be saved.")
	apply_settings()

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		for key in GameState.DEFAULT_SETTINGS:
			var value: Variant = config.get_value("settings", key, GameState.DEFAULT_SETTINGS[key])
			if typeof(value) == typeof(GameState.DEFAULT_SETTINGS[key]):
				GameState.settings[key] = value
	apply_settings()

func apply_settings() -> void:
	GameState.settings.fov = clampf(GameState.settings.fov, 55.0, 85.0)
	Engine.max_fps = 30 if GameState.settings.fps_limit == 30 else 60
	AudioServer.set_bus_volume_db(0, linear_to_db(clampf(GameState.settings.master, 0.001, 1.0)))
