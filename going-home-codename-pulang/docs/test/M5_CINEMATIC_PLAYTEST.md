# M5 opening cinematic review

The current opening is a blocking prototype with 22 authored shots, not final character animation or an accepted vertical slice. All captions and device text are English. Raka remains competent, loses his role through restructuring, has professional alternatives, and chooses to go home.

## Play the opening

Begin a new journey, watch the apartment and parking shots, ride to the office, finish the restructuring conversation, watch the sign-out/evening sequence, answer Mom, and watch packing/departure. The shot durations total 99 seconds: morning 24, office 15, sign-out 11, evening 23, departure 26. Dialogue, commute, transitions and pauses add to this time; it is not a measured player-session length.

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

Final waking/walking/packing performances, reference-reviewed hero assets, rigs/gestures, father-memory insert, screen/practical-light polish, cinematic foley/voice treatment and natural-speed pacing approval remain open. The 30-60 minute polished slice is still a separate goal.

## Authoring and automated checks

`data/cutscenes/opening.json` contains sequence purpose/characters/audio priority and per-shot IDs, framing, FOV, duration, camera/target, optional camera endpoint, set, prop text, luggage/packing visibility and departure travel. Coordinates are local to the isolated stage. `scripts/cutscenes/cinematic_stage.gd` builds replaceable blocking geometry. The director moves the camera and stage props from elapsed time; it does not create an unbounded tween per shot. Shots cut directly; sequence handoffs use the existing fade flow.

`powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Cinematic -Visual -FixedFps 30`

The suite checks every shot's metadata and set, natural timeline completion, skip from every shot with identical final flags, set and camera framing, completion deduplication, short/held skip, camera movement/reduced motion, pause, synchronized rider/bike travel, stage replacement/cleanup and departure checkpoint handoff. Captures are saved under ignored `tests/screenshots/cinematic_*.png`. The test advances the timeline directly between captures; it is not a human pacing test. The Story suite additionally checks the integrated meeting -> sign-out -> evening -> mother -> departure flow.
