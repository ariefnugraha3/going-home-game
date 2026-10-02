extends Node3D

# F6 / native render: same production model, orthographic views expose proportions.
var camera: Camera3D

func _ready() -> void:
	Engine.max_fps = 30
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("d7d1bf")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("e8dfca")
	env.environment.ambient_light_energy = .45
	add_child(env)
	var sun := DirectionalLight3D.new()
	add_child(sun)
	sun.rotation_degrees = Vector3(-48,-35,0)
	sun.light_color = Color("fff1d8")
	sun.light_energy = .8
	sun.shadow_enabled = true
	LowPoly.box(self,Vector3(0,-.025,0),Vector3(200,.05,200),Color("8b9186"))
	var bike := BikeVisual.new()
	bike.show_rider_arms = false
	add_child(bike)
	camera = Camera3D.new()
	add_child(camera)
	camera.make_current()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.25
	await shot("bike_side",Vector3(4,.79,0),Vector3(0,.79,0))
	await shot("bike_front",Vector3(0,.79,-4),Vector3(0,.79,0))
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	camera.fov = 40
	await shot("bike_three_quarter",Vector3(2.3,1.65,-2.9),Vector3(0,.70,0))
	await shot("bike_rear",Vector3(-2.5,1.7,3.2),Vector3(0,.70,0))
	await shot("bike_right_controls",Vector3(1.05,.69,-.69),Vector3(.21,.30,.015))
	await shot("bike_left_controls",Vector3(-1.05,.64,-.62),Vector3(-.21,.31,.015))
	var actor := CinematicActor.new()
	add_child(actor)
	actor.build(Color("65715d"))
	CinematicMount.sample(actor,bike,1)
	await shot("bike_rider",Vector3(3.0,1.9,-3.3),Vector3(0,.92,0))
	await shot("bike_right_boot",Vector3(1.05,.69,-.69),Vector3(.23,.33,.015))
	await shot("bike_left_boot",Vector3(-1.05,.64,-.62),Vector3(-.23,.33,.015))
	print("BIKE REVIEW COMPLETE")
	get_tree().quit()

func shot(id: String, from: Vector3, target: Vector3) -> void:
	camera.position = from
	camera.look_at(target)
	for i in range(8): await get_tree().process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://tests/screenshots")
	get_viewport().get_texture().get_image().save_png("res://tests/screenshots/"+id+".png")
