extends Node

var bike_speed: float = 0.0
var engine_active: bool = false
var rain_target: float = 0.0
var night_target: float = 0.0
var unlocked: bool = false
var idle: AudioStreamPlayer
var load_loop: AudioStreamPlayer
var wind: AudioStreamPlayer
var rain: AudioStreamPlayer
var birds: AudioStreamPlayer
var insects: AudioStreamPlayer
var traffic: AudioStreamPlayer
var warung: AudioStreamPlayer
var roof: AudioStreamPlayer
var music: AudioStreamPlayer
var ignition: AudioStreamPlayer
var cooldown: AudioStreamPlayer
var ui_player: AudioStreamPlayer
var ui_streams: Dictionary = {}
var ui_cooldown: float = 0
var soundscape: Dictionary
var context: String = "menu"
var sheltered: bool = false
var focus_suspended: bool = false
var current_cue: String = ""
var cue_remaining: float = 0
signal vehicle_cue_played(id: String)
signal ui_cue_played(id: String)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Sends flow to an earlier bus in Godot's mixer order.
	for bus in ["Music", "Ambience", "Vehicle", "Dialogue", "SFX", "UI"]:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, bus)
	soundscape = JSON.parse_string(FileAccess.get_file_as_string("res://data/audio/soundscape.json"))
	# UI feedback remains available in paused menus and shares the SFX slider.
	AudioServer.set_bus_send(AudioServer.get_bus_index("UI"), "SFX")
	ui_player = AudioStreamPlayer.new()
	ui_player.bus = "UI"
	add_child(ui_player)
	for id in soundscape.ui:
		ui_streams[id] = load(soundscape.ui[id].path)
	idle = _player("res://assets/audio/bike_idle.wav", "Vehicle")
	load_loop = _player("res://assets/audio/bike_load.wav", "Vehicle")
	wind = _player("res://assets/audio/wind.wav", "Ambience")
	rain = _player("res://assets/audio/rain.wav", "Ambience")
	birds = _player("res://assets/audio/birds.wav", "Ambience")
	insects = _player("res://assets/audio/insects.wav", "Ambience")
	traffic = _player("res://assets/audio/traffic.wav", "Ambience")
	warung = _player("res://assets/audio/warung.wav", "Ambience")
	roof = _player("res://assets/audio/rain_roof.wav", "Ambience")
	ignition = _player("res://assets/audio/ignition.wav", "SFX")
	cooldown = _player("res://assets/audio/cooldown.wav", "SFX")
	music = AudioStreamPlayer.new()
	music.bus = "Music"
	add_child(music)
	music.finished.connect(stop_music)

func _player(path: String, bus: String) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = load(path)
	player.bus = bus
	player.volume_db = -60
	add_child(player)
	return player

func unlock() -> void:
	if unlocked:
		return
	unlocked = true
	# Headless tests exercise logical events/mixing without starting a dummy mixer.
	if DisplayServer.get_name() != "headless":
		for player in ambient_players():
			player.play()

func ambient_players() -> Array:
	return [idle, load_loop, wind, rain, birds, insects, traffic, warung, roof]

func set_context(id: String, under_roof: bool = false) -> bool:
	if not soundscape.zones.has(id):
		return false
	context = id
	sheltered = under_roof
	return true

func road_context(distance: float, in_city: bool = false) -> String:
	if in_city:
		return "city"
	for region in soundscape.karawang_regions:
		if distance >= region.from and distance < region.to:
			return region.zone
	return "fields"

func _gain(amount: float, level: float) -> float:
	return -60.0 if amount <= 0 else maxf(-60, level + linear_to_db(amount))

func play_music_cue(id: String) -> bool:
	if not unlocked or focus_suspended or get_tree().paused or not soundscape.music.has(id) or not current_cue.is_empty():
		return false
	var definition: Dictionary = soundscape.music[id]
	music.stream = load(definition.path)
	if music.stream == null:
		return false
	current_cue = id
	cue_remaining = music.stream.get_length()
	music.volume_db = definition.gain_db
	if DisplayServer.get_name() != "headless":
		music.play()
	return true

func stop_music() -> void:
	current_cue = ""
	cue_remaining = 0
	music.stop()
	music.stream = null

func vehicle_event(id: String) -> bool:
	if not unlocked or focus_suspended or get_tree().paused or id not in ["start", "stop"]:
		return false
	var player: AudioStreamPlayer = ignition if id == "start" else cooldown
	( cooldown if id == "start" else ignition ).stop()
	player.volume_db = -18 if id == "start" else -20
	if DisplayServer.get_name() != "headless":
		player.play()
	vehicle_cue_played.emit(id)
	return true

func ui_event(id: String) -> bool:
	if not unlocked or focus_suspended or ui_cooldown > 0 or not ui_streams.has(id):
		return false
	_set_bus_level("Master", GameState.settings.master)
	_set_bus_level("SFX", GameState.settings.sfx)
	if GameState.settings.master <= 0 or GameState.settings.sfx <= 0:
		return false
	ui_player.stream = ui_streams[id]
	ui_player.volume_db = soundscape.ui[id].gain_db
	ui_cooldown = 0.08
	if DisplayServer.get_name() != "headless":
		ui_player.play()
	ui_cue_played.emit(id)
	return true

func reset_scene_audio() -> void:
	stop_music()
	ignition.stop()
	cooldown.stop()
	set_context("menu")
	engine_active = false
	bike_speed = 0

func _set_bus_level(bus: String, level: float) -> void:
	var index := AudioServer.get_bus_index(bus)
	AudioServer.set_bus_volume_db(index, linear_to_db(clampf(level, 0.001, 1)))
	AudioServer.set_bus_mute(index, level <= 0 or (bus == "Master" and focus_suspended))

func _process(delta: float) -> void:
	update_mix(delta)

func update_mix(delta: float) -> void:
	ui_cooldown = maxf(0, ui_cooldown - maxf(0, delta))
	_set_bus_level("Master", GameState.settings.master)
	_set_bus_level("Vehicle", GameState.settings.vehicle)
	_set_bus_level("Ambience", GameState.settings.ambience)
	_set_bus_level("Music", GameState.settings.music)
	_set_bus_level("SFX", GameState.settings.sfx)
	var suspended := get_tree().paused or focus_suspended
	music.stream_paused = suspended
	ignition.stream_paused = suspended
	cooldown.stream_paused = suspended
	for player in ambient_players():
		player.stream_paused = focus_suspended
	if not suspended and not current_cue.is_empty():
		cue_remaining = maxf(0, cue_remaining - delta)
		if cue_remaining <= 0:
			stop_music()
	var zone: Dictionary = soundscape.zones[context]
	var blend := 1.0 - exp(-maxf(0, delta) * 2)
	var engine := engine_active and not get_tree().paused
	idle.volume_db = lerpf(idle.volume_db, -17.0 - bike_speed * 6 if engine else -60.0, blend)
	idle.pitch_scale = 0.85 + bike_speed * 0.5
	load_loop.volume_db = lerpf(load_loop.volume_db, -27.0 + bike_speed * 10 if engine else -60.0, blend)
	load_loop.pitch_scale = 0.8 + bike_speed * 0.8
	wind.volume_db = lerpf(wind.volume_db, _gain(bike_speed if engine else 0, -19), blend)
	rain.volume_db = lerpf(rain.volume_db, _gain(rain_target * zone.outside, -20), blend)
	birds.volume_db = lerpf(birds.volume_db, _gain(zone.birds * (1 - night_target), -24 - rain_target * 10), blend)
	insects.volume_db = lerpf(insects.volume_db, _gain(zone.insects * night_target, -26 - rain_target * 8), blend)
	traffic.volume_db = lerpf(traffic.volume_db, _gain(zone.traffic, -24), blend)
	warung.volume_db = lerpf(warung.volume_db, _gain(zone.warung, -22), blend)
	roof.volume_db = lerpf(roof.volume_db, _gain(rain_target if sheltered else 0, -23), blend)

func rain_volume_target() -> float:
	return -60.0 if rain_target <= 0 else -20.0 + linear_to_db(clampf(rain_target, 0.001, 1))

func _exit_tree() -> void:
	for player in ambient_players() + [music, ignition, cooldown, ui_player]:
		player.stop()
		player.stream = null

func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED]:
		focus_suspended = true
		if is_instance_valid(ui_player):
			ui_player.stop()
		ui_cooldown = 0
	elif what in [NOTIFICATION_APPLICATION_FOCUS_IN, NOTIFICATION_APPLICATION_RESUMED]:
		focus_suspended = false
