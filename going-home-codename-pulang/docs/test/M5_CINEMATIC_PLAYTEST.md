# M5 opening cinematic review

The current opening is a blocking prototype with 23 authored shots, not final character animation or an accepted vertical slice. All captions and device text are English. Raka remains competent, loses his role through restructuring, has professional alternatives, and chooses to go home.

## Play the opening

Begin a new journey, watch the apartment and parking shots, ride to the office, finish the restructuring conversation, watch the sign-out/evening sequence, answer Mom, and watch packing/departure. The shot durations total 101 seconds: morning 24, office 15, sign-out 11, evening 23, departure 28. Dialogue, commute, transitions and pauses add to this time; it is not a measured player-session length.

Hold Space for more than 0.8 seconds or select Skip scene. This finishes the current sequence, not the whole prologue. Pause freezes the shot clock and movement. Reduced camera motion makes camera travel static; the departing motorcycle still moves through the set.

Checkpoint IDs and save schema remain unchanged. Continue can replay material after the last stable checkpoint, including the meeting/sign-out after the commute checkpoint. Departure restores the packing sequence; completion restores riding at the Karawang start. The game does not save mid-shot or mid-dialogue.

## Human review - pending

- [ ] Watch at natural speed: can the alarm, badge, HR screen, recruiter opportunities, Apply, Mom and route text be read before each cut?
- [ ] Check the story's restraint: no suggestion that Raka is incompetent or has no work options. Confirm the sign-out pause feels appropriate after the dialogue.
- [ ] Inspect parking, luggage, analog cluster, seated characters and title reveal at Low and Medium. Record placeholder geometry/clipping that final art must resolve.
- [ ] Compare reduced motion on/off. Assess camera comfort through cuts, small dollies and the handoff to first-person riding at 30 FPS.
- [ ] Pause at the departure title, open settings, return, and finish. Confirm the title returns and controls remain locked until the road starts.
- [ ] Skip early, at set changes, and near the end. Reload the saved commute and departure checkpoints. Confirm there are no duplicate dialogue starts, stuck transitions or missing departure flags.
- [ ] Repeat text readability, touch Skip, pause/background and Continue on real browser and Android builds once export prerequisites are available.

Final waking/walking/full packing performances, reference-reviewed hero assets, skinned rigs/faces/contact refinement, memory sound bridge, further screen/practical-light polish and cinematic foley/voice treatment and natural-speed pacing approval remain open. The 30-60 minute polished slice is still a separate goal.

## Authoring and automated checks

`data/cutscenes/opening.json` contains sequence purpose/characters/audio priority and per-shot IDs, framing, FOV, duration, camera/target, optional camera endpoint, set, prop text, luggage/packing visibility and departure travel. Coordinates are local to the isolated stage. `scripts/cutscenes/cinematic_stage.gd` builds replaceable blocking geometry. The director moves the camera and stage props from elapsed time; it does not create an unbounded tween per shot. Shots cut directly; sequence handoffs use the existing fade flow.

`powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Cinematic -Visual -FixedFps 30`

The suite checks every shot's metadata and set, natural timeline completion, skip from every shot with identical final flags, set and camera framing, completion deduplication, short/held skip, camera movement/reduced motion, pause, synchronized rider/bike travel, stage replacement/cleanup and departure checkpoint handoff. Captures are saved under ignored `tests/screenshots/cinematic_*.png`. The test advances the timeline directly between captures; it is not a human pacing test. The Story suite additionally checks the integrated meeting -> sign-out -> evening -> mother -> departure flow.

## Character performance pass - pending human review

- [ ] Watch the phone shot: one handset becomes visible in the raised hand, the desk phone disappears, and the call pose remains through dialogue. Review hand/ear contact from the actual camera.
- [ ] Watch the packing reach and listening nod. They should remain understated; inspect joint seams and any prop penetration before replacing the blocking meshes.
- [ ] Inspect helmeted riding and passenger poses, with no extra first-person arms on the cinematic motorcycle. The playable cockpit retains its own arms.
- [ ] Confirm the two-second father/young-Raka insert reads as a memory, the child sits behind the father, and the return to the luggage/title shot is clear. Assess reading time and the future sound bridge.
- [ ] Pause mid-gesture, change reduced motion, resume, skip, and Continue from departure. Check that reduced motion holds the camera while actor movement remains; skip lands on the correct final actor pose.

`CinematicActor` uses a small Node3D joint hierarchy with six AnimationPlayer clips sampled manually by the shot director. This is not a Skeleton3D/skinned production character. No independent actor clock or per-shot animation tween runs behind the director. `performance` and `npc_performance` in the shot data choose authored clips. Final dialogue poses are held rather than driven by voice/lip synchronization. Existing stable checkpoint IDs and save schema are unchanged.

The Cinematic suite now also compares actor poses for skips from every shot, checks deterministic seeking of all clips, freezes joints/prop state during pause, verifies phone handoff and memory cleanup, and captures `performance_phone.png`, `performance_pack.png` and `performance_memory.png` under the ignored screenshot folder.
