class_name EncounterChapter
extends RoadWorld

signal checkpoint_requested(id: String)
signal ambience_changed(id: String)
@export_range(120, 1800, 12) var route_length := 120.0
@export_range(0, 1800) var npc_distance := 80.0
@export_range(0, 1800) var weather_distance := 50.0
@export_range(0, 1800) var ambience_distance := 65.0
@export_range(0, 1800) var checkpoint_distance := 100.0
@export var checkpoint_id := "authoring.roadside"
@export_enum("morning", "overcast", "drizzle", "rain", "heavy_rain", "golden_hour", "mist", "night") var arrival_weather := "overcast"
@export_enum("city", "roadside", "fields", "warung", "indoors") var arrival_ambience := "warung"
@export var debug_markers := true
var checkpoint_seen := false
var ambience := "fields"
var built := false

func _ready() -> void:
	build()

func build(_is_city: bool = false) -> void:
	if built:
		return
	built = true
	_build_environment()
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for d in range(-12, int(route_length), 6):
		var a := center(d)
		var b := center(d + 6)
		for vertex in [a + Vector3(-5, 0, 0), b + Vector3(-5, 0, 0), a + Vector3(5, 0, 0), a + Vector3(5, 0, 0), b + Vector3(-5, 0, 0), b + Vector3(5, 0, 0)]:
			surface.add_vertex(vertex)
	surface.generate_normals()
	var road := MeshInstance3D.new()
	road.name = "Road"
	road.mesh = surface.commit()
	road_material = LowPoly.material(Color("555954")).duplicate()
	road.material_override = road_material
	add_child(road)
	road.create_trimesh_collision()
	LowPoly.box(self, center(route_length / 2) + Vector3(0, -1, 0), Vector3(180, 1, route_length + 100), Color("7c9560"))
	$NPC.position = center(npc_distance) + Vector3(-7, 0, 0)
	LowPoly.box(self, center(npc_distance) + Vector3(-7, -0.08, 0), Vector3(6, 0.15, 15), Color("b3ab8c"))
	for spec in [["Weather", weather_distance], ["Ambience", ambience_distance], ["Checkpoint", checkpoint_distance]]:
		var marker: Marker3D = get_node("Markers/" + spec[0])
		marker.position = center(spec[1])
		var label := LowPoly.label(marker, spec[0], Vector3(6, 2, 0), 24)
		label.visible = debug_markers
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	reset_preview()

func configuration_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	for value in [npc_distance, weather_distance, ambience_distance, checkpoint_distance]:
		if value < 0 or value > route_length:
			errors.append("Event distance lies outside the chapter road")
	if checkpoint_id.strip_edges().is_empty():
		errors.append("Checkpoint needs a stable ID")
	if not profiles.has(arrival_weather):
		errors.append("Arrival weather profile does not exist")
	if not AudioManager.soundscape.zones.has(arrival_ambience):
		errors.append("Arrival ambience zone does not exist")
	return errors

func sample_distance(distance: float) -> void:
	if get_tree().paused or AudioManager.focus_suspended:
		return
	var at := clampf(distance, 0, route_length)
	var weather := arrival_weather if at >= weather_distance else "morning"
	if weather != current_profile:
		set_weather_profile(weather, true)
	var next_ambience := arrival_ambience if at >= ambience_distance else "fields"
	if next_ambience != ambience:
		ambience = next_ambience
		ambience_changed.emit(ambience)
	if at >= checkpoint_distance and not checkpoint_seen:
		checkpoint_seen = true
		checkpoint_requested.emit(checkpoint_id)

func reset_preview() -> void:
	checkpoint_seen = false
	ambience = "fields"
	set_weather_profile("morning", true)
	$NPC.release()
