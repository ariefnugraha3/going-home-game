class_name PracticeUI
extends GameUI

var hint_label: Label
var sections: Array = []
var session_summary: String = ""
var weather_profiles: Dictionary = {}
var weather_name: String = "Morning"

func _build_hud() -> void:
	super._build_hud()
	for child in toolbar.get_children():
		toolbar.remove_child(child)
		child.queue_free()
	_button(toolbar, "Sections", func(): action_requested.emit("sections"))
	_button(toolbar, "Pause", func(): action_requested.emit("pause"))
	hint_label = _label(hud, "", 20)
	hint_label.anchor_left = 0.15
	hint_label.anchor_right = 0.85
	hint_label.offset_top = 156
	hint_label.offset_bottom = 220
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.add_theme_color_override("font_shadow_color", Color("14251d"))
	hint_label.add_theme_constant_override("shadow_offset_y", 2)

func update_practice(bike: BikeMotorController, section: Dictionary, metrics: RideMetrics) -> void:
	var at_stop := -bike.position.z >= 673 and bike.speed_mps < 2.2
	update_hud(bike.speed_mps * 3.6, -bike.position.z, "Switch off the engine" if at_stop else "", at_stop, false)
	route_label.text = section.name
	status_label.text = "KM/H   ·   PRACTICE ROAD"
	hint_label.text = section.hint
	session_summary = "Riding time: %02d:%02d   ·   Distance: %.0f m\nRecoveries: %d   ·   Obstacle contacts: %d" % [int(metrics.riding_seconds) / 60, int(metrics.riding_seconds) % 60, metrics.distance_meters, metrics.recoveries, metrics.contacts]

func show_pause() -> void:
	_clear("pause")
	var box := _panel("A little riding practice", "Explore at your own pace. Your story progress stays where you left it.")
	_paragraph(box, session_summary, 20, GOLD)
	_button(box, "Continue practicing", func(): action_requested.emit("resume")).grab_focus()
	_button(box, "Choose a road section", func(): action_requested.emit("sections"))
	_button(box, "Settings & accessibility", show_settings)
	_button(box, "Controls", show_controls)
	_button(box, "Clear skies / rain", func(): action_requested.emit("weather"))
	_button(box, "Light & weather: " + weather_name, func(): action_requested.emit("atmosphere"))
	_button(box, "Return safely to the road", func(): action_requested.emit("recover"))
	_button(box, "Save a local playtest report", func(): action_requested.emit("report"))
	_button(box, "Return to title", func(): action_requested.emit("menu"))

func show_sections() -> void:
	_clear("sections")
	var box := _panel("Find your rhythm", "Try a section again, or ride the full road from the start.")
	for section in sections:
		_button(box, section.name, func(): action_requested.emit("section:" + section.id))
	_button(box, "Back", func(): action_requested.emit("back"))

func show_atmosphere() -> void:
	_clear("atmosphere")
	var box := _panel("Light along the road", "Choose a mood for this practice ride. Changes blend in as you resume.")
	for id in WeatherProfile.IDS:
		var profile: WeatherProfile = weather_profiles[id]
		_button(box, profile.display_name, func(): action_requested.emit("atmosphere:" + id))
	_button(box, "Back", func(): action_requested.emit("back"))

func show_rest() -> void:
	_clear("practice_rest")
	var box := _panel("The engine goes quiet", "Stay a while. There is no score to beat.")
	_paragraph(box, session_summary, 22, GOLD)
	_button(box, "Ride the road again", func(): action_requested.emit("section:straight")).grab_focus()
	_button(box, "Try another section", func(): action_requested.emit("sections"))
	_button(box, "Save a local playtest report", func(): action_requested.emit("report"))
	_button(box, "Return to title", func(): action_requested.emit("menu"))
