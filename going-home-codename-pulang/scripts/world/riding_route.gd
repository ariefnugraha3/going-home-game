class_name RidingRoute
extends RefCounted

# Shared by road geometry, recovery and steering; the bike never guesses a track.
var practice: bool = false

static func story_center(distance: float) -> Vector3:
	return Vector3(sin(distance / 180.0) * 20.0 + sin(distance / 77.0) * 3.0, sin(distance / 230.0) * 2.0, -distance)

func sample(distance: float) -> Vector3:
	if not practice:
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
