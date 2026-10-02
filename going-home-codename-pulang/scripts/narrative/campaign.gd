class_name Campaign
extends RefCounted

const CHAPTERS := ["karawang", "cirebon", "tegal", "pekalongan", "semarang", "salatiga", "solo", "ngawi", "madiun", "kediri", "malang", "lumajang", "jember", "banyuwangi", "epilogue"]

static func chapter(id: String) -> Dictionary:
	if id not in CHAPTERS:
		return {}
	return ContentText.load_bundle("res://data/chapters/%s.json" % id)

static func encounter_flag(id: String) -> String:
	return "story.karawang.sheltered" if id == "karawang" else "story.%s.encounter" % id

static func valid_checkpoint(chapter_id: String, checkpoint: String) -> bool:
	if chapter_id == "prologue":
		return checkpoint in ["morning", "commute", "departure"]
	if chapter_id not in CHAPTERS:
		return false
	return checkpoint in ["road_start", "rest", "complete"] or checkpoint == ("warung" if chapter_id == "karawang" else "encounter")
