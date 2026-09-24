# Validation record

## M4 audio update - 2026-09-24

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility. Native checks use Windows / NVIDIA RTX 3050 Laptop GPU.

| Check | Result |
| --- | --- |
| Headless regression suites, fixed 30 render cadence | **93 Story + 34 Practice + 44 Input + 58 Narrative + 52 Mood + 48 Audio = 329 checks, 0 failures** |
| Native Audio suite, actual 30 FPS cap | **50 checks, 0 failures**; real stream playback/pause and preserved loop position |
| Audio lifecycle | Activation gate, no ignition replay on pause, cue clock freeze, background mute, resume, title cleanup and Continue without replay |
| Location/weather mix | City-to-field traffic crossfade; warung crockery; sheltered rain only when wet; stopped riding wind fades out; bounded long-frame interpolation |
| Music | Original 24-second non-looping first-night phrase; no duplicate cue while active; journal retains it; completion returns to silence |
| Settings/save | Music/SFX persistence and independent mute; zero actually mutes; settings leave journey save untouched |
| Practice | Ignition at entry, pause without restart, shelter cooldown once even on repeated interaction, ignition after repeating ride |
| Source media | Six new mono 22,050 Hz WAVs reproduce byte-for-byte; peak amplitudes below clipping and zero-valued endpoints |
| UI inspection | Music and Sound effects sliders inspected in the scrollable native settings panel at 1280 x 720 |
| Resource PCK export and isolated boot | **Pass**, 1,117,800 bytes; new soundscape JSON and all six added audio resources included; main scene exits 0 after 120 frames outside the source project |
| Human listening and real Web/Android lifecycle | **Pending**; see [M4 listening checklist](M4_PLAYTEST.md) |

The combined suites passed, then the affected Audio/Practice suites were rerun after adding the repeated-shelter interaction guard and its regression checks. Final native Audio log: `.godot-test/AudioTests-native30.log`; screenshot: `tests/screenshots/audio_settings.png` (ignored). No game parser/runtime errors in final runs. The existing sandbox certificate-store startup error does not affect these offline checks.

Headless tests exercise cue state, timing and target volumes without starting the dummy audio mixer. Native tests additionally exercise real player playback and suspension. Neither constitutes listening acceptance or mobile/browser performance evidence. All twelve audio sources remain synthesized prototypes; final vehicle/regional recordings and mix review are open. The PCK is a resource package, not a playable HTML5/APK build; matching export templates remain unavailable.

## M4 mood update · 2026-09-24

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility. Native render checks use Windows / NVIDIA RTX 3050 Laptop GPU.

| Check | Result |
| --- | --- |
| Combined headless suites at fixed 30 render cadence | **93 Story + 34 Practice + 44 Input + 58 Narrative + 52 Mood = 281 checks, 0 failures** |
| Native Mood suite at an actual 30 FPS cap | **52 checks, 0 failures** |
| Authored resources | Eight profiles load; sky/light/rain targets agree; chapter cues reference valid profiles in distance order |
| Transitions | No initial material snap; pause freezes blend; rapid selection cancels stale tween; dry material restored |
| Rain/audio | Drizzle has fewer streaks and lower rain volume target than heavy rain; Low caps streaks at 44; night selects insect ambience |
| Night and restore | Motorcycle beam and warm stop lights active; completed checkpoint restores Night; title/practice exit clears night audio target |
| Save isolation | Practice choices and local reports preserve journey state/file; report includes selected weather profile |
| Native inspection | All eight profiles and chooser captured at 1280×720; night beam on/off compared; dry profiles clear rain overlay |
| Resource PCK export and isolated packed boot | Pass; **609,724 bytes**, all eight weather resources and insect audio included; main scene boots outside the source project and exits 0 after 120 frames |
| Human visual/mix acceptance and real Web/Android profiling | **Pending**; use [M4 review guide](M4_PLAYTEST.md) |

Run `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Mood -Visual -FixedFps 30`. Native screenshots are local ignored artifacts under `tests/screenshots/mood_*.png`; the native log is preserved as `.godot-test/MoodTests-native30.log`. The screenshot harness explicitly refreshes rain drawing when switching profiles without the normal Boot update loop, preventing stale rain in dry-profile captures.

The six synthesized audio sources are reproducible from the standard-library generator. Existing WAV bytes and import UIDs were preserved; only the new insect source is added. Audio target/playback initialization checks do not constitute a human sound-mix review. No game parser/runtime errors occurred in the final runs; the existing sandbox certificate-store startup message remains.

The rebuilt `export/web/pulang.pck` is an ignored resource package, not a playable HTML5 build. Matching Web/Android export templates and real target-platform acceptance are still pending.

## M3 narrative update · 2026-09-23

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility, Windows / NVIDIA RTX 3050 Laptop GPU for the rendered check.

| Check | Result |
| --- | --- |
| Final combined headless suites, fixed 30 render cadence | **93 Story + 34 Practice + 44 Input + 58 Narrative = 229 checks, 0 failures** |
| Native Narrative with `-StoryDebug -Visual -FixedFps 30` | **61 checks, 0 failures** |
| Delayed queue and locks | Repeated flags do not reset delay; cutscene/dialogue/fade/pause block delivery; busy toast slot defers notices; one banner at a time |
| Save/reload | Remaining delay, delivered order, shown/read/replied state persist; legacy read/replied v1 messages migrate without repeat banners; malformed phone state rejected |
| Save failure | Invalid snapshot intentionally rejects a quiet save; notice stays queued and retries successfully after state is valid |
| Integrated encounter | Shelter → delayed Dad message → reply → guesthouse → journal → reload preserves chapter, phone and reflection |
| Viewer | Disabled on ordinary startup; explicit debug opt-in enables filter/refresh; snapshot and journey file remain unchanged |
| Native render inspection | Banner, unread badge, scrollable inbox and debug panel inspected at 1280×720; badge expansion no longer pushes pause outside viewport |
| Human narrative review / real browser / physical Android | **Pending**; use [M3 guide](M3_PLAYTEST.md) and existing platform checklist |

Reproduce with `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite All -FixedFps 30`, then `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Narrative -StoryDebug -Visual -FixedFps 30`. Narrative has three additional checks when the viewer is enabled. Native screenshots are ignored artifacts in `tests/screenshots/narrative_*.png`; the rendered run log is preserved locally as `.godot-test/NarrativeTests-native30.log`.

The final run has no game parser/runtime errors. The existing sandbox certificate-store startup message remains. Headless fixed cadence is not an FPS performance measurement. Release-build gating is implemented using `OS.is_debug_build()` but a real release export remains untested without matching templates.

## M2 input update · 2026-09-23

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility renderer, Windows. This delivery adds basic keyboard remapping and touch/safe-area improvements; it does not close platform acceptance.

| Check | Result |
| --- | --- |
| Headless story / practice / input suites at fixed 60 and 30 render cadences | **93 + 34 + 44 = 171 checks, 0 failures** per combined run |
| Native rendered input suite | **44 checks, 0 failures**; Controls menu and wide touch layout inspected |
| Physical key remapping | Captures while paused; conflict/modifier rejection; Escape cancel; reset; old key stops driving, replacement drives shared controller |
| Persistence and invalid input settings | Settings reload/new-journey preservation; unknown actions, invalid types and reserved keys safely ignored; journey file unchanged |
| Synthetic multitouch events | Simultaneous steering/throttle; independent finger release; drag out/reentry; hidden-menu rejection; background/focus cleanup |
| Simulated safe rectangles | 1280×720, 1600×720, 1280×960 with cutout insets; root bounds, nonoverlapping controls and interaction placement checked |
| Browser iframe and physical Android | **Pending**; use [M2 checklist](M2_PLAYTEST.md) after installing/configuring matching export templates |

Run `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Input -Visual` for the focused rendered suite. `-Suite All` now includes Input alongside Story and Practice, sequentially in isolated storage. Key preferences are restored to defaults when the input test ends.

Synthetic touch events are injected in window pixels and converted by Godot's viewport stretch transform; the first test draft used logical coordinates and was corrected before the successful runs. The Android display-safe-area API branch still needs a real device: desktop inset simulation validates layout math, not the platform's reported cutout rectangle or physical button ergonomics. One initial native shutdown reported resource-lifetime warnings; a verbose repeat exited cleanly without reproducing them. The existing sandbox certificate-store startup message remains as documented below.

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
