class_name BikeVisual
extends Node3D

var show_rider_arms: bool = true
var instruments: BikeInstruments
var bars: Node3D

func _ready() -> void:
	var steel := Color("a9b5b0")
	var black := Color("29312e")
	var paint := Color("466e64")
	LowPoly.sphere(self, Vector3(0, 0.85, -0.2), Vector3(0.69, 0.25, 1.05), paint)
	LowPoly.cylinder(self, Vector3(0, 1.075, -0.22), 0.09, 0.018, steel)
	LowPoly.box(self, Vector3(0, 0.79, 0.48), Vector3(0.48, 0.13, 0.67), black)
	LowPoly.box(self, Vector3(0, 0.42, -0.06), Vector3(0.37, 0.42, 0.39), steel)
	for y in range(6):
		LowPoly.box(self, Vector3(0, 0.28 + y * 0.058, -0.06), Vector3(0.42, 0.018, 0.43), black)
	for z in [-0.87, 0.86]:
		var wheel := LowPoly.cylinder(self, Vector3(0, 0.34, z), 0.34, 0.15, black, -1, 18)
		wheel.rotation.z = PI / 2
		var hub := LowPoly.cylinder(self, Vector3(0, 0.34, z), 0.23, 0.16, steel, -1, 12)
		hub.rotation.z = PI / 2
	for side in [-1, 1]:
		LowPoly.beam(self, Vector3(side * 0.14, 0.35, -0.87), Vector3(side * 0.14, 1.13, -0.57), 0.035, steel)
		LowPoly.beam(self, Vector3(side * 0.2, 0.36, 0.87), Vector3(side * 0.2, 0.75, 0.52), 0.05, steel)
	var lamp := LowPoly.cylinder(self, Vector3(0, 1.04, -0.84), 0.17, 0.12, steel, -1, 18)
	lamp.rotation.x = PI / 2
	var glass := LowPoly.cylinder(self, Vector3(0, 1.04, -0.911), 0.15, 0.015, Color("f5eac6"), -1, 18)
	glass.rotation.x = PI / 2
	bars = Node3D.new()
	add_child(bars)
	LowPoly.beam(bars, Vector3(-0.62, 1.15, -0.38), Vector3(0.62, 1.15, -0.38), 0.024, steel)
	for side in [-1, 1]:
		LowPoly.beam(bars, Vector3(side * 0.42, 1.15, -0.38), Vector3(side * 0.65, 1.15, -0.3), 0.047, black)
		LowPoly.beam(bars, Vector3(side * 0.46, 1.17, -0.38), Vector3(side * 0.74, 1.49, -0.55), 0.016, steel)
		LowPoly.sphere(bars, Vector3(side * 0.76, 1.53, -0.55), Vector3(0.32, 0.12, 0.04), black)
		var mirror := LowPoly.sphere(bars, Vector3(side * 0.76, 1.534, -0.524), Vector3(0.285, 0.095, 0.015), Color("a9c2ba"))
		mirror.material_override = LowPoly.material(Color("a9c2ba"), true)
		# Static sky/road approximation keeps mirrors inexpensive on WebGL.
		LowPoly.box(bars, Vector3(side * 0.76, 1.507, -0.513), Vector3(0.17, 0.03, 0.004), Color("758b7b"))
		if show_rider_arms:
			LowPoly.sphere(bars, Vector3(side * 0.51, 1.165, -0.29), Vector3(0.15, 0.08, 0.21), Color("6d5d47"))
			LowPoly.beam(bars, Vector3(side * 0.51, 1.13, -0.23), Vector3(side * 0.41, 0.98, 0.2), 0.078, Color("65715d"))
	instruments = BikeInstruments.new()
	instruments.position = Vector3(0, 1.16, -.67)
	instruments.rotation_degrees.x = 22
	bars.add_child(instruments)
	LowPoly.label(self, "THUNDER 250", Vector3(0, 0.96, 0.23), 9).rotation_degrees.x = -60

func update_instruments(speed: float, steer: float, rpm: float = 0, powered: bool = false, night: float = 0) -> void:
	instruments.update_readings(speed, rpm, powered, night)
	bars.rotation.y = -steer * 0.07
