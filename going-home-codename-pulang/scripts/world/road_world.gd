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
var marking_batches: Array[MultiMeshInstance3D] = []
var chapter_data: Dictionary = {}
var encounter_stage: CampaignStage
var riding_route := RidingRoute.new()

func sample_route(distance: float) -> Vector3:
	return riding_route.sample(distance)

func route_heading(distance: float) -> float:
	var direction := sample_route(distance + 2.0) - sample_route(distance)
	return atan2(-direction.x, -direction.z)

static func center(distance: float) -> Vector3:
	return RidingRoute.story_center(distance)

static func heading(distance: float) -> float:
	var direction := center(distance + 2.0) - center(distance)
	return atan2(-direction.x, -direction.z)

func build(is_city: bool = false) -> void:
	city = is_city
	riding_route.profile = {} if city else chapter_data.get("road_shape", {})
	_build_environment()
	_build_road()
	_build_landscape()
	_build_stops()
	if not city and chapter_data.get("chapter_id", "karawang") != "karawang":
		encounter_stage = CampaignStage.new()
		add_child(encounter_stage)
		encounter_stage.position = sample_route(1130) + Vector3(-16, 0, 0)
		encounter_stage.build(chapter_data)
		_build_chapter_identity()
	if not city:
		RegionalLandmarks.build(self, chapter_data.get("chapter_id", "karawang"))
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
	sun.shadow_opacity = .68
	sun.shadow_blur = 2.0
	sun.directional_shadow_max_distance = 110.0
	add_child(sun)

func _build_road() -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(-2, 154):
		var a := sample_route(i * 12.0)
		var b := sample_route((i + 1) * 12.0)
		for vertex in [a + Vector3(-5, 0, 0), b + Vector3(-5, 0, 0), a + Vector3(5, 0, 0), a + Vector3(5, 0, 0), b + Vector3(-5, 0, 0), b + Vector3(5, 0, 0)]:
			surface.add_vertex(vertex)
	surface.generate_normals()
	var road := MeshInstance3D.new()
	road.mesh = surface.commit()
	road_material = LowPoly.material(Color("6c7069")).duplicate()
	road.material_override = road_material
	add_child(road)
	road.create_trimesh_collision()
	var shoulder_surface := SurfaceTool.new()
	shoulder_surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(-2,154):
		var a := sample_route(i*12.0)+Vector3(0,-.04,0)
		var b := sample_route((i+1)*12.0)+Vector3(0,-.04,0)
		for side in [-1,1]:
			var left := minf(side*5.0,side*9.1)
			var right := maxf(side*5.0,side*9.1)
			for point in [a+Vector3(left,0,0),b+Vector3(left,0,0),a+Vector3(right,0,0),a+Vector3(right,0,0),b+Vector3(left,0,0),b+Vector3(right,0,0)]: shoulder_surface.add_vertex(point)
	shoulder_surface.generate_normals()
	LowPoly.mesh(self,shoulder_surface.commit(),Vector3.ZERO,Color("acac8c"))

	# Carry the verge through the same grade as the asphalt. A flat world floor
	# leaves raised routes floating and can catch the bike on steep recoveries.
	var terrain_surface := SurfaceTool.new()
	terrain_surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var left_edge := -45.0 if chapter_data.get("biome", "") == "coast" else -150.0
	var sections := [Vector2(left_edge, -2.85), Vector2(-28, -.16), Vector2(28, -.16), Vector2(45, -2.85), Vector2(150, -2.85)]
	if left_edge < -45: sections.insert(1, Vector2(-45, -2.85))
	for i in range(-2, 154):
		var a := sample_route(i * 12.0)
		var b := sample_route((i + 1) * 12.0)
		for edge in range(sections.size() - 1):
			var left := Vector3(sections[edge].x, sections[edge].y, 0)
			var right := Vector3(sections[edge + 1].x, sections[edge + 1].y, 0)
			for vertex in [a + left, b + left, a + right, a + right, b + left, b + right]: terrain_surface.add_vertex(vertex)
	terrain_surface.generate_normals()
	var verge := MeshInstance3D.new()
	verge.mesh = terrain_surface.commit()
	verge.material_override = LowPoly.material(Color("91a475"))
	add_child(verge)
	verge.create_trimesh_collision()
	var center_marks: Array[Transform3D] = []
	var edge_marks: Array[Transform3D] = []
	for i in range(-2, 154):
		var d := i * 12.0
		var c := sample_route(d)
		center_marks.append(Transform3D(Basis(Vector3.UP, route_heading(d)), c + Vector3(0, 0.026, -2.5)))
		for side in [-1, 1]:
			edge_marks.append(Transform3D(Basis(Vector3.UP, route_heading(d)), c + Vector3(side * 4.6, 0.022, -6)))

	marking_batches.append_array(RoadMarkings.build(self, center_marks, Vector3(.13, .016, 4), Color("ded8b8"), 220, "CenterMarkings"))
	marking_batches.append_array(RoadMarkings.build(self, edge_marks, Vector3(.13, .014, 12.3), Color("d3d0b3"), 220, "EdgeMarkings"))
	var ground := LowPoly.box(self, Vector3(0, -3.8, -850), Vector3(1600, 1, 2300), Color("91a475"))
	ground.create_trimesh_collision()

func _build_landscape() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 4201
	if not riding_route.profile.is_empty(): rng.seed += str(chapter_data.chapter_id).hash()
	for i in range(85):
		var d := float(i) * 23.0
		var c := sample_route(d)
		for side in [-1, 1]:
			var pos := c + Vector3(side * rng.randf_range(12, 37), -0.5, rng.randf_range(-8, 8))
			if _reserved_roadside(d, side): continue
			pos.y = _terrain_height(pos) + .5
			pos.y = _terrain_height(pos)
			var tree := CozyForms.tree(self, pos, i % 3, rng.randf_range(6.0, 8.8))
			LowPoly.bake(tree)
			if i % 2 == 0: optional_details.append(tree)
			if i % 7 == 0:
				var palm_pos := pos + Vector3(8 * side, 0, -7)
				palm_pos.y = _terrain_height(palm_pos)
				var palm := CozyForms.palm(self, palm_pos)
				LowPoly.bake(palm)
		if i % 3 == 0:
			var pole := c + Vector3(8.3, 0, 0)
			LowPoly.cylinder(self, pole + Vector3(0, 5, 0), 0.12, 10, Color("69675d")).visibility_range_end = 300
			LowPoly.box(self, pole + Vector3(0, 8.7, 0), Vector3(2.8, 0.12, 0.14), Color("555957")).visibility_range_end = 300
			var next := sample_route(d + 69) + Vector3(8.3, 8.7, 0)
			for x in [-1.0, 1.0]:
				LowPoly.beam(self, pole + Vector3(x, 8.7, 0), next + Vector3(x, 0, 0), 0.025, Color("50564e")).visibility_range_end = 250
		if d < 290 or city:
			for side in [-1, 1]:
				var height := rng.randf_range(5, 15)
				CozyDressing.town_building(self,c+Vector3(side*24,0,0),height,side)
		elif i % 6 == 0:
			LowPoly.house(self, c + Vector3(26, 0, 0), Color("c3bc91"))
	for i in range(22):
		var d := i * 88.0
		for side in [-1, 1]:
			var field := LowPoly.box(self, sample_route(d) + Vector3(side * 68, -2.7, 0), Vector3(94, 0.3, 65), Color("a4ad62") if i % 2 else Color("7f9f66"))
			field.visibility_range_end = 650
			for j in range(4):
				LowPoly.box(self, sample_route(d) + Vector3(side * 68, -2.48, -30 + j * 18), Vector3(95, 0.12, 0.5), Color("c4b885")).visibility_range_end = 350
	for i in range(10):
		for side in [-1,1]:
			if side < 0 and chapter_data.get("biome", "") == "coast": continue
			var height := 220.0 if chapter_data.get("biome", "") in ["mountain","highlands"] else 110.0
			height += (i%3)*18
			var hill := LowPoly.sphere(self,Vector3(side*(460+(i%3)*80),-height*.32,-i*210),Vector3(640,height,510),Color("94ac99") if i%2 else Color("799a89"))
			hill.rotation.y = i*.5
	_build_verge_details()

func _build_verge_details() -> void:
	for section in range(9):
		var group := Node3D.new()
		add_child(group)
		for i in range(6):
			var d := section * 200 + i * 32
			for side in [-1,1]:
				if _reserved_roadside(d,side): continue
				var pos := sample_route(d)+Vector3(side*(11+(i%3)*1.4),0,0)
				pos.y = _terrain_height(pos)
				for j in range(2):
					LowPoly.sphere(group,pos+Vector3(j*.65,.40,j*.3),Vector3(1.5,.95,1.3),Color("78965f") if j else Color("9bab70"))
				if i%2 == 0:
					var stone := LowPoly.sphere(group,pos+Vector3(1.8,.21,.2),Vector3(.9,.6,.7),Color("a7a58d"))
					stone.rotation.y = i
		LowPoly.bake(group,180)

func _build_stops() -> void:
	var chapter: Dictionary = chapter_data if not chapter_data.is_empty() else ContentText.load_bundle("res://data/chapters/karawang.json")
	for stop in chapter.stops:
		stops.append(stop.duplicate(true))
	for stop in stops:
		var d: float = stop.distance
		var pos := sample_route(d)
		add_practical_light(pos + Vector3(-14, 3, 0))
		stop["position"] = pos + Vector3(-5.8, 0, 0)
		LowPoly.box(self, pos + Vector3(-9, -0.05, 0), Vector3(12, 0.15, 26), Color("b3ab8c"))
		LowPoly.box(self, pos + Vector3(-6.7, 2.55, 12), Vector3(3.55, 1.07, 0.18), Color("baaa83"))
		LowPoly.box(self, pos + Vector3(-6.7, 2.55, 12.1), Vector3(3.35, .88, .05), Color("547460"))
		LowPoly.cylinder(self, pos + Vector3(-6.7, 1.2, 12), 0.07, 2.4, Color("7e7d6b"))
		LowPoly.label(self, stop.label.to_upper(), pos + Vector3(-6.7, 2.55, 12.14), 21)
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
			LowPoly.box(self,pos+Vector3(-15,1.55,.02),Vector3(.85,.8,.74),Color("e2d4ae"))
			LowPoly.box(self,pos+Vector3(-15,1.62,.405),Vector3(.58,.27,.035),Color("47665e"))
			LowPoly.box(self,pos+Vector3(-15,1.29,.41),Vector3(.32,.06,.04),Color("bc8962"))
			for i in range(7):
				var a := Vector3(-14.50+sin(i*.42)*.28,1.65-i*.16,.1)
				var b := Vector3(-14.50+sin((i+1)*.42)*.28,1.65-(i+1)*.16,.1)
				LowPoly.beam(self,pos+a,pos+b,.032,Color("424d42"))
			LowPoly.planter(self,pos+Vector3(-19,0,3),1.2)
			LowPoly.label(self, "FUEL", pos + Vector3(-15, 3.45, 4.1), 35)
		else:
			LowPoly.box(self, pos + Vector3(-10, 0.5, 0), Vector3(3, 0.16, 0.8), Color("836849"))
			for x in [-11, -9]:
				LowPoly.box(self, pos + Vector3(x, 0.25, 0), Vector3(0.16, 0.5, 0.8), Color("685c43"))

func _build_chapter_identity() -> void:
	var biome: String = chapter_data.get("biome", "fields")
	LowPoly.label(self, chapter_data.end_location.to_upper(), sample_route(80) + Vector3(-8, 3, 0), 38)
	for i in range(18):
		if _reserved_roadside(120 + i * 90, -1): continue
		var pos := sample_route(120 + i * 90) + Vector3(-32, 0, 0)
		if biome != "coast": pos.y = _terrain_height(pos)
		match biome:
			"coast":
				LowPoly.box(self, pos + Vector3(-100, -2, 0), Vector3(145, .15, 95), Color("6d9ea8")).visibility_range_end = 500
				LowPoly.box(self, pos + Vector3(-15, -1, 0), Vector3(25, .2, 95), Color("d4c391")).visibility_range_end = 400
			"highlands", "mountain":
				LowPoly.cylinder(self, pos + Vector3(-90, 15, 0), 90, 95 if biome == "mountain" else 45, Color("6e847d"), 0, 7).visibility_range_end = 700
			"plantation", "teak":
				for j in range(4):
					var tree := pos + Vector3(-j * 9, 0, 0)
					LowPoly.cylinder(self, tree + Vector3(0, 3, 0), .3, 6, Color("756b52")).visibility_range_end = 250
					LowPoly.sphere(self, tree + Vector3(0, 6, 0), Vector3(6, 2, 6), Color("466957")).visibility_range_end = 280
			"textiles":
				for x in [-1.0, 5.0]: LowPoly.cylinder(self, pos + Vector3(x, 2.05, 0), .06, 4.1, Color("78694b")).visibility_range_end = 190
				LowPoly.beam(self, pos + Vector3(-1, 4, 0), pos + Vector3(5, 4, 0), .045, Color("78694b")).visibility_range_end = 190
				for j in range(3):
					LowPoly.box(self, pos + Vector3(j * 2, 2.5, 0), Vector3(1.7, 3, .05), Color("a77758") if j % 2 else Color("596f87")).visibility_range_end = 190
			"city", "neighborhood", "campus", "guesthouse", "home", "workshop":
				var house := LowPoly.house(self, pos, Color("c4b494") if i % 2 else Color("9eae9b"))
				for mesh in house.get_children():
					if mesh is GeometryInstance3D: mesh.visibility_range_end = 240

func _reserved_roadside(distance: float, side: int) -> bool:
	if city or side > 0: return false
	if absf(distance - 680) < 32: return true
	for stop in chapter_data.get("stops", []):
		if absf(distance - float(stop.distance)) < 24: return true
	return false

func _terrain_height(point: Vector3) -> float:
	var center_point := sample_route(-point.z)
	var lateral := absf(point.x - center_point.x)
	return center_point.y + lerpf(-.16, -2.85, clampf((lateral - 28) / 17.0, 0, 1))

func _build_traffic() -> void:
	for i in range(4):
		var car := CozyDressing.vehicle(self,i)
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
		var car: TrafficCar = item.node
		car.roll(delta * 9)
		car.position = sample_route(item.distance) + Vector3(2.5, 0, 0)
		car.rotation.y = route_heading(item.distance) + PI
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
		[road_material, "albedo_color", Color("6c7069").lerp(Color("465e5c"), profile.wetness)],
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
