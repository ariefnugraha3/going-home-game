class_name RideMetrics
extends RefCounted

var riding_seconds: float = 0.0
var distance_meters: float = 0.0
var recoveries: int = 0
var contacts: int = 0
var max_roll_degrees: float = 0.0
var frame_samples: Array[float] = []
var previous_position := Vector3.ZERO
var has_position: bool = false

func reset_position() -> void:
	has_position = false

func sample_bike(bike: BikeMotorController, delta: float) -> void:
	if not bike.enabled:
		reset_position()
		return
	riding_seconds += delta
	if has_position:
		distance_meters += bike.position.distance_to(previous_position)
	previous_position = bike.position
	has_position = true
	max_roll_degrees = maxf(max_roll_degrees, absf(rad_to_deg(bike.lean.rotation.z)))

func sample_frame(delta: float) -> void:
	# Bounded rolling sample window, even during a long comfort session.
	if delta > 0:
		frame_samples.append(delta * 1000.0)
		if frame_samples.size() > 900:
			frame_samples.pop_front()

func snapshot() -> Dictionary:
	var sorted := frame_samples.duplicate()
	sorted.sort()
	var median: float = 0.0 if sorted.is_empty() else sorted[sorted.size() / 2]
	var p95: float = 0.0 if sorted.is_empty() else sorted[mini(int(sorted.size() * 0.95), sorted.size() - 1)]
	return {"report_version": 1, "track": "riding_practice_v1", "engine": Engine.get_version_info().string,
		"riding_seconds": snappedf(riding_seconds, 0.01), "distance_meters": snappedf(distance_meters, 0.01),
		"recoveries": recoveries, "obstacle_contacts": contacts, "max_camera_roll_degrees": max_roll_degrees,
		"recent_frame_count": sorted.size(), "recent_frame_median_ms": median, "recent_frame_p95_ms": p95,
		"settings": GameState.settings.duplicate(true),
		"human_comfort_review": "Not assessed by this report"}

func save_report() -> String:
	var directory := "user://ride_reports"
	if DirAccess.make_dir_recursive_absolute(directory) != OK:
		return ""
	var path := directory + "/practice_%d_%d.json" % [int(Time.get_unix_time_from_system()), Time.get_ticks_msec()]
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return ""
	file.store_string(JSON.stringify(snapshot(), "\t"))
	file.close()
	return path
