class_name RoadWorld
extends Node3D

const LENGTH := 1800.0
var sun: DirectionalLight3D
var environment: Environment
var stops: Array[Dictionary] = []
var traffic: Array[Dictionary] = []
var city: bool = false
var wet: bool = false
var elapsed: float = 0.0
var road_material: StandardMaterial3D
var optional_details: Array[Node3D] = []
var active_quality: int = -1
signal weather_profile_changed(id: String)
var profiles: Dictionary = {}
var current_profile: String = "morning"
var rain_amount: float = 0
var night_amount: float = 0
var weather_tween: Tween
var practical_lights: Array[OmniLight3D] = []

static func center(distance: float) -> Vector3:
	return RidingRoute.story_center(distance)

static func heading(distance: float) -> float:
	var direction := center(distance + 2.0) - center(distance)
	return atan2(-direction.x, -direction.z)

func build(is_city: bool = false) -> void:
	city = is_city
	_build_environment()
	_build_road()
	_build_landscape()
	_build_stops()
	_build_traffic()
	set_weather_profile("morning", true)

func _build_environment() -> void:
	profiles = WeatherProfile.load_presets()
	var world_env := WorldEnvironment.new()
	environment = Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("629198")
	sky_mat.sky_horizon_color = Color("e4d7b1")
	sky_mat.ground_bottom_color = Color("7a8970")
	sky_mat.ground_horizon_color = Color("e4d7b1")
	sky_mat.sky_curve = 0.45
	sky.sky_material = sky_mat
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("becac5")
	environment.ambient_light_energy = 0.32
	environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	environment.fog_enabled = true
	environment.fog_light_color = Color("d2c7a8")
	environment.fog_density = 0.0012
	environment.fog_sky_affect = 0.25
	world_env.environment = environment
	add_child(world_env)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-28, -32, 0)
	sun.light_color = Color("ffdfaa")
	sun.light_energy = 0.72
	sun.light_cull_mask = 1
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 110.0
	add_child(sun)

func _build_road() -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(-2, 154):
		var a := center(i * 12.0)
		var b := center((i + 1) * 12.0)
		for vertex in [a + Vector3(-5, 0, 0), b + Vector3(-5, 0, 0), a + Vector3(5, 0, 0), a + Vector3(5, 0, 0), b + Vector3(-5, 0, 0), b + Vector3(5, 0, 0)]:
			surface.add_vertex(vertex)
	surface.generate_normals()
	var road := MeshInstance3D.new()
	road.mesh = surface.commit()
	road_material = LowPoly.material(Color("555954")).duplicate()
	road.material_override = road_material
	add_child(road)
	road.create_trimesh_collision()
	for i in range(-2, 154):
		var d := i * 12.0
		var c := center(d)
		var mark := LowPoly.box(self, c + Vector3(0, 0.026, -2.5), Vector3(0.13, 0.016, 4), Color("ded8b8"))
		mark.rotation.y = heading(d)
		mark.visibility_range_end = 220
		for side in [-1, 1]:
			var edge := LowPoly.box(self, c + Vector3(side * 4.6, 0.022, -6), Vector3(0.13, 0.014, 12.3), Color("d3d0b3"))
			edge.rotation.y = heading(d)
			edge.visibility_range_end = 220
			LowPoly.box(self, c + Vector3(side * 7.0, -0.18, -6), Vector3(4.1, 0.25, 12.6), Color("a9a184")).visibility_range_end = 260
	var ground := LowPoly.box(self, Vector3(0, -3.8, -850), Vector3(1600, 1, 2300), Color("7c9560"))
	ground.create_trimesh_collision()

func _build_landscape() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 4201
	for i in range(85):
		var d := float(i) * 23.0
		var c := center(d)
		for side in [-1, 1]:
			var pos := c + Vector3(side * rng.randf_range(12, 37), -0.5, rng.randf_range(-8, 8))
			var tree := Node3D.new()
			add_child(tree)
			tree.position = pos
			if i % 2 == 0:
				optional_details.append(tree)
			LowPoly.cylinder(tree, Vector3(0, 2.5, 0), 0.23, 6, Color("736b49"), 0.12).visibility_range_end = 260
			var crown := LowPoly.sphere(tree, Vector3(0, 6.5, 0), Vector3(6.8, 2.8, 6.0), Color("526f48") if i % 2 else Color("6c8351"))
			crown.visibility_range_end = 300
			if i % 4 == 0:
				var palm := Node3D.new()
				add_child(palm)
				palm.position = pos + Vector3(8 * side, 0, -7)
				LowPoly.beam(palm, Vector3.ZERO, Vector3(0.6, 9, 0), 0.18, Color("8c8161"))
				for k in range(6):
					var frond := LowPoly.sphere(palm, Vector3(0.6, 9.0, 0), Vector3(7, 0.25, 1.4), Color("52795a"))
					frond.rotation.y = k * TAU / 6
					frond.rotation.z = 0.2
		if i % 3 == 0:
			var pole := c + Vector3(8.3, 0, 0)
			LowPoly.cylinder(self, pole + Vector3(0, 5, 0), 0.12, 10, Color("69675d")).visibility_range_end = 300
			LowPoly.box(self, pole + Vector3(0, 8.7, 0), Vector3(2.8, 0.12, 0.14), Color("555957")).visibility_range_end = 300
			var next := center(d + 69) + Vector3(8.3, 8.7, 0)
			for x in [-1.0, 1.0]:
				LowPoly.beam(self, pole + Vector3(x, 8.7, 0), next + Vector3(x, 0, 0), 0.025, Color("50564e")).visibility_range_end = 250
		if d < 290 or city:
			for side in [-1, 1]:
				var height := rng.randf_range(5, 15)
				var building := LowPoly.box(self, c + Vector3(side * 23, height / 2, 0), Vector3(12, height, 15), Color("929f96") if i % 2 else Color("b2b5a1"))
				building.visibility_range_end = 350
				for y in range(2, int(height), 3):
					LowPoly.box(self, c + Vector3(side * 16.9, y, 0), Vector3(0.04, 1.3, 10), Color("516c71")).visibility_range_end = 180
		elif i % 6 == 0:
			LowPoly.house(self, c + Vector3(26, 0, 0), Color("c3bc91"))
	for i in range(22):
		var d := i * 88.0
		for side in [-1, 1]:
			var field := LowPoly.box(self, center(d) + Vector3(side * 68, -2.7, 0), Vector3(94, 0.3, 65), Color("a4ad62") if i % 2 else Color("7f9f66"))
			field.visibility_range_end = 650
			for j in range(4):
				LowPoly.box(self, center(d) + Vector3(side * 68, -2.48, -30 + j * 18), Vector3(95, 0.12, 0.5), Color("c4b885")).visibility_range_end = 350
	for i in range(12):
		var hill := LowPoly.cylinder(self, Vector3(270 + (i % 3) * 90, 12, -i * 190), 170, 95 + i % 4 * 30, Color("81988a"), 0, 7)
		hill.rotation.y = i

func _build_stops() -> void:
	var chapter: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/chapters/karawang.json"))
	for stop in chapter.stops:
		stops.append(stop.duplicate(true))
	for stop in stops:
		var d: float = stop.distance
		var pos := center(d)
		add_practical_light(pos + Vector3(-14, 3, 0))
		stop["position"] = pos + Vector3(-5.8, 0, 0)
		LowPoly.box(self, pos + Vector3(-9, -0.05, 0), Vector3(12, 0.15, 26), Color("b3ab8c"))
		LowPoly.box(self, pos + Vector3(-6.7, 2.8, 12), Vector3(3.5, 1.5, 0.15), Color("345747"))
		LowPoly.cylinder(self, pos + Vector3(-6.7, 1.2, 12), 0.07, 2.4, Color("7e7d6b"))
		LowPoly.label(self, stop.label.to_upper(), pos + Vector3(-6.7, 2.8, 12.1), 23)
		if stop.id == "warung":
			LowPoly.warung(self, pos + Vector3(-16, 0, -3))
		elif stop.id == "rest":
			LowPoly.house(self, pos + Vector3(-16, 0, -3), Color("c7c09c"), "GUESTHOUSE")
			LowPoly.person(self, pos + Vector3(-16, 0, 1), Color("72836b"))
		elif stop.id == "fuel":
			LowPoly.box(self, pos + Vector3(-15, 3.4, 0), Vector3(9, 0.4, 8), Color("b55244"))
			for x in [-19, -11]:
				LowPoly.cylinder(self, pos + Vector3(x, 1.7, 0), 0.13, 3.4, Color("eee0ba"))
			LowPoly.box(self, pos + Vector3(-15, 1, 0), Vector3(0.8, 2, 0.7), Color("c15142"))
			LowPoly.label(self, "FUEL", pos + Vector3(-15, 3.45, 4.1), 35)
		else:
			LowPoly.box(self, pos + Vector3(-10, 0.5, 0), Vector3(3, 0.16, 0.8), Color("836849"))
			for x in [-11, -9]:
				LowPoly.box(self, pos + Vector3(x, 0.25, 0), Vector3(0.16, 0.5, 0.8), Color("685c43"))

func _build_traffic() -> void:
	for i in range(4):
		var car := Node3D.new()
		add_child(car)
		LowPoly.box(car, Vector3(0, 0.8, 0), Vector3(1.7, 0.8, 3.8), Color("beaf73") if i % 2 else Color("678c86"))
		LowPoly.box(car, Vector3(0, 1.5, -0.1), Vector3(1.6, 0.65, 2), Color("47636b"))
		for x in [-0.85, 0.85]:
			for z in [-1.15, 1.15]:
				var wheel := LowPoly.cylinder(car, Vector3(x, 0.45, z), 0.38, 0.18, Color("303934"))
				wheel.rotation.z = PI / 2
		traffic.append({"node": car, "distance": 250.0 + i * 440})

func _process(delta: float) -> void:
	elapsed += delta
	for lamp in practical_lights:
		lamp.light_energy = night_amount * 2.2
		lamp.visible = night_amount > 0.01
	if active_quality != GameState.settings.quality:
		active_quality = GameState.settings.quality
		sun.shadow_enabled = active_quality > 0
		sun.directional_shadow_max_distance = 150.0 if active_quality == 2 else 85.0
		get_viewport().msaa_3d = Viewport.MSAA_DISABLED if active_quality == 0 else Viewport.MSAA_2X
		for detail in optional_details:
			detail.visible = active_quality > 0
	for item in traffic:
		item.distance = fposmod(item.distance - delta * 9, LENGTH)
		var car: Node3D = item.node
		car.position = center(item.distance) + Vector3(2.5, 0, 0)
		car.rotation.y = heading(item.distance) + PI
		car.visible = GameState.settings.quality > 0

func set_weather(rain: bool) -> void:
	set_weather_profile("rain" if rain else "morning")

func set_weather_profile(id: String, instant: bool = false) -> bool:
	if not profiles.has(id):
		return false
	var profile: WeatherProfile = profiles[id]
	if profile == null:
		return false
	if is_instance_valid(weather_tween):
		weather_tween.kill()
	current_profile = id
	wet = profile.rainfall > 0
	AudioManager.rain_target = profile.rainfall
	AudioManager.night_target = profile.night
	var sky_material: ProceduralSkyMaterial = environment.sky.sky_material
	var properties := [
		[sky_material, "sky_top_color", profile.sky_top], [sky_material, "sky_horizon_color", profile.horizon],
		[sky_material, "ground_horizon_color", profile.horizon], [sky_material, "ground_bottom_color", profile.ambient_color.darkened(0.4)],
		[environment, "ambient_light_color", profile.ambient_color], [environment, "ambient_light_energy", profile.ambient_energy],
		[environment, "fog_light_color", profile.fog_color], [environment, "fog_density", profile.fog_density],
		[sun, "light_color", profile.sun_color], [sun, "light_energy", profile.sun_energy], [sun, "rotation_degrees", profile.sun_rotation],
		[road_material, "albedo_color", Color("555954").lerp(Color("334746"), profile.wetness)],
		[road_material, "roughness", lerpf(0.95, 0.32, profile.wetness)],
		[self, "rain_amount", profile.rainfall], [self, "night_amount", profile.night]
	]
	if not instant:
		weather_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	for item in properties:
		if instant:
			item[0].set(item[1], item[2])
		else:
			weather_tween.tween_property(item[0], item[1], item[2], 3.0)
	weather_profile_changed.emit(id)
	return true

func add_practical_light(point: Vector3) -> void:
	var lamp := OmniLight3D.new()
	lamp.position = point
	lamp.light_color = Color("ffc887")
	lamp.omni_range = 12
	lamp.shadow_enabled = false
	lamp.light_energy = 0
	add_child(lamp)
	practical_lights.append(lamp)
