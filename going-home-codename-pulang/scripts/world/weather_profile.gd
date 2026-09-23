class_name WeatherProfile
extends Resource

const IDS := ["morning", "overcast", "drizzle", "rain", "heavy_rain", "mist", "golden_hour", "night"]
@export var display_name: String = "Morning"
@export var sky_top: Color = Color("629198")
@export var horizon: Color = Color("e4d7b1")
@export var ambient_color: Color = Color("becac5")
@export var ambient_energy: float = 0.32
@export var sun_color: Color = Color("ffdfaa")
@export var sun_energy: float = 0.72
@export var sun_rotation: Vector3 = Vector3(-28, -32, 0)
@export var fog_color: Color = Color("d2c7a8")
@export var fog_density: float = 0.0012
@export_range(0, 1) var rainfall: float = 0
@export_range(0, 1) var wetness: float = 0
@export_range(0, 1) var night: float = 0

static func load_presets() -> Dictionary:
	var result := {}
	for id in IDS:
		result[id] = load("res://data/weather/" + id + ".tres") as WeatherProfile
	return result
