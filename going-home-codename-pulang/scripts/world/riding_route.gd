class_name RidingRoute
extends RefCounted

# Shared by road geometry, recovery and steering; the bike never guesses a track.
var practice: bool = false
var profile: Dictionary = {}

static func story_center(distance: float) -> Vector3:
	return Vector3(sin(distance / 180.0) * 20.0 + sin(distance / 77.0) * 3.0, sin(distance / 230.0) * 2.0, -distance)

func sample(distance: float) -> Vector3:
	if not practice:
		if not profile.is_empty():
			# Smooth grades and bends keep geometry, steering and recovery on the
			# same authored route. No random sampling occurs during physics.
			var phase: float = profile.get("phase", 0.0)
			var bend: float = profile.get("bend", 20.0)
			var wavelength: float = profile.get("wavelength", 180.0)
			var detail: float = profile.get("detail", 3.0)
			var rise: float = profile.get("rise", 2.0)
			var grade_length: float = profile.get("grade_length", 230.0)
			var x := bend * (sin(distance / wavelength + phase) - sin(phase)) + detail * sin(distance / 77.0)
			var y := rise * (1.0 - cos(distance / grade_length))
			return Vector3(x, y, -distance)
		return story_center(distance)
	var x := 0.0
	var y := 0.0
	if distance >= 100 and distance < 230:
		x = 6.0 * (1.0 - cos(PI * (distance - 100.0) / 130.0))
	elif distance >= 230 and distance < 330:
		x = 12.0 + 12.0 * (1.0 - cos(TAU * (distance - 230.0) / 100.0))
	elif distance >= 330:
		x = 12.0
	if distance >= 350 and distance < 450:
		y = 2.0 * (1.0 - cos(PI * (distance - 350.0) / 100.0))
	elif distance >= 450 and distance < 540:
		y = 2.0 * (1.0 + cos(PI * (distance - 450.0) / 90.0))
	elif distance >= 550 and distance <= 590:
		y = 0.06 * (1.0 - cos(TAU * (distance - 550.0) / 8.0))
	return Vector3(x, y, -distance)

func heading(distance: float) -> float:
	var direction := sample(distance + 0.25) - sample(distance)
	return atan2(-direction.x, -direction.z)
