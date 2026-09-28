class_name CinematicStage
extends Node3D

# Replaceable blocking geometry; authored shots refer to stable prop names.
var props: Dictionary = {}
var screen: Label3D

func build(location: String, night: bool) -> void:
	if location in ["parking", "memory"]:
		_parking(location == "memory")
	else:
		_interior(location, night)
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0, 3.5, 1.5)
	lamp.light_color = Color("ffddb0") if night else Color("e0ece7")
	lamp.light_energy = 1.1 if night else 1.8
	lamp.omni_range = 14
	lamp.light_cull_mask = 2
	lamp.layers = 2
	add_child(lamp)
	for child in find_children("*", "GeometryInstance3D", true, false):
		child.layers = 2

func _text(value: String, pos: Vector3, size: float = 0.002) -> Label3D:
	var label := LowPoly.label(self, value, pos, 32)
	label.pixel_size = size
	label.no_depth_test = false
	return label

func _interior(location: String, night: bool) -> void:
	LowPoly.box(self, Vector3(0, -0.1, 0), Vector3(10, 0.2, 10), Color("9c9279"))
	LowPoly.box(self, Vector3(0, 2, -3), Vector3(10, 4, 0.2), Color("c7c6ae"))
	LowPoly.box(self, Vector3(-4, 2, 0), Vector3(0.2, 4, 6), Color("929f93"))
	LowPoly.box(self, Vector3(4, 2, 0), Vector3(0.2, 4, 6), Color("929f93"))
	LowPoly.box(self, Vector3(-1.9, 2.15, -2.86), Vector3(2.4, 1.8, 0.08), Color("263f50") if night else Color("86aeb6"))
	for x in [-3.1, -1.9, -0.7]:
		LowPoly.box(self, Vector3(x, 2.15, -2.8), Vector3(0.06, 1.8, 0.1), Color("ded2b7"))
	LowPoly.box(self, Vector3(0, 0.83, -0.6), Vector3(2.9, 0.12, 1.2), Color("80634a"))
	for x in [-1.25, 1.25]:
		LowPoly.box(self, Vector3(x, 0.4, -0.6), Vector3(0.1, 0.8, 1), Color("5c5041"))
	var laptop := CinematicLaptop.new()
	add_child(laptop)
	laptop.build()
	props.laptop = laptop
	screen = laptop.screen
	LowPoly.cylinder(self, Vector3(-0.95, 1, -0.7), 0.09, 0.22, Color("eee0b5"))
	LowPoly.cylinder(self, Vector3(-1.2, 1.08, -0.8), 0.14, 0.35, Color("819591"))
	LowPoly.beam(self, Vector3(-1.2, 1.1, -0.8), Vector3(-1.0, 1.22, -0.8), 0.04, Color("819591"))
	props.phone_body = LowPoly.box(self, Vector3(0.86, 0.925, -0.45), Vector3(0.18, 0.025, 0.33), Color("253a3b"))
	props.phone_face = LowPoly.box(self, Vector3(0.86, 0.941, -0.45), Vector3(0.155, 0.008, 0.29), Color("54716a"))
	var phone := _text("06:40", Vector3(0.86, 0.947, -0.45), 0.00065)
	phone.rotation.x = -PI / 2
	props.phone = phone
	var badge := LowPoly.box(self, Vector3(-0.5, 0.915, -0.35), Vector3(0.15, 0.035, 0.23), Color("dbd6bd"))
	props.badge = badge
	var badge_text := _text("RAKA", Vector3(-0.5, 0.938, -0.35), 0.00055)
	badge_text.rotation.x = -PI / 2
	props.badge_text = badge_text
	props.lanyard = LowPoly.beam(self, Vector3(-0.58, 0.945, -0.44), Vector3(-0.7, 0.945, -0.63), 0.012, Color("48676e"))
	var bag := PackingProps.new()
	add_child(bag)
	bag.build()
	props.bag = bag
	bag.visible = false
	if location == "office":
		_text("MEETING ROOM 03", Vector3(1.4, 2.6, -2.8), 0.005)
		props.nadia = _seated(Vector3(0.65, 0, -1.7), PI, Color("677c7c"))
		_chair(Vector3(0.65, 0, -1.7), PI)
	else:
		LowPoly.box(self, Vector3(2.5, 0.35, -1), Vector3(1.4, 0.65, 2.6), Color("4e6e68"))
		LowPoly.box(self, Vector3(2.5, 0.72, -1.85), Vector3(1.1, 0.2, 0.55), Color("ddd3b5"))
		LowPoly.box(self, Vector3(1.5, 0.69, -1.75), Vector3(0.6, 0.08, 0.65), Color("80634a"))
		for x in [1.28, 1.72]:
			for z in [-1.99, -1.51]:
				LowPoly.box(self, Vector3(x, 0.325, z), Vector3(0.06, 0.65, 0.06), Color("5c5041"))
		LowPoly.box(self, Vector3(-2.6, 0.45, 0.2), Vector3(0.65, 0.08, 0.6), Color("665b47"))
		LowPoly.box(self, Vector3(-2.6, 0.95, -0.08), Vector3(0.65, 0.9, 0.08), Color("665b47"))
		LowPoly.box(self, Vector3(-2.6, 1.02, 0.01), Vector3(0.55, 0.55, 0.14), Color("698174"))
	props.raka = _seated(Vector3(0, 0, 0.45), 0, Color("65715d"))
	props.raka_chair = _chair(Vector3(0, 0, 0.45), 0)
	if night:
		LowPoly.cylinder(self, Vector3(1.2, 1.02, -0.95), 0.055, 0.24, Color("a58c65"))
		LowPoly.cylinder(self, Vector3(1.2, 1.24, -0.95), 0.16, 0.23, Color("ebce94"), 0.1)
		var practical := OmniLight3D.new()
		practical.position = Vector3(1.2, 1.25, -0.75)
		practical.light_color = Color("ffc685")
		practical.light_energy = 1.4
		practical.omni_range = 4
		practical.light_cull_mask = 2
		practical.layers = 2
		add_child(practical)

func _chair(pos: Vector3, facing: float) -> Node3D:
	var chair := Node3D.new()
	add_child(chair)
	chair.position = pos
	chair.rotation.y = facing
	LowPoly.box(chair, Vector3(0, 0.61, 0), Vector3(0.56, 0.09, 0.48), Color("665b47"))
	LowPoly.box(chair, Vector3(0, 0.99, 0.25), Vector3(0.56, 0.7, 0.07), Color("665b47"))
	for x in [-0.22, 0.22]:
		for z in [-0.18, 0.18]:
			LowPoly.box(chair, Vector3(x, 0.3, z), Vector3(0.06, 0.6, 0.06), Color("665b47"))
	return chair

func _seated(pos: Vector3, facing: float, shirt: Color) -> CinematicActor:
	var actor := CinematicActor.new()
	add_child(actor)
	actor.position = pos
	actor.rotation.y = facing
	actor.build(shirt)
	return actor

func _parking(memory: bool = false) -> void:
	LowPoly.box(self, Vector3(0, -0.12, 0), Vector3(24, 0.2, 20), Color("a59570") if memory else Color("64716c"))
	if memory:
		LowPoly.box(self, Vector3(0, -0.13, -5), Vector3(35, 0.2, 12), Color("8b9d6a"))
		for x in [-5, 4]:
			LowPoly.cylinder(self, Vector3(x, 1.5, -2.8), 0.18, 3, Color("796548"))
			LowPoly.sphere(self, Vector3(x, 3.4, -2.8), Vector3(3.5, 2.4, 3), Color("758c64"))
		for x in range(-8, 9, 2):
			LowPoly.box(self, Vector3(x, 0.45, -3.5), Vector3(0.09, 0.9, 0.09), Color("96866a"))
		LowPoly.box(self, Vector3(0, 0.6, -3.5), Vector3(17, 0.1, 0.08), Color("96866a"))
	else:
		LowPoly.box(self, Vector3(0, 1.8, -4), Vector3(18, 3.6, 0.3), Color("b6baa5"))
		for x in [-6, -3, 3, 6]:
			LowPoly.box(self, Vector3(x, 1.65, -3.8), Vector3(1.8, 2.7, 0.15), Color("637d76"))
		for x in [-3, 0, 3]:
			LowPoly.box(self, Vector3(x, 0, 0), Vector3(0.07, 0.02, 4), Color("c9c6a9"))
		_text("RESIDENT PARKING", Vector3(-1, 3, -3.75), 0.007)
	var bike := BikeVisual.new()
	bike.show_rider_arms = false
	add_child(bike)
	bike.rotation.y = -PI / 2
	props.bike = bike
	var rider := _seated(Vector3(0, 0.22, 0), -PI / 2, Color("916c4e") if memory else Color("65715d"))
	props.rider = rider
	if not memory:
		props.walker = _seated(Vector3.ZERO, 0, Color("65715d"))
	if memory:
		var child := _seated(Vector3(-0.57, 0.48, 0), -PI / 2, Color("b39864"))
		child.scale = Vector3.ONE * 0.65
		props.young_raka = child
	var luggage := CinematicLuggage.new()
	bike.add_child(luggage)
	luggage.build()
	props.luggage = luggage

func configure(shot: Dictionary) -> void:
	if screen != null:
		screen.text = shot.get("screen", "")
	if props.has("phone"):
		props.phone.text = shot.get("phone", "06:40")
		var phone_position := Vector3(1.5, 0.75, -1.75) if shot.get("bedside_phone", false) else Vector3(0.86, 0.925, -0.45)
		props.phone_body.position = phone_position
		props.phone_face.position = phone_position + Vector3(0, 0.016, 0)
		props.phone.position = phone_position + Vector3(0, 0.022, 0)
	if props.has("bag"):
		props.bag.visible = shot.get("packing", false)
		for key in ["badge", "badge_text", "lanyard"]:
			props[key].visible = not shot.get("packing", false)
	if props.has("raka"):
		props.raka.visible = shot.get("actor", true)
	if props.has("nadia"):
		props.nadia.visible = shot.get("actor", true)
	if props.has("luggage"):
		props.luggage.visible = shot.get("luggage", false)
	if props.has("walker"):
		props.walker.visible = shot.get("performance", "rest") == "walk" or shot.get("luggage_check", false)
		props.rider.visible = not props.walker.visible

func pose(shot: Dictionary, weight: float) -> void:
	if props.has("raka"):
		if shot.get("performance", "rest") == "walk":
			_pose_walk(props.raka, shot, weight)
		elif shot.get("performance", "rest") == "wake":
			# Sit toward the foot of the bed as the torso rises. Like the actor
			# clip, placement is a pure function of the shot's shared clock.
			props.raka.position = Vector3(2.5, 0.13, -1.05).lerp(Vector3(2.5, 0, 0.2), smoothstep(0.15, 0.55, weight))
			props.raka.rotation = Vector3(0, PI, 0)
			props.raka.sample("wake", weight)
		else:
			props.raka.position = Vector3(0, 0, 0.45)
			props.raka.rotation = Vector3.ZERO
			props.raka.sample(shot.get("performance", "rest"), weight)
		var packing: PackingProps = props.bag
		var packing_action: bool = shot.get("performance", "rest") == "pack"
		packing.sample(weight if packing_action else 1.0)
		if packing_action:
			packing.pose_actor(props.raka, weight)
		props.laptop.reset_to_desk()
		if shot.get("laptop_packing", false):
			props.laptop.sample(weight, packing, props.raka)
		props.raka_chair.position = Vector3(-0.35, 0, 0.25) if shot.get("laptop_packing", false) else Vector3(0, 0, 0.45)
		var on_table: bool = not props.raka.handset.visible
		for key in ["phone", "phone_body", "phone_face"]:
			props[key].visible = on_table
	if props.has("nadia"):
		props.nadia.sample(shot.get("npc_performance", "listen"), weight)
	if props.has("rider"):
		props.rider.sample("ride", weight)
	if props.has("luggage"):
		props.luggage.sample(weight if shot.get("luggage_check", false) else 1.0)
	if props.has("walker"):
		if shot.get("luggage_check", false):
			props.luggage.pose_actor(props.walker, weight)
		elif props.walker.visible:
			_pose_walk(props.walker, shot, weight)
		else:
			props.walker.position = Vector3.ZERO
			props.walker.rotation = Vector3.ZERO
			props.walker.sample("walk", 0)
	if props.has("young_raka"):
		props.young_raka.sample("passenger", weight)
	if props.has("bike"):
		var travel: float = shot.get("travel", 0.0) * weight
		props.bike.position.x = travel
		props.rider.position.x = travel

func _pose_walk(actor: CinematicActor, shot: Dictionary, weight: float) -> void:
	var from_values: Array = shot.get("actor_from", [0, 0, 0])
	var to_values: Array = shot.get("actor_to", from_values)
	var start := Vector3(from_values[0], from_values[1], from_values[2])
	var end := Vector3(to_values[0], to_values[1], to_values[2])
	var direction := end - start
	actor.position = start.lerp(end, weight)
	actor.rotation = Vector3(0, atan2(-direction.x, -direction.z), 0) if direction.length_squared() > 0 else Vector3.ZERO
	# Root travel and the repeating gait share the director's eased progress.
	# An integer stride count lands on a neutral pose at either end, and seeking
	# backwards or skipping never depends on a previous animation frame.
	actor.sample("walk", fposmod(weight * maxi(1, int(shot.get("walk_cycles", 1))), 1.0))

func actor_snapshot() -> Dictionary:
	var result := {}
	for key in ["raka", "nadia", "rider", "young_raka", "walker"]:
		if props.has(key):
			result[key] = [props[key].transform, props[key].visible, props[key].pose_snapshot()]
	return result

func prop_snapshot() -> Dictionary:
	var result := {}
	if props.has("bag"):
		result.bag = props.bag.pose_snapshot()
		result.laptop = props.laptop.pose_snapshot()
		result.chair = props.raka_chair.transform
		for key in ["badge", "badge_text", "lanyard"]:
			result[key] = props[key].visible
	if props.has("luggage"):
		result.luggage = props.luggage.pose_snapshot()
	return result
