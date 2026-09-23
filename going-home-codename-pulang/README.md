# PULANG

A quiet first-person motorcycle journey across Java. Built in **Godot 4.7.2 Stable**, GDScript, **Compatibility** renderer.

This repository now contains a **playable development slice**, from the Jakarta opening through the first night in Karawang. It is an early implementation of M0–M5 systems, not the full 8–12 hour game or a production-approved M5. The roadmap's platform, riding-comfort, art, and pacing gates remain open. Later chapters are represented only on the route map; they are not playable yet.

## Run

1. Import `project.godot` in Godot **4.7.2 Stable**.
2. Press **F6** only when testing a specific scene; use **F5** to play the game.
3. Select **Begin a new journey**. Continue is enabled when a readable checkpoint exists.

For the new M1 riding track, select **Practice ride** on the title menu. It is available immediately and leaves your story save untouched.

The engine supplied for this workspace is:

```powershell
& 'D:\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe' --path .
```

No external addons, accounts, network connection, or asset downloads are required to run in the editor.

## Playable flow

Apartment morning → short first-person commute → restructuring meeting → mother's call → packing/departure → 1.8 km compressed roadside route → rain shelter and conversation → guesthouse → authored journal reflection → chapter ending.

Optional stops: fuel station and rice-field turnout. Shelter is required before resting. Stop near the green roadside signs and interact. If a stop is missed, the recovery action and the guesthouse's return-to-shelter behavior prevent a progression trap.

Allow roughly **8–15 minutes** for a first unhurried run, depending on stops and reading. This is an estimate, not a measured playtest result. The roadmap's 30–60 minute polished vertical slice remains a later pacing/content target.

## Riding practice · M1 update

The separate **720 m practice road** includes a straight, a gentle bend, tighter bends, a four-meter rise/descent, small physical bumps, a quiet intersection, and a shelter/stop area. It uses the same motorcycle controller and keyboard/touch actions as the story.

- Use **Sections** to revisit a section, or ride from the start to the shelter.
- Brake at the shelter and interact to switch off the engine; choose **Ride the road again** to repeat.
- Open **Pause → Settings & accessibility** to compare riding assist, reduced motion, FOV, or a 30 FPS limit.
- The pause menu also lets you switch clear/rain weather, recover to the road, and save a local playtest report.
- Reports are JSON files in `user://ride_reports/`. They record riding time/distance, contacts, recoveries, camera roll, settings, and a bounded window of frame timings. Pauses and section jumps are excluded from riding metrics. Reports never write to the journey save and are not uploaded.

Steering assist now follows the upcoming road toward the left lane. Solid obstacles cause a forgiving stop, and recovery uses the active route. Distance/fuel tracking uses actual movement rather than requested motor speed.

Use the [M1 playtest guide](docs/test/M1_PLAYTEST.md) for the remaining human comfort review. Automated physics checks and reports do not assess nausea or declare the milestone accepted.

Local validation for this update: **93 story checks + 34 practice checks passed** at both 60 and 30 fixed render cadences. The **34 practice checks also passed in a native rendered run capped at 30 FPS**. The updated resource PCK exports and boots the practice scene; this does not replace a Web/Android export test.

## Input and layout · M2 update

Open **Controls** from the title or either pause menu, or **Settings & accessibility → Keyboard controls**. Select an action and press a single key to replace its shortcuts. Escape cancels capture; **Restore default keyboard controls** brings back every default. Preferences survive restarts and new journeys in the separate settings file.

Riding, glance, interaction, phone/journal/route, and recovery controls can be changed. Conflicting keys are rejected; other actions' defaults stay reserved so restoring defaults remains predictable. Escape, Enter, and cinematic Space remain fixed. Modifier combinations and function keys are excluded. Bindings use physical key positions; this is a basic keyboard remapping system, not controller or per-layout key localization support.

Interaction and phone notification hints follow the selected controls or switch to touch instructions. Touch buttons now follow the safe UI rectangle, release on hiding/backgrounding/resizing, and support dragging out of and back into a control. Unrelated touches no longer release keyboard actions. The interaction button sits above the riding controls. On Android, the UI uses the reported display safe area; simulated inset/aspect-ratio tests are covered locally, while real notch and touch ergonomics validation remains pending.

M2 validation covered **93 story + 34 practice + 44 input checks (171 total)**. See the [validation record](docs/test/VALIDATION.md) and [M2 platform checklist](docs/test/M2_PLAYTEST.md). M2 remains in progress until browser and physical Android gates pass.

## Phone and story inspection · M3 update

Messages now arrive through a separate `PhoneDataService`, using story conditions and `delay_seconds` in `data/phone/messages.json`. Delivery time advances during riding, scenic stops, and the chapter ending; cutscenes, dialogue, transitions, pause, and open menus freeze it. Delivered messages wait for a free banner slot and appear in delivery order. The Phone button shows an unread count; opening the inbox marks delivered messages read and suppresses their queued banners.

Delivered/read/replied messages, displayed notices, and remaining delivery delays are part of the journey save. Message arrival, banner display, reading, and replying save quietly without replacing the banner with a checkpoint toast. Continue retains the stable story checkpoint. A delay resumes from the last saved value rather than counting time while the game is closed. Existing v1 saves migrate automatically; already read/replied messages do not notify again. A banner hidden by a new dialogue or menu is considered shown; its message remains in the inbox.

For development, launch a debug/editor game with:

```powershell
& 'D:\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe' --path . -- --story-debug
```

**Story debug** then appears on the story title/pause menus. It provides a read-only snapshot of chapter/checkpoint, searchable flags, dialogue state, and phone delivery state. Refresh updates the snapshot. It cannot edit flags or save progress, is absent from normal launches and practice mode, and is disabled in release builds. See the [M3 test guide](docs/test/M3_PLAYTEST.md) for authoring and acceptance checks.

Final local validation: **93 story + 34 practice + 44 input + 58 narrative = 229 checks passed** at a fixed 30 render cadence. The native narrative suite with the viewer enabled also passes **61 checks**, including the unread badge staying inside the screen at an actual 30 FPS cap. Real Web/Android narrative and save acceptance remains open.

## Light and weather · M4 update

Eight editable Godot resources in `data/weather/` now define **Morning, Overcast, Drizzle, Rain, Heavy rain, Morning mist, Golden hour, and Night**. Sky, directional light, ambient color, fog, rain density, and road wetness blend over three seconds. Selecting another profile cancels the old transition; pause freezes it. The effects use Compatibility-friendly fog, a bounded rain overlay, and simple road materials.

Use **Practice ride → Pause → Light & weather** to compare profiles on the same road. A selection resumes the ride; section changes retain the chosen mood. The existing clear/rain shortcut remains available. Local practice reports include the selected profile, and practice never writes to the story save.

Karawang now moves through morning → overcast → drizzle → rain/heavy rain → clearing drizzle → golden hour using authored distance cues. Rest/reflection and Continue at the completed chapter use night. Night adds a motorcycle headlight, warm lamps at stops, and an original synthesized insect loop; rain volume follows its intensity and birds fade out at night. These remain prototype audio and lighting, with final recordings, art review, and music still pending.

See the [M4 visual/audio review guide](docs/test/M4_PLAYTEST.md). This update does not close the human art, audio, comfort, or target-platform performance gates.

Local validation: **281 combined checks passed** at a fixed 30 render cadence; **52 mood checks also passed with native rendering capped at 30 FPS**. All eight profiles and the comparison menu were inspected in rendered screenshots. Human listening and real Web/Android profiling remain pending.

## Controls (defaults)

| Action | Keyboard |
| --- | --- |
| Accelerate | W / Up |
| Brake | S / Down / Space |
| Steer | A / D or Left / Right |
| Glance | Q / R |
| Interact while stopped | E |
| Advance focused dialogue button | Enter |
| Phone / Journal / Route | Tab / J / M |
| Pause / Back | Escape |
| Recover to road | Backspace |
| Skip cinematic | Hold Space, or click Skip scene |

Touch controls use the same input actions and track multiple fingers. They appear on touch devices, or can be enabled in Settings. The mouse controls all menus. Photo mode is reserved in the input map but intentionally not implemented in this P0/P1 prototype.

## Implemented systems

- CharacterBody3D motorcycle, gradual throttle, braking, speed-sensitive steering, optional assist, forgiving road recovery, three ground probes, visual lean, stable first-person camera, adjustable FOV.
- Original low-poly Thunder 250-inspired placeholder exterior/cockpit, analog needle, simplified static mirrors, tank, hands, forks, round headlamp, exposed engine, intact seat.
- Deterministic authored road assembly, rice fields, utility poles, homes, warung, fuel stop, guesthouse, ambient traffic, authored rain and lighting transitions.
- External JSON dialogue, branching choices and conditions, namespaced flags, cutscene shot sequences, deterministic skip handoff, phone replies, journal choices.
- One active save slot, schema v1, verified temporary writes, backup fallback for a corrupt primary save. Settings have a separate ConfigFile.
- Pausing on focus loss/backgrounding, touch release cleanup, reduced motion, dialogue text sizing, volume sliders, 30 FPS limit, quality presets.
- Original synthesized placeholder engine/road/rain/bird loops; audio starts after a user interaction. No final recorded motorcycle or regional ambience assets yet.

## Development roadmap

Based on the [Development Roadmap v1](../PULANG_Development_Roadmap_v1.md). Status last reviewed: **2026-09-24**.

**Legend:** `[x]` = implemented at the stated scope; `[ ]` = unfinished or awaiting validation. A completed prototype task does not mean its entire milestone has passed acceptance. **M0–M5 are in progress; M6–M14 have not started. No milestone is fully accepted yet.**

### M0 — Project Foundation · In progress

- [x] Configure Godot 4.7.2, GDScript, Compatibility renderer, landscape baseline, and project folders.
- [x] Implement boot, main menu, core services, separate settings persistence, and setup documentation.
- [x] Add Web and Android Debug export presets; export and boot the resource PCK locally.
- [ ] Install matching export templates and configure the Android JDK/SDK.
- [ ] Launch actual Web and Android builds and verify setup on a clean machine.

### M1 — Motorcycle Feel Prototype · In progress

- [x] Implement first-person riding, acceleration, braking, steering, ground probes, and road recovery.
- [x] Add prototype cockpit/instruments, engine loops, FOV settings, riding assist, and reduced motion.
- [x] Test movement, braking, steering, ground contact, and pause behavior automatically.
- [x] Complete the dedicated test track with straights, gentle/tighter curves, slope, physical bumps, an intersection, and a stop area.
- [x] Add section selection, clear/rain comparison, repeat rides, and local playtest reports without changing story saves.
- [x] Test continuous track traversal, collision response, route-aware recovery, pause, and save isolation automatically.
- [ ] Pass human 5-minute and 15-minute riding tests, including comfort and handling at 30 FPS.

### M2 — Platform & Input Prototype · In progress

- [x] Implement named input actions, WASD/arrows, keyboard/touch detection, and multitouch controls.
- [x] Test simultaneous touch steering/acceleration and release cleanup in the local integration suite.
- [x] Add persistent keyboard remapping, conflict validation, cancel/reset controls, and input-aware interaction/phone hints.
- [x] Add safe-area UI insets, responsive touch-zone layout, and cleanup on hiding, resizing, focus loss, and backgrounding.
- [x] Test remapped physical keys in the shared bike controller, settings persistence, touch event routing, and simulated 16:9, 20:9, and 4:3 safe rectangles.
- [ ] Validate browser keyboard focus, fullscreen, audio activation, and save persistence in an iframe.
- [ ] Validate touch ergonomics, safe areas, and the same gameplay loop on physical Android devices.

### M3 — Narrative Systems Prototype · In progress

- [x] Implement external dialogue data, choices, conditions, story flags, and stop interactions.
- [x] Implement phone messages/replies, authored journal choices, and checkpoint save/load with backup recovery.
- [x] Implement cinematic shot sequencing and deterministic skip/control handoff.
- [x] Test the encounter → journal → save → reload sequence and dialogue references.
- [x] Add delayed phone delivery, serialized banners, unread counts, and persistent delivery/read/reply state with legacy-save migration.
- [x] Add an opt-in, read-only story-flag debug viewer with filtering and refresh.
- [x] Test delivery locks, queue order, save/reload deduplication, malformed phone state, and the encounter → message/reply → journal sequence.
- [ ] Validate narrative/save behavior in real Web and Android builds.

### M4 — Visual & Audio Mood Prototype · In progress

- [x] Build the low-poly roadside kit: fields, trees, poles, homes, warung, fuel stop, guesthouse, and traffic.
- [x] Add a Thunder 250-inspired placeholder bike, clear/rain transitions, and layered synthesized audio.
- [x] Implement authored morning, overcast, golden-hour, and night profiles plus drizzle, rain, heavy rain, and mist.
- [x] Blend sky/light/fog/wetness/rain; add a practice comparison menu, night headlight/stop lamps, and synthetic insect ambience.
- [x] Test transition interruption/pause, rain quality limits, chapter profile restoration, and practice save isolation.
- [ ] Refine hero bike and character art; add recorded motorcycle/regional ambience and the first music cue.
- [ ] Review visual identity and sound quality, and profile actual target-platform builds.

### M5 — Vertical Slice · In progress

- [x] Connect Jakarta opening → commute → layoff → mother's call → departure → first road segment.
- [x] Connect optional stops → rain shelter/conversation → guesthouse → journal → chapter ending.
- [x] Test the compact desktop flow, checkpoint recovery, and Continue through completion.
- [ ] Expand and playtest pacing toward the planned 30–60 minute slice.
- [ ] Finish production-quality opening cutscenes, character animation, hero assets, and audio.
- [ ] Pass browser, Android, performance, riding-comfort, and narrative acceptance gates.

**Production gate:** do not begin full chapter production until the M5 riding, platform, narrative, and art issues are resolved.

### M6 — Production Toolkit · Not started

- [ ] Create reusable authoring templates for chapters, NPCs, and cutscenes.
- [ ] Expand the existing basic content checks into the full reference/localization/audio validator.
- [ ] Add a development-only menu for chapter jumps, weather/time, flags, checkpoints, and performance.
- [ ] Verify that a new encounter can be authored without changing global core code.

### M7 — Chapter Production Wave 1 · Not started

- [ ] Produce the final Karawang chapter beyond the current prototype.
- [ ] Produce Cirebon, Tegal, Pekalongan, and Semarang.
- [ ] Complete each chapter's narrative, environment, audio, cutscenes, saves, and platform playtests.

### M8 — Chapter Production Wave 2 · Not started

- [ ] Produce Salatiga, Solo, Ngawi, Madiun, and Kediri.
- [ ] Produce Malang, Lumajang, Jember, Banyuwangi, and the family-home epilogue.
- [ ] Validate the complete route and preserve the restrained homecoming ending.

### M9 — Full Game Alpha · Not started

- [ ] Make every main chapter, mandatory cutscene, transition, and ending playable without debug tools.
- [ ] Review story continuity, English text, flags, and saves across chapters.
- [ ] Complete the campaign in Web and Android builds with no progression blockers.

### M10 — Content Complete / Beta · Not started

- [ ] Lock major content and polish riding, dialogue pacing, visuals, audio, UI, and accessibility.
- [ ] Run the planned player-category playtests, including Indonesian and motion-sensitive players.
- [ ] Resolve findings and verify readable, comfortable touch and desktop experiences.

### M11 — Optimization & Release Candidate · Not started

- [ ] Profile Web loading, memory, draw calls, particles, and scene unloading.
- [ ] Profile Android thermals, battery, frame pacing, startup, and resume behavior.
- [ ] Validate Low/Medium/High presets and meet the zero-blocker/zero-critical release gate.

### M12 — itch.io Launch · Not started

- [ ] Prepare cover art, screenshots, trailer, descriptions, controls, and browser requirements.
- [ ] Package a release Web build with `index.html` at the ZIP root and configure the itch.io page.
- [ ] Pass fresh-browser launch, sound, fullscreen, save/reload, and Continue tests before release.

### M13 — Google Play Launch · Not started

- [ ] Finalize package identity, versioning, icons, release signing, and AAB export.
- [ ] Prepare store assets, privacy/content declarations, and verify submission requirements.
- [ ] Pass device-matrix, install/upgrade, lifecycle, and save-compatibility tests before release.

### M14 — Post-Launch Support · Not started

- [ ] Prioritize crash, progression, save, rendering, and control fixes from release feedback.
- [ ] Preserve save compatibility and regression-test patches.
- [ ] Consider optional features and quality-of-life improvements after stability is established.

See [Implementation status](docs/IMPLEMENTATION_STATUS.md) for concrete follow-up tasks and [Validation record](docs/test/VALIDATION.md) for test evidence and platform limitations. Update these checkboxes when implementation or acceptance evidence changes.

## Architecture

`scripts/boot.gd` orchestrates the local scene flow. The global services are limited to game state, saving, input mode, audio, and dialogue. World, bike, scene transitions, cinematic director, interaction scanner, and UI have separate scripts.

`scenes/chapters/` contains separately instantiated prologue and Karawang worlds. `scenes/practice/RidingPractice.tscn` is the separate M1 track. `RidingRoute` supplies route samples to both practice geometry and the shared bike controller; practice disables journey-stat recording. Most placeholder geometry is assembled by reusable mesh builders at runtime; open the game to see it. These builders are a small fixed environment kit, not an open-world city generator. Final artist-authored models can replace them without changing the narrative data.

Content lives under `data/chapters`, `data/dialogue`, `data/phone`, and `data/cutscenes`. Public IDs are part of the save contract. Do not rename them without an explicit migration.

## Validation

From this project directory:

```powershell
powershell -ExecutionPolicy Bypass -File tools/test.ps1
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Practice -FixedFps 30
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Practice -Visual -FixedFps 30
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Input -Visual
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Narrative -StoryDebug -Visual
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Mood -Visual -FixedFps 30
```

The helper isolates all test saves in `.godot-test/`. **Do not run the test scenes against your normal user profile**: their corruption and new-game cases deliberately replace the test save. The default `-Suite All` runs story, practice, input, narrative, and mood sequentially; use `-Suite Story`, `Practice`, `Input`, `Narrative`, or `Mood` to select one. `-StoryDebug` enables additional viewer checks in the narrative suite. Headless `-FixedFps` changes simulated render cadence; with `-Visual`, it sets the actual native FPS cap. Physics remains at 60 ticks per second. The helper fails on script errors or a missing success summary, even if the engine exits with code zero.

The story suite exercises content references, conditions, schema validation, corrupt-save fallback, opening/skip handoff, physical throttle/brake/steering, ground contact, pause, every stop, multitouch action handling, journal persistence, and Continue. The practice suite drives the full track under physics, checks solid-obstacle response, recovery, metrics, save isolation, and real title/practice scene transitions. `-Visual` also captures rendered screenshots under `tests/screenshots/` (ignored by Git). See [Validation record](docs/test/VALIDATION.md) for results and outstanding platform work.

## Export

Presets are provided for **Web** (single threaded) and **Android Debug** (landscape, arm64). JSON content is explicitly included. Test scenes, tools, screenshots, and docs are excluded.

Matching **4.7.2 export templates are not installed in the supplied environment**, so no working HTML5 or APK build is claimed. Android also needs a configured supported JDK/SDK. Install the matching templates through Godot, configure Android export settings, and then run:

```powershell
New-Item -ItemType Directory -Force export/web, export/android
godot --headless --path . --export-release Web export/web/index.html
godot --headless --path . --export-debug 'Android Debug' export/android/pulang-debug.apk
```

The package ID is a development placeholder. No release credentials, signing keys, store upload, or production AAB configuration is included. Platform acceptance requires real browser and Android testing; native desktop results do not substitute for it.

## Design references and scope

The parent folder contains `PULANG_GDD_Revised_v2.md`, `PULANG_TDD_v1.md`, and `PULANG_Development_Roadmap_v1.md`. Canon is preserved: Raka is competent, loses his role through restructuring, has further career options, and chooses to go home to Banyuwangi. All playable text is English. No racing, combat, moral scores, or Bali continuation.

The next production work and unfulfilled requirements are tracked in `docs/IMPLEMENTATION_STATUS.md`. Asset provenance is in `LICENSES/README.md`.
