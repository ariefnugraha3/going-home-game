# Validation record

## M1 update · 2026-09-23

Same Godot 4.7.2 build and native hardware as the initial record below. The new practice suite drives the complete route under physics rather than teleporting past bends, grades, or bumps.

| Check | Result |
| --- | --- |
| Story regression suite, fixed render cadence at 60 and 30 | **93 checks, 0 failures** per run |
| Practice suite, fixed render cadence at 60 and 30 | **34 checks, 0 failures** per run |
| Native practice suite with actual 30 FPS cap | **34 checks, 0 failures** |
| Combined headless suites | **127 checks, 0 failures** |
| Complete assisted practice-road traversal | No automatic recovery; maximum lateral distance from road center **3.006 m** on a road with 5 m half-width; maximum bike/road height difference **0.057 m** |
| Reduced-motion camera through full track | Zero camera roll |
| Practice/story isolation | Story snapshot and journey file unchanged; title → practice → title scene replacement verified |
| Render inspection at 1280×720 | Practice entry, cockpit, tight curve, shelter, sections, settings, rain/touch overlay inspected |
| Updated PCK export and packed practice-scene boot | Pass; 475,276-byte resource pack, practice JSON/scripts/scene included, headless scene boot exits 0 after 120 frames |
| Human 5/15-minute comfort sessions | **Pending**; use [M1 playtest guide](M1_PLAYTEST.md) |
| Real browser and physical Android | **Pending**; matching export templates remain unavailable |

Additional regressions cover an intentional solid-barrier collision, stopping without tunneling or false cruising speed, left-lane recovery, recovery after a fall, assist disabled, bounded camera lean, pause/time exclusion, throttle cleanup, weather/ambience switching, and local report serialization. Section jumps are excluded from distance; reports never replace story saves. Only the automatic full-track segment has zero recoveries; the later test deliberately exercises recovery twice.

The test helper now supports `-Suite Story|Practice|All`, `-FixedFps 30|60`, and `-Visual`. It rejects script errors and missing success summaries even when Godot exits zero. Scene-navigation tests await completed scene replacement rather than assuming a fixed number of physics ticks is sufficient at 30 FPS.

Headless `--fixed-fps` is a simulation-cadence check, not measured rendering performance. The native test uses `Engine.max_fps = 30`, keeps physics at 60 Hz, and captures actual rendered output. Neither is a physical Android benchmark or human comfort assessment.

## Initial slice · 2026-09-22

Date: 2026-09-22. Engine: **4.7.2.stable.official.ed1daf0bf**. Renderer: Compatibility / OpenGL 3.3. Native visual test hardware: NVIDIA GeForce RTX 3050 Laptop GPU on Windows.

## Executed

| Check | Result |
| --- | --- |
| Headless editor import | Pass; no GDScript parser errors or missing game assets |
| Automated suite | **93 checks, 0 failures** |
| Native rendered integration run | **93 checks, 0 failures**; complete Jakarta-to-Karawang flow |
| Viewport inspection | 1280×720 and 1280×600; menu, cinematic, cockpit, dialogue, phone, map, journal, completion screenshots |
| PCK resource export with Web preset | Pass; JSON, scenes, scripts and audio included; tests/tools excluded |
| Boot exported PCK from outside project directory | Pass; engine exits 0 after 120 frames without missing game resources |
| Complete Web export | Blocked: missing `web_nothreads_debug.zip` / `web_nothreads_release.zip` for 4.7.2 |
| Android Debug export | Blocked: missing 4.7.2 `android_debug.apk` / `android_release.apk`; SDK build tools also need updating/configuration |
| Browser, itch.io iframe, physical Android | Not tested |
| Human comfort, final sound mix, narrative pacing | Not accepted; requires human playtesting |

The isolated Windows tool environment logs `Failed to read the root certificate store` at engine startup. The offline game and tests continue normally. This is not counted as a game parser/runtime error. No browser/network success is inferred from these runs.

Headless validation intentionally does not start audible audio streams; rendered runs exercise audio initialization and shutdown. An initial dummy-mixer shutdown resource warning was addressed by keeping headless validation audio-free.

## Test coverage

- Every dialogue start/next/choice target exists; condition checks accept/reject the correct flags.
- Fresh save, replacement save, backup, malformed schema, unknown future schema, missing phone data, malformed journal entry, corruption recovery.
- New Game → opening skip → commute, throttle physically moves the bike, brake stops it, left steer changes heading, ground contact on grade.
- Pause blocks movement; opening/office/departure skip restores deterministic state and control.
- Layoff and mother's call maintain canonical flags, including the quiet reply branch.
- Fuel, scenic engine-off, rain, shelter conversation, phone pause, multitouch steering+throttle, touch release.
- Guesthouse → reflection → save → return to title → Continue restores completion and journal.

The integration test uses direct checkpoint placement between some encounters to keep regressions quick. It is not a substitute for riding every meter, testing every branch interactively, or human 15-minute comfort sessions.

## Reproduce safely

Run `tools/test.ps1` or `tools/test.ps1 -Visual` from PowerShell. The helper imports first, isolates APPDATA to `.godot-test`, and restores the environment afterward. Never launch the corruption tests against a real player's save folder.

The initial delivered PCK is `export/web/pulang.pck` (ignored build artifact, approximately 446 KiB). It is a Godot resource pack, **not** a playable HTML5 distribution. Rebuild after editing using `--export-pack Web export/web/pulang.pck`.

## Required platform gate

- Install matching export templates; Web page launch and audio activation from a genuine user gesture.
- Chrome, Firefox, Edge, embedded/fullscreen keyboard focus, browser reload, storage persistence.
- Two physical Android performance classes, touch control at different aspect ratios, safe area, app suspend/resume, kill/relaunch.
- Low/Medium/High real-export profiling, 30 FPS feel, 15-minute comfort tests, thermal behavior.
- Final art/cutscene/narrative review before M5 acceptance or mass chapter authoring.
