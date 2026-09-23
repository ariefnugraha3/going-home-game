extends Node

var world: PracticeWorld
var bike: BikeMotorController
var ui: PracticeUI
var metrics := RideMetrics.new()
var resting: bool = false
var leaving: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	world = PracticeWorld.new()
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(world)
	world.build()
	bike = preload("res://scenes/bike/BikePlayer.tscn").instantiate()
	bike.route = world.route
	bike.route_limit = world.definition.length - 10.0
	bike.record_journey = false
	bike.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(bike)
	bike.obstacle_contact.connect(func(): metrics.contacts += 1)
	bike.recovered.connect(func():
		metrics.recoveries += 1
		metrics.reset_position())
	ui = PracticeUI.new()
	add_child(ui)
	ui.sections = world.definition.sections
	ui.action_requested.connect(_on_action)
	start_section("straight")
	AudioManager.unlock()

func start_section(id: String) -> void:
	for section in world.definition.sections:
		if section.id == id:
			InputModeManager.release_riding()
			bike.teleport(section.start)
			metrics.reset_position()
			resting = false
			_resume()
			return

func _current_section() -> Dictionary:
	var distance := -bike.position.z
	for section in world.definition.sections:
		if distance < section.end:
			return section
	return world.definition.sections.back()

func _on_action(action: String) -> void:
	if leaving:
		return
	if action.begins_with("section:"):
		start_section(action.trim_prefix("section:"))
		return
	match action:
		"pause", "back": _pause()
		"resume": _resume()
		"sections":
			_pause()
			ui.show_sections()
		"recover":
			bike.recover_to_road()
			resting = false
			_resume()
		"weather":
			world.set_weather(not world.wet)
			_resume()
		"interact":
			if -bike.position.z >= 673 and bike.speed_mps < 2.2:
				bike.stop()
				resting = true
				ui.show_rest()
		"report":
			var path := metrics.save_report()
			ui.toast("Playtest report saved locally" if not path.is_empty() else "Could not save the report. Please check storage.")
		"menu":
			leaving = true
			bike.stop()
			get_tree().paused = false
			AudioManager.rain_target = 0
			get_tree().change_scene_to_file("res://scenes/boot/Boot.tscn")

func _pause() -> void:
	get_tree().paused = true
	InputModeManager.release_riding()
	AudioManager.engine_active = false
	ui.show_pause()

func _resume() -> void:
	get_tree().paused = false
	InputModeManager.release_riding()
	if resting:
		ui.show_rest()
		return
	bike.enabled = true
	bike.engine_on = true
	bike.camera.make_current()
	ui.riding()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo() or leaving:
		return
	if event.is_action_pressed("pause"):
		if ui.mode in ["settings", "sections", "controls"]:
			_pause()
		elif get_tree().paused:
			_resume()
		else:
			_pause()
		get_viewport().set_input_as_handled()
	elif not get_tree().paused:
		if event.is_action_pressed("recover"):
			_on_action("recover")
		elif event.is_action_pressed("interact"):
			_on_action("interact")

func _physics_process(delta: float) -> void:
	if not get_tree().paused and is_instance_valid(bike):
		metrics.sample_bike(bike, delta)

func _process(delta: float) -> void:
	if not is_instance_valid(ui):
		return
	ui.weather.rain = world.wet and not resting and not get_tree().paused
	ui.weather.queue_redraw()
	if get_tree().paused:
		return
	if not resting:
		metrics.sample_frame(delta)
		ui.update_practice(bike, _current_section(), metrics)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		if is_instance_valid(ui) and not get_tree().paused and not leaving:
			_pause()

func _exit_tree() -> void:
	InputModeManager.release_riding()
	AudioManager.engine_active = false
	AudioManager.rain_target = 0
	LowPoly.materials.clear()
