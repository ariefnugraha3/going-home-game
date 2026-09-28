# Scene-transition lifecycle regression

This closes the local accelerated transition-test part of **PERF-01 / M4–M5**. It follows the TDD's scene unloading, object-count and save regression requirements. It is not a long-duration riding, browser, Android, OS working-set or thermal acceptance test.

## Run

From the project directory:

```powershell
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Lifecycle -FixedFps 30
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Lifecycle -Visual -FixedFps 30
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Lifecycle -FixedFps 30 -SoakCycles 10
```

The default is three cycles; `-SoakCycles` accepts 1–100 and only affects Lifecycle. `-Suite All` includes three cycles by default. Use the helper's isolated `.godot-test/` storage: New Game intentionally replaces the test journey. Do not launch this test against the player's normal profile.

The harness remains outside `SceneTree.current_scene` so the game's actual title/practice actions can replace and free their real scene roots. It alternates Low/Medium quality each cycle. Native mode caps rendering at 30 FPS; headless fixed cadence accelerates simulated time and cannot measure real FPS.

## One cycle

1. Load the title, enter Practice ride and switch to heavy rain and the tight bend.
2. Hold steering and throttle through the touch-control handler, propagate application focus-out to the tree, verify pause/input/audio suspension, then focus-in and explicit Resume.
3. Open settings while paused, return to the title through the actual practice action, and compare story memory and checkpoint bytes.
4. Start New Game, pause and leave the opening, then Continue the stable morning checkpoint.
5. Skip the opening, reach the office, complete the layoff dialogue, sign-out, mother's call and departure handoffs.
6. Visit the shelter and guesthouse, open the phone, select a journal reflection, return to the title, then Continue the completed chapter. Confirm that first-night music stops on leaving and does not replay on Continue.
7. Enter and leave practice again after story completion. Verify the same save isolation and disposal with a populated journey.
8. Unload the final title and compare with the initial empty-tree baseline.

Road travel is accelerated with teleports and cinematics are skipped through their normal action. This verifies handoffs and interrupted checkpoint restoration, not continuous full-length riding or every animation frame. The separate Story, Practice, Cinematic and CinematicAudio suites cover those subsystems.

## Assertions and report

- Live nodes and orphan nodes return to the baseline after every cycle.
- Singleton and viewport signal-connection counts return to baseline, detecting accumulated callbacks.
- Weak references to replaced scene roots, UI, bike, director, worlds, cinematic stages, selected stage meshes, MultiMeshes and marking meshes expire.
- The procedural material cache empties on scene exit; only the original shared audio players/buses remain.
- No riding input, scene pause, engine state or first-night music cue survives final disposal.
- Practice leaves both in-memory story state and saved bytes unchanged; Continue at completion does not rewrite the checkpoint.

Results are written to `user://lifecycle_report.json`, located under `.godot-test/Godot/app_userdata/PULANG/` with the Windows helper. The report records the engine/backend, cycles, checks/failures, and snapshots at the empty baseline, each final menu and each empty-tree cleanup. It includes node/orphan/object/resource counts, signal subscriptions, cache size, audio pool size and Godot static-memory usage. Native runs also include the renderer's reported video-memory counter.

Logs are in `.godot-test/LifecycleTests.log`. Each run replaces the report/log; copy them if retaining comparisons. The suite adds no production singleton, save field or gameplay UI, and tests/tools remain excluded from exports.

Godot's object/resource/memory counters are observational: engine caches can warm up, monitor values can lag, and Compatibility memory counters may be unavailable or zero. Static memory is not the process working set. The harness does not assert byte-for-byte memory equality or claim a general absence of memory leaks. Node counts, signal counts and watched resource lifetimes are the pass/fail evidence.

## Remaining acceptance

- [x] Repeat actual story/practice scene replacements, interrupt an opening, and restore a completed checkpoint.
- [x] Check local scene-resource, input, audio, signal and save cleanup.
- [ ] Run long-duration natural-speed gameplay and scene transitions in actual Web and Android exports.
- [ ] Measure OS/process and GPU memory with platform tools, including warm-up and recovery after repeated loads.
- [ ] Verify real browser-tab/mobile lifecycle events, audio focus and storage behavior.
- [ ] Meet frame-time, device-temperature and riding-comfort gates.

Recorded run results are in [VALIDATION.md](VALIDATION.md).
