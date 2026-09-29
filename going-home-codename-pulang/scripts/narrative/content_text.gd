class_name ContentText
extends RefCounted

const ENGLISH_PATH := "res://data/localization/en.json"
static var english: Dictionary = {}

static func load_bundle(path: String) -> Variant:
	if english.is_empty():
		var catalog: Variant = JSON.parse_string(FileAccess.get_file_as_string(ENGLISH_PATH))
		if catalog is Dictionary and catalog.get("strings") is Dictionary:
			english = catalog.strings
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return resolve(data, english)

static func resolve(value: Variant, strings: Dictionary) -> Variant:
	# Keep source text as a fallback for an incomplete authoring fixture/catalog.
	# Runtime enum fields have no text_keys; validation rejects bindings to them.
	if value is Array:
		var result: Array = []
		for item in value:
			result.append(resolve(item, strings))
		return result
	if value is Dictionary:
		var result: Dictionary = {}
		for field in value:
			result[field] = value[field].duplicate() if field == "text_keys" and value[field] is Dictionary else resolve(value[field], strings)
		var bindings: Variant = value.get("text_keys", {})
		if bindings is Dictionary:
			for field in bindings:
				var key: Variant = bindings[field]
				if key is String and result.get(field) is String and strings.get(key) is String:
					result[field] = strings[key]
		return result
	return value
