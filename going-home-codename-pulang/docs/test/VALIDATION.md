# Validation record

## Traffic car shapes and rolling wheels - 2026-10-02

- **Implemented:** original hatchback/wagon bodies with tapered shoulders, curved hood/roof crowns, framed glazing, closed cabin seams, real wheel openings and recessed liners; detailed rims, mirrors, lights, wipers, handles, grille and bumpers. Four wheel pivots follow distance travelled through the production road traffic update.
- **Validation:** **49 native RoadRender checks** at a 30 FPS cap and **60 headless CampaignStaging checks**, zero failures. The traffic assertions inspect actual rendered wheel vertices for road contact, preserve independent wheel pivots after batching, verify route/speed/rotation, quality visibility and stable node count. Existing repeated world disposal and save-isolation checks pass. Logs: `.godot-test/RoadRenderTests.log` and `CampaignStagingTests.log`.
- **Visual review:** `tools/CarReview.tscn` captures seven native Compatibility views, including both silhouettes and the production road (`.godot-test/car-review.log`, `CAR REVIEW COMPLETE`). Reviewed front, side, rear and road images after correcting see-through wheel houses and hood/cabin seams. PNGs remain ignored local artifacts under `tests/screenshots/car_*.png`.
- **Scope:** focused visual/traffic regression; no new full-route or full-suite acceptance run. The existing sandbox root-certificate-store message remains; final logs contain no script, parse or compile errors. No Web/Android changes.

## Rider footrests, rear brake and gear lever - 2026-10-02

- **Implemented:** short frame-mounted rubber footrests with hinge/bolt detail, right rear-brake lever/pad/linkage, and left gearbox lever with rubber toe peg. Shared raised/rearward ankle targets update mounting, departure, father memory and homecoming poses.
- **Validation:** **539 native Cinematic checks** at 30 FPS, plus **60 CampaignStaging and 35 Cockpit headless checks**, all zero failures. Logs: `.godot-test/CinematicTests.log`, `CampaignStagingTests.log`, `CockpitTests.log`. Four added assertions verify side assignment, forward pedal placement, no resting boot/pedal bounds overlap, a small brake-pad gap and shift-toe clearance. Existing sole-to-peg, mounting/luggage, pause, Skip, rewind, save-isolation and instrument tests remain passing.
- **Rendered review:** `bike-foot-controls-review.log` completes successfully. BikeReview now captures nine views, including both foot-control assemblies with and without boots. Native mounting and father-memory shots use the new pose. No manual-shifting gameplay, pedal actuation animation or new input bindings are claimed. The existing sandbox certificate-store message remains; final test logs have no script/parse/compile failures.

## Motorcycle curved surfaces - 2026-10-02

- **Implemented:** spline-shaped tank, cushioned saddle, rounded side/tail panels, radiused engine fins/cover, domed headlamp, rounded gauge housings/indicators/mirrors, bent header/grab-rail tubes and tapered muffler. `BikeForms` generates scene-owned meshes with shared surface normals. Existing proportions and riding controls remain.
- **Native regression:** **535 Cinematic, 60 CampaignStaging and 35 Cockpit checks**, zero failures, Windows Compatibility at 30 FPS. Logs: `.godot-test/CinematicTests.log`, `CampaignStagingTests.log`, `CockpitTests.log`. Tank wipe contact now tests actual mesh triangles rather than an ellipsoid equation; normals interpolate across triangle edges. Helmet/seat support, mounted soles/grips, pause, Skip, rewind, homecoming and instrument calibration still pass.
- **Visual review:** refreshed the five `bike_*.png` review views; inspected body contours, rear lamp/body separation, cockpit and tank wiping. A final end-cap winding correction removed hollow-looking caps and was verified by rerendering BikeReview (`bike-curves-review.log`). Existing screenshots are generated local artifacts, not replacement assets.
- **Final follow-up:** after the cap correction, 535 headless Cinematic checks passed again (`bike-curves-final-contact.log`), and the configured native project entry exited successfully after 120 frames (`bike-curves-boot.log`).
- **Scope:** no changes to story data, player-save schema or physics, and no Web/Android work. This is focused art/contact validation, not exhaustive collision or final art acceptance. The existing sandbox certificate-store warning remains.

## Motorcycle proportions and contact revision - 2026-10-02

- **Implemented:** a coherent 1.42 m wheelbase / .63 m tire layout; narrower tank and saddle; smaller lamp, gauges, controls, mirrors, engine and exhaust; connected brackets, rear mudguard and shared footpegs. Details and authored dimensions are in [art direction](../ART_DIRECTION.md#motorcycle-proportion-revision--2026-10-02).
- **Final native checks:** **535 Cinematic + 60 CampaignStaging + 35 Cockpit = 630**, all with zero failures, Windows Compatibility renderer at a 30 FPS cap. Logs: `.godot-test/CinematicTests.log`, `CampaignStagingTests.log`, `bike-final-cockpit.log`. CampaignStaging also passed 60 headless checks after the ignition correction. This is focused regression coverage, not a new full-suite or full-route run.
- **Contact correction:** the first revised ignition placement exceeded the seated arm's reach and failed the homecoming contact check. The connected ignition housing moved closer to the rider; final headless and native staging reruns pass the original 2 mm tolerance. The father's memory pose now uses the same mounted grip anchors. Helmet support is measured against actual saddle triangles; both shoe soles are checked against the rendered footpegs.
- **Visual evidence:** `tools/BikeReview.tscn` exits successfully and produces five native model views; inspected side, front, front/rear three-quarter and seated rider. Also reviewed `mount_seated`, `performance_memory`, daytime cockpit/ordinary downward glance, and homecoming ignition captures. Screenshots remain ignored local artifacts and can be regenerated. The normal configured project entry exits successfully after 120 frames (`bike-boot-smoke.log`).
- **Scope:** no external models or textures, no save-schema or riding-physics changes, and no Web/Android work. No claim of exact manufacturer dimensions or exhaustive intersection-free animation. Final logs contain no failed checks or script/parse/compile errors; the existing sandbox certificate-store message remains.

## Character anatomy, hero props and contact revision - 2026-10-02

- **Implemented:** female Nadia and mother variants; shaped faces, limbs, hands, shoes/bare feet; single-axis elbow reach and grounded walking; a detailed motorcycle with thin crossed spokes, engine components and shaped controls; an open-front helmet; detailed laptop, ID card/strap and cups. Static roadside people share the revised anatomy. See [art revision](../ART_DIRECTION.md#character-and-close-up-revision--2026-10-02).
- **Regressions:** successful results total **2,296 runtime checks across 19 suites and 50 Python tests**. `.godot-test/hero-all.log` contains the content-tool tests and the first fifteen passing suites, then stops at obsolete unit-sphere helmet assumptions. Those assertions were changed to inspect all eight actual mesh-bound corners. Corrected/remaining suite logs are `hero-final-Cinematic.log` (**531**), `hero-final-CinematicAudio.log` (**77**), `hero-final-Phone.log` (**79**) and `hero-final-Interface.log` (**41**); `hero-final-staging.log` (**60**) replaces the earlier 58-check staging result. All these final suite results have zero failures. This is an aggregate of the full run and targeted final reruns, not a claim that the initial All invocation exited successfully.
- **Final native evidence:** **531 cinematic checks** (`hero-final-native-CinematicTests.log`) and **60 staging checks** (`hero-porch-native-final.log`), zero failures, Windows Compatibility renderer with a 30 FPS cap. The native tests used a separate isolated APPDATA beneath `.godot-test/hero-native-profile`; headless and native player saves did not overlap. Normal configured project entry also exits successfully after 120 frames (`hero-final-entry.log`). No editor F5-button interaction is claimed.
- **Contact defects corrected:** residual IK basis scale after Skip; ID strap crossing the mug; hair protruding through the old helmet; a detailed laptop lid protruding through the closed bag flap; and family feet inside the raised home foundation/steps. Laptop packing now checks every mesh corner above the raincoat trim and below the flap. Home tests sample standing/entrance shoe heights; walking tests sample stance foot locking, level soles and forward knee bend. Existing hand/prop contact, pause, seeking, Skip, framing, resource-lifetime and checkpoint checks remain in place.
- **Rendered review:** inspected walking, waking/rising, packing/laptop closure, helmet pickup/donning, seated riding, family dialogue, home steps and the nine-view native art gallery. `tools/ArtReview.tscn` completes and refreshes `cozy_*.png`, `hero_nadia.png`, `hero_laptop.png` and `hero_id_card.png`. These are actual game meshes rendered by Godot, not concept imagery.
- **Limits:** sampled contacts and bounding checks do not certify every possible mesh pair/frame, full human biomechanics or final artist acceptance. Original stylized geometry is retained rather than importing a manufacturer motorcycle scan or production character rig. No new full-route performance claim, Web/Android work or M10 acceptance is made. The known sandbox root-certificate warning remains; no game script/resource errors were present in the final runs.

## Warm low-poly art revision - 2026-10-01

- **Scope:** shared faceted/chamfered forms, detailed houses and urban facades, branching trees/palms, shrubs, continuous road shoulders, distant hills, motorcycle, characters, furnished rooms, shelters, fuel pumps and traffic. Morning and golden-hour lighting were revised. See [art direction and reproduction steps](../ART_DIRECTION.md).
- **Regression:** `tools/test.ps1 -Suite All -FixedFps 30` passed **2,286 runtime checks across 19 suites and 50 Python tests**, zero failures (`.godot-test/cozy-all.log`). The final urban-facade detail was added afterward and is covered by the following native runs; the complete suite was not rerun for that decorative change.
- **Native final-source checks:** `CampaignStaging -Visual` **58**, `Cinematic -Visual` **523**, and `RoadRender -Visual` **37** checks, all zero failures at a 30 FPS cap. Logs: `.godot-test/cozy-native-staging.log`, `cozy-native-cinematic.log`, `cozy-native-road.log`. Editor import and the six-view `ArtReview` gallery completed without game script/resource errors.
- **Visual inspection:** reviewed actual rendered room, motorcycle, road, warung, home and character gallery images, plus waking/rising, packing, dinner, interview, speaker close-up and epilogue contact captures. Corrected black vertex colors during geometry merging, an overlapping bookshelf, nearby oversized hills and a bench intersecting homecoming standing poses during iteration.
- **Render samples:** story Low draw calls **503 / 238 / 255**, Medium **942 / 526 / 654** at 20 / 650 / 1,100 m; practice Low **84 / 76 / 48**, Medium **143 / 155 / 151** at 20 / 260 / 650 m. Static decoration is merged by material within local groups. These are draw-call samples on the native Compatibility renderer, not GPU timings, a full-route frame-rate guarantee or an identical-content comparison with earlier art. Repeated world disposal and unchanged story checkpoint checks passed.
- **Project entry:** normal configured project launch (no test scene), isolated APPDATA, exits successfully after 120 frames; `.godot-test/cozy-native-entry.log`. This checks the scene used by F5, without claiming an editor-button interaction.
- **Limits:** the earlier full-campaign timing predates this art revision. No Web/Android work or human art-acceptance claim is included. The known sandbox certificate-store warning remains; offline tests complete normally.

## Native desktop routes, staging and complete ride - 2026-10-01

Current user scope is **Godot native desktop**. Web/Android work is deferred; earlier export fingerprints below describe earlier source and have not been rebuilt for this pass.

- **Complete native journey:** `tools/test.ps1 -Suite NativeJourney -Visual -FixedFps 30` passed **37 checks, zero failures**. Started the real Boot menu, selected New Game, physically drove with input actions and stopped at optional/mandatory stops. All cutscenes ran to their normal end. Visible dialogue/journal buttons advanced the story; no test teleport, checkpoint injection, development menu or Skip was used. It reached the epilogue, saved all fifteen reflections and covered **23.263913 km** in **2,163.23 simulated seconds**. Both-branch and interrupted-checkpoint tests remain in the separate accelerated Campaign suite.
- **Ride bounds:** zero automatic recoveries or blocking obstacle contacts. Worst left-lane tracking offset was **0.0131 m** and worst road-height difference **0.0590 m**. These figures measure the assisted automated route, not manual steering skill or human motion comfort.
- **Native frame sample:** Windows Compatibility/OpenGL 3.3, RTX 3050 Laptop GPU, Medium quality, assist/reduced motion enabled, 30 FPS cap. The report collected 46,361 riding process intervals: median/p95 **33.333 ms**, worst **137.790 ms**. These are Godot process deltas, not GPU timings or a zero-stutter guarantee. Loading/cinematic/menu intervals are excluded. The later decorative roadside groups were added after this full run and are validated by native captures and regressions, so these timing figures must not be attributed to their cost.
- **Evidence:** `.godot-test/native-journey-visual.log`, `.godot-test/Godot/app_userdata/PULANG/native_journey_visual_report.json` and `tests/screenshots/native_journey_ending.png`. The native JSON was retained separately before the later headless run; the helper now uses separate report names so one mode cannot overwrite the other's evidence. The final source including regional decoration also completed the headless no-teleport journey: **37 checks, zero failures**, 23.263913 km, zero recoveries/contacts (`.godot-test/native-journey-final-headless.log` and `native_journey_headless_report.json`). Headless time is not a rendering benchmark.
- **Staging:** native `CampaignStaging` passed **58 checks**. Samples validate ignition/key, father's grip and epilogue cloth contact within 2 mm, reset after seeking/Skip, stable prop counts, doorway clearance and speaker faces above the dialogue panel. Inspected dinner, interview, homecoming and epilogue renders; corrected bag occlusion, cropped head framing and seated height. Added native review captures for each regional roadside group and removed trees intersecting those sites. Logs: `.godot-test/native-staging-final.log`, `.godot-test/native-regional-review.log`; captures: `staging_*.png`, `regional_*.png`.
- **Regression:** **2,286 runtime checks across 19 suites and 50 Python tests**, zero failures. Content remains 27 JSON files / 764 text fields / 616 localization keys, zero validation errors or warnings. Road profiles now reject malformed types and unsafe numeric ranges. Initial log: `.godot-test/native-desktop-all.log`; final decorative-art regression: `.godot-test/native-desktop-final-all.log`.
- **Changes:** fourteen continuous road profiles and matching verge collision; wheel rotation, frame/suspension/luggage/ignition details; facial age/glasses cues; dinner seating, chapter speaker cameras, engine-off timing, cleaning contact and staggered family entry. Regional groups add workshop, fabric racks, older shopfront, lookout, courtyard, campus gate, cart and drying-rack silhouettes. Decoration is outside the road and adds no physics bodies. Title route now names Banyuwangi.
- **Final rendered checks:** after the decorative-art adjustments, `CampaignStaging -Visual` passes **58 checks** and `Interface -Visual` passes **41 checks**. Reviewed the title at 125% interface scale and corrected stacked tire contact in the Tegal group. Logs: `native-regional-final.log`, `native-interface-final.log`. A separate normal project-entry launch (no test scene, isolated clean player profile) exits successfully after 120 frames; `native-f5-entry-console.log` records no game script/resource errors. This command exercises the configured F5 entry scene; it is not a claim of clicking F5 in the editor.
- **Acceptance:** the automated run is about 36 minutes and selects dialogue rapidly. It is not the GDD's 8–12 hour campaign, a 30–60 minute slice or an actual participant session. M1 human comfort, production performances/art/recordings, pacing and M10 player-category feedback remain open. No claim of zero possible bugs or final content lock is made. See [desktop guide](../DESKTOP_PLAY.md).

The known sandbox certificate-store startup message remains; the offline project does not require network access.

## Full-route prototype integration and Web audio fix - 2026-10-01

- **Scope:** the compact draft route now runs from Jakarta/Karawang through all subsequent chapters to Banyuwangi and the family-home epilogue. Chapter encounters, both choices, journals, phone sequencing, normal advancement and legacy Continue are implemented. This does not accept M7/M8 production quality or M10 content lock; see [open gates](CAMPAIGN_BETA_READINESS.md).
- **Headless:** `tools/test.ps1 -Suite All -FixedFps 30` passed **2,228 runtime checks in 18 suites and 48 Python tests**, zero failures. Campaign coverage contributes **572 checks**. Preflight: **27 JSON files, 764 text fields, 616 stable localization keys, zero errors/warnings**. Log: `.godot-test/campaign-final-all30.log`.
- **Native Compatibility renderer:** campaign **287 checks**, audio **76 checks**, cinematic audio **83 checks**, zero failures. Logs: `campaign-final-native.log`, `campaign-audio-native-recheck.log`, `campaign-cinematic-audio-native.log` under `.godot-test`. Reviewed chapter captures including the Kediri room, homecoming standing poses and caption placement. Native runs use a 30 FPS cap; they are not Android performance measurements.
- **Native test correction:** the UI mixer assertion originally read a single frame and missed a 180 ms cue after renderer initialization. It now warms the renderer and records maximum playback position and SFX bus peak over a bounded 300 ms interval. The actual bus-level assertion is retained and passes in the isolated native run.
- **Web campaign:** an isolated `prepare_campaign_qa.py` snapshot exported the same campaign into WebAssembly with `CampaignTests` as entry point. Both branches reached the terminal epilogue: **572 checks, zero progression failures** in the Codex in-app browser. Result observed at `2026-09-30T22:23:53.934Z` (2026-10-01 in Jakarta), summarized in `.godot-test/campaign-web-qa-result.json`. This test uses checkpoint teleports and sampled cutscene durations; it is not a natural 8–12 hour session or browser-family compatibility matrix.
- **Web defect fixed:** the first QA run failed at Salatiga with `RangeError: Array buffer allocation failed` through `Sample._duplicateAudioBuffer` and `_unpause`. Ambient/music/cinematic audio wrote `stream_paused` every frame. The setter now runs only on a state change; the repeated complete two-branch run had no repeat of that exception.
- **Open Web finding:** after the successful QA result, explicit engine shutdown logged `Pages in use exist at exit in PagedAllocator: N16WorkerThreadPool5GroupE`. A separate minimal Web project containing only a Label, a timer and `SceneTree.quit()` did not reproduce it. No engine-cause claim is made. Normal Web menus hide Quit, but further isolation of this campaign-test shutdown finding remains required. Logs must not be described as wholly error-free.
- **Final small changes:** cleared non-phone route notices when returning to the title; Interface suite **41 checks, zero failures** (`campaign-interface-final.log`). Replaced eleven repeated encounter closings with chapter-specific English prose and synchronized existing localization keys; final content validator passed with unchanged counts and no errors/warnings. No flags, branching edges, save schema or durations changed. These two small changes followed the full QA snapshot run.
- **Final player-build smoke:** after the last export, launched the normal Web distribution, used Continue to restore the saved Jakarta commute, opened Pause and returned to title. HUD and Pause text rendered correctly, the title had no leftover notice, and the browser error log was empty for this smoke session. Earlier checks also exercised New Game, opening Skip and reload/Continue. This is separate from the QA build's shutdown finding.
- **Packaging:** Web and signed Android debug exports succeeded with matching 4.7.2 templates. Enabled ETC2/ASTC texture import to satisfy the Web preset's mobile texture setting. `tools/export_beta.ps1` isolates editor configuration and debug signing keys; `tools/audit_exports.py` verifies all 27 JSON files byte-for-byte against source, Web pack checksums and development/output exclusions. Final audit: `.godot-test/campaign-export-audit.json`.

| Final artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| `export/web/index.pck` | 1,961,732 | `68dd45c3164d3d04bda5f5fb694bc5448b9a5c273a054cae91d02a0df974104a` |
| `export/web/index.wasm` | 37,902,138 | `11ea19645368f8e73cf337b59cfd7ceeb4ebb51f7a3bbf77d1a5c3ddfedbc522` |
| `export/android/pulang-debug.apk` | 29,677,788 | `77f9ebf91be01b80ee28353e344a8dd603ec7927dc198175604ae7f1d17559fa` |

Android packaging is not device acceptance: ADB reports no connected devices. The SDK signing tool uses its available 28.0.3 fallback; a target-device/release-toolchain review remains open. Natural platform playthroughs, final recorded sound/art, authored pacing, player categories and motion/touch comfort remain **not accepted**. Use the [beta session report](BETA_PLAYTEST_REPORT.md) for actual participants; no external testers or feedback are fabricated. The known local certificate-store startup warning remains environmental.

## M5 luggage buckle threading - 2026-09-30

- **Headless:** `tools/test.ps1 -Suite All -FixedFps 30` passed **45 Python tests and 1,553 runtime checks across 17 Godot suites**, with 0 failures, including **523 Cinematic and 77 CinematicAudio checks**. Content preflight covers 12 JSON files, 331 inventoried text fields and 202 stable localization keys; the known Cirebon slice-boundary warning remains.
- **Native Windows / Compatibility:** **523 Cinematic and 83 CinematicAudio checks passed** at a 30 FPS cap. Inspected loose ends, first-buckle completion, second-buckle feeding and the final tails at 1280×720. The existing luggage-check camera exposes both buckle locations. The final props and actor pose match the following tightening shot exactly.
- **Coverage:** 101 samples check hand-to-webbing contact within 2 mm, grip clearance from bag/torso, fixed frame endpoints and feet, stationary bag/bike, caption-safe grip positions and stable node count. Tests verify the first buckle finishes before the second, no tightening occurs during threading, tails emerge only after insertion starts, pause/focus, rewind/reset, reduced motion, natural handoff, all-shot Skip and journey-state isolation. Each fabric cue triggers once; early Skip discards the later buckle cue and clears voices.
- **Content:** one eight-second insert brings the opening to **36 shots / 167 authored seconds**, including 90 seconds for departure and **26 sound events** across the existing five assets. One stable English caption key is added. No new save fields, checkpoints, narrative flags, physics bodies or webbing nodes are introduced by sampling.
- **Evidence:** `.godot-test/BuckleThreading-all30.log`, `BuckleThreading-native.log`, `BuckleThreadingAudio-native.log`; captures `tests/screenshots/threading_ready.png`, `threading_first.png`, `threading_second.png`, `threading_complete.png`. Final logs have no failed checks or script/parse/compile/leak errors. The known certificate-store startup message remains environmental.
- **Scope:** prototype insertion through two buckles toward the M5 prerequisite for M7. Bands are already draped around the bag/frame at the opening cut; routing them is still unanimated. Final buckle mechanics, fingers, webbing deformation, recorded foley, human pacing/readability and target-platform acceptance remain open. No new export or milestone acceptance is claimed.

## M5 closed-bag table pickup - 2026-09-30

- **Headless:** `tools/test.ps1 -Suite All -FixedFps 30` passed **45 Python tests and 1,528 runtime checks across 17 Godot suites**, with 0 failures, including **502 Cinematic and 73 CinematicAudio checks**. Content preflight covers 12 JSON files, 327 inventoried text fields and 201 stable localization keys; the known Cirebon slice-boundary warning remains.
- **Native Windows / Compatibility:** **502 Cinematic and 79 CinematicAudio checks passed** at a 30 FPS cap. Inspected ready, lift, draw and held poses at 1280×720. The bag rises vertically before drawing toward Raka; the closed laptop and other packed items stay with the assembly. Native audio verifies playback/mixer behavior with the final cue timing.
- **Coverage:** 101 samples check two-hand contact within 2 mm, all packed contents following the bag, closed flap/laptop, planted feet, lift-before-draw timing, table/torso clearance, projected head/feet/bag positions and stable node count. Pause/focus, backward seeking, route re-entry resetting bag/laptop/chair/actor, reduced motion, parking stage cleanup, all-shot Skip and save isolation pass. Each fabric cue triggers once; early Skip discards the later draw cue and clears sound voices.
- **Content:** one six-second insert brings the opening to **35 shots / 159 authored seconds**, including 82 seconds for departure and **24 sound events** across the existing five assets. One stable English caption key is added. No new save fields, checkpoints, narrative flags, physics bodies or copied props are introduced.
- **Evidence:** `.godot-test/BagPickup-all30.log`, `BagPickup-native.log`, `BagPickupAudio-native.log`; captures `tests/screenshots/bag_pickup_ready.png`, `bag_pickup_lift.png`, `bag_pickup_draw.png`, `bag_pickup_held.png`. Final logs have no failed checks or script/parse/compile/leak errors. The known certificate-store startup message remains environmental.
- **Scope:** prototype table pickup toward the M5 prerequisite for M7. Standing/chair preparation, the trip downstairs, bag reorientation across the parking cut and initial strap threading remain unanimated. Final weight/finger/cloth/full-mesh contact, recorded foley and human/target-platform acceptance remain open. No new export or milestone acceptance is claimed.

## M5 luggage carrying and rear-seat placement - 2026-09-30

- **Headless:** `tools/test.ps1 -Suite All -FixedFps 30` passed **45 Python tests and 1,500 runtime checks across 17 Godot suites**, with 0 failures, including **478 Cinematic and 69 CinematicAudio checks**. Content preflight covers 12 JSON files, 323 inventoried text fields and 200 stable localization keys; the known Cirebon slice-boundary warning remains.
- **Native Windows / Compatibility:** **478 Cinematic and 75 CinematicAudio checks passed** at a 30 FPS cap. Reviewed carrying, approach, lowering and placed-bag captures at 1280×720. Widened the camera to keep the head and feet inside the caption bars. Placement finishes at the exact local seat anchor, avoiding accumulated global-coordinate rounding before strap checks.
- **Coverage:** 101 samples check both hand grips within 2 mm, bag clearance from seat height and torso, planted feet during placement, stationary motorcycle, head/feet/bag framing and stable node count. Pause/focus, seeking back from the departing motorcycle, reduced motion, natural handoff to loose prethreaded straps, all-shot Skip and journey-state isolation pass. The two fabric cues trigger once; early Skip discards the later seat-placement cue and clears voices.
- **Content:** one eight-second insert brings the opening to **34 shots / 153 authored seconds**, including 76 seconds for departure and **22 sound events** across the existing five assets. One stable English caption key is added. No new save fields, checkpoints, narrative flags or gameplay cargo physics.
- **Evidence:** `.godot-test/LuggageLoading-all30.log`, `LuggageLoading-native.log`, `LuggageLoadingAudio-native.log`; captures `tests/screenshots/luggage_carry_start.png`, `luggage_carry_step.png`, `luggage_lowering.png`, `luggage_loaded.png`. Final logs have no failed checks or script/parse/compile/leak errors. The known certificate-store startup message remains environmental.
- **Scope:** a bounded prototype carry and seat placement toward the M5 prerequisite for M7. Initial table pickup, the trip downstairs and strap threading remain editorial omissions. Final weight/stride/finger/cloth/contact work, recorded foley and human/target-platform acceptance remain open; no new export or milestone acceptance is claimed.

## M5 clothes, charger and toolkit packing - 2026-09-30

- **Headless:** `tools/test.ps1 -Suite All -FixedFps 30` passed **45 Python tests and 1,473 runtime checks across 17 Godot suites**, with 0 failures, including **455 Cinematic and 65 CinematicAudio checks**. Content preflight covers 12 JSON files, 319 inventoried text fields and 199 stable localization keys; only the known Cirebon slice-boundary warning remains.
- **Native Windows / Compatibility:** **455 Cinematic and 71 CinematicAudio checks passed** at a 30 FPS cap. Reviewed ready/lift/stowed captures and the following raincoat placement at 1280×720. Three separate inserts place Raka beside the upright flap and use opposing camera angles; a small forward lean keeps the clothes grip within reach. Final captures show the packed supplies retained in the bag.
- **Coverage:** 101 samples per supply insert check grip contact within 2 mm, table/bag-wall/item clearance, placement order, head/flap separation, caption framing and node stability. Pause/focus, backward seeking, direct-entry resets, reduced motion, natural prop handoffs, all-shot Skip, cleanup and save isolation pass. Raincoat placement is also sampled against all three packed supplies after adjusting their layout. Each insert triggers one fabric cue at 1.5 seconds; tests cover once-only playback and early Skip dropping later cues.
- **Content:** three three-second inserts bring the opening to **33 shots / 145 authored seconds**, including a 68-second departure sequence and **20 audio events** across the existing five sound assets. Three captions have new stable English keys; existing bindings remain unchanged. No save fields, checkpoints or story flags are added.
- **Evidence:** `.godot-test/Supplies-all30.log`, `Supplies-native.log`, `SuppliesAudio-native.log`; `tests/screenshots/supplies_ready_0.png` through `supplies_ready_2.png`, `supplies_lift_0.png` through `supplies_lift_2.png`, `supplies_stowed_0.png` through `supplies_stowed_2.png`, and `pack_placed.png`. Final logs have no failed checks or script/parse/compile errors. The known certificate-store startup message remains environmental.
- **Scope:** prototype packing actions toward the M5 prerequisite for M7. Seat changes between inserts remain editorial cuts. Final rigs/fingers/cloth, full mesh contact, preparation/luggage-carrying/fastening, human pacing/listening and target-platform acceptance remain open. No new export or milestone acceptance is claimed.

## M5 helmet retrieval - 2026-09-30

- **Headless:** `tools/test.ps1 -Suite All -FixedFps 30` passed **45 Python tests and 1,401 runtime checks across 17 Godot suites**, with 0 failures, including **392 Cinematic and 56 CinematicAudio checks**. Content validation covers 12 JSON files, 307 inventoried text fields and 196 localization keys; the existing Cirebon slice-boundary warning remains.
- **Native Windows / Compatibility:** **392 Cinematic and 62 CinematicAudio checks passed** at a 30 FPS cap. Inspected seat, grip and lift captures at 1280×720; moved the pickup camera to the opposite side after the initial view hid the resting helmet behind the tank. Actual native audio playback is covered; final human listening acceptance remains open.
- **Coverage:** 101 sampled pickup poses verify hand contact after gripping, fixed feet/bike, helmet clearance from seat/luggage, parked strap clearance and caption-safe framing. Pause/focus, rewind/reset, reduced motion, natural handoff, all-shot Skip, prop/node stability, audio timing and save isolation pass. The final pickup pose exactly matches the existing helmet-donning start.
- **Content:** one four-second shot and one reused fabric cue bring the opening to **30 shots / 136 authored seconds and 17 audio events** across the same five sound assets. A stable English catalog key covers the new caption. Webbing rests folded above the seat and unfolds once the helmet clears the motorcycle.
- **Evidence:** `.godot-test/HelmetPickup-all30.log`, `HelmetPickup-native.log`, `HelmetPickupAudio-native.log`; captures `tests/screenshots/helmet_pickup_seat.png`, `helmet_pickup_grip.png`, `helmet_pickup_lift.png`, `helmet_pickup_held.png`. Final logs have no failed checks or script/parse/compile errors. The known certificate-store startup message remains environmental.
- **Scope:** prototype opening continuity toward the M5 prerequisite for M7; production rigs/full mesh contact, remaining preparation actions and M5 human/art/platform gates remain open. No new export, Web/Android acceptance or milestone completion is claimed.

## M6 development menu and temporary journey sessions - 2026-09-29

- **Headless:** `tools/test.ps1 -Suite All -FixedFps 30` passed **45 Python tests and 1,377 runtime checks across 17 Godot suites**, including **93 Development checks**, with 0 failures. Ordinary launches reject session entry and expose no development menu. Existing story, save, phone, lifecycle, rendering and interface regressions pass.
- **Native Windows / Compatibility:** **93 Development checks passed** at a 30 FPS cap, including the final performance-toggle wiring. Reviewed the menu, scrolled flags section and gameplay overlay at 1280×720. Moved the overlay away from the normal HUD. The encounter test now waits for actual process frames after teleport, so the interaction scanner observes the position even when native rendering batches physics ticks.
- **Coverage:** seven implemented chapter/checkpoint fixtures and prerequisites, transition guard, F8/Escape dispatch, pause/dialogue preservation, released riding input, focus guard, weather override/automatic, finite bounded teleport, JSON flag validation/unset and live performance counters. Primary, backup and temporary journey files remain byte-for-byte unchanged through jumps and a real shelter encounter. Session exit and scene teardown restore the original state; normal Continue/saving works afterward.
- **Evidence:** `.godot-test/M6Development-all30.log`, `.godot-test/Development-native.log`; captures `tests/screenshots/development_menu.png`, `development_flags.png`, `development_overlay.png`. Final logs have no script/parse/compile errors, failed checks or resource-leak errors. The known certificate-store startup message remains environmental.
- **Scope:** editor-only opt-in enforced by debug/editor feature and `--dev-tools` checks. Actual release-template, Web and Android execution remains unverified; no new platform acceptance or benchmark claim is made. Journey isolation does not suppress settings persistence. M5 human/art/platform gates still precede mass chapter production. See [development menu usage](../M6_DEVELOPMENT_MENU.md).

## M6 localization and static template contracts - 2026-09-29

- **Headless:** `tools/test.ps1 -Suite All -FixedFps 30` passed **45 Python tests and 1,281 runtime checks across 16 Godot suites**, including **43 Toolkit checks**, with 0 failures. Content validation covers 12 JSON files, 303 inventoried text fields and 195 stable localization keys; only the known Cirebon boundary warning remains.
- **Catalog coverage:** missing/duplicate/invalid bindings, missing/unused catalog entries, source drift, enum bindings, optional translation completeness and locale identity. Choice/shot reorder preserves keys; seeding is dry-run by default, additive, idempotent and never overwrites existing catalog text. Runtime verifies nested resolution, fallback, source immutability and actual dialogue-loader use. All seven pre-existing JSON content files were compared to HEAD with metadata removed: every original value is unchanged.
- **Static templates:** four source scenes are parsed/instantiated off-tree; 16 broken fixtures cover missing anchors/markers/resources, invalid event bounds/weather/audio/radius, wrong dialogue/arrival IDs, unsafe preview flag settings, transformed cutscene roots, orphan shot groups and coincident camera targets. Valid JSON-only framing is accepted. Inspection preserves state/weather and frees all orphan nodes.
- **Resource pack:** exported the Web resource PCK and booted it from outside the project directory for 120 headless frames, exit 0. Export log confirms `data/localization/en.json` is included. This checks packaged resources, not an HTML5 distribution or browser acceptance.
- **Evidence:** `.godot-test/M6Toolkit-all30.log`, `toolkit-export-console.log`, `toolkit-pack-boot.log`. No script/parse/compile or game runtime errors; the known certificate-store startup message remains environmental. No new visual changes or native-render acceptance are claimed in this pass.
- **Remaining:** general development menu, broader GDScript/UI localization and M5 human/target-platform gates. See [workflow and scope](../M6_LOCALIZATION.md).

## M6 encounter authoring templates - 2026-09-29

- **Headless:** `tools/test.ps1 -Suite All -FixedFps 30` passed **30 Python tests and 1,238 runtime checks across 15 Godot suites**, including **49 Authoring checks**, with 0 failures. Content preflight covers 11 JSON files / 303 text fields; the known missing Cirebon chapter remains the single warning.
- **Native Windows / Compatibility:** **49 Authoring checks passed** at a 30 FPS cap. Reviewed road, arrival cinematic and dialogue captures at 1280×720; corrected reversed NPC labels with billboarding. Deferred render initialization/disposal fixed the initial test fixture's native sky-texture shutdown warnings; final logs contain no resource-leak or script/parse/compile errors.
- **Coverage:** road collision, marker placement, threshold weather/ambience, once-only checkpoint/restart, distance/speed/busy interaction guards, NPC animation, pause/focus, natural/Skip handoffs, both dialogue choices, local node/choice flags and conditions, reduced motion, camera-marker override, missing reference diagnostics, scene release and audio restoration. A new bundle/ID and changed NPC/weather/camera properties run through the unchanged preview host. Campaign state and save bytes are unchanged.
- **Reproduce:** [Authoring guide](../M6_AUTHORING.md). Logs: `.godot-test/M6Authoring-all30.log` and `.godot-test/Authoring-native.log`. Captures: `tests/screenshots/authoring_road.png`, `authoring_cutscene.png`, `authoring_dialogue.png`. Godot 4.7.2; Python 3.11. The existing certificate-store startup message is unrelated to offline test results.
- **Scope:** standalone authoring proof with prototype art; no new campaign chapter, platform export or M5 acceptance. Static scene validation, localization catalog and the general development menu remain open.

## M6 content validation toolkit - 2026-09-29

- Current content: **9 JSON files, 0 errors, 1 expected warning, 287 inventoried text fields**. The warning is the existing Karawang-to-Cirebon slice boundary; `--strict` exits 1 for it.
- **30 Python fault-injection tests passed** through `tools/test.ps1 -Suite All -FixedFps 30`, followed by **1,189 Godot runtime checks across 14 suites, 0 failures**. Log: `.godot-test/M6Content-all30.log`. Python 3.11 and Godot 4.7.2 Compatibility on Windows.
- Covered duplicate keys/IDs, broken dialogue edges and trapped cycles, conditional-choice fallback, blank text, malformed JSON/types, missing/escaping resources, corrupt/truncated WAV, missing cue/weather/phone references, ordered timings, chapter boundaries, route bounds, deterministic reporting and byte-for-byte read-only behavior.
- `Content` runs without Godot; `All` stops on invalid content before importing the project. JSON reporting and strict/non-strict exit behavior were tested. Test fixtures are disposable copies under `.godot-test`; no player saves or source content are modified.
- Runtime/game data are unchanged. No new native-render, PCK, browser or Android acceptance is claimed for this tooling pass. Existing sandbox certificate-store startup messages remain unrelated to the offline runtime checks.
- M6 remains in progress: templates, runtime bundle registration, development controls, localization keys/catalog validation and the new-encounter gate are pending. See [tool usage and limits](../M6_CONTENT_TOOLS.md).

## M5 chin-strap fastening - 2026-09-29

- **Headless:** all 14 suites passed, 1,188 checks. The final loose-buckle clearance correction and added assertion passed the Cinematic rerun: **371 checks**, yielding **1,189 checks / 0 failures** across final suite results (53 CinematicAudio).
- **Native Windows / Compatibility:** **371 Cinematic and 59 CinematicAudio checks passed** at a 30 FPS cap. Loose, joined, pulling and secured close-ups plus held-helmet webbing were inspected at 1280×720. Loose buckle endpoints were moved forward after capture revealed torso overlap.
- **Coverage:** 101 samples check hand contact, helmet anchors, buckle/tail torso clearance, planted feet, stationary bike, framing and node stability. Also verified pause/focus, rewind, reduced motion, exact helmet-to-strap-to-mount handoffs, secured departure, interior hiding, all-shot Skip snapshots, once-only sound timing and unchanged saves/checkpoints.
- **Timeline:** 29 shots / 132 authored seconds (departure 55), five sound assets / sixteen events. Chin-strap fabric at 2.5 seconds; existing memory bridge unchanged.
- **Resource pack:** 1,758,024-byte PCK exported and booted independently, exit 0 after 120 frames. Final logs contain no script/parse/compile errors. The existing sandbox certificate-store startup message is unrelated to these offline checks.
- **Pending:** production shell/cheek/neck/finger contact, buckle hardware and cloth behavior, recorded fastening sound, human review and actual Web/Android acceptance. Point checks do not certify full mesh collision or mechanical restraint.

Reproduce with `tools/test.ps1 -Suite All -FixedFps 30`; final `-Suite Cinematic -FixedFps 30`; native `-Suite Cinematic -Visual -FixedFps 30` and `-Suite CinematicAudio -Visual -FixedFps 30`. Ignored logs: `.godot-test/ChinStrap-all30.log`, `ChinStrap-final-headless.log`, `ChinStrap-native30.log`, `ChinStrapAudio-native30.log`, `chin-strap-export.log`, `chin-strap-pack-boot.log`. Captures: `tests/screenshots/chin_strap_*.png`. See the [strap review checklist](M5_CINEMATIC_PLAYTEST.md#chin-strap-fastening-pass).

## M5 helmet preparation - 2026-09-29

- **Headless:** all 14 suites passed, **1,165 checks / 0 failures**, including 349 Cinematic and 51 CinematicAudio, at fixed 30 cadence.
- **Native Windows / Compatibility:** 349 Cinematic and 57 CinematicAudio checks passed at a 30 FPS cap. Held, raised, overhead and worn helmet frames inspected at 1280×720; shoulder connectors corrected after visual review.
- **Coverage:** 101 samples for two-hand targets, connected shoulders, stationary shoes/bike, framing and node stability; pause/focus, rewind, reduced motion, hidden-helmet reset, exact mounting handoff, all-shot Skip equivalence, once-only fabric timing and memory tail. Opening: 28 shots / 128 seconds, fifteen events; saves/checkpoints unchanged.
- **Resource pack:** 1,754,044-byte PCK exported and booted independently, exit 0 after 120 frames. Final logs contain no script/parse/compile errors; the existing sandbox certificate-store message remains unrelated to these offline checks.
- **Still open:** helmet retrieval/chin-strap fastening, final shell/head/finger contact and shoulder deformation, recorded foley, human pacing and actual Web/Android acceptance. The existing closed helmet mesh remains a blocking asset; point checks do not certify full mesh clearance.

Reproduce: `tools/test.ps1 -Suite All -FixedFps 30`, plus `-Suite Cinematic -Visual -FixedFps 30` and `-Suite CinematicAudio -Visual -FixedFps 30`. Ignored logs: `.godot-test/Helmet-all30.log`, `Helmet-native30.log`, `HelmetAudio-native30.log`, `helmet-export.log`, `helmet-pack-boot.log`. Captures: `tests/screenshots/helmet_*.png`. See the [helmet review checklist](M5_CINEMATIC_PLAYTEST.md#helmet-preparation-pass).

## M5 motorcycle mounting - 2026-09-29

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility; native Windows at 1280×720 with a 30 FPS cap.

| Check | Result |
| --- | --- |
| Full headless regression, fixed 30 cadence | **96 Story + 34 Practice + 30 Cockpit + 21 RoadRender + 145 Lifecycle + 57 TouchLayout + 79 Input + 60 Narrative + 52 Mood + 71 Audio + 329 Cinematic + 49 CinematicAudio + 79 Phone + 41 Interface = 1,143 checks, 0 failures** |
| Native Cinematic | **329 checks, 0 failures**; mounting, all-shot Skip equivalence including shoe transforms, prior packing/strap/wipe/waking/walking/memory regressions and checkpoint handoffs |
| Native CinematicAudio | **55 checks, 0 failures**; mounting fabric event, memory tail into mounting, native playback/mixer/pause and Skip cleanup |
| Geometry / state | 101 samples check the initially planted left foot, level shoes above the surface, shoe-corner luggage clearance, caption-safe framing and constant node count; final grip contact, exact seated-pose handoff, pause/focus, rewind, reduced motion and unchanged journey state |
| Visual review | Standing, lift, crossing, seated, departure and shifted strap-check views inspected. Corrected the initial support-foot reach and a camera outside the parking wall; widened final framing to show the bike above the caption bar |
| Timeline | **27 shots / 123 authored seconds**, departure 46 seconds; five sound assets / fourteen events. Memory sound ends 1.4 seconds into mounting; fabric at 2.5 seconds. Save schema/checkpoints unchanged |
| Resource PCK / independent boot | **Pass**, 1,751,048 bytes; final pack boots outside the source project and exits 0 after 120 frames. Exporting resources does not establish browser/Android acceptance |
| Remaining | Helmet donning, cloth storage, preparation/sitting transitions, full body mesh contact and physical balance, production rigs/fingers/foley, human review and real Web/Android acceptance |

Reproduce with `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite All -FixedFps 30`; native `-Suite Cinematic -Visual -FixedFps 30` and `-Suite CinematicAudio -Visual -FixedFps 30`. Ignored logs: `.godot-test/Mount-all30.log`, `Mount-native30.log`, `MountAudio-native30.log`, `mount-export.log`, `mount-pack-boot.log`. Captures: `tests/screenshots/mount_*.png`. See the [mounting review checklist](M5_CINEMATIC_PLAYTEST.md#motorcycle-mounting-pass).

These bounded point checks do not certify full mesh collision, weight transfer or final animation acceptance. Native captures are desktop evidence, not physical Android/browser testing. The existing sandbox certificate-store startup message is unrelated to offline checks.

## M5 bike touch and memory - 2026-09-29

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility; native Windows at 1280×720 with a 30 FPS cap.

| Check | Result |
| --- | --- |
| Headless regression | **96 Story + 34 Practice + 30 Cockpit + 21 RoadRender + 145 Lifecycle + 57 TouchLayout + 79 Input + 60 Narrative + 52 Mood + 71 Audio + 304 Cinematic + 48 CinematicAudio + 79 Phone + 41 Interface = 1,117 checks, 0 failures** across final suite results |
| Run scope | Full All run passed 1,116 checks; the final camera refinement and additional torso-occlusion assertion were verified by rerunning Cinematic: **304 checks, 0 failures** |
| Native Cinematic | **304 checks, 0 failures**; tank wiping, held cloth, all-shot Skip equivalence, existing packing/strap/waking/walking/memory regressions and checkpoint handoffs |
| Native CinematicAudio | **54 checks, 0 failures**; two wiping cues, memory bridge moved to bike touch, once-only scheduling, native mixer/playback/pause and Skip cleanup |
| Geometry / state | 101 samples check hand/cloth contact within 2 mm, modeled tank-surface offset, cap separation, stationary legs/bike, cloth framing, torso occlusion and node stability; stroke return, pause/focus, rewind, reduced motion, no journey-state changes and no cloth leaking into memory/departure/morning |
| Visual review | Ready, contact, wiping and withdrawal inspected. Camera refined to expose the cloth beyond the handlebars and torso; the final headless/native camera checks pass |
| Timeline | **26 shots / 118 authored seconds**, departure 41 seconds; five sound assets / thirteen events. The motor cue starts 0.6 seconds before memory and ends 1.4 seconds into departure. No new save fields or checkpoint IDs |
| Resource PCK / independent boot | **Pass**, 1,747,524 bytes; final pack boots outside the source project and exits 0 after 120 frames |
| Remaining | Production palm/fingers/cloth/mesh contact, visible dust removal, expression, standing transitions, cloth retrieval/storage, recorded wiping sound, human review and actual Web/Android acceptance |

Reproduce with `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite All -FixedFps 30`; native `-Suite Cinematic -Visual -FixedFps 30` and `-Suite CinematicAudio -Visual -FixedFps 30`. Ignored logs: `.godot-test/BikeTouch-all30.log`, `BikeTouch-final-headless.log`, `BikeTouch-native30.log`, `BikeTouchAudio-native30.log`, `bike-touch-export.log`, `bike-touch-pack-boot.log`. Captures: `tests/screenshots/bike_touch_*.png`. See the [bike-touch review checklist](M5_CINEMATIC_PLAYTEST.md#bike-touch-pass).

The rigid cloth follows a modeled ellipsoid; point and torso-box checks do not certify complete faceted-mesh contact, finger grips, cloth deformation or every possible occluder. Final test logs contain no game script errors. The existing sandbox certificate-store startup message remains unrelated to offline checks; resource-pack export does not establish browser/Android acceptance.

## M5 luggage strap check - 2026-09-28

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility; native Windows at 1280×720 with a 30 FPS cap.

| Check | Result |
| --- | --- |
| Full headless regression, fixed 30 cadence | **96 Story + 34 Practice + 30 Cockpit + 21 RoadRender + 145 Lifecycle + 57 TouchLayout + 79 Input + 60 Narrative + 52 Mood + 71 Audio + 279 Cinematic + 46 CinematicAudio + 79 Phone + 41 Interface = 1,090 checks, 0 failures** |
| Native Cinematic | **279 checks, 0 failures**; standing two-strap action, existing packing/waking/walking/phone/memory, all-shot Skip equivalence and checkpoint restoration |
| Native CinematicAudio | **52 checks, 0 failures**; two added fabric events, unchanged memory bridge timing, native playback/mixer/pause/focus and Skip cleanup |
| Contact / geometry | 101 samples check hand grips within 2 mm, grip clearance in front of the torso, unchanged leg transforms, fixed frame endpoints, luggage/grip framing and constant node count |
| Continuity / state | Ordered tightening, short secured tails, pause/focus, rewind/repeated seeking, reduced motion, unchanged journey state, memory-stage disposal, identical secured bag on return, movement with the departing motorcycle and no luggage on the morning approach |
| Visual inspection / fixes | Ready, both pulls and secured poses inspected. Pull direction and camera refined to separate hands from the torso and expose both buckles. Direct basis construction fixes numerical drift from repeated rotation/scale decomposition; final full regression and native runs pass |
| Timeline | **25 shots / 113 authored seconds**, five sound assets / eleven events; no new save fields or checkpoint IDs |
| Resource PCK / independent boot | **Pass**, 1,744,376 bytes; pack boots outside the source project and exits 0 after 120 frames |
| Remaining | Carrying/placing luggage, initial strap threading/fastening, bike-touch gesture, mounting transitions, production fingers/cloth/foley, human review and real Web/Android acceptance |

Reproduce with `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite All -FixedFps 30`; native `-Suite Cinematic -Visual -FixedFps 30` and `-Suite CinematicAudio -Visual -FixedFps 30`. Final ignored logs: `.godot-test/Straps-all30.log`, `Straps-native30.log`, `StrapsAudio-native30.log`, `straps-export.log`, `straps-pack-boot.log`. Captures: `tests/screenshots/straps_*.png`. See the [strap review checklist](M5_CINEMATIC_PLAYTEST.md#luggage-strap-check-pass).

These bounded checks cover the authored prototype, not all mesh intersections, physical cargo restraint or production cloth behavior. Final test/export/boot logs contain no game script errors. The existing sandbox certificate-store startup message remains unrelated to offline checks; exporting a resource PCK does not establish browser or Android acceptance.

## M5 laptop packing - 2026-09-28

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility; native Windows at 1280×720 with a 30 FPS cap.

| Check | Result |
| --- | --- |
| Full headless regression, fixed 30 cadence | **96 Story + 34 Practice + 30 Cockpit + 21 RoadRender + 145 Lifecycle + 57 TouchLayout + 79 Input + 60 Narrative + 52 Mood + 71 Audio + 258 Cinematic + 44 CinematicAudio + 79 Phone + 41 Interface = 1,067 checks, 0 failures** |
| Native Cinematic | **258 checks, 0 failures**; laptop closure/transfer/stowage, existing raincoat/waking/walking/phone/memory, all-shot Skip equivalence and checkpoint handoffs |
| Native CinematicAudio | **50 checks, 0 failures**; two added fabric events, memory bridge, native playback/pause/resume, SFX output and Skip cleanup |
| Geometry / framing | 101 samples check lid, both carry grips and flap contact within 2 mm; lift-before-transfer; laptop bounds against four bag walls; base/lid projection between caption bars; final fit above raincoat and below flap |
| State / lifecycle | Open route screen before packing; sampled prop/hand/chair restoration; rewind, pause/focus and reduced-motion behavior; fixed node count; unchanged journey state; interior props freed on parking cut |
| Native inspection | Ready, closed, lifting and packed poses reviewed. Initial lateral laptop placement refined to leave a gap beside the bag; final geometry/framing tests and native rerun passed |
| Timeline | **25 shots / 113 authored seconds**, departure 36 seconds; five sound assets / nine authored events; no save format or checkpoint changes |
| Resource PCK / independent boot | **Pass**, 1,740,964 bytes; pack boots from outside the source project and exits 0 after 120 frames |
| Remaining | Preparation actions across the cut, individual remaining items, luggage fastening, production finger/cloth/posture/contact/foley, human pacing/listening and actual Web/Android acceptance |

Reproduce with `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite All -FixedFps 30`; native `-Suite Cinematic -Visual -FixedFps 30` and `-Suite CinematicAudio -Visual -FixedFps 30`. Ignored logs: `.godot-test/Laptop-all30.log`, `Laptop-native30.log`, `LaptopAudio-native30.log`, `laptop-export.log`, `laptop-pack-boot.log`. Captures: `tests/screenshots/laptop_*.png`. See the [laptop review checklist](M5_CINEMATIC_PLAYTEST.md#laptop-packing-pass).

Contact and box-bound checks cover the authored prototype; they do not establish full character mesh collision, finger grips or cloth behavior. Final test/export/boot logs contain no game script errors. The existing sandbox certificate-store startup message remains unrelated to these offline checks. A PCK is not a browser or Android build.

## M5 packing performance - 2026-09-28

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility; native Windows at 1280×720, capped at 30 FPS.

| Check | Result |
| --- | --- |
| Headless regression | **1,041 checks, 0 failures** across the final suite results: 96 Story + 34 Practice + 30 Cockpit + 21 RoadRender + 145 Lifecycle + 57 TouchLayout + 79 Input + 60 Narrative + 52 Mood + 71 Audio + 234 Cinematic + 42 CinematicAudio + 79 Phone + 41 Interface |
| Run scope | Full All run passed 1,040 checks. A final camera correction and new framing assertion were then verified by rerunning Cinematic: **234 checks, 0 failures** |
| Native Cinematic | **234 checks, 0 failures**, including natural completion, all-shot actor/prop Skip equivalence and departure checkpoint recovery |
| Packing action | Raincoat pickup, clearance over bag wall, release inside, right-hand flap closure; 101 samples verify grip/contact and projected prop bounds between caption bars |
| State/lifecycle | Pause/focus freeze, deterministic rewind, reduced-motion independence, fixed node count during sampling, packed state on direct route entry, badge/actor reset and unchanged journey state |
| Visual inspection | Open bag, lift, placement, closing and closed poses reviewed. Initial raincoat framing overlapped the caption bar; the camera was raised/pulled back and FOV widened, then the final framing assertion and native captures passed |
| Resource PCK / independent boot | **Pass**, 1,737,360 bytes; boot from the pack outside the source project exits 0 after 120 frames |
| Pending | Remaining item/laptop packing, luggage fastening, production rig/finger/cloth/contact/foley, human pacing review and actual Web/Android acceptance |

Reproduce with `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite All -FixedFps 30` and `-Suite Cinematic -Visual -FixedFps 30`. Logs: `.godot-test/Packing-all30.log`, `Packing-final-headless.log`, `Packing-native30.log`, `packing-export.log`, `packing-pack-boot.log`; captures: `tests/screenshots/pack_*.png` (all ignored). See the [packing review](M5_CINEMATIC_PLAYTEST.md#packing-performance-pass).

The geometric assertions cover authored points and bounds, not full mesh collision or production animation acceptance. Final test/boot logs have no game script errors; the existing sandbox certificate-store startup message remains unrelated to offline tests. Resource-pack export is not an actual browser or Android build.

## M5 waking performance - 2026-09-28

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility; native Windows / NVIDIA RTX 3050 Laptop GPU at 1280×720 and a 30 FPS cap.

| Check | Result |
| --- | --- |
| Combined headless suites, fixed 30 cadence | **96 Story + 34 Practice + 30 Cockpit + 21 RoadRender + 145 Lifecycle + 57 TouchLayout + 79 Input + 60 Narrative + 52 Mood + 71 Audio + 191 Cinematic + 42 CinematicAudio + 79 Phone + 41 Interface = 998 checks, 0 failures** |
| Native Cinematic | **191 checks, 0 failures**; lying-to-seated waking, existing walking/phone/packing/memory poses, all-shot natural/Skip equivalence and checkpoint handoffs |
| Native CinematicAudio | **48 checks, 0 failures**; waking cloth onset at 1.6 seconds, late-frame offset, Skip cleanup and existing native playback/pause/SFX tests |
| Waking state | Horizontal/upright torso, bed root endpoints, bare feet, deterministic seeking, pause/focus freeze, reduced-camera-motion independence and reset of torso/head/leg offsets/phone placement |
| Geometry and visuals | Bedside alarm plus lying/rising/seated native captures inspected. First pass bent shins through the mattress; root travel now clears the foot edge before bending. Forty-one timeline samples verify bounded knee/shin centerline clearance |
| Narrative/save contract | Existing `room` shot ID and five-second duration retained; **24 shots / 105 seconds**, eight actor clips and seven timed sound events. No save schema, checkpoint or story flag changes |
| Resource PCK / independent boot | **Pass**, 1,733,572 bytes; main scene boots from the pack outside the source project and exits 0 after 120 frames |
| Remaining acceptance | Human pacing/weight transfer, final bed/hand contact, face/eye/costume/cloth refinement, recorded bedsheet sound, real Web/Android performance and mobile framing |

Reproduce with `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite All -FixedFps 30`, and native `-Suite Cinematic -Visual -FixedFps 30` / `-Suite CinematicAudio -Visual -FixedFps 30`. Native logs: `.godot-test/Waking-native30.log`, `WakingAudio-native30.log`; captures: `tests/screenshots/wake_*.png`; pack logs: `.godot-test/waking-export.log`, `waking-pack-boot.log` (all ignored). See [Waking review](M5_CINEMATIC_PLAYTEST.md#waking-performance-pass).

The native checks and captures use the prototype rig. Centerline samples do not certify full mesh contact, foot locking or cloth deformation; no human animation/listening acceptance is claimed. Final test and boot logs contain no game script errors or renderer disposal warnings. The existing sandbox certificate-store startup message remains unrelated to these offline tests.

## M5 walking performances - 2026-09-28

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility; native Windows / NVIDIA RTX 3050 Laptop GPU at 1280×720 and a 30 FPS cap.

| Check | Result |
| --- | --- |
| Combined final headless results, fixed 30 cadence | **96 Story + 34 Practice + 30 Cockpit + 21 RoadRender + 145 Lifecycle + 57 TouchLayout + 79 Input + 60 Narrative + 52 Mood + 71 Audio + 173 Cinematic + 39 CinematicAudio + 79 Phone + 41 Interface = 977 checks, 0 failures** |
| Native Cinematic | **173 checks, 0 failures**; includes all-shot natural/skip final-state equivalence and the two walking approaches |
| Walking behavior | Authored root position/direction and alternating hip/knee/arm gait, neutral endpoints, deterministic backward seeking, pause and reduced-camera-motion independence |
| Pose handoffs | Parked motorcycle remains stationary; only one Raka appears during approach; cluster/meeting cuts restore rider/seated poses and original seated proportions; phone, packing and father-memory regression checks pass |
| Framing | Native start/mid/end views inspected for both walks; office camera widened/repositioned after initial inspection; six projection checks keep head/feet between cinematic bars at the test viewport |
| Narrative contract | One new four-second office shot; **24 shots / 105 authored seconds** across five sequences; existing flags/checkpoint IDs/schema and six cinematic sound events retained |
| Resource PCK / independent boot | **Pass**, 1,731,412 bytes; main scene boots from the pack outside the source project and exits 0 after 120 frames |
| Human/final/platform acceptance | **Pending**: natural-speed gait, foot locking, furniture contact on final rigs, mounting/sitting transitions, recorded footsteps, mobile aspect ratios and actual Web/Android performance |

Reproduce with `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite All -FixedFps 30` and `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Cinematic -Visual -FixedFps 30`; native log retained as `.godot-test/Walking-native30.log`, captures in `tests/screenshots/walk_*.png`, pack logs in `.godot-test/walking-export.log` and `walking-pack-boot.log` (ignored). See [Walking review](M5_CINEMATIC_PLAYTEST.md#walking-performance-pass).

The headless runner initially supplied a square 1280×1280 viewport, causing two horizontal projection assertions to fail despite the native landscape captures passing. The Cinematic harness now explicitly requests the same 1280×720 landscape viewport for both backends. This scopes framing checks to that viewport; it does not certify every aspect ratio. Native verification preceded this harness-only normalization and failure-diagnostic addition; production scripts/data are the same. The existing sandbox certificate-store startup message remains unrelated to offline gameplay.

## M4/M5 scene-transition lifecycle - 2026-09-28

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility; native Windows / NVIDIA RTX 3050 Laptop GPU at a 30 FPS cap. This update adds a regression harness and documentation; production behavior and save schema are unchanged.

| Check | Result |
| --- | --- |
| Combined headless suites, fixed 30 render cadence | **96 Story + 34 Practice + 30 Cockpit + 21 RoadRender + 145 Lifecycle + 57 TouchLayout + 79 Input + 60 Narrative + 52 Mood + 71 Audio + 142 Cinematic + 39 CinematicAudio + 79 Phone + 41 Interface = 946 checks, 0 failures** |
| Native Lifecycle, three cycles | **145 checks, 0 failures**; actual title/practice replacements, interrupted opening/Continue, prologue handoffs, shelter/rest/reflection and completed Continue |
| Extended headless Lifecycle, ten cycles at fixed 30 cadence | **481 checks, 0 failures**; each cycle restores baseline node/orphan counts, signal connections, material-cache cleanup and audio pool size |
| Native cleanup baseline | **20 live nodes / 0 orphan nodes** before loading and after all three cycles; singleton/viewport subscriptions return to baseline; material cache empties; watched scene/world/stage/marking resources expire |
| Native menu snapshots | **2,060 live nodes / 0 orphans**, 67 cached materials on each return; audio retains its original **13 players / 7 buses** |
| Native diagnostic memory | Empty-tree static memory warms from 35,417,527 bytes initially to 69,197,970 / 69,237,374 / 69,243,602 after cycles; reported resource count 45 initially, 49 after each cycle. These observations do not establish OS/GPU memory acceptance |
| Input/audio/save | Simulated focus loss releases held two-finger riding input and pauses/suspends audio; focus return leaves explicit Resume required; practice preserves story state/save bytes; completed Continue does not rewrite the save or replay music |
| Target-platform and duration gates | **Pending**: real Web/Android lifecycle, natural-speed extended play, OS/GPU memory and thermal profiling |

Use the [Lifecycle guide](LIFECYCLE.md) for commands, exact route, report fields and limits. Native evidence is retained locally in `.godot-test/LifecycleTests-native30.log` and `lifecycle-native30.json`; standard headless evidence in `LifecycleTests-headless30.log` and `lifecycle-headless30.json`; extended evidence in `LifecycleTests-ten-cycles.log` and `lifecycle-ten-cycles.json`. All artifacts are ignored by Git. Tests/tools/docs remain excluded by both export presets; no production export change is introduced.

An initial harness run referenced a nonexistent input-action constant; it was corrected to the current eight riding actions before the final runs. Final suites have no game script errors or native renderer disposal warnings. The existing sandbox root-certificate-store startup error remains unrelated to these offline tests.

## M4/M5 road-marking batches - 2026-09-28

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility; native Windows / NVIDIA RTX 3050 Laptop GPU at a 30 FPS cap.

| Check | Result |
| --- | --- |
| Combined headless suites, fixed 30 render cadence | **96 Story + 34 Practice + 30 Cockpit + 21 RoadRender + 57 TouchLayout + 79 Input + 60 Narrative + 52 Mood + 71 Audio + 142 Cinematic + 39 CinematicAudio + 79 Phone + 41 Interface = 801 checks, 0 failures** |
| Native RoadRender suite | **37 checks, 0 failures**; includes four GPU-backed transform/culling checks and 12 native draw-call probes omitted from headless |
| Geometry | All 468 story / 90 practice marks preserved with original transforms and dimensions, shared meshes and no added collision; render nodes reduced to 42 / 8 |
| Native before/after | All 12 fixed-camera Low/Medium views improved, **6.7–25.7% fewer draw calls**; full counts and measurement constraints in [Road rendering review](ROAD_RENDER.md) |
| Native visual review | Story road before/after and practice bend inspected; no nearby paint placement discrepancy observed; conservative chunk culling can retain distant marks longer |
| Lifecycle | Both measured worlds plus four alternating world loads disposed; node count returns to baseline, weak MultiMesh/BoxMesh references expire, save bytes remain unchanged |
| Resource PCK export / independent boot | **Pass**, 1,728,308 bytes; main scene boots outside source project and exits 0 after 120 frames |
| Actual Web/Android FPS, GPU/OS memory soak and thermal profiling | **Pending**; desktop counters and resource-reference checks do not establish these gates |

Reproduce with `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite All -FixedFps 30` and `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite RoadRender -Visual -FixedFps 30`. Native logs: `.godot-test/road-render-before.log` and `RoadRenderTests-native30.log`; captures: `tests/screenshots/road_render_*.png`; export/boot logs: `.godot-test/road-render-export.log` and `road-render-pack-boot.log` (ignored).

During validation, the headless Dummy backend returned identity MultiMesh transforms, so actual transform/culling-extents verification remains native-only. The first native stress harness freed freshly built environments before rendering; it emitted GLES texture warnings on shutdown. Letting each world complete a draw before disposal and a frame after disposal removed those warnings in the final run. No production workaround or GPU-memory acceptance is claimed. The existing sandbox certificate-store startup error remains; final tests have no game parser/runtime errors or native texture warnings.

## M2 paired touch placement - 2026-09-27

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility; native Windows / NVIDIA RTX 3050 Laptop GPU at a 30 FPS cap.

| Check | Result |
| --- | --- |
| Combined headless suites, fixed 30 render cadence | **96 Story + 34 Practice + 30 Cockpit + 57 TouchLayout + 79 Input + 60 Narrative + 52 Mood + 71 Audio + 142 Cinematic + 39 CinematicAudio + 79 Phone + 41 Interface = 780 checks, 0 failures** |
| Native TouchLayout suite, actual 30 FPS cap | **57 checks, 0 failures** |
| Settings and migration | Four positions persist, survive New Game, normalize bounds/nonfinite/partial/malformed values and preserve original defaults for older settings |
| UI | Real slider callbacks save/apply and update the noninteractive preview; Reset restores positions and readouts without changing size |
| Layout | 27 combinations across 1280x720, 1600x720 and 960x540 windows, three button sizes and three placements at requested 125% UI with simulated insets; controls and interaction remain disjoint and inside bounds |
| Input | Nine two-finger steering/throttle cases hit moved/scaled buttons; layout/resize releases ownership, unrelated SFX volume changes preserve it |
| Isolation | Preview cannot drive; preference/reset leaves checkpoint bytes unchanged; story and practice share the chosen placement |
| Native visual inspection | Settings preview and asymmetric layouts at standard/small window sizes inspected; larger controls remain within safe bounds |
| Resource PCK export / independent boot | **Pass**, 1,726,048 bytes; packed main scene boots outside source project and exits 0 after 120 frames |
| Physical thumb comfort, real Web/Android | **Pending**, see [touch-position review](M2_PLAYTEST.md#touch-position-preference) |

Reproduce with `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite All -FixedFps 30` and `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite TouchLayout -Visual -FixedFps 30`. Native log: `.godot-test/TouchLayoutTests-native30.log`; captures: `tests/screenshots/touch_layout_*.png`; export/boot logs: `.godot-test/touch-layout-export.log` and `touch-layout-pack-boot.log` (ignored).

The native test initially injected viewport-local positions as window input, applying the native stretch twice at 960x540. It now uses `Viewport.push_input(event, true)` consistently with the coordinate space produced by the control transform. An initial indentation error in the new test was corrected before final runs. Final runs have no game parser/runtime errors; the existing sandbox certificate-store startup error remains. Desktop input injection and PCK boot do not certify real browser/Android behavior or thumb ergonomics.

## M1/M4 analog cockpit - 2026-09-27

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility; native Windows / NVIDIA RTX 3050 Laptop GPU at a 30 FPS cap.

| Check | Result |
| --- | --- |
| Combined headless suites, fixed 30 render cadence | **96 Story + 34 Practice + 30 Cockpit + 79 Input + 60 Narrative + 52 Mood + 71 Audio + 142 Cinematic + 39 CinematicAudio + 79 Phone + 41 Interface = 723 checks, 0 failures** |
| Native Cockpit suite, actual 30 FPS cap | **30 checks, 0 failures** |
| Dial calibration | Both needles align at zero/midpoint/full scale; bounds and nonfinite values remain safe; numbered major/minor marks and units use depth testing |
| Controller | Powered idle, throttle response, cruise range, engine-off coasting, immediate stop/recovery, equal 30/60-update easing, real physics input and pause verified |
| Lighting/resources | Morning/night follow active headlight; parked bike stays unlit; three materials are per-cluster, geometry/material counts stay fixed during updates |
| Isolation/lifecycle | Practice leaves story memory and save bytes intact; story Continue restores powered instruments; story stop clears readings |
| Native visual inspection | Forward and downward glance at Morning/Night plus unpowered panel at 1280x720; numbers enlarged after initial inspection; numeric speed HUD retained |
| Resource PCK export and independent boot | **Pass**, 1,723,744 bytes; packed main scene boots outside source project and exits 0 after 120 frames |
| Human/device readability, final reference-reviewed bike art, real Web/Android | **Pending**, see [analog cockpit review](M4_PLAYTEST.md#analog-cockpit-review) |

Reproduce with `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite All -FixedFps 30` and `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Cockpit -Visual -FixedFps 30`. Native log: `.godot-test/CockpitTests-native30.log`; captures: `tests/screenshots/cockpit_*.png`; export/boot logs: `.godot-test/cockpit-export.log` and `cockpit-pack-boot.log` (ignored).

The native test initially read the headlight before its render-frame update. It now waits for a complete `_process` cycle after changing weather rather than assuming three physics ticks imply a rendered frame at 30 FPS. Angle comparisons allow normal floating-point conversion. Final runs contain no game parser/runtime errors; the existing sandbox certificate-store startup error remains. Native captures/PCK boot do not establish physical-device readability or real browser/APK acceptance.

## M5 cinematic sound timeline - 2026-09-27

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility; native Windows / NVIDIA RTX 3050 Laptop GPU at a 30 FPS cap.

| Check | Result |
| --- | --- |
| Combined headless suites, fixed 30 render cadence | **96 Story + 34 Practice + 79 Input + 60 Narrative + 52 Mood + 71 Audio + 142 Cinematic + 39 CinematicAudio + 79 Phone + 41 Interface = 693 checks, 0 failures** |
| Native CinematicAudio suite, actual 30 FPS cap | **45 checks, 0 failures**, including SFX sample meter, playback advancement, pause position and resume |
| Authored data/assets | Five short nonlooping assets, six ordered in-shot events with valid bank references; two SFX voices maximum |
| Timeline | Offset crossing starts once at the elapsed sample position; stale events discarded; packing gestures both fire; motor bridges straps to memory to present and ends during title |
| Lifecycle | Activation, mute/unmute, skip, replacement, cancellation, natural completion and director disposal clear or preserve sound as appropriate; background/pause freeze shot and cue clocks |
| Isolation | No new save fields; snapshot and checkpoint bytes unchanged by sound; existing story/cinematic checkpoint tests pass |
| Source WAV checks | Mono 22,050 Hz PCM, 0.45–4.0 seconds; peak 0.2200–0.3801 full scale, RMS 0.0604–0.1159, first/last samples zero, no clipping; regeneration byte-identical for all five assets |
| Resource PCK export / independent boot | **Pass**, 1,720,804 bytes; five imported samples, bank and audio script included; main scene boots outside source project and exits 0 after 120 frames |
| Human listening, final recording/contact timing, physical Android and real Web | **Pending**, see [cinematic sound review](M5_CINEMATIC_PLAYTEST.md#cinematic-sound-pass) |

Reproduce with `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite All -FixedFps 30` and `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite CinematicAudio -Visual -FixedFps 30`. Native log: `.godot-test/CinematicAudioTests-native30.log`; export/boot logs: `.godot-test/cinematic-audio-export.log` and `cinematic-audio-pack-boot.log` (ignored). All final runs have no game parser/runtime errors; the existing sandbox certificate-store startup error remains. Mixer measurements verify signal flow, not subjective sound quality; native/PCK checks do not certify browser or Android behavior.

## M2/M5 interface scaling - 2026-09-27

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility; native Windows / NVIDIA RTX 3050 Laptop GPU at a 30 FPS cap.

| Check | Result |
| --- | --- |
| Combined headless suites, fixed 30 render cadence | **96 Story + 34 Practice + 79 Input + 60 Narrative + 52 Mood + 71 Audio + 142 Cinematic + 79 Phone + 41 Interface = 654 checks, 0 failures** |
| Native Interface suite, actual 30 FPS cap | **41 checks, 0 failures** |
| Settings | Three choices persist and apply without rebuilding the current menu; New Game preserves size; legacy/malformed/nonfinite values normalize safely |
| Safe layout | All sizes at 1280×720, 1600×720 and 1280×960 with simulated insets retain transformed safe bounds; constrained bounds limit enlargement without rewriting the choice |
| Largest screen layouts | Title, settings, controls, phone, photo detail, map, journal, dialogue, cinematic and completion content remain within horizontal safe bounds |
| Focus and reading | Title's last action, photo close button and final dialogue choice become reachable by focus scrolling; longest authored cinematic caption fits with 28-point text and 125% UI |
| Touch and isolation | Two-finger input hits scaled visuals with Largest touch buttons; interaction stays clear; resizing releases fingers; page previews preserve story snapshot, save bytes and camera FOV |
| Native visual inspection | Enlarged settings, title/menu bottom, photo/caption navigation, dialogue/final choice, cinematic caption and riding HUD inspected at 1280×720 |
| Resource PCK export and independent boot | **Pass**, 1,275,480 bytes; packed main scene boots outside the project and exits 0 after 120 frames |
| Human readability, physical Android and real Web | **Pending**, see [interface review guide](M2_PLAYTEST.md#interface-size-preference) |

Reproduce with `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite All -FixedFps 30` and `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Interface -Visual -FixedFps 30`. Native log: `.godot-test/InterfaceTests-native30.log`; captures: `tests/screenshots/interface_125_*.png`; export/boot logs: `.godot-test/interface-export.log` and `interface-pack-boot.log` (ignored).

Visual inspection caught broken words on compact HUD buttons; wrapping is now limited to vertical menu buttons and the cinematic skip button has adequate width. Focus-scroll checks allow two viewport pixels of border rounding because Godot's integer scroll offset can leave about 1.25 pixels at 125% scale. Content remains readable and focused actions reachable. Final runs contain no game parser/runtime errors; the existing sandbox certificate-store startup error remains. Native checks and PCK boot do not certify real browser/APK behavior or physical readability.

## M4/M5 interface sound set - 2026-09-27

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility; native Windows / NVIDIA RTX 3050 Laptop GPU with a 30 FPS cap preserved through settings save/load.

| Check | Result |
| --- | --- |
| Combined headless suites, fixed 30 render cadence | **96 Story + 34 Practice + 79 Input + 60 Narrative + 52 Mood + 71 Audio + 142 Cinematic + 79 Phone = 613 checks, 0 failures** |
| Native Audio suite, actual 30 FPS cap | **76 checks, 0 failures**; includes live playback, pause state, loop retention, UI playback clock and SFX bus sample meter |
| UI resources and routing | Three nonlooping 100–180 ms WAVs; one UI playback voice; UI sends to the earlier SFX bus, then Master |
| Activation and callbacks | Keyboard Enter activates Settings and unlocks audio; selector/back/confirmation callbacks emit their intended cue and original action; programmatic screen construction/focus stays silent |
| Pause, repetition and lifecycle | Feedback plays and advances while paused; 80 ms repeat interval; muted/unknown/background requests discarded; focus loss stops UI audio; returning never replays it |
| Story/input isolation | Story Escape pause/return emits correct cues; rate limiting never suppresses button callbacks; UI feedback/settings leave checkpoint bytes unchanged; existing narrative/input/phone suites pass |
| Source WAV checks | Mono 22,050 Hz PCM; measured peaks 0.2210–0.2435 full scale, RMS 0.0794–0.0923; first samples zero and final samples within 2 PCM units of zero; no clipping |
| Resource PCK export and independent boot | **Pass**, 1,273,528 bytes; all three imported UI samples included; packed main scene boots outside the source project and exits 0 after 120 frames |
| Human listening and actual Web/Android audio | **Pending**, see [interface feedback review](M4_PLAYTEST.md#interface-feedback-review) |

Reproduce with `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite All -FixedFps 30` and `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Audio -Visual -FixedFps 30`. Native log: `.godot-test/AudioTests-ui-native30.log`; export/boot logs: `.godot-test/ui-audio-export.log` and `ui-audio-pack-boot.log` (ignored).

The native Audio runner now retains the requested FPS in settings so preference reloads cannot silently restore 60 FPS during a 30 FPS test. Bus order explicitly places SFX before UI; native meter coverage verifies samples reach SFX rather than only checking the send's name. Final runs have no game parser/runtime errors; the pre-existing sandbox certificate-store startup error remains. Waveform inspection and native playback validate technical behavior, not perceived timbre, balance, browser gesture policy, physical phone speakers or final mix acceptance. The PCK is not an HTML5/APK build.

## M2/M5 touch button sizes - 2026-09-27

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility. Native Windows checks use the NVIDIA RTX 3050 Laptop GPU with an actual 30 FPS cap.

| Check | Result |
| --- | --- |
| Combined headless suites, fixed 30 render cadence | **96 Story + 34 Practice + 79 Input + 60 Narrative + 52 Mood + 48 Audio + 142 Cinematic + 79 Phone = 590 checks, 0 failures** |
| Native Input suite, actual 30 FPS cap | **79 checks, 0 failures** |
| Settings and preview | Selecting Largest updates the paused riding controls and preview; preview touch cannot accelerate; separate settings reload and New Game retain size; checkpoint bytes unchanged |
| Legacy/invalid settings | Missing key and invalid type return to Standard; out-of-range, nonfinite and intermediate values normalize before persistence |
| Layout and input | All three sizes at 1280×720, 1600×720 and 960×540 windows with simulated insets: zones contained and disjoint, interaction clear, simultaneous throttle/steering via screen coordinates |
| Constrained logical bounds | Explicit 640×400 safe rectangle limits effective size while retaining 150% preference; resizing/changing size clears ownership; unrelated SFX setting change preserves held input |
| Native visual inspection | Scrollable settings preview and 150% riding layouts inspected; riding labels readable, interaction above touch zones; preview extends below the initial scroll fold |
| Resource PCK export and independent boot | **Pass**, 1,251,548 bytes; packed main scene boots outside the source project and exits 0 after 120 frames |
| Physical Android comfort and Web acceptance | **Pending**; use the [M2 touch-size checklist](M2_PLAYTEST.md#touch-size-preference) |

Reproduce with `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite All -FixedFps 30` and `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Input -Visual -FixedFps 30`. Native log: `.godot-test/InputTests-touch-size-native30.log`; export/boot logs: `.godot-test/touch-size-export.log` and `touch-size-pack-boot.log`. Captures are ignored under `tests/screenshots/input_touch_size_settings.png` and `input_touch_largest_*.png`.

The initial constrained-layout assertion assumed shrinking the native window also reduced logical UI bounds. Godot's canvas stretching retains a baseline logical size; the final test explicitly constrains the logical safe rectangle. Final runs contain no game parser/runtime errors. The pre-existing sandbox certificate-store startup error remains. Native automation, synthetic touch and resource-PCK export do not replace physical thumb ergonomics, real Web/APK builds or platform lifecycle acceptance. This update covers riding buttons and labels; full menu/HUD scaling remains open.

## M5 photo album update - 2026-09-25

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility; native Windows / NVIDIA RTX 3050 Laptop GPU at a 30 FPS cap.

| Check | Result |
| --- | --- |
| Combined headless suites, fixed 30 render cadence | **96 Story + 34 Practice + 44 Input + 60 Narrative + 52 Mood + 48 Audio + 142 Cinematic + 79 Phone = 555 checks, 0 failures** |
| Native Phone suite, actual 30 FPS cap | **79 checks, 0 failures** |
| Album data and unlocks | Three unique entries and imported 960×540 textures; family photo available initially; departure/shelter gates; ordered copies; locked/unknown lookups expose no content |
| Save and read isolation | Browsing leaves snapshot, checkpoint bytes and three unread messages unchanged; existing saved flags restore all photos; New Game retains only the family photo |
| UI navigation and fallbacks | Real button callbacks and Escape; detail → album → home; bounded Previous/Next with single-photo coverage; stale trip selection, empty album and missing-image fallback |
| Native inspection | Home, album and all three photo details captured and inspected at 1280×720; thumbnails, captions and navigation visible; detail layout tightened to fit the close button |
| Resource PCK export and isolated boot | **Pass**, 1,249,388 bytes; all three imported textures and photos JSON included; packed main scene boots outside the source project and exits 0 after 120 frames |
| Human art/readability, touch and real Web/Android | **Pending**, see [photo album checklist](M3_PLAYTEST.md#photo-album) |

Reproduce with `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite All -FixedFps 30` and `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Phone -Visual -FixedFps 30`. Native log: `.godot-test/PhoneTests-native30.log`; export/boot logs: `.godot-test/photos-export.log` and `photos-pack-boot.log`; captures: `tests/screenshots/phone_photos.png` and `phone_photo_*.png` (all ignored).

The three original stills were generated by the native render tool and visually inspected before use. Album visibility uses existing flags without a schema change. No game parser/runtime errors in final runs; the pre-existing sandbox certificate-store startup error remains. This validates a resource pack and native behavior, not an HTML5/APK build, platform performance, final art or free-camera Photo Mode.

## M5 phone interface update - 2026-09-25

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility. Native checks use Windows / NVIDIA RTX 3050 Laptop GPU at a 30 FPS cap.

| Check | Result |
| --- | --- |
| Combined headless suites, fixed 30 render cadence | **96 Story + 34 Practice + 44 Input + 60 Narrative + 52 Mood + 48 Audio + 142 Cinematic + 35 Phone = 511 checks, 0 failures** |
| Native Phone suite, actual 30 FPS cap | **35 checks, 0 failures** |
| Read status and replies | Home preserves unread state; Messages/Email filter and mark their own delivered entries; reply remains in Email; existing save/load retains reads and replies |
| Call history | Both completed mother-call branches unlock one recollection; unfinished call/final-line flag alone does not; repeated reads do not write saves, set flags or replay dialogue |
| Navigation | Actual UI buttons open correct sections; Back/Escape returns shortcuts to phone while paused; home closes to riding; direct map retains original close behavior |
| Story/save isolation | Calls, Route and Journal browsing leaves checkpoint file unchanged; cinematic locks prevent phone opening; paused bike cannot move; New Game clears live history and badges |
| Native inspection | Home, Messages, Email and Calls captured and inspected at 1280 x 720; longer Messages list remains scrollable |
| Resource PCK export and isolated boot | **Pass**, 1,144,432 bytes; calls JSON included; packed main scene boots outside the source project and exits 0 after 120 frames |
| Human readability, touch and real Web/Android acceptance | **Pending**, see [phone review guide](M3_PLAYTEST.md) |

Reproduce with `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite All -FixedFps 30` and `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Phone -Visual -FixedFps 30`. Native log: `.godot-test/PhoneTests-native30.log`; screenshots: `tests/screenshots/phone_*.png` (ignored).

Narrative gains two section-read checks (60 in a normal launch, 63 with StoryDebug enabled). The legacy combined service methods remain available when no channel is specified. Calls use the existing saved dialogue-completion state, with no new save fields or schema migration. The history is an authored recollection and remembered line, not voice playback or a transcript. No game parser/runtime errors in final runs; the pre-existing sandbox certificate-store startup error remains. The resource PCK is not an HTML5/APK build; matching export templates and real platform acceptance remain pending.

## M5 character performance update - 2026-09-25

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility. Native rendering uses Windows / NVIDIA RTX 3050 Laptop GPU at a 30 FPS cap.

| Check | Result |
| --- | --- |
| Combined headless suites, fixed 30 render cadence | **96 Story + 34 Practice + 44 Input + 58 Narrative + 52 Mood + 48 Audio + 142 Cinematic = 474 checks, 0 failures** |
| Native Cinematic suite, actual 30 FPS cap | **142 checks, 0 failures** |
| Performance clips | All six clips sample successfully; seeking back to a previous progress restores the same joint transforms and prop state; unknown clips preserve the current pose |
| Timeline ownership | Manual AnimationPlayer clock does not advance independently; pause freezes joints/props; skipping each of 23 shots restores final actor transforms and poses |
| Phone/packing | Phone handoff hides desk prop, displays handset and holds call pose through dialogue; packing reach uses the authored clip with Raka visible |
| Memory/departure | Young Raka sits behind father in passenger pose; both use helmet geometry; no departure luggage in memory; return removes child and restores present-day luggage/set |
| Native visual review | Phone, packing, memory and departure captures inspected; interior wall closed behind phone camera; cinematic lights assigned to visible layer 2; duplicate cockpit arms removed for cinematic bikes |
| Resource PCK export and isolated boot | **Pass**, 1,141,584 bytes; actor script and opening JSON included; main scene boots outside the source project and exits 0 after 120 frames |
| Human animation/comfort acceptance and real Web/Android | **Pending**; use [M5 cinematic review guide](M5_CINEMATIC_PLAYTEST.md) |

Native log: `.godot-test/CinematicTests-performance-native30.log`. Captures: `tests/screenshots/performance_*.png` and `cinematic_departure_midpoint.png` (ignored). Reproduce with the existing All and Cinematic commands. All final suites exit successfully with no game parser/runtime errors; the existing sandbox certificate-store startup error remains.

The opening now has 23 shots and 101 authored seconds. The two-second memory uses the existing ambience crossfade, not a finished cinematic sound bridge. Character tests cover deterministic mechanics, not natural acting or correct production-quality hand contact. Models use an articulated Node3D hierarchy with AnimationPlayer tracks, not skinned Skeleton3D assets. Save schema and stable checkpoints remain unchanged. This PCK is a resource package, not a playable HTML5/APK build; matching export templates and platform acceptance remain pending.

## M5 opening cinematic update - 2026-09-24

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility. Native rendering uses Windows / NVIDIA RTX 3050 Laptop GPU at a 30 FPS cap.

| Check | Result |
| --- | --- |
| Final combined headless suites, fixed 30 render cadence | **96 Story + 34 Practice + 44 Input + 58 Narrative + 52 Mood + 48 Audio + 92 Cinematic = 424 checks, 0 failures** |
| Native Cinematic suite, actual 30 FPS cap | **92 checks, 0 failures** |
| Authored content | 22 shots across morning, office, sign-out, night and departure; unique per-sequence shot IDs, valid timing/framing/FOV and matching stage selection |
| Timeline and skip | Natural completion once per sequence; skip from every shot matches final flags, set and camera framing; short press ignored, held skip completes |
| Camera and staging | Dolly moves; reduced motion stays static; pause freezes clock; rider/bike move together; luggage visible; parking uses city ambience |
| Cleanup and handoff | Old stages freed on replacement/cancellation; departure Continue locks riding, then restores camera, controls and road-start checkpoint |
| Integrated story | Layoff dialogue now leads to sign-out, evening apartment, mother call and departure; existing save schema/checkpoint IDs retained |
| Native inspection | All 22 shot starts plus departure midpoint captured; representative phone, HR screen, cluster, packing, night and departure/title images reviewed at 1280 x 720 |
| Resource export and isolated packed boot | **Pass**, 1,134,396-byte PCK; new stage script and opening JSON included; main scene boots outside the source project and exits 0 after 120 frames |
| Human pacing, final performance/art, actual browser/Android | **Pending**; use [M5 cinematic review guide](M5_CINEMATIC_PLAYTEST.md) |

Reproduce with `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite All -FixedFps 30` and `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Cinematic -Visual -FixedFps 30`. Native log: `.godot-test/CinematicTests-native30.log`; captures: `tests/screenshots/cinematic_*.png` (ignored).

The resource PCK is not an HTML5/APK build; matching export templates and real platform validation remain pending.

The timeline harness advances shot time directly between captures; it does not measure human reading speed or approve cinematic pacing. Authored shot time is 99 seconds excluding transitions, commute, dialogue and pauses. Actors and props remain code-built blocking geometry; departure is root movement, not final rig animation. No parser/runtime errors in the final runs. The pre-existing sandbox certificate-store startup error remains and does not affect offline tests.

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
