class_name BikeMotorController
extends CharacterBody3D

signal speed_changed(kph: float)
var speed_mps: float = 0.0
var steering: float = 0.0
var enabled: bool = false
var engine_on: bool = true
var route_limit: float = 1760.0
var camera: Camera3D
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
	for z in [-0.7, 0.0, 0.7]:
		var ray := RayCast3D.new()
		ray.position = Vector3(0, 0.65, z)
		ray.target_position = Vector3(0, -2, 0)
		ray.add_exception(self)
		add_child(ray)
		probes.append(ray)

func teleport(distance: float, lane: float = -2.5) -> void:
	position = RoadWorld.center(distance) + Vector3(lane, 0.08, 0)
	rotation.y = RoadWorld.heading(distance)
	speed_mps = 0
	velocity = Vector3.ZERO

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
		rotation.y = lerp_angle(rotation.y, RoadWorld.heading(distance), delta * 1.5)
	var center := RoadWorld.center(distance)
	if absf(position.x - center.x) > 7.0:
		position.x = move_toward(position.x, center.x + signf(position.x - center.x) * 6.5, delta * 4)
		speed_mps = minf(speed_mps, 7.0)
		rotation.y = lerp_angle(rotation.y, RoadWorld.heading(distance), delta * 2.0)
	var forward := -transform.basis.z
	velocity.x = forward.x * speed_mps
	velocity.z = forward.z * speed_mps
	velocity.y -= 16 * delta
	if is_on_floor():
		velocity.y = -0.5
	move_and_slide()
	if position.y < center.y - 1.0 or position.z > 15:
		teleport(distance)
	rotation.y = clampf(rotation.y, -0.75, 0.75)
	var normal := Vector3.ZERO
	for ray in probes:
		if ray.is_colliding():
			normal += ray.get_collision_normal()
	if normal.length() > 0:
		visual.rotation.x = lerpf(visual.rotation.x, atan2(normal.z, normal.y), delta * 4)
	visual.rotation.z = lerpf(visual.rotation.z, -steering * speed_mps * 0.006, delta * 4)
	lean.rotation.z = 0 if GameState.settings.reduced_motion else visual.rotation.z * 0.16
	head.rotation.y = lerpf(head.rotation.y, Input.get_axis("look_right", "look_left") * 0.65, delta * 5)
	head.rotation.x = lerpf(head.rotation.x, Input.get_axis("look_down", "look_up") * 0.25, delta * 5)
	visual.update_instruments(speed_mps * 3.6, steering)
	GameState.bike.distance += speed_mps * delta / 1000.0
	GameState.bike.fuel = maxf(0.8, GameState.bike.fuel - speed_mps * delta * 0.000055)
	AudioManager.bike_speed = speed_mps / 26.0
	AudioManager.engine_active = engine_on
	speed_changed.emit(speed_mps * 3.6)

func stop() -> void:
	enabled = false
	speed_mps = 0
	velocity = Vector3.ZERO
	InputModeManager.release_riding()
