extends Node3D

# F6: inspect the production traffic models from both sides and on the road.
var camera: Camera3D

func _ready() -> void:
	Engine.max_fps = 30
	var studio := Node3D.new()
	add_child(studio)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("d7d1bf")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("e8dfca")
	env.environment.ambient_light_energy = .45
	studio.add_child(env)
	var sun := DirectionalLight3D.new()
	studio.add_child(sun)
	sun.rotation_degrees = Vector3(-48,-35,0)
	sun.light_color = Color("fff1d8")
	sun.light_energy = .8
	sun.shadow_enabled = true
	LowPoly.box(studio,Vector3(0,-.025,0),Vector3(200,.05,200),Color("8b9186"))
	camera = Camera3D.new()
	add_child(camera)
	camera.make_current()
	camera.fov = 40
	for variant in range(2):
		var car := CozyDressing.vehicle(studio,variant)
		var id := "wagon" if variant else "hatchback"
		await shot("car_"+id+"_front",Vector3(4.4,2.9,-5.9),Vector3(0,.77,0))
		await shot("car_"+id+"_rear",Vector3(-4.4,2.8,6.1),Vector3(0,.77,0))
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = 5.1
		await shot("car_"+id+"_side",Vector3(5,.85,0),Vector3(0,.85,0))
		camera.projection = Camera3D.PROJECTION_PERSPECTIVE
		car.queue_free()
		await get_tree().process_frame
	studio.queue_free()
	await get_tree().process_frame
	GameState.settings.quality = 1
	var road := RoadWorld.new()
	add_child(road)
	road.build(false)
	road.set_process(false)
	road.traffic[0].distance = 48.0
	road._process(0)
	var car: TrafficCar = road.traffic[0].node
	await shot("car_road",car.global_position+Vector3(-4.0,2.5,5.8),car.global_position+Vector3(0,.75,0))
	print("CAR REVIEW COMPLETE")
	get_tree().quit()

func shot(id: String, from: Vector3, target: Vector3) -> void:
	camera.position = from
	camera.look_at(target)
	for i in range(8): await get_tree().process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://tests/screenshots")
	get_viewport().get_texture().get_image().save_png("res://tests/screenshots/"+id+".png")
