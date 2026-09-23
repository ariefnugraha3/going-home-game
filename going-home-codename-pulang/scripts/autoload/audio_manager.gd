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

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for bus in ["Music", "Ambience", "Vehicle", "Dialogue", "UI", "SFX"]:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, bus)
	idle = _player("res://assets/audio/bike_idle.wav", "Vehicle")
	load_loop = _player("res://assets/audio/bike_load.wav", "Vehicle")
	wind = _player("res://assets/audio/wind.wav", "Ambience")
	rain = _player("res://assets/audio/rain.wav", "Ambience")
	birds = _player("res://assets/audio/birds.wav", "Ambience")
	insects = _player("res://assets/audio/insects.wav", "Ambience")

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
	# A headless validation process has no audible output or real mixer lifetime.
	if DisplayServer.get_name() == "headless":
		return
	unlocked = true
	for player in [idle, load_loop, wind, rain, birds, insects]:
		player.play()

func _process(delta: float) -> void:
	if not unlocked:
		return
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Vehicle"), linear_to_db(maxf(0.001, GameState.settings.vehicle)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambience"), linear_to_db(maxf(0.001, GameState.settings.ambience)))
	var engine := engine_active and not get_tree().paused
	idle.volume_db = lerpf(idle.volume_db, -17.0 - bike_speed * 6 if engine else -60.0, delta * 4)
	idle.pitch_scale = 0.85 + bike_speed * 0.5
	load_loop.volume_db = lerpf(load_loop.volume_db, -27.0 + bike_speed * 10 if engine else -60.0, delta * 4)
	load_loop.pitch_scale = 0.8 + bike_speed * 0.8
	wind.volume_db = lerpf(wind.volume_db, -34.0 + bike_speed * 15, delta * 2)
	var blend := 1.0 - exp(-delta * 2)
	rain.volume_db = lerpf(rain.volume_db, rain_volume_target(), blend)
	birds.volume_db = lerpf(birds.volume_db, lerpf(-24.0 - rain_target * 10, -60, night_target), blend)
	insects.volume_db = lerpf(insects.volume_db, lerpf(-60, -26, night_target) - rain_target * 8, blend)

func rain_volume_target() -> float:
	return -60.0 if rain_target <= 0 else -20.0 + linear_to_db(clampf(rain_target, 0.001, 1))

func _exit_tree() -> void:
	for player in [idle, load_loop, wind, rain, birds, insects]:
		player.stop()
		player.stream = null
