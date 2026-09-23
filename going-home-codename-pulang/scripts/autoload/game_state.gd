extends Node

signal flag_changed(id: String, value: Variant)
signal journey_changed
const DEFAULT_SETTINGS := {"reduced_motion": true, "riding_assist": true, "fov": 70.0, "master": 0.75, "vehicle": 0.55, "ambience": 0.65, "quality": 1, "fps_limit": 60, "text_size": 22, "touch": false, "key_bindings": {}}
var settings: Dictionary = DEFAULT_SETTINGS.duplicate(true)
var chapter: String = "prologue"
var checkpoint: String = "morning"
var flags: Dictionary = {}
var bike: Dictionary = {"fuel": 12.0, "condition": 1.0, "distance": 0.0}
var journal: Dictionary = {}
var phone: Dictionary = {"read": [], "replies": {}, "delivered": [], "notified": [], "pending": {}}
var dialogue_states: Dictionary = {}

func new_journey() -> void:
	chapter = "prologue"
	checkpoint = "morning"
	flags.clear()
	bike = {"fuel": 12.0, "condition": 1.0, "distance": 0.0}
	journal.clear()
	phone = {"read": [], "replies": {}, "delivered": [], "notified": [], "pending": {}}
	dialogue_states.clear()
	journey_changed.emit()

func set_flag(id: String, value: Variant = true) -> void:
	flags[id] = value
	flag_changed.emit(id, value)

func snapshot() -> Dictionary:
	return {"schema_version": 1, "save_id": "slot_01", "chapter": chapter, "checkpoint": checkpoint, "flags": flags.duplicate(true), "bike": bike.duplicate(true), "journal": journal.duplicate(true), "phone": phone.duplicate(true), "dialogue_states": dialogue_states.duplicate(true)}

func restore(data: Dictionary) -> void:
	chapter = data.chapter
	checkpoint = data.checkpoint
	flags = data.flags.duplicate(true)
	bike = data.bike.duplicate(true)
	journal = data.journal.duplicate(true)
	phone = data.phone.duplicate(true)
	dialogue_states = data.get("dialogue_states", {}).duplicate(true)
	journey_changed.emit()
