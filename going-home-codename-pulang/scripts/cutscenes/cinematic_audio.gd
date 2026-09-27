class_name CinematicAudio
extends Node

# Two bounded voices allow a sound tail to bridge a cut. The director owns time.
signal cue_started(id: String, offset: float)
var bank: Dictionary = {}
var streams: Dictionary = {}
var voices: Array[AudioStreamPlayer] = []
var remaining: Array[float] = [0.0, 0.0]
var pending: Array = []
var elapsed: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	bank = JSON.parse_string(FileAccess.get_file_as_string("res://data/audio/cinematic.json"))
	for id in bank:
		streams[id] = load(bank[id].path)
	for i in range(2):
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		voices.append(player)

func begin_shot(events: Array) -> void:
	pending = events.duplicate(true)
	elapsed = 0
	advance(0)

func advance(delta: float) -> void:
	if get_tree().paused or AudioManager.focus_suspended:
		return
	delta = maxf(0, delta)
	elapsed += delta
	for i in range(voices.size()):
		remaining[i] = maxf(0, remaining[i] - delta)
		if remaining[i] <= 0:
			voices[i].stop()
	# Consume even muted/locked events: unmuting must not replay an old action.
	for event in pending.duplicate():
		if float(event.at) <= elapsed:
			pending.erase(event)
			_start(event.cue, elapsed - float(event.at))

func _start(id: String, offset: float) -> void:
	if not streams.has(id) or not AudioManager.unlocked or AudioManager.focus_suspended or get_tree().paused:
		return
	if GameState.settings.master <= 0 or GameState.settings.sfx <= 0:
		return
	var stream: AudioStream = streams[id]
	if offset >= stream.get_length():
		return
	var index := remaining.find(0.0)
	if index < 0:
		return # Bounded polyphony; keep already playing tails intact.
	var player := voices[index]
	player.stream = stream
	player.volume_db = bank[id].gain_db
	remaining[index] = stream.get_length() - offset
	if DisplayServer.get_name() != "headless":
		player.play(offset)
	cue_started.emit(id, offset)

func stop() -> void:
	pending.clear()
	elapsed = 0
	for i in range(voices.size()):
		remaining[i] = 0
		voices[i].stop()
		voices[i].stream = null

func _process(_delta: float) -> void:
	for player in voices:
		player.stream_paused = get_tree().paused or AudioManager.focus_suspended

func _exit_tree() -> void:
	stop()
