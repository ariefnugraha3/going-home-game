class_name EncounterCutscene
extends CutsceneDirector

signal dialogue_requested(id: String)
@export var dialogue_after := "authoring.greeting"

func _ready() -> void:
	super._ready()
	for sequence in definitions.values():
		for shot in sequence.shots:
			var marker := get_node_or_null("Shots/" + shot.shot_id)
			if marker == null:
				continue # JSON camera coordinates remain a supported fallback.
			for mapping in [["Camera", "camera"], ["Target", "target"], ["End", "camera_end"]]:
				var point := marker.get_node_or_null(mapping[0]) as Node3D
				if point != null:
					var local := to_local(point.global_position)
					shot[mapping[1]] = [local.x, local.y, local.z]
	finished.connect(_handoff)

func _handoff(_id: String) -> void:
	if not dialogue_after.is_empty():
		dialogue_requested.emit(dialogue_after)
