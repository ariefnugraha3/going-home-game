class_name BikeInstruments
extends Node3D

# A compact, replaceable analog cluster. RPM is a presentation value supplied
# by the forgiving automatic riding controller, not a simulated transmission.
var speed_needle: Node3D
var rpm_needle: Node3D
var face_material: StandardMaterial3D
var ink_material: StandardMaterial3D
var needle_material: StandardMaterial3D
var labels: Array[Label3D] = []
var displayed_speed: float = 0
var displayed_rpm: float = 0
var illumination: float = 0

func _ready() -> void:
	# Per-cluster materials: a lit riding bike must not light a parked/cinematic bike.
	face_material = _material(Color("20342f"))
	ink_material = _material(Color("eee1ba"))
	needle_material = _material(Color("f3a66b"))
	for side in [-1, 1]:
		var center := Vector3(side * 0.15, 0, 0)
		LowPoly.cylinder(self, center, .14, .085, Color("a9b5b0"), -1, 32)
		var face := LowPoly.cylinder(self, center + Vector3(0, .049, 0), .126, .012, Color.WHITE, -1, 32)
		face.material_override = face_material
		for i in range(11):
			var angle := -2.25 + i * .45
			var tick := LowPoly.box(self, center + Vector3(sin(angle) * .106, .059, -cos(angle) * .106), Vector3(.005, .003, .018 if i % 2 == 0 else .011), Color.WHITE)
			tick.material_override = ink_material
			tick.rotation.y = -angle
			if i % 2 == 0:
				_label(str(i * 10 if side == -1 else i), center + Vector3(sin(angle) * .079, .064, -cos(angle) * .079), .001, 22)
		_label("km/h" if side == -1 else "x1000 rpm", center + Vector3(0, .064, .063), .0008, 18)
		var pointer := Node3D.new()
		add_child(pointer)
		pointer.position = center + Vector3(0, .066, 0)
		var hand := LowPoly.box(pointer, Vector3(0, 0, -.036), Vector3(.006, .004, .088), Color.WHITE)
		hand.material_override = needle_material
		var hub := LowPoly.cylinder(self, center + Vector3(0, .07, 0), .012, .01, Color.WHITE, -1, 12)
		hub.material_override = ink_material
		if side == -1:
			speed_needle = pointer
		else:
			rpm_needle = pointer
	update_readings(0, 0, false, 0)

func _material(color: Color) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = .85
	result.emission_enabled = true
	result.emission = color
	result.emission_energy_multiplier = 0
	return result

func _label(text: String, point: Vector3, pixel: float, font: int) -> void:
	var label := LowPoly.label(self, text, point, font)
	label.pixel_size = pixel
	label.rotation.x = -PI / 2
	label.no_depth_test = false
	label.shaded = true
	labels.append(label)

func update_readings(speed: float, rpm: float, powered: bool, night: float) -> void:
	displayed_speed = clampf(speed, 0, 100) if is_finite(speed) else 0
	displayed_rpm = clampf(rpm, 0, 10000) if powered and is_finite(rpm) else 0
	speed_needle.rotation.y = 2.25 - displayed_speed / 100 * 4.5
	rpm_needle.rotation.y = 2.25 - displayed_rpm / 10000 * 4.5
	illumination = clampf(night, 0, 1) if powered and is_finite(night) else 0
	face_material.emission_energy_multiplier = illumination * .22
	ink_material.emission_energy_multiplier = illumination * .7
	needle_material.emission_energy_multiplier = illumination * .8
	for label in labels:
		label.shaded = illumination < .15
