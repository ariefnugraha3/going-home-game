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

## Working analog cockpit · M1/M4 update, 2026-09-27

The motorcycle now has two working analog dials: **speed in km/h** and **RPM ×1000**, with larger numbers, major/minor ticks, needle hubs and a cluster tilted toward the rider. The existing camera/FOV and numeric speed HUD remain available. Use the downward-glance control to inspect the instruments; this is still a prototype cluster rather than a reference-approved Thunder model.

Speed follows the riding controller. RPM eases between idle, throttle and cruising values for the game's relaxed automatic riding model; it does not introduce gear shifting or affect handling/audio. Stopping clears both needles immediately, recovery returns to zero speed and powered idle, and Pause holds the current readings. The same behavior applies in story and Practice ride, including Continue.

At night the dial markings and needles illuminate with the active motorcycle headlight. Turning the engine off or stopping extinguishes the panel. Each motorcycle owns its instrument materials, so riding lights cannot illuminate parked/cinematic bikes. No extra light, viewport, shader, texture download or save field is required.

Compare **Practice ride → Pause → Light & weather → Morning / Night**. Human readability across phone sizes/FOV settings and final motorcycle art remain open in the [cockpit review guide](docs/test/M4_PLAYTEST.md#analog-cockpit-review).

Local validation: **723 combined checks passed** at fixed 30 render cadence, including **30 cockpit checks**. The same 30 checks passed in native Godot capped at 30 FPS; forward/downward day and night views and the unpowered panel were inspected. The resource PCK exports and boots independently. Physical readability, final bike art and real Web/Android acceptance remain pending.

## Input and layout · M2 update

Open **Controls** from the title or either pause menu, or **Settings & accessibility → Keyboard controls**. Select an action and press a single key to replace its shortcuts. Escape cancels capture; **Restore default keyboard controls** brings back every default. Preferences survive restarts and new journeys in the separate settings file.

Riding, glance, interaction, phone/journal/route, and recovery controls can be changed. Conflicting keys are rejected; other actions' defaults stay reserved so restoring defaults remains predictable. Escape, Enter, and cinematic Space remain fixed. Modifier combinations and function keys are excluded. Bindings use physical key positions; this is a basic keyboard remapping system, not controller or per-layout key localization support.

Interaction and phone notification hints follow the selected controls or switch to touch instructions. Touch buttons now follow the safe UI rectangle, release on hiding/backgrounding/resizing, and support dragging out of and back into a control. Unrelated touches no longer release keyboard actions. The interaction button sits above the riding controls. On Android, the UI uses the reported display safe area; simulated inset/aspect-ratio tests are covered locally, while real notch and touch ergonomics validation remains pending.

M2 validation covered **93 story + 34 practice + 44 input checks (171 total)**. See the [validation record](docs/test/VALIDATION.md) and [M2 platform checklist](docs/test/M2_PLAYTEST.md). M2 remains in progress until browser and physical Android gates pass.

## Touch button sizes · M2/M5 update, 2026-09-27

Open **Settings & accessibility → Touch button size** to choose **Standard (100%)**, **Larger (125%)**, or **Largest (150%)**. The scrollable settings page includes a live, noninteractive preview. The same preference applies to story and practice riding; **Show touch controls** lets you inspect it on desktop too.

The four riding buttons and their labels scale together. Their layout fits the safe area, reducing the effective size when necessary while retaining your chosen preference. The interaction button moves above the riding controls. Resizing or changing button size releases existing touches so old finger positions cannot keep accelerating or steering. Volume changes leave held controls alone.

The preference persists in `settings.cfg`, survives New Game, and never modifies the journey checkpoint. Older settings use Standard; invalid values fall back or normalize to the supported sizes. Touch size further adjusts riding buttons within the interface scale described below; paired button positions can now be adjusted as described below. Physical Android ergonomics and browser acceptance remain pending in the [M2 checklist](docs/test/M2_PLAYTEST.md).

Local validation: **590 combined checks passed** at fixed 30 render cadence, including **79 input checks**. The same 79 input checks passed in native Godot capped at 30 FPS, with the settings preview and large-button layouts inspected at 1280×720, 1600×720 and 960×540 window sizes. Automated touch input and desktop captures do not establish physical-device comfort.

## Touch button positions · M2 update, 2026-09-27

Open **Settings & accessibility → Touch button positions**. Four sliders move the left steering pair and right brake/ride pair **inward** or **upward**, independently, in 5% steps. The preview updates immediately. **Reset touch positions** restores the original edge layout while keeping your chosen button and interface sizes. Scroll to reach all four sliders and Reset.

100% means the available travel on the current safe layout, not a fixed pixel distance. Each pair stays in its own half with a central gap; riding controls stay in the lower portion of the screen. The interaction button follows the higher pair. Small screens or large buttons may leave little inward travel, while your saved preference is retained for larger screens. The preview demonstrates the same relative placement within its own available space.

Positions persist in `settings.cfg`, apply to story and Practice ride, and survive New Game. Older settings retain the original layout; malformed/partial values normalize safely. Changing placement, safe area or size releases held touches. Unrelated volume changes preserve held input, and the preview never controls the motorcycle. Individual button dragging and swapping steering/throttle sides are not implemented.

Physical thumb comfort and actual browser/Android acceptance remain open in the [touch-position review guide](docs/test/M2_PLAYTEST.md#touch-position-preference).

Local validation: **780 combined checks passed** at fixed 30 render cadence, including **57 touch-layout checks**. The same 57 checks passed in native Godot capped at 30 FPS, with settings preview and adjusted layouts inspected. The resource PCK exports and boots independently; real Web/Android ergonomics remain pending.

## Interface size · M2/M5 update, 2026-09-27

Open **Settings & accessibility → Interface size** for **Standard (100%)**, **Larger (110%)**, or **Largest (125%)**. The preference applies immediately to menus, the HUD, phone, journal, map and dialogue without closing the current page. It persists separately from the journey and survives New Game. Older settings default to Standard; invalid values normalize safely.

Enlargement is limited by the safe area to retain a 1024×540 logical layout where space permits. A constrained display can use less enlargement than requested while keeping your saved choice. **Touch button size** and **Larger dialogue text** work alongside this setting; touch hit areas follow the scaled visuals and changing scale clears held touches. World camera FOV and the rain overlay are unaffected.

The title menu is scrollable, long vertical menu buttons wrap, and dialogue scrolling follows keyboard focus. Cinematic captions now size their background to the wrapped text. At larger sizes, scroll to reach lower menu entries, photo captions/navigation, and dialogue choices. Human readability and physical Android/Web acceptance remain pending in the [interface review guide](docs/test/M2_PLAYTEST.md#interface-size-preference).

Local validation: **654 combined checks passed** at fixed 30 render cadence, including **41 interface checks**. All 41 also passed in native Godot capped at 30 FPS; enlarged settings, menu scrolling, photo captions, dialogue choices, cinematic text and touch HUD were inspected. The resource PCK exports and boots independently. Real device/browser acceptance remains open.

## Phone and story inspection · M3 update

Messages now arrive through a separate `PhoneDataService`, using story conditions and `delay_seconds` in `data/phone/messages.json`. Delivery time advances during riding, scenic stops, and the chapter ending; cutscenes, dialogue, transitions, pause, and open menus freeze it. Delivered messages wait for a free banner slot and appear in delivery order. The Phone button shows an unread count; opening Messages or Email marks the delivered entries in that section read and suppresses their queued banners. Phone home leaves both sections unread.

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

Karawang now moves through morning → overcast → drizzle → rain/heavy rain → clearing drizzle → golden hour using authored distance cues. Rest/reflection and Continue at the completed chapter use night. Night adds a motorcycle headlight, warm lamps at stops, and an original synthesized insect loop; rain volume follows its intensity and birds fade out at night. These remain prototype audio and lighting, with final recordings, art review, and human mix acceptance still pending.

See the [M4 visual/audio review guide](docs/test/M4_PLAYTEST.md). This update does not close the human art, audio, comfort, or target-platform performance gates.

Local validation: **281 combined checks passed** at a fixed 30 render cadence; **52 mood checks also passed with native rendering capped at 30 FPS**. All eight profiles and the comparison menu were inspected in rendered screenshots. Human listening and real Web/Android profiling remain pending.

## Road marking batching · M4/M5 update, 2026-09-28

Repeated road markings now use small **MultiMesh batches**, grouped into 96-meter stretches. The story road retains all 468 center/edge marks in 42 render nodes; Practice ride retains 90 marks in eight nodes. Positions, rotations, sizes and colors are preserved. The road surface, collision, route and interaction geometry are unchanged.

Batch visibility uses a conservative distance margin so nearby marks remain visible when a chunk center is farther away. Far markings may therefore appear slightly farther out than before. The batches belong to their world and are freed with it; repeated loading/unloading is covered by resource and node-count checks.

Native fixed-camera measurements in Godot Compatibility show fewer draw calls at all 12 sampled views across Low/Medium quality. For example, the story road at 20 m / Medium changed **1,094 → 994**, and the practice bend at 260 m / Medium changed **187 → 139**. These are desktop draw-call measurements without the gameplay HUD or motorcycle; they do not establish FPS, mobile thermals, or real Web/Android performance. See the [render comparison and review guide](docs/test/ROAD_RENDER.md).

Local validation: **801 combined headless checks passed**, including **21 RoadRender checks**. The native RoadRender suite passed **37 checks**, adding transform/culling verification and 12 renderer measurements. Story/practice road views were inspected, resource disposal returned node counts to baseline, and the resource PCK exports and boots independently. Target-platform profiling remains pending.

## Scene-transition lifecycle · M4/M5 update, 2026-09-28

A repeatable **Lifecycle** suite now exercises actual title/practice scene replacements and the story handoffs through Karawang's ending. Each cycle interrupts the opening, restores it with Continue, passes through the office/call/departure, visits shelter and guesthouse, opens Phone and settings, and restores the completed checkpoint. Simulated background/foreground notifications check pause, touch release and audio focus.

After each cycle, live/orphan node counts and singleton/viewport signal subscriptions must return to their initial values. Watched scene, UI, world, cinematic and marking resources must be released; the material cache must empty and the shared audio pool must remain fixed. Practice and completed-checkpoint restoration preserve saved bytes. A local JSON report records cleanup counts and diagnostic memory counters.

Use `-Suite Lifecycle` for three cycles or `-SoakCycles 10` for an extended run; see the [lifecycle test guide](docs/test/LIFECYCLE.md). **946 combined headless checks passed**, including **145 Lifecycle checks**; native rendering also passed **145 checks across three cycles**. An additional **10-cycle headless run passed 481 checks**. This is accelerated transition coverage using cutscene skips and road teleports. Long-duration gameplay, OS/GPU memory investigation and real Web/Android lifecycle/performance acceptance remain open.

## Location audio and music · M4 update

The road now blends between city traffic, roadside, fields, warung, and indoor ambience using `data/audio/soundscape.json`. Loops keep their playback position across zone changes. A sheltered stop adds roof rain only while it is raining; the warung adds sparse crockery sounds. Riding wind fades out when the engine stops.

An original **24-second first-night phrase** plays when the guesthouse conversation ends. It finishes into silence; selecting a journal entry keeps the current phrase, and Continue at rest/completion does not replay it. Actual stops and departures trigger synthesized engine cooldown/ignition; pause/resume does not replay ignition. Music pauses with the game. Backgrounding suspends playback and mutes output; returning resumes the same audio.

**Settings & accessibility** now includes persistent **Music volume** and **Sound effects volume** controls alongside Master, Vehicle, and Ambience. Vehicle controls engine loops; Sound effects controls ignition/cooldown and UI feedback. Zero fully mutes the selected bus. Audio still requires user activation.

These are original synthesized prototypes, not regional or motorcycle recordings. Final recording replacement and human listening acceptance remain open. See the [M4 review guide](docs/test/M4_PLAYTEST.md) for the listening checklist.

Local validation: **329 combined checks passed** at fixed 30 render cadence (**93 Story + 34 Practice + 44 Input + 58 Narrative + 52 Mood + 48 Audio**). The native Audio suite passed **50 checks** at a 30 FPS cap, including real stream playback and pause state. Human listening and real Web/Android acceptance remain pending.

## Interface sound set · M4/M5 update, 2026-09-27

Buttons now have three short original synthesized tones: **select**, **confirm**, and **back**. These cover story/practice menus, phone navigation, authored replies, dialogue choices and journal selections. Settings toggles/selectors also give feedback; Escape and the phone/journal/map shortcuts use the corresponding navigation tones. Opening a panel programmatically or moving focus does not play a sound.

UI feedback follows **Sound effects** and **Master** volume and works while the game is paused. The first activated menu button can unlock audio. A single player and an 80 ms interval limit rapid repeated sounds without blocking button actions. Muted/background requests are discarded; losing focus stops the current tone and returning never replays it. Continuous volume-slider movement and hover remain silent.

The 100–180 ms mono WAVs are generated by `python tools/generate_ui_audio.py`; cue paths and gains live in `data/audio/soundscape.json`. These remain prototype sounds. Human listening on headphones/phone speakers and browser audio-activation acceptance remain open in the [audio review guide](docs/test/M4_PLAYTEST.md#interface-feedback-review).

Local validation: **613 combined checks passed** at fixed 30 render cadence, including **71 audio checks**. The native Audio suite passed **76 checks** at a 30 FPS cap, including actual paused UI playback and samples reaching the SFX bus. The resource PCK includes all three new cues and boots independently; real Web/Android audio and final listening acceptance remain pending.

## Opening cinematics - M5 update

The opening now has **24 authored shots across five sequences**: morning routine and parking, HR notification/meeting, post-meeting sign-out, evening apartment, and packing/departure. Phone and laptop inserts show the alarm, HR message, recruiter opportunities, Apply, Mom, and the route home. The bike appears in the parking set with luggage at departure, followed by a PULANG title reveal and the existing ride into Karawang.

Shots in `data/cutscenes/opening.json` define stable IDs, purpose, framing, FOV, duration, optional camera endpoint, set, and prop text. `CinematicStage` builds the replaceable interior/parking sets; the director handles framing, restrained camera travel and the shared rider/bike departure movement. **Reduced camera motion** disables camera travel. Pause freezes the timeline; hold Space or select **Skip scene** to finish the current sequence, restore its final set/framing, and commit its flags once.

The restructuring conversation now leads through badge/sign-out before the evening scene. Existing checkpoint IDs remain unchanged: Continue restores the stable checkpoint, not an individual shot. An interruption around the meeting can replay the commute/meeting from its saved checkpoint. Continue at departure restores packing, and finishing/skipping it restores the riding camera and controls.

The authored shot durations total **105 seconds**, excluding dialogue, commute, transitions and player pauses. This remains a compact prototype: actors use articulated blocking geometry, waking and walking follow the shot clock, and bike departure uses root movement. Final skinned rigs and performances, full packing actions, bed/foot/hand contact and mounting/sitting transitions, cinematic foley/voice treatment and the planned 30-60 minute slice remain unfinished. Use the [M5 cinematic review guide](docs/test/M5_CINEMATIC_PLAYTEST.md).

Prior cinematic update validation: **424 combined checks passed** at fixed 30 render cadence, including **92 cinematic checks**. The same 92 cinematic checks also passed with native rendering capped at 30 FPS. Representative phone/laptop, packing, night, cluster and departure/title captures were inspected. Human pacing, final art and Web/Android acceptance remain pending.

## Cinematic sound cues · M5 update, 2026-09-27

The opening now has five original synthesized sound sketches: a morning alarm, HR notification, Mom's ringtone, fabric, and a soft motorcycle/air memory bridge. Seven events are timed in the authored shots, including the waking cloth cue added below. The four-second motorcycle cue begins 0.6 seconds before the father/child insert, continues through its two seconds, and fades over the first 1.4 seconds of the present-day title shot. Location ambience continues underneath; no new music or voice acting is added.

Cinematic sound follows **Sound effects** and **Master** volume. Pause and backgrounding freeze picture and sound together. Skip, sequence replacement, cancellation and completion clear active sounds; muted or expired events never replay when volume returns. A two-voice pool keeps overlapping tails bounded. Continue uses the existing stable checkpoint and can replay its sequence normally; sound adds no save fields.

Cue timing lives in `data/cutscenes/opening.json`, with asset paths/gains in `data/audio/cinematic.json`. Regenerate the five nonlooping WAVs with `python tools/generate_cinematic_audio.py`. These are prototype synthesis, with final recordings, contact timing and human listening review still pending in the [M5 cinematic guide](docs/test/M5_CINEMATIC_PLAYTEST.md#cinematic-sound-pass).

Local validation: **693 combined checks passed** at fixed 30 render cadence, including **39 cinematic audio checks**. The native cinematic audio suite passed **45 checks** at a 30 FPS cap, including actual SFX output and playback pause/resume. The resource PCK exports and boots independently. Human listening and real Web/Android acceptance remain pending.

## Packing performance · M5 update, 2026-09-28

The five-second packing insert now shows Raka picking up a folded raincoat, lifting it over an open bag, placing it inside, and closing the flap with his other hand. Clothes, a charger and a toolkit are visible inside. A higher camera angle frames the hands and bag. The following route insert retains the closed bag; the laptop remains on the desk for route planning. The opening stays at **24 shots / 105 authored seconds** and reuses the two existing fabric cues.

The director samples both props and a two-joint hand reach from the same shot clock. Pause/background freezes the action, backward seeking restores it, and Skip restores the final luggage state. The complete office badge, including its label and lanyard, is hidden during packing. Journey checkpoints and saves are unchanged.

This completes the **raincoat placement and flap-closing prototype**. Individual clothes/charger/toolkit placement, laptop packing after route planning, fastening the bag to the motorcycle, finger grips, fabric deformation and final recorded foley remain unfinished. See the [packing review checklist](docs/test/M5_CINEMATIC_PLAYTEST.md#packing-performance-pass).

Local validation: **1,041 combined headless checks passed**, including **234 Cinematic checks** after the final framing correction. The full run passed 1,040 checks; the final Cinematic rerun adds a caption-clearance check. Native Cinematic also passed **234 checks** at 30 FPS. Pickup, placement and closure views were inspected, and the resource PCK exports and boots independently. Final animation/contact review and real Web/Android acceptance remain pending.

## Waking performance · M5 update, 2026-09-28

The opening now shows Raka waking on the bed and sitting at its foot before the coffee/badge inserts. The alarm phone sits on a new bedside table. The existing five-second `room` shot uses a bedside camera and an eighth `AnimationPlayer` clip for the torso, head, arms and legs; the character has bare feet in bed. A short fabric cue at 1.6 seconds reuses the original cloth sound prototype, bringing the opening to seven timed sound events.

The legs remain extended until they clear the mattress edge, then bend into the seated pose. Pause/background freeze the shared shot clock, reduced camera motion keeps the performance, and seeking/Skip remain deterministic. The following insert restores ordinary actor transforms and the desk phone placement. Existing shot IDs, **24 shots / 105 authored seconds**, checkpoints and save schema are retained.

This is still a blocking performance with simple meshes. Final bed/hand contact, expressive face/eye animation, cloth simulation or authored cloth deformation, costume refinement and recorded bedsheet sound remain open in the [waking review checklist](docs/test/M5_CINEMATIC_PLAYTEST.md#waking-performance-pass).

Local validation: **998 combined headless checks passed**, including **191 Cinematic and 42 CinematicAudio checks**. Native runs passed **191 Cinematic and 48 CinematicAudio checks** at 30 FPS. Bedside alarm and lying/rising/seated views were inspected; knee timing was refined to avoid lowering the shins through the mattress. The resource PCK exports and boots independently. Final performance/contact review and real Web/Android acceptance remain pending.

## Walking performances · M5 update, 2026-09-28

Raka now walks toward the parked motorcycle during the morning sequence and toward the meeting table after the HR message. A seventh `AnimationPlayer` clip drives alternating hip, knee and arm movement, while the shot director moves the character along an authored path. The camera leaves room for the standing character; the motorcycle remains parked and its seated rider is hidden during the approach.

Pause freezes both the gait and position. Reduced camera motion keeps the character moving while holding the camera still. Rewinding or skipping produces deterministic poses, and the following cut restores the original seated/riding posture without a duplicate Raka. Walking is limited to these cinematics; gameplay remains first-person riding with bounded stop interactions.

The new office shot adds four seconds, bringing the opening to **24 shots / 105 authored seconds**. These are blocking performances: foot locking, production rigs, mounting/sitting animation and recorded footsteps remain open in the [walking review checklist](docs/test/M5_CINEMATIC_PLAYTEST.md#walking-performance-pass).

Local validation: **977 combined headless checks passed**, including **173 Cinematic checks**. The native Cinematic run also passed **173 checks** at 30 FPS; both walking shots were inspected at start/mid/end and their camera framing refined. The resource PCK exports and boots independently. Human gait/contact review and real Web/Android acceptance remain pending.

## Character performances and memory - M5 update, 2026-09-25

The opening characters now have articulated head, shoulder and elbow joints driven by six original `AnimationPlayer` clips: rest, listening, lifting the phone, reaching during packing, riding and passenger poses. The director samples each clip at the shot's current progress. Pause freezes the pose, and skipping any shot restores the same final pose as normal completion. The phone disappears from the desk when the handheld prop appears; Raka holds it during the mother's dialogue.

A **two-second memory insert** before departure shows young Raka behind his father on the motorcycle, with a distinct roadside set and **A MEMORY / With Dad** caption. Both riders use prototype helmet geometry. It returns to present-day parking with the luggage and title reveal. Cinematic bikes hide the first-person arm meshes to avoid duplicate hands. Interior lighting layers and the room wall behind the phone shot are also corrected.

This earlier pass brought the opening to **23 shots / 101 authored seconds**; the walking update above extends it to 24 / 105. These are reusable animation prototypes, not finished character art: skinning, facial/lip animation, complete packing actions, refined bed/hand/foot contact and final cinematic sound remain open. The memory keeps continuous ambient crossfades and now has the synthesized sound bridge described above; final recorded sound and listening acceptance remain pending.

Local validation: **474 combined checks passed**, including **142 cinematic checks**, at fixed 30 render cadence. The 142 cinematic checks also passed in native Godot at a 30 FPS cap. Phone, packing, father/child and departure poses were inspected in rendered captures. Human animation/comfort review and real Web/Android validation remain pending.

## Phone sections and call history - M5 update, 2026-09-25

**Phone** opens a home screen with **Messages, Email, Calls, Photos, Route, and Journal**. Messages and Email show separate unread counts. Opening one section marks all delivered entries in that section read, including those below the scroll fold, while leaving the other section unread. The HUD Phone badge still shows the combined unread total. Replies remain authored and stay in their current section after sending.

**Calls** contains Mom's first-evening call only after its dialogue completes. It shows the story time, Raka's short recollection, and a remembered line from the existing dialogue data. Either dialogue branch unlocks the same shared recollection. Reading call history never restarts dialogue or changes flags/checkpoints. It derives availability from the existing saved dialogue-completion state, so old v1 saves remain compatible and New Game clears the history naturally.

**Route** and **Journal** open from the phone with a **Back to phone** button. Escape returns from a section/shortcut to phone home, then closes the phone on the next press. Direct map/journal shortcuts retain their original close behavior. Riding stays paused throughout phone navigation.

This implements a call-history view, not outgoing calls or audio replay. Additional call content, voice playback, and a full localization key table remain future work. The [phone review guide](docs/test/M3_PLAYTEST.md) includes the updated authoring and acceptance checks.

Prior phone-section validation: **511 combined checks passed** at fixed 30 render cadence, including **35 phone checks**. The Phone suite also passed all 35 checks in native Godot capped at 30 FPS; home, Messages, Email and Calls captures were inspected. Real browser/Android and human readability acceptance remain open.

## Phone photo album - M5 update, 2026-09-25

Open **Phone → Photos** for an authored album with thumbnails, captions, and Previous/Next navigation. **Dad and me** is available from the start; **Packed for the road** unlocks after departure; **A place out of the rain** unlocks after the Karawang shelter encounter. The three 960×540 prototype stills are rendered from this project's original 3D assets and loaded as textures during play.

Escape returns from a photo to the album, then phone home, then riding. Browsing stays paused and leaves message unread counts, story state, and checkpoint files unchanged. Existing saved flags restore unlocked photos on Continue; New Game retains only the family photo. Unknown or locked photo links return to the album, and missing images show a readable fallback.

This is an authored story album. Free-camera Photo Mode, player captures, sharing, and final photo artwork remain unfinished. See the [authoring and playtest guide](docs/test/M3_PLAYTEST.md#photo-album) for data fields and the native render command.

Local validation: **555 combined checks passed** at fixed 30 render cadence, including **79 phone checks**. All 79 phone checks also passed in native Godot capped at 30 FPS; album and all three photo views were inspected at 1280×720. The resource PCK includes all three textures and photo JSON and boots independently. Real Web/Android and human readability acceptance remain open.

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
- Original synthesized engine/road/rain/bird/insect/location loops, vehicle cues and a sparse first-night music phrase; audio starts after a user interaction. No final recorded motorcycle or regional ambience assets yet.

## Development roadmap

Based on the [Development Roadmap v1](../PULANG_Development_Roadmap_v1.md). Status last reviewed: **2026-09-25**.

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
- [x] Add persistent 100%/125%/150% riding touch-button sizes, a noninteractive settings preview, safe-area fitting, and interaction-button repositioning.
- [x] Test all sizes with simultaneous touch steering/throttle, settings reload and New Game, legacy/invalid values, constrained layouts, and held-input cleanup.
- [x] Add persistent 100%/110%/125% menu/HUD scaling with safe-area limits, a scrollable title menu, wrapping menu buttons and adaptive cinematic captions.
- [x] Test scaled settings/save isolation, three aspect ratios, ten screen layouts, focus scrolling, caption readability and combined interface/touch scaling.
- [x] Add independent inward/upward placement for left/right touch pairs, persistent preferences, live preview and reset.
- [x] Test placement with button/UI scaling, safe-area limits, multitouch, input release, legacy settings and save isolation.
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
- [x] Add phone home, separate Messages/Email unread state, completed-call history, and Route/Journal return navigation.
- [x] Test channel reads/replies, call completion gates, read-only history, old-schema save/load, New Game, and phone navigation locks.
- [x] Add Photos with three original rendered stills, thumbnails, captions, story-based unlocks, and bounded Previous/Next navigation.
- [x] Test album unlock/save/New Game behavior, nested Back navigation, read-only browsing, and empty/missing-image fallbacks.
- [ ] Validate narrative/save behavior in real Web and Android builds.

### M4 — Visual & Audio Mood Prototype · In progress

- [x] Build the low-poly roadside kit: fields, trees, poles, homes, warung, fuel stop, guesthouse, and traffic.
- [x] Add a Thunder 250-inspired placeholder bike, clear/rain transitions, and layered synthesized audio.
- [x] Implement authored morning, overcast, golden-hour, and night profiles plus drizzle, rain, heavy rain, and mist.
- [x] Blend sky/light/fog/wetness/rain; add a practice comparison menu, night headlight/stop lamps, and synthetic insect ambience.
- [x] Test transition interruption/pause, rain quality limits, chapter profile restoration, and practice save isolation.
- [x] Add continuous location ambience, sheltered roof rain, ignition/cooldown, and the first restrained original music prototype.
- [x] Add persistent Music/SFX controls, true zero-volume mute, and audio pause/background/Continue regression checks.
- [x] Add three original UI tones with SFX/Master routing, paused-menu playback, repeat limiting and focus-loss cleanup.
- [x] Test real menu callbacks and keyboard activation, cue routing, muted/background request suppression, and unchanged journey saves.
- [x] Replace the static tachometer with a live RPM needle; refine analog dial numbers, units, ticks and rider-facing tilt.
- [x] Add per-bike night instrument illumination and immediate stop/recovery updates; test calibration, pause, Continue and save isolation.
- [ ] Review cockpit readability on physical devices and reference-check the final hero motorcycle.
- [ ] Refine hero bike and character art; replace synthesized placeholders with recorded motorcycle/regional ambience and review the final mix.
- [x] Batch story/practice road markings into bounded MultiMeshes after native before/after draw-call measurement.
- [x] Test original marking transforms, dimensions, culling margins and resource disposal across repeated world loads.
- [x] Add repeated real scene-transition regression with checkpoint restoration, background/foreground handling and per-cycle node/resource/signal/audio cleanup reports.
- [ ] Complete long-duration natural-speed transition and OS/GPU memory profiling on actual Web/Android exports.
- [ ] Review visual identity and sound quality, and profile actual target-platform builds.

### M5 — Vertical Slice · In progress

- [x] Connect Jakarta opening → commute → layoff → mother's call → departure → first road segment.
- [x] Connect optional stops → rain shelter/conversation → guesthouse → journal → chapter ending.
- [x] Test the compact desktop flow, checkpoint recovery, and Continue through completion.
- [x] Expand the opening to 24 authored shots with interior/parking sets, readable phone/laptop inserts, post-meeting sign-out, and departure/title reveal.
- [x] Add per-shot framing/FOV, restrained camera travel, reduced-motion behavior, deterministic skip, pause and stable-checkpoint regression checks.
- [x] Add articulated prototype actors, eight director-sampled AnimationPlayer clips, phone prop handoff, and a father/young-Raka memory insert.
- [x] Test deterministic actor poses after seeking/skipping, pause, dialogue handoff and memory-to-present restoration.
- [x] Add a director-sampled walking gait and authored approaches to the parked motorcycle and meeting table; restore seated/riding poses on the following cut.
- [x] Add lying-to-seated waking performance, bedside alarm placement and timed fabric cue; verify pause/focus, seeking, mattress clearance and pose reset.
- [x] Add raincoat pickup/placement and bag-flap closure with sampled hand contact; test pause/focus, rewind, prop reset and all-shot Skip equivalence.
- [ ] Animate remaining individual packing actions, laptop stowage after route planning and luggage fastening; refine fingers, cloth and recorded contact sound with production assets.
- [ ] Refine waking bed/hand contact, facial expression, cloth and final recorded bedsheet sound with production assets.
- [ ] Refine planted feet, mounting/sitting transitions and final walking performances/footsteps with production character rigs.
- [x] Connect the prototype UI sound set across story/practice menus, phone sections, authored choices and keyboard navigation.
- [x] Add five original cinematic sound prototypes and seven timed events, including waking fabric and a motorcycle sound bridge through the father memory.
- [x] Test sound timing/tails, activation, SFX/Master mute, pause/background, skip/replacement cleanup and save isolation, including native playback.
- [ ] Review cinematic sound/contact timing on headphones and phone speakers; replace prototypes with final recordings.
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
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Cockpit -Visual -FixedFps 30
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite TouchLayout -Visual -FixedFps 30
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Input -Visual
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Narrative -StoryDebug -Visual
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Mood -Visual -FixedFps 30
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite RoadRender -Visual -FixedFps 30
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Lifecycle -Visual -FixedFps 30
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Lifecycle -FixedFps 30 -SoakCycles 10
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Audio -Visual -FixedFps 30
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Cinematic -Visual -FixedFps 30
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite CinematicAudio -Visual -FixedFps 30
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Phone -Visual -FixedFps 30
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Interface -Visual -FixedFps 30
```

The helper isolates all test saves in `.godot-test/`. **Do not run the test scenes against your normal user profile**: their corruption and new-game cases deliberately replace the test save. The default `-Suite All` runs story, practice, cockpit, road render, lifecycle, touch layout, input, narrative, mood, audio, cinematic, cinematic audio, phone, and interface sequentially; use `-Suite Story`, `Practice`, `Cockpit`, `RoadRender`, `Lifecycle`, `TouchLayout`, `Input`, `Narrative`, `Mood`, `Audio`, `Cinematic`, `CinematicAudio`, `Phone`, or `Interface` to select one. `-StoryDebug` enables additional viewer checks in the narrative suite. Headless `-FixedFps` changes simulated render cadence; with `-Visual`, it sets the actual native FPS cap (RoadRender and Lifecycle always use a native 30 FPS cap). Physics remains at 60 ticks per second. The helper fails on script errors or a missing success summary, even if the engine exits with code zero.

The story suite exercises content references, conditions, schema validation, corrupt-save fallback, opening/skip handoff, physical throttle/brake/steering, ground contact, pause, every stop, multitouch action handling, journal persistence, and Continue. The practice suite drives the full track under physics, checks solid-obstacle response, recovery, metrics, save isolation, and real title/practice scene transitions. Suites with visual snapshots write screenshots under `tests/screenshots/` (ignored by Git); Lifecycle writes a local JSON counter report instead. See [Validation record](docs/test/VALIDATION.md) for results and outstanding platform work.

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
