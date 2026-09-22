class_name InteractionScanner
extends Node

var candidate: Dictionary = {}

func scan(bike: BikeMotorController, stops: Array[Dictionary]) -> Dictionary:
	candidate = {}
	var closest := 30.0
	for stop in stops:
		var point: Vector3 = stop.position
		var distance := bike.position.distance_to(point)
		if distance < closest:
			closest = distance
			candidate = stop
	return candidate

func can_interact(bike: BikeMotorController) -> bool:
	return not candidate.is_empty() and bike.speed_mps * 3.6 < 8

func get_interaction_label(bike: BikeMotorController) -> String:
	if candidate.is_empty():
		return ""
	if not can_interact(bike):
		return "Slow down · " + candidate.label
	var key := "Tap" if InputModeManager.touch_mode or GameState.settings.touch else "E"
	return key + "  ·  " + candidate.label
