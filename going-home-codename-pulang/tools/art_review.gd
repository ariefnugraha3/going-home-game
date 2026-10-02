extends Node

# Native review camera only; never loads or writes the player's journey.
var camera: Camera3D

func _ready() -> void:
	GameState.settings.quality = 2
	Engine.max_fps = 30
	camera = Camera3D.new()
	add_child(camera)
	camera.fov = 48
	camera.make_current()
	var world := RoadWorld.new()
	world.chapter_data = Campaign.chapter("karawang")
	add_child(world)
	world.build()
	world.set_weather_profile("morning", true)
	var center := world.sample_route(1130)
	await shot("cozy_warung",center+Vector3(1,5.5,19),center+Vector3(-15,1.6,1))
	var bike := BikeVisual.new()
	bike.show_rider_arms = false
	add_child(bike)
	bike.position = center+Vector3(-8,0,6)
	bike.luggage.visible = true
	await shot("cozy_motorcycle",bike.position+Vector3(2.4,1.6,-2.8),bike.position+Vector3(0,.8,0))
	bike.queue_free()
	await shot("cozy_road",world.sample_route(610)+Vector3(-2.5,2.1,0),world.sample_route(670)+Vector3(-2.5,1,0))
	world.queue_free()
	await get_tree().process_frame
	world = RoadWorld.new()
	world.chapter_data = Campaign.chapter("banyuwangi")
	add_child(world)
	world.build()
	world.set_weather_profile("golden_hour", true)
	var stage := world.encounter_stage
	stage.sample(camera,world.chapter_data.arrival_shots[3],.8)
	await shot("cozy_home",stage.to_global(Vector3(9,4.3,12)),stage.to_global(Vector3(0,1.8,-1.2)))
	stage.frame_dialogue(camera,"Mom")
	await capture("cozy_character")
	world.queue_free()
	await get_tree().process_frame
	var room := CinematicStage.new()
	add_child(room)
	room.build("apartment",true)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("333e3b")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("ecd7b8")
	env.environment.ambient_light_energy = .5
	add_child(env)
	await shot("cozy_room",Vector3(3.4,2.8,3.8),Vector3(-.2,1.2,-.9))
	await shot("hero_laptop",Vector3(.8,1.55,.6),Vector3(.05,1.05,-.66))
	await shot("hero_id_card",Vector3(-.3,1.5,-.09),Vector3(-.61,.915,-.55))
	room.queue_free()
	await get_tree().process_frame
	room = CinematicStage.new()
	add_child(room)
	room.build("office",false)
	room.pose({"performance":"listen"},.5)
	await shot("hero_nadia",Vector3(1.45,1.58,.4),Vector3(.65,1.35,-1.65))
	room.queue_free()
	env.queue_free()
	camera.queue_free()
	await get_tree().process_frame
	print("ART REVIEW COMPLETE")
	get_tree().quit()

func shot(id: String, from: Vector3, target: Vector3) -> void:
	camera.position = from
	camera.look_at(target)
	await capture(id)

func capture(id: String) -> void:
	for i in range(8): await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var folder := "res://tests/screenshots/"
	DirAccess.make_dir_recursive_absolute(folder)
	get_viewport().get_texture().get_image().save_png(folder+id+".png")
