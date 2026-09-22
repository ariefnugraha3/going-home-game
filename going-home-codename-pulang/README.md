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

## Controls

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

Based on the [Development Roadmap v1](../PULANG_Development_Roadmap_v1.md). Status last reviewed: **2026-09-23**.

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
- [ ] Validate browser keyboard focus, fullscreen, audio activation, and save persistence in an iframe.
- [ ] Validate touch ergonomics, safe areas, and the same gameplay loop on physical Android devices.

### M3 — Narrative Systems Prototype · In progress

- [x] Implement external dialogue data, choices, conditions, story flags, and stop interactions.
- [x] Implement phone messages/replies, authored journal choices, and checkpoint save/load with backup recovery.
- [x] Implement cinematic shot sequencing and deterministic skip/control handoff.
- [x] Test the encounter → journal → save → reload sequence and dialogue references.
- [ ] Add the notification queue and story-flag debug viewer.
- [ ] Validate narrative/save behavior in real Web and Android builds.

### M4 — Visual & Audio Mood Prototype · In progress

- [x] Build the low-poly roadside kit: fields, trees, poles, homes, warung, fuel stop, guesthouse, and traffic.
- [x] Add a Thunder 250-inspired placeholder bike, clear/rain transitions, and layered synthesized audio.
- [ ] Complete morning, overcast, golden-hour, and night lighting variants plus drizzle/full-rain treatment.
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
```

The helper isolates all test saves in `.godot-test/`. **Do not run the test scenes against your normal user profile**: their corruption and new-game cases deliberately replace the test save. The default `-Suite All` runs story and practice sequentially; `-Suite Story` or `-Suite Practice` selects one. Headless `-FixedFps` changes simulated render cadence; with `-Visual`, it sets the actual native FPS cap. Physics remains at 60 ticks per second. The helper fails on script errors or a missing success summary, even if the engine exits with code zero.

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
