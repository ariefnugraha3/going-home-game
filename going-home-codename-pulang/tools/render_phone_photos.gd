extends SceneTree

# Original in-engine stills, baked once for the phone album. Gameplay only
# loads the resulting PNGs; it does not create extra 3D worlds for the gallery.
func _initialize() -> void:
	call_deferred("render_album")

func render_album() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Phone photo rendering requires a native renderer; omit --headless.")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/photos"))
	for id in ["with_dad", "leaving_jakarta", "saris_warung"]:
		var viewport := SubViewport.new()
		viewport.size = Vector2i(960, 540)
		viewport.own_world_3d = true
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		var world := Node3D.new()
		viewport.add_child(world)
		var env := WorldEnvironment.new()
		env.environment = Environment.new()
		env.environment.background_mode = Environment.BG_COLOR
		env.environment.background_color = Color("c6c9b0")
		env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		env.environment.ambient_light_color = Color("c4d0c1")
		env.environment.ambient_light_energy = 0.5
		world.add_child(env)
		var camera := Camera3D.new()
		world.add_child(camera)
		camera.fov = 46
		camera.cull_mask = 2
		if id == "saris_warung":
			LowPoly.box(world, Vector3(0, -0.1, 3), Vector3(35, 0.2, 30), Color("7a8570"))
			LowPoly.warung(world, Vector3.ZERO)
			var light := DirectionalLight3D.new()
			light.rotation_degrees = Vector3(-48, -35, 0)
			light.light_color = Color("dfe4d4")
			light.light_energy = 1.2
			light.layers = 2
			light.light_cull_mask = 2
			world.add_child(light)
			camera.position = Vector3(10, 4, 16)
			camera.look_at(Vector3(0, 1.6, 4))
		else:
			var stage := CinematicStage.new()
			world.add_child(stage)
			stage.build("memory" if id == "with_dad" else "parking", false)
			stage.configure({"luggage": id == "leaving_jakarta"})
			stage.pose({}, 0)
			if id == "leaving_jakarta":
				stage.props.rider.hide()
			camera.position = Vector3(2.8, 1.9, 4.2) if id == "with_dad" else Vector3(3, 1.65, 4)
			camera.look_at(Vector3(-0.2, 0.9, 0))
		for mesh in world.find_children("*", "GeometryInstance3D", true, false):
			mesh.layers = 2
		camera.make_current()
		for frame in range(8):
			await process_frame
		await RenderingServer.frame_post_draw
		var result := viewport.get_texture().get_image().save_png("res://assets/photos/" + id + ".png")
		if result != OK:
			push_error("Could not save photo: " + id)
			quit(1)
			return
		print("Rendered album photo: " + id)
		viewport.queue_free()
		await process_frame
	quit(0)
