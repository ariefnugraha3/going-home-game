# Implementation status · M4 mood update, 2026-09-24

This is a **prototype milestone delivery**, not a declaration that M0–M5 are accepted. Follow the original roadmap's human playtest and platform gates before chapter production.

| Milestone | Implemented here | Remaining acceptance work |
| --- | --- | --- |
| M0 Foundation | GDScript/Compatibility, boot, menu, directories, version pin, settings, export presets | Matching templates, browser launch, Android launch, reproducible CI runner |
| M1 Riding | CharacterBody3D, comfort settings, cockpit, route-aware assist/recovery, forgiving collision response; dedicated seven-section track, pause/weather/repeat controls, save-isolated local reports, full-track regression suite | Human 5/15-minute feel and nausea tests; physical-device and browser checks; final bike art remains in M4/M5 |
| M2 Input/platform | Named actions, keyboard/arrows, persistent basic key remapping with conflict checks/reset, dynamic prompts, multitouch overlay with ownership cleanup, Android safe-area insets, simulated aspect-ratio checks | Physical Android ergonomics and safe-area validation, Web iframe/focus/audio/storage tests; see M2 checklist |
| M3 Narrative | Branches/conditions/flags, delayed phone delivery and banner queue, unread/read/reply persistence, legacy phone migration, read-only opt-in flag viewer, journal, checkpoint save and backup, cutscene director/skip | Real Web/Android save and lifecycle validation; richer calls/photos and full localization key table remain broader production work |
| M4 Mood | Low-poly environment kit; eight authored lighting/weather resources with interruptible blends; variable rain/fog/wetness; night beam/stop lamps; practice comparison menu and reports; synthetic insect/rain/bird ambience | Human art/audio acceptance, hero bike/character refinement, authored animation, real motorcycle/regional recordings, first music cue, terrain/LOD and target-platform profiling |
| M5 Slice | Complete compact Jakarta-to-Karawang playable loop | 30–60 minute pacing, production-quality required shots, final assets/animations, all platform/comfort acceptance tests |
| M6–M14 | Not begun | Production tools, all remaining chapters, alpha/beta, optimization, releases |

## Concrete follow-up tasks

1. **PLATFORM-01:** Install Godot 4.7.2 export templates. Configure Android JDK/SDK; create debug builds. Test Chrome/Firefox/Edge including an itch.io-like iframe and two physical Android classes.
2. **RIDE-01:** Use the implemented Practice ride and [M1 playtest guide](test/M1_PLAYTEST.md) for human 5/15-minute sessions with reduced motion on/off, Low at 30 FPS, pause/resume, and continuous bends. Record comfort, stopping, steering corrections, and missed stops. The technical track is complete; human acceptance remains open.
3. **ART-01:** Replace prototype Thunder geometry with a reference-reviewed glTF hero motorcycle. Keep the round headlight, maintained paint, tank silhouette, analog cockpit, and intact seat. The supplied documents contain no actual reference image assets; current proportions are an approximation.
4. **ART-02:** Replace simple character primitives with Raka/NPC rigs, hands, seated poses, and restrained gesture animation. Refine terrain-to-road edges, vegetation variety, and roadside silhouettes.
5. **STORY-01:** Expand and time the opening morning/parking/commute/HR/sign-out/apartment/packing/departure shots. Current cinematics use static room compositions and text; final exterior departure and flashback performances are not implemented.
6. **AUDIO-01:** Replace synthesized loop placeholders with licensed or original recorded vehicle layers and Indonesian environmental audio. Add ignition/shutdown/mechanical cues and a restrained music motif.
7. **UI-01:** Run the [M2 platform checklist](test/M2_PLAYTEST.md) for Android touch sizes/notches and browser focus. Basic keyboard remapping and safe-area layout are implemented; adjustable UI scaling and phone Calls/Photos remain future work if retained in scope.
8. **PERF-01:** Profile real exports. Combine repeated road markings/poles/vegetation into MultiMeshes where measured draw calls justify it; confirm scene-memory recovery over repeated transitions.
9. **CONTENT-01:** Only after the slice gate passes, author Cirebon onward with chapter scenes and the existing data interfaces. Preserve all listed GDD chapters and the restrained Banyuwangi/family-home ending.

## Deliberate prototype limits

- No free walking: bounded stop interactions as recommended by the TDD.
- Mirror images are static sky/road approximations, not true rear views.
- Traffic is a small decorative pool in the opposing lane with no collision penalties.
- Fuel bottoms out at an assistance reserve; this prototype cannot strand the player.
- Weather and lighting use eight combined authored presets. Final NPC weather behavior, puddle details, recorded regional ambience, and music remain unfinished; no astronomical time simulation is used.
- Save checkpoints restore stable scenes, not an exact moving position or a half-spoken line. Dialogue decisions survive via flags, and a dialogue interrupted by quitting may be replayed from the stable checkpoint.
- JSON integrity checks validate schema and keep a previous backup; they do not authenticate save files.
- Photo mode, controller support, extra save slots, UI scaling, and dynamic mirrors are not claimed.
- Placeholder meshes are assembled at runtime and are not visible as a finished level in the editor's static scene view.

## Save contract

Schema v1 is stored at `user://journey.json`, with `.bak` as the last valid primary and `.tmp` as a verified staging write. It contains chapter/checkpoint, flags, dialogue states, bike fuel/condition/distance, journal selections, and phone read/replies/delivered/notified/pending state. Missing additive phone fields migrate from pre-queue v1 saves; legacy read/replied IDs are already delivered and notified. Pending values are remaining seconds of unlocked gameplay, saved at checkpoints and phone events. Quiet phone saves retain the stable story checkpoint; they do not restore an exact riding position. Settings live in `user://settings.cfg`. New Game replaces journey state while preserving settings. Future schema versions currently fail safely, rather than being guessed or downgraded.
