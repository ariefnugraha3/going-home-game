class_name PhoneDataService
extends Node

signal inbox_changed
var messages: Array = []
var calls: Array = []
var photos: Array = []
const CHANNELS := ["Messages", "Email"]

func _ready() -> void:
	messages = JSON.parse_string(FileAccess.get_file_as_string("res://data/phone/messages.json"))
	calls = JSON.parse_string(FileAccess.get_file_as_string("res://data/phone/calls.json"))
	photos = JSON.parse_string(FileAccess.get_file_as_string("res://data/phone/photos.json"))
	GameState.flag_changed.connect(_flag_changed)
	GameState.journey_changed.connect(reconcile)
	reconcile()

func _flag_changed(_id: String, _value: Variant) -> void:
	reconcile()

func reconcile() -> void:
	for message in messages:
		var id: String = message.id
		if id in GameState.phone.delivered:
			GameState.phone.pending.erase(id)
		elif GameState.flags.get(message.condition, false) and not GameState.phone.pending.has(id):
			GameState.phone.pending[id] = float(message.get("delay_seconds", 0))
	inbox_changed.emit()

func advance(delta: float, delivery_allowed: bool, banner_available: bool) -> Dictionary:
	# The owner provides the cutscene/menu lock; there are no wall-clock timers.
	if not delivery_allowed:
		return {}
	var changed := false
	var scheduled := messages.duplicate()
	scheduled.sort_custom(func(a: Dictionary, b: Dictionary):
		var a_delay := float(GameState.phone.pending.get(a.id, INF))
		var b_delay := float(GameState.phone.pending.get(b.id, INF))
		return a.id < b.id if a_delay == b_delay else a_delay < b_delay)
	for message in scheduled:
		var id: String = message.id
		if not GameState.phone.pending.has(id):
			continue
		GameState.phone.pending[id] = maxf(0, float(GameState.phone.pending[id]) - maxf(0, delta))
		if GameState.phone.pending[id] <= 0:
			GameState.phone.pending.erase(id)
			if id not in GameState.phone.delivered:
				GameState.phone.delivered.append(id)
			changed = true
	var notice: Dictionary = {}
	if banner_available:
		# Delivery order is the queue order, including across save/reload.
		for id in GameState.phone.delivered:
			if id in GameState.phone.notified or id in GameState.phone.read or GameState.phone.replies.has(id):
				continue
			notice = message_by_id(id)
			if not notice.is_empty():
				GameState.phone.notified.append(id)
				changed = true
				break
	if changed:
		if not SaveManager.save_game(false) and not notice.is_empty():
			# Preserve the visible save error and retry this notice after the slot clears.
			GameState.phone.notified.erase(notice.id)
			notice = {}
		inbox_changed.emit()
	return notice

func message_by_id(id: String) -> Dictionary:
	for message in messages:
		if message.id == id:
			return message
	return {}

func received_messages(channel: String = "") -> Array:
	var result: Array = []
	for id in GameState.phone.delivered:
		var message := message_by_id(id)
		if not message.is_empty() and (channel.is_empty() or message.type == channel):
			result.append(message.duplicate(true))
	return result

func unread_count(channel: String = "") -> int:
	var count := 0
	for message in received_messages(channel):
		if message.id not in GameState.phone.read and not GameState.phone.replies.has(message.id):
			count += 1
	return count

func mark_inbox_read(channel: String = "") -> void:
	var changed := false
	for message in received_messages(channel):
		if message.id not in GameState.phone.read:
			GameState.phone.read.append(message.id)
			changed = true
	if changed:
		SaveManager.save_game(false)
		inbox_changed.emit()

func call_history() -> Array:
	# Completion already belongs to the stable save contract. Reading history
	# never starts a dialogue or writes a second source of call-completion state.
	var result: Array = []
	for call in calls:
		if GameState.dialogue_states.get(call.dialogue, "") != "complete":
			continue
		var entry: Dictionary = call.duplicate(true)
		var nodes: Dictionary = DialogueManager.content.get(call.dialogue, {}).get("nodes", {})
		entry["remembered_line"] = nodes.get(call.remembered_node, {}).get("text", "")
		result.append(entry)
	return result

func available_photos() -> Array:
	var result: Array = []
	for photo in photos:
		if photo.condition.is_empty() or GameState.flags.get(photo.condition, false):
			result.append(photo.duplicate(true))
	return result

func photo_by_id(id: String) -> Dictionary:
	for photo in available_photos():
		if photo.id == id:
			return photo
	return {}

func reply(id: String) -> bool:
	var message := message_by_id(id)
	if message.is_empty() or id not in GameState.phone.delivered or GameState.phone.replies.has(id):
		return false
	GameState.phone.replies[id] = message.reply
	if id not in GameState.phone.read:
		GameState.phone.read.append(id)
	GameState.set_flag("phone." + id + ".replied")
	var saved := SaveManager.save_game(false)
	inbox_changed.emit()
	return saved
