extends "res://tests/test_runner.gd"

func _ready() -> void:
	visual_test = "--visual" in OS.get_cmdline_user_args()
	Engine.max_fps = (30 if "--limit-30" in OS.get_cmdline_user_args() else 60) if visual_test else 0
	GameState.new_journey()
	GameState.settings = GameState.DEFAULT_SETTINGS.duplicate(true)
	GameState.settings.touch = false
	InputModeManager.touch_mode = false
	SaveManager.save_game()
	var saved := FileAccess.get_file_as_string(SaveManager.SAVE_PATH)
	var snapshot := GameState.snapshot()
	app = preload("res://scenes/practice/RidingPractice.tscn").instantiate()
	add_child(app)
	await frames(4)
	var bike: BikeMotorController = app.bike
	var cluster: BikeInstruments = bike.visual.instruments
	bike.set_physics_process(false)
	check(cluster.labels.size() == 14 and cluster.labels.all(func(label): return not label.no_depth_test), "Both analog dials have six numbers and units with normal depth testing")
	check(is_equal_approx(cluster.rotation_degrees.x, 22), "Cluster tilts toward the rider while preserving camera framing")
	for values in [[0.0, 0.0, 2.25], [50.0, 5000.0, 0.0], [100.0, 10000.0, -2.25]]:
		cluster.update_readings(values[0], values[1], true, 0)
		check(is_equal_approx(cluster.speed_needle.rotation.y, values[2]) and is_equal_approx(cluster.rpm_needle.rotation.y, values[2]), "Both needles agree with dial calibration: " + str(values[0]))
	cluster.update_readings(-10, -2000, true, -1)
	check(cluster.displayed_speed == 0 and cluster.displayed_rpm == 0 and cluster.illumination == 0, "Negative readings and light are clamped")
	cluster.update_readings(250, 18000, true, 2)
	check(cluster.displayed_speed == 100 and cluster.displayed_rpm == 10000 and cluster.illumination == 1, "Readings cannot pass the dial limits")
	cluster.update_readings(NAN, INF, true, NAN)
	check(cluster.displayed_speed == 0 and cluster.displayed_rpm == 0 and cluster.illumination == 0, "Nonfinite presentation inputs are safe")
	cluster.update_readings(40, 4000, false, 1)
	check(cluster.displayed_speed == 40 and cluster.displayed_rpm == 0 and cluster.illumination == 0, "Engine-off coasting retains speed but has no RPM or panel light")
	var parked := BikeVisual.new()
	parked.show_rider_arms = false
	add_child(parked)
	_test_bike_proportions(parked)
	cluster.update_readings(40, 4000, true, 1)
	check(cluster.face_material != parked.instruments.face_material and parked.instruments.illumination == 0 and parked.instruments.speed_needle.rotation.y == 2.25, "Parked bike starts at zero and cannot inherit riding-bike illumination")
	var geometry_count := cluster.get_child_count()
	var material := cluster.face_material
	for i in range(120):
		cluster.update_readings(i, i * 80, true, i / 120.0)
	check(cluster.get_child_count() == geometry_count and cluster.face_material == material, "Instrument updates reuse geometry and materials")
	parked.queue_free()
	await frames(2)
	bike.enabled = true
	bike.engine_on = true
	bike.speed_mps = 0
	bike.presentation_rpm = 0
	bike._update_cockpit(1)
	check(cluster.displayed_speed == 0 and is_equal_approx(cluster.displayed_rpm, 1300), "Powered stopped motorcycle settles at idle RPM")
	Input.action_press("accelerate")
	bike._update_cockpit(.1)
	check(is_equal_approx(cluster.displayed_rpm, 1660), "RPM rises at a bounded rate under throttle")
	bike._update_cockpit(1)
	check(is_equal_approx(cluster.displayed_rpm, 2200), "Stationary throttle stays restrained")
	Input.action_release("accelerate")
	bike._update_cockpit(1)
	check(is_equal_approx(cluster.displayed_rpm, 1300), "Releasing throttle returns to idle")
	bike.speed_mps = 26
	Input.action_press("accelerate")
	bike._update_cockpit(2)
	check(is_equal_approx(cluster.displayed_speed, 93.6) and is_equal_approx(cluster.displayed_rpm, 6100), "Cruise-speed presentation stays within the useful analog range")
	Input.action_release("accelerate")
	var frame_rate_rpm := bike.presentation_rpm
	bike._update_cockpit(0)
	check(bike.presentation_rpm == frame_rate_rpm, "Zero time cannot advance the RPM easing")
	bike.presentation_rpm = 0
	for i in range(30):
		bike._update_cockpit(1.0 / 30)
	frame_rate_rpm = bike.presentation_rpm
	bike.presentation_rpm = 0
	for i in range(60):
		bike._update_cockpit(1.0 / 60)
	check(is_equal_approx(bike.presentation_rpm, frame_rate_rpm), "RPM easing agrees at 30 and 60 updates per second")
	bike.stop()
	check(cluster.displayed_speed == 0 and cluster.displayed_rpm == 0 and cluster.illumination == 0, "Stop resets both needles and panel light immediately")
	bike.enabled = true
	bike.speed_mps = 18
	bike._update_cockpit(2)
	bike.recover_to_road()
	check(cluster.displayed_speed == 0 and cluster.displayed_rpm == 1300 and bike.visual.bars.rotation.y == 0, "Recovery resets speed, steering and powered idle immediately")
	bike.set_physics_process(true)
	Input.action_press("accelerate")
	await physics_frames(60)
	Input.action_release("accelerate")
	check(cluster.displayed_speed > 0 and is_equal_approx(cluster.displayed_speed, bike.speed_mps * 3.6) and cluster.displayed_rpm > 1300, "Actual practice physics feeds speed and RPM")
	var motion := bike.transform
	var rpm := cluster.displayed_rpm
	var needle := cluster.speed_needle.transform
	app._pause()
	await frames(5)
	check(bike.transform == motion and cluster.displayed_rpm == rpm and cluster.speed_needle.transform == needle, "Pause holds needles and riding position together")
	app._resume()
	await frames(4)
	bike.set_physics_process(false)
	for profile in ["morning", "night"]:
		app.world.set_weather_profile(profile, true)
		# World-to-headlight update happens in _process, after process_frame.
		# At 30 FPS several physics ticks can precede that one render update.
		await get_tree().process_frame
		await get_tree().process_frame
		bike.speed_mps = 50.0 / 3.6
		bike._update_cockpit(2)
		check(is_equal_approx(cluster.illumination, 1.0 if profile == "night" else 0.0), "Panel light follows world night/headlight state: " + profile)
		await capture("cockpit_" + profile)
		# Inspect an ordinary downward glance using the existing camera controls.
		bike.head.rotation.x = -.25
		await capture("cockpit_" + profile + "_glance")
		bike.head.rotation.x = 0
	check(cluster.face_material.emission_energy_multiplier > 0 and cluster.labels.all(func(label): return not label.shaded), "Night lights dial markings and needle without extra lights or viewports")
	bike.engine_on = false
	bike._update_cockpit(.1)
	check(cluster.displayed_speed > 0 and cluster.displayed_rpm == 0 and cluster.illumination == 0, "Controller engine-off state clears tachometer and backlight")
	bike.stop()
	await capture("cockpit_night_off")
	check(GameState.snapshot() == snapshot and FileAccess.get_file_as_string(SaveManager.SAVE_PATH) == saved, "Practice cockpit operations leave story memory and checkpoint bytes unchanged")
	app.queue_free()
	await frames(4)
	# The same controller is used by the story; verify checkpoint restoration too.
	app = preload("res://scenes/boot/Boot.tscn").instantiate()
	add_child(app)
	await frames(4)
	GameState.checkpoint = "road_start"
	GameState.chapter = "karawang"
	app._restore_checkpoint()
	await settle()
	await frames(5)
	check(app.bike.enabled and app.bike.visual.instruments.displayed_rpm > 0, "Story Continue restores powered cockpit without new save fields")
	app.bike.stop()
	check(app.bike.visual.instruments.displayed_speed == 0 and app.bike.visual.instruments.displayed_rpm == 0, "Story stop clears instrument readings")
	app.queue_free()
	await frames(3)
	print("COCKPIT TEST RESULT: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)

func physics_frames(count: int) -> void:
	for i in range(count):
		await get_tree().physics_frame

func _test_bike_proportions(bike: BikeVisual) -> void:
	var base := bike.wheels[0].position.distance_to(bike.wheels[1].position)
	var tank_size := bike.tank.mesh.get_aabb().size * bike.tank.scale
	check(base > 1.35 and base < 1.5 and tank_size.z / base > .43 and tank_size.z / base < .53, "Tank length and wheelbase retain compact road-bike proportions")
	var grip_width := BikeVisual.hand_grip(1).x * 2
	check(tank_size.x < grip_width * .65 and grip_width < .85, "Tank stays narrower than a human-scale handlebar")
	check(bike.instruments.scale.x * .58 < tank_size.x * .75, "Twin instruments stay within the tank width")
	var grounded := true
	for wheel in bike.wheels:
		for child in wheel.get_children():
			if child is MeshInstance3D:
				var bounds: AABB = child.transform * child.mesh.get_aabb()
				if bounds.size.y > .60:
					grounded = grounded and absf(wheel.position.y + bounds.position.y) < .002
	check(grounded, "Rendered tire bounds touch the ground at both axles")
	var before := bike.wheels[0].rotation.x
	bike.roll_wheels(BikeVisual.WHEEL_RADIUS * PI)
	check(absf(angle_difference(before, bike.wheels[0].rotation.x)) > PI - .001, "Half a tire circumference rolls the visible wheel by half a turn")
