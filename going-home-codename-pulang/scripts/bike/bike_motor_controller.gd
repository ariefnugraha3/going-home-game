class_name BikeMotorController
extends CharacterBody3D

signal speed_changed(kph: float)
signal obstacle_contact
signal recovered
var route: RidingRoute = RidingRoute.new()
var record_journey: bool = true
var speed_mps: float = 0.0
var steering: float = 0.0
var enabled: bool = false
var engine_on: bool = true
var route_limit: float = 1760.0
var camera: Camera3D
var headlight: SpotLight3D
var visual: BikeVisual
var head: Node3D
var lean: Node3D
var probes: Array[RayCast3D] = []

func _ready() -> void:
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.36
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	floor_snap_length = 1.0
	visual = BikeVisual.new()
	add_child(visual)
	lean = Node3D.new()
	add_child(lean)
	head = Node3D.new()
	lean.add_child(head)
	head.position = Vector3(0, 1.75, 0.4)
	camera = Camera3D.new()
	head.add_child(camera)
	camera.near = 0.04
	camera.far = 900
	camera.rotation.x = -0.14
	headlight = SpotLight3D.new()
	headlight.position = Vector3(0, 1.0, -0.85)
	headlight.rotation_degrees.x = -8
	headlight.light_color = Color("ffe1aa")
	headlight.spot_range = 42
	headlight.spot_angle = 32
	headlight.light_energy = 0
	headlight.shadow_enabled = false
	add_child(headlight)
	for z in [-0.7, 0.0, 0.7]:
		var ray := RayCast3D.new()
		ray.position = Vector3(0, 0.65, z)
		ray.target_position = Vector3(0, -2, 0)
		ray.add_exception(self)
		add_child(ray)
		probes.append(ray)

func teleport(distance: float, lane: float = -2.5) -> void:
	position = route.sample(distance) + Vector3(lane, 0.08, 0)
	rotation.y = route.heading(distance)
	speed_mps = 0
	steering = 0
	velocity = Vector3.ZERO
	if is_instance_valid(visual):
		visual.rotation = Vector3.ZERO
		lean.rotation = Vector3.ZERO
		head.rotation = Vector3.ZERO

func recover_to_road() -> void:
	teleport(clampf(-position.z, 10.0, route_limit - 20.0))
	InputModeManager.release_riding()
	recovered.emit()

func _physics_process(delta: float) -> void:
	camera.fov = GameState.settings.fov
	if not enabled:
		AudioManager.bike_speed = 0
		AudioManager.engine_active = false
		return
	var throttle := Input.get_action_strength("accelerate")
	var brake := Input.get_action_strength("brake")
	var raw_steer := Input.get_axis("steer_left", "steer_right")
	steering = move_toward(steering, raw_steer, delta * 3.8)
	var distance := clampf(-position.z, 0, route_limit)
	var acceleration := throttle * lerpf(4.2, 1.1, speed_mps / 26.0) - 0.35 - speed_mps * 0.025 - brake * 8.0
	if not engine_on:
		acceleration = -5.0
	if -position.z > route_limit - 15:
		acceleration -= 8.0
	speed_mps = clampf(speed_mps + acceleration * delta, 0, 26.0)
	var turn_rate := lerpf(0.9, 0.36, speed_mps / 26.0)
	rotation.y -= steering * turn_rate * minf(speed_mps / 3.0, 1.0) * delta
	if GameState.settings.riding_assist and absf(raw_steer) < 0.1 and speed_mps > 1:
		var look_ahead := clampf(speed_mps * 0.55, 4.0, 12.0)
		var target := route.sample(distance + look_ahead) + Vector3(-2.5, 0, 0)
		var toward := target - position
		var desired_heading := atan2(-toward.x, -toward.z)
		rotation.y = lerp_angle(rotation.y, desired_heading, 1.0 - exp(-delta * 4.0))
	var center := route.sample(distance)
	if absf(position.x - center.x) > 7.0:
		position.x = move_toward(position.x, center.x + signf(position.x - center.x) * 6.5, delta * 4)
		speed_mps = minf(speed_mps, 7.0)
		rotation.y = lerp_angle(rotation.y, route.heading(distance), 1.0 - exp(-delta * 2.0))
	var forward := -transform.basis.z
	velocity.x = forward.x * speed_mps
	velocity.z = forward.z * speed_mps
	velocity.y -= 16 * delta
	if is_on_floor():
		velocity.y = -0.5
	var previous_position := position
	move_and_slide()
	# A forgiving stop on a solid obstacle, with no bounce or damage.
	for index in range(get_slide_collision_count()):
		var normal := get_slide_collision(index).get_normal()
		if absf(normal.y) < 0.5 and normal.dot(forward) < -0.35:
			if speed_mps > 1.0:
				obstacle_contact.emit()
			speed_mps = minf(speed_mps, Vector2(position.x - previous_position.x, position.z - previous_position.z).length() / maxf(delta, 0.001))
	if position.y < center.y - 1.0 or position.z > 15:
		recover_to_road()
		previous_position = position
	var route_heading := route.heading(distance)
	rotation.y = route_heading + clampf(wrapf(rotation.y - route_heading, -PI, PI), -0.75, 0.75)
	var normal := Vector3.ZERO
	for ray in probes:
		if ray.is_colliding():
			normal += ray.get_collision_normal()
	if normal.length() > 0:
		visual.rotation.x = lerpf(visual.rotation.x, atan2(normal.z, normal.y), 1.0 - exp(-delta * 4))
	visual.rotation.z = lerpf(visual.rotation.z, -steering * speed_mps * 0.006, 1.0 - exp(-delta * 4))
	lean.rotation.z = 0 if GameState.settings.reduced_motion else visual.rotation.z * 0.16
	head.rotation.y = lerpf(head.rotation.y, Input.get_axis("look_right", "look_left") * 0.65, 1.0 - exp(-delta * 5))
	head.rotation.x = lerpf(head.rotation.x, Input.get_axis("look_down", "look_up") * 0.25, 1.0 - exp(-delta * 5))
	visual.update_instruments(speed_mps * 3.6, steering)
	if record_journey:
		var travelled := position.distance_to(previous_position)
		GameState.bike.distance += travelled / 1000.0
		GameState.bike.fuel = maxf(0.8, GameState.bike.fuel - travelled * 0.000055)
	AudioManager.bike_speed = speed_mps / 26.0
	AudioManager.engine_active = engine_on
	speed_changed.emit(speed_mps * 3.6)

func stop() -> void:
	enabled = false
	speed_mps = 0
	velocity = Vector3.ZERO
	InputModeManager.release_riding()
