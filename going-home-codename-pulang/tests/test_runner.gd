extends Node

var failures: int = 0
var checks: int = 0
var app: Node
var visual_test: bool = false

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + description)
	else:
		print("PASS: " + description)

func frames(count: int) -> void:
	for i in range(count):
		await get_tree().physics_frame
	await get_tree().process_frame

func settle() -> void:
	await frames(3)
	var budget := 240
	while app.flow.busy and budget > 0:
		await frames(1)
		budget -= 1
	check(budget > 0, "Transition finishes within four seconds")

func _ready() -> void:
	visual_test = "--visual" in OS.get_cmdline_user_args()
	var target_fps := 30 if "--limit-30" in OS.get_cmdline_user_args() else 60
	Engine.max_fps = 0 if not visual_test else target_fps
	GameState.settings.fps_limit = target_fps
	await frames(2)
	_test_data()
	_test_save()
	GameState.new_journey()
	app = preload("res://scenes/boot/Boot.tscn").instantiate()
	add_child(app)
	await frames(5)
	check(app.ui.mode == "menu", "Boot presents main menu")
	await capture("menu")
	app._on_action("new_confirmed")
	await settle()
	check(app.state == "cutscene", "New journey starts opening cinematic")
	await capture("opening")
	app.director.finish()
	await settle()
	check(app.state == "riding" and app.commute, "Skipping opening restores commute controls")
	Input.action_press("accelerate")
	await frames(180)
	Input.action_release("accelerate")
	check(app.bike.speed_mps > 5 and app.bike.position.z < -17, "Throttle physically advances the motorcycle")
	Input.action_press("brake")
	await frames(150)
	Input.action_release("brake")
	check(app.bike.speed_mps < 0.1, "Brake brings bike to rest")
	app._pause()
	var paused_pos: Vector3 = app.bike.position
	Input.action_press("accelerate")
	await frames(10)
	check(app.bike.position == paused_pos, "Pause freezes physics")
	Input.action_release("accelerate")
	app._resume()
	app.bike.teleport(310)
	await frames(3)
	await settle()
	check(app.director.active_id == "office", "Office arrival starts meeting cinematic")
	app.director.finish()
	await frames(2)
	complete_dialogue(0)
	await settle()
	check(GameState.flags.get("story.prologue.laid_off", false), "Layoff flag committed")
	check(app.director.active_id == "signout", "Layoff leads to badge and sign-out sequence")
	app.director.finish()
	await settle()
	check(app.director.active_id == "night", "Sign-out hands off to evening apartment")
	app.director.finish()
	complete_dialogue(1)
	await settle()
	check(GameState.flags.get("story.prologue.called_mom", false), "Mother call completes on quiet branch")
	app.director.finish()
	await settle()
	check(app.state == "riding" and not app.commute, "Departure hands off to Karawang road")
	check(GameState.flags.get("story.prologue.departed", false), "Skip commits departure flags")
	app.bike.teleport(510)
	Input.action_press("accelerate")
	await frames(180)
	Input.action_release("accelerate")
	await capture("riding")
	check(app.bike.is_on_floor(), "Ground probe and collision keep the bike grounded on a slope")
	var yaw: float = app.bike.rotation.y
	Input.action_press("steer_left")
	await frames(20)
	Input.action_release("steer_left")
	check(app.bike.rotation.y > yaw, "Left steering turns the motorcycle left")
	app.bike.teleport(390)
	await frames(3)
	app._interact()
	complete_dialogue(0)
	check(GameState.bike.fuel == 12, "Fuel encounter refills tank")
	app.bike.teleport(720)
	await frames(3)
	app._interact()
	check(app.state == "scenic" and not app.bike.enabled, "Scenic stop switches engine off")
	app._resume()
	app.bike.teleport(1130)
	await frames(4)
	check(app.world.wet, "Rain event triggered by distance")
	app._interact()
	await capture("warung")
	complete_dialogue(0)
	check(GameState.flags.get("story.karawang.sheltered", false), "Shelter dialogue commits checkpoint")
	check(GameState.checkpoint == "warung", "Shelter is the active checkpoint")
	app._on_action("phone")
	await capture("phone")
	check(app.ui.mode == "phone" and get_tree().paused, "Phone pauses the ride")
	app._resume()
	app._on_action("map")
	await capture("map")
	app._resume()
	GameState.settings.touch = true
	await frames(4)
	var touch: TouchControls = app.ui.touch
	touch.zones = {"accelerate": Rect2(900, 500, 100, 100), "steer_left": Rect2(10, 500, 100, 100)}
	touch._update_finger(1, Vector2(930, 530))
	touch._update_finger(2, Vector2(40, 530))
	check(Input.is_action_pressed("accelerate") and Input.is_action_pressed("steer_left"), "Two touch pointers can steer and accelerate together")
	touch.release_all()
	check(not Input.is_action_pressed("accelerate"), "Touch release clears held actions")
	GameState.settings.touch = false
	app.bike.teleport(1700)
	await frames(4)
	app._interact()
	complete_dialogue(0)
	check(app.state == "reflection", "Rest opens authored journal choices")
	await capture("journal")
	app._journal_selected("tea", "Someone made tea. I didn't have to explain much.")
	check(GameState.checkpoint == "complete", "Journal completes chapter")
	check(SaveManager.load_game() and not GameState.journal.is_empty(), "Journal survives save/load")
	app._return_to_menu()
	app._on_action("continue")
	await settle()
	check(app.state == "complete", "Continue restores completed chapter without replaying prologue")
	await capture("complete")
	print("TEST RESULT: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)

func complete_dialogue(choice_index: int) -> void:
	var budget := 40
	while not DialogueManager.active_id.is_empty() and budget > 0:
		DialogueManager.advance(mini(choice_index, DialogueManager.choices.size() - 1))
		budget -= 1
	check(budget > 0, "Dialogue reaches a terminal node")

func _test_data() -> void:
	for id in DialogueManager.content:
		var nodes: Dictionary = DialogueManager.content[id].nodes
		check(nodes.has("start"), id + " has a start node")
		for node in nodes.values():
			var next: String = node.get("next", "end")
			check(next == "end" or nodes.has(next), id + " has valid next reference")
			for choice in node.get("choices", []):
				check(choice.next == "end" or nodes.has(choice.next), id + " has valid choice reference")
	GameState.set_flag("test.condition", true)
	check(DialogueManager.matches({"test.condition": true}), "Dialogue accepts matching conditions")
	check(not DialogueManager.matches({"test.condition": false}), "Dialogue rejects mismatched conditions")

func _test_save() -> void:
	GameState.new_journey()
	check(SaveManager.validate(GameState.snapshot()), "Fresh save schema validates")
	var future := GameState.snapshot()
	future.schema_version = 99
	check(not SaveManager.validate(future), "Future schema is rejected safely")
	check(not SaveManager.validate({"schema_version": 1}), "Incomplete save rejected")
	var malformed := GameState.snapshot()
	malformed.erase("phone")
	check(not SaveManager.validate(malformed), "Missing phone dictionary rejected without a runtime error")
	malformed = GameState.snapshot()
	malformed.journal["broken"] = "invalid"
	check(not SaveManager.validate(malformed), "Malformed journal entry rejected")
	check(SaveManager.save_game(), "Initial save written")
	GameState.set_flag("test.persisted", true)
	check(SaveManager.save_game(), "Replacement save written with backup")
	GameState.flags.clear()
	check(SaveManager.load_game() and GameState.flags.get("test.persisted", false), "Narrative state round-trips")
	var file := FileAccess.open(SaveManager.SAVE_PATH, FileAccess.WRITE)
	file.store_string("{broken")
	file.close()
	check(SaveManager.load_game(), "Corrupt primary save recovers backup")
	check(not GameState.flags.has("test.persisted"), "Backup contains previous valid checkpoint")
	SaveManager.save_game()

func capture(name: String) -> void:
	if not visual_test:
		return
	await frames(3)
	await RenderingServer.frame_post_draw
	var path := "res://tests/screenshots/" + name + ".png"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tests/screenshots"))
	get_viewport().get_texture().get_image().save_png(path)
