extends Node

signal save_completed
signal save_failed(reason: String)
signal settings_applied
const SAVE_PATH := "user://journey.json"
const SETTINGS_PATH := "user://settings.cfg"
var last_error: String = ""
var development_active := false
var _development_original: Dictionary = {}

func development_available() -> bool:
	return OS.is_debug_build() and OS.has_feature("editor") and "--dev-tools" in OS.get_cmdline_user_args()

func begin_development_session() -> bool:
	if not development_available():
		return false
	if not development_active:
		_development_original = GameState.snapshot()
		development_active = true
	return true

func end_development_session() -> void:
	if not development_active:
		return
	# Keep writes blocked while restore signals notify narrative services.
	GameState.restore(_development_original)
	_development_original = {}
	development_active = false

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
	for field in ["read", "delivered", "notified"]:
		if not data.phone.get(field, []) is Array:
			return false
		for id in data.phone.get(field, []):
			if not id is String:
				return false
	if not data.phone.get("pending", {}) is Dictionary:
		return false
	for id in data.phone.get("pending", {}):
		var delay: Variant = data.phone.pending[id]
		if not id is String or (not delay is float and not delay is int):
			return false
		if not is_finite(float(delay)) or delay < 0:
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
		# Additive v1 migration: old read/replied messages must not notify again.
		var known: Array = result.phone.read.duplicate()
		for id in result.phone.replies:
			if id not in known:
				known.append(id)
		result.phone.get_or_add("delivered", known.duplicate())
		result.phone.get_or_add("notified", known.duplicate())
		result.phone.get_or_add("pending", {})
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
	if development_active:
		return false
	return not read_save().is_empty() or not read_save(SAVE_PATH + ".bak").is_empty()

func save_game(announce: bool = true) -> bool:
	if development_active:
		return true # Successful transient checkpoint; no disk write or save toast.
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
	if announce:
		save_completed.emit()
	return true

func load_game() -> bool:
	if development_active:
		return false
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

func save_settings() -> bool:
	_normalize_touch_scale()
	_normalize_ui_scale()
	_normalize_touch_layout()
	var config := ConfigFile.new()
	for key in GameState.settings:
		config.set_value("settings", key, GameState.settings[key])
	var saved := config.save(SETTINGS_PATH) == OK
	if not saved:
		save_failed.emit("Settings could not be saved.")
	apply_settings()
	return saved

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		for key in GameState.DEFAULT_SETTINGS:
			var value: Variant = config.get_value("settings", key, GameState.DEFAULT_SETTINGS[key])
			if typeof(value) == typeof(GameState.DEFAULT_SETTINGS[key]):
				GameState.settings[key] = value
			elif key in ["touch_scale", "ui_scale", "touch_layout"]:
				GameState.settings[key] = GameState.DEFAULT_SETTINGS[key]
	apply_settings()

func _normalize_touch_scale() -> void:
	var value: Variant = GameState.settings.get("touch_scale", 1.0)
	if not (value is float or value is int) or not is_finite(float(value)):
		value = 1.0
	GameState.settings.touch_scale = clampf(snappedf(float(value), 0.25), 1.0, 1.5)

func _normalize_ui_scale() -> void:
	var value: Variant = GameState.settings.get("ui_scale", 1.0)
	if not (value is float or value is int) or not is_finite(float(value)):
		value = 1.0
	var nearest := 1.0
	for option in [1.0, 1.1, 1.25]:
		if absf(float(value) - option) < absf(float(value) - nearest):
			nearest = option
	GameState.settings.ui_scale = nearest

func _normalize_touch_layout() -> void:
	var value: Variant = GameState.settings.get("touch_layout", {})
	var layout: Dictionary = GameState.DEFAULT_SETTINGS.touch_layout.duplicate()
	if value is Dictionary:
		for key in layout:
			var amount: Variant = value.get(key, 0.0)
			if (amount is float or amount is int) and is_finite(float(amount)):
				layout[key] = clampf(snappedf(float(amount), 0.05), 0, 1)
	GameState.settings.touch_layout = layout

func apply_settings() -> void:
	_normalize_touch_scale()
	_normalize_ui_scale()
	_normalize_touch_layout()
	GameState.settings.fov = clampf(GameState.settings.fov, 55.0, 85.0)
	Engine.max_fps = 30 if GameState.settings.fps_limit == 30 else 60
	AudioServer.set_bus_volume_db(0, linear_to_db(clampf(GameState.settings.master, 0.001, 1.0)))
	settings_applied.emit()
