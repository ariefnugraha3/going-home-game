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

Final waking/walking/full packing performances, reference-reviewed hero assets, skinned rigs/faces/contact refinement, final recorded memory sound/foley, further screen/practical-light polish and voice treatment and natural-speed pacing approval remain open. The 30-60 minute polished slice is still a separate goal.

## Authoring and automated checks

`data/cutscenes/opening.json` contains sequence purpose/characters/audio priority and per-shot IDs, framing, FOV, duration, camera/target, optional camera endpoint, set, prop text, luggage/packing visibility and departure travel. Coordinates are local to the isolated stage. `scripts/cutscenes/cinematic_stage.gd` builds replaceable blocking geometry. The director moves the camera and stage props from elapsed time; it does not create an unbounded tween per shot. Shots cut directly; sequence handoffs use the existing fade flow.

`powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Cinematic -Visual -FixedFps 30`

The suite checks every shot's metadata and set, natural timeline completion, skip from every shot with identical final flags, set and camera framing, completion deduplication, short/held skip, camera movement/reduced motion, pause, synchronized rider/bike travel, stage replacement/cleanup and departure checkpoint handoff. Captures are saved under ignored `tests/screenshots/cinematic_*.png`. The test advances the timeline directly between captures; it is not a human pacing test. The Story suite additionally checks the integrated meeting -> sign-out -> evening -> mother -> departure flow.

## Character performance pass - pending human review

- [ ] Watch the phone shot: one handset becomes visible in the raised hand, the desk phone disappears, and the call pose remains through dialogue. Review hand/ear contact from the actual camera.
- [ ] Watch the packing reach and listening nod. They should remain understated; inspect joint seams and any prop penetration before replacing the blocking meshes.
- [ ] Inspect helmeted riding and passenger poses, with no extra first-person arms on the cinematic motorcycle. The playable cockpit retains its own arms.
- [ ] Confirm the two-second father/young-Raka insert reads as a memory, the child sits behind the father, and the return to the luggage/title shot is clear. Assess reading time and the new prototype sound bridge.
- [ ] Pause mid-gesture, change reduced motion, resume, skip, and Continue from departure. Check that reduced motion holds the camera while actor movement remains; skip lands on the correct final actor pose.

`CinematicActor` uses a small Node3D joint hierarchy with six AnimationPlayer clips sampled manually by the shot director. This is not a Skeleton3D/skinned production character. No independent actor clock or per-shot animation tween runs behind the director. `performance` and `npc_performance` in the shot data choose authored clips. Final dialogue poses are held rather than driven by voice/lip synchronization. Existing stable checkpoint IDs and save schema are unchanged.

The Cinematic suite now also compares actor poses for skips from every shot, checks deterministic seeking of all clips, freezes joints/prop state during pause, verifies phone handoff and memory cleanup, and captures `performance_phone.png`, `performance_pack.png` and `performance_memory.png` under the ignored screenshot folder.

## Cinematic sound pass

Five original mono 22,050 Hz PCM sketches are synthesized by `tools/generate_cinematic_audio.py`. No recordings or third-party sounds are used. This implements the sound timeline and memory transition; final foley/voice performances and listening acceptance remain open.

| Shot | Cue | Start within shot | Duration |
| --- | --- | --- | --- |
| Morning / alarm | alarm | 0.15 s | 2.0 s |
| Office / HR message | message | 0.25 s | 0.45 s |
| Night / Mom calls | phone | 0.20 s | 2.6 s |
| Departure / packing | fabric | 1.6 s and 3.3 s | 0.85 s each |
| Departure / straps | memory_motor | 4.4 s | 4.0 s, across the next two cuts |

Each shot may contain an ordered `audio` array of `{ "cue": "bank_id", "at": seconds }`. `data/audio/cinematic.json` maps IDs to imported assets and gain in dB. Events must start within their shot. `CinematicAudio` owns two SFX voices and the director advances its clock; ordinary cuts keep remaining tails. Full voices cause additional requests to be discarded. A late frame starts a still-relevant cue at its elapsed offset and drops sounds whose duration has already passed. No queued event survives its shot, skip, replacement, completion or cancellation.

Audio requires the existing user activation. Master/SFX zero drops new events; existing sound follows its bus mute. Pause/background freezes active stream playback and both shot/audio clocks. Resume continues the same voice. Skipping restores final visual/story state without playing skipped sound events. Existing checkpoint semantics remain: Continue restarts the stable sequence, not a saved mid-sound position.

- [ ] At natural speed, listen to the alarm, HR notification and ringtone. They should remain quiet and readable without resembling urgent gameplay prompts.
- [ ] Compare packing fabric with the prototype reach; record contact/timing adjustments for the final animation pass.
- [ ] Listen from straps through the two-second memory and title. The motor/air should connect the images, fade naturally and leave space for the present-day road sound.
- [ ] Pause mid-cue, open settings, mute/unmute SFX, background/resume and skip. Check for clicks, stale alarms, duplicate cues or tails under dialogue.
- [ ] Compare headphones and phone speakers at comfortable volume; approve final timbre, gain and ambience balance only after human listening.
- [ ] Repeat activation, pause/focus, touch Skip and Continue on real Web/Android exports.

Run `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite CinematicAudio -FixedFps 30` for logical coverage, or add `-Visual` for native playback/mixer checks. Tests cover asset/event metadata, late frames, once-only scheduling, two-cut memory tails, bounded voices, pause/background, muted/unknown events, replacement/skip/cancel/free cleanup and unchanged journey bytes. Native tests additionally verify playback position, pause/resume and samples reaching SFX. They do not replace human listening or target-platform acceptance.
