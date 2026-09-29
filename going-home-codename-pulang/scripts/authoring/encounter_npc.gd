class_name EncounterNPC
extends Node3D

signal dialogue_requested(id: String)
@export var display_name := "Roadside host"
@export var dialogue_id := "authoring.greeting"
@export var interaction_label := "Say hello"
@export var shirt := Color("81917a")
@export_range(1, 10) var interaction_radius := 4.0
var actor: CinematicActor
var busy := false
var clock := 0.0

func _ready() -> void:
	actor = CinematicActor.new()
	$Visual.add_child(actor)
	actor.build(shirt)
	actor.sample("walk", 0)
	var label := LowPoly.label(self, display_name, Vector3(0, 2.1, 0), 22)
	label.pixel_size = 0.004
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED

func _process(delta: float) -> void:
	if not busy or AudioManager.focus_suspended:
		return
	clock += delta
	# Keep the standing lower body while the conversation adds a small head nod.
	actor.head.rotation.x = sin(clock * 1.5) * 0.035

func interact(viewer: Vector3, speed_kmh: float = 0) -> bool:
	if busy or get_tree().paused or AudioManager.focus_suspended or absf(speed_kmh) >= 8:
		return false
	if viewer.distance_to($InteractionAnchor.global_position) > interaction_radius:
		return false
	busy = true
	clock = 0
	dialogue_requested.emit(dialogue_id)
	return true

func release() -> void:
	busy = false
	clock = 0
	actor.sample("walk", 0)
