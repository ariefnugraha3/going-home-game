# M5 opening cinematic review

The current opening is a blocking prototype with 30 authored shots, not final character animation or an accepted vertical slice. All captions and device text are English. Raka remains competent, loses his role through restructuring, has professional alternatives, and chooses to go home.

## Play the opening

Begin a new journey, watch the apartment and parking shots, ride to the office, finish the restructuring conversation, watch the sign-out/evening sequence, answer Mom, and watch packing/departure. The shot durations total 136 seconds: morning 24, office 19, sign-out 11, evening 23, departure 59. Dialogue, commute, transitions and pauses add to this time; it is not a measured player-session length.

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
- [ ] Confirm the two-second father/young-Raka insert reads as a memory, the child sits behind the father, and the return to mounting and the title shot is clear. Assess reading time and the new prototype sound bridge.
- [ ] Pause mid-gesture, change reduced motion, resume, skip, and Continue from departure. Check that reduced motion holds the camera while actor movement remains; skip lands on the correct final actor pose.

`CinematicActor` uses a small Node3D joint hierarchy with eight AnimationPlayer clips sampled manually by the shot director. This is not a Skeleton3D/skinned production character. No independent actor clock or per-shot animation tween runs behind the director. `performance` and `npc_performance` in the shot data choose authored clips. Final dialogue poses are held rather than driven by voice/lip synchronization. Existing stable checkpoint IDs and save schema are unchanged.

The Cinematic suite now also compares actor poses for skips from every shot, checks deterministic seeking of all clips, freezes joints/prop state during pause, verifies phone handoff and memory cleanup, and captures `performance_phone.png`, `performance_pack.png` and `performance_memory.png` under the ignored screenshot folder.

## Walking performance pass

Morning `parking` now uses a five-second approach beside the stationary bike. Office `walk_to_meeting` adds a four-second rear view before the seated meeting. `performance: "walk"` uses stage-local `actor_from`, `actor_to` and a positive integer `walk_cycles` (four for parking, three for office). Root position and gait phase derive from the same eased shot progress. This lets speed ease at either end without an independent actor clock; the integer cycle count lands on a neutral stance.

The actor retains its original seated geometry for dialogue and memory; present-day riding uses the articulated legs from the mounting pass. Walking raises the upper body, swaps in articulated hips/knees, and hides phone/helmet props. Waking also uses articulated legs, as described below. The parking set hides its seated rider while the walking actor is visible, then restores him on the cluster cut. The office cut returns Raka to his chair. These morning/office transitions remain direct editorial cuts. The departure sequence has the mounting performance described below. A small neck mesh connects head and torso in both postures.

Automated checks cover start/mid/end root position, facing, deterministic backward seeking, pause, reduced-motion independence, neutral endpoints, actor visibility and restoration of the seated pose. Native start/mid/end captures are in `tests/screenshots/walk_*.png`. Projection checks keep the head/feet between the cinematic bars at the test viewport. All-shot skip tests also include the new office shot. No save fields or flag IDs change.

- [ ] Watch both approaches at natural speed and compare reduced motion on/off; review gait cadence, foot sliding and the cuts into seated poses.
- [ ] Confirm only one Raka is visible beside the bike, and inspect floor contact, furniture clearance and proportions on final models.
- [ ] Review head/feet and caption clearance across phone aspect ratios and larger UI/text settings.
- [ ] Replace blocking gait with final rig animation, foot locking, remaining sitting transitions and licensed/original recorded footsteps where appropriate.
- [ ] Repeat pause/background, Skip and Continue on real Web/Android exports.

## Packing performance pass

The existing five-second `departure/packing` insert now shows a folded raincoat lifted over the bag wall, lowered into the opening and released, followed by the right hand closing the flap. Clothes, charger and toolkit are preplaced inside. The following route insert retains the closed bag and the laptop on the desk. The badge, label and lanyard hide together. No extra shots, sounds or save fields are added.

`PackingProps` owns the replaceable geometry and samples absolute prop transforms. `CinematicActor.reach_hand` solves the upper arm/forearm against sampled contact points. The director calls both after the actor clip; there is no item reparenting, tween, physics simulation or independent timer. The reach clamps targets outside the blocking arm's length. One hundred and one samples check raincoat grip (within 2 mm), flap contact during closure and clearance above the bag's side wall. These checks cover authored contact points, not all mesh intersections or production finger/cloth contact.

The Cinematic suite covers open/closed endpoints, ordered placement/closure, pause/focus, rewind, reduced-motion independence, unchanged story state, node-count stability, direct entry into the route insert and all-shot Skip equivalence for props. At the authored 1280×720 viewport, sampled raincoat/flap bounds must stay between the caption bars throughout the action. Native captures: `pack_ready.png`, `pack_lift.png`, `pack_placed.png`, `pack_closing.png`, `pack_closed.png` in the ignored screenshot folder.

- [ ] Watch the five-second insert at natural speed; assess the pickup, release and flap timing against both fabric cues.
- [ ] Review hand/forearm visibility, elbow shape and mesh contact on phone-size framing and actual Web/Android builds.
- [ ] Replace blocking raincoat/bag/rig assets, add finger grips and cloth deformation, and record final fabric/fastener foley.
- [x] Add laptop stowage after route planning, as described below.
- [ ] Add remaining item placement and fastening luggage to the motorcycle.

## Helmet preparation pass

The five-second `departure/helmet` insert follows memory. Raka begins holding the existing helmet, raises it in front, moves it above his head, lowers it and releases both hands into the chin-strap check. `CinematicHelmet` samples the helmet offset, shoulder lift and hand targets from the director clock; other actor clips reset those offsets. No duplicate helmet, additional clock or save field is introduced. The memory tail fades during the first 1.4 seconds; fabric plays at 2.8 seconds.

Checks cover two-hand target contact, connected shoulder geometry, stationary feet/bike, framing and node stability at 101 samples, plus pause/focus, rewind, reduced motion, scene reset, exact mounting handoff and all-shot Skip equivalence. Captures: `helmet_held.png`, `helmet_lift.png`, `helmet_above.png`, `helmet_worn.png`.

- [x] Add sampled helmet lift, placement and release before mounting.
- [x] Add helmet retrieval from the seat with continuous two-hand contact and a matching held-pose handoff.
- [ ] Refine shell opening, head/finger contact, shoulder deformation and recorded foley with production assets.
- [ ] Review natural-speed motion, phone-size readability and actual Web/Android pause/Skip/audio behavior. Point-contact checks do not certify complete mesh clearance.

## Helmet retrieval pass

The four-second `departure/helmet_pickup` shot returns from the father memory to a helmet resting on the front of the motorcycle seat. Raka reaches both rim targets before lifting, raises the helmet clear of the seat, then draws it toward his body. The existing helmet is repositioned rather than duplicated or reparented. Webbing stays folded above the seat until the helmet clears the bike, then settles into the loose donning pose. The last sample exactly matches the first sample of `departure/helmet`, including hands, feet and strap state.

The camera views the seat from the opposite side so the tank does not hide the pickup. A reused fabric cue at 1.6 seconds follows the memory sound tail without restarting it. One new stable English caption key is included in the catalog. No save schema or checkpoint changes are introduced.

- [x] Sample 101 positions for two-hand targets, planted feet, helmet/seat/luggage bounds, folded webbing, caption framing and constant node count.
- [x] Cover pause/background, rewind, reduced motion, natural handoff and Skip from the new shot.
- [ ] Review natural-speed weight transfer, full mesh/torso contact, fingers and physical strap behavior with production rigs and final foley; point samples are not a full collision simulation.

Captures: `helmet_pickup_seat.png`, `helmet_pickup_grip.png`, `helmet_pickup_lift.png`, `helmet_pickup_held.png`. The actor begins beside the parked motorcycle after an editorial cut; carrying the packed luggage to the bike and putting away the wiping cloth remain separate unfinished actions.

## Chin-strap fastening pass

The four-second `departure/chin_strap` insert follows helmet donning. Raka reaches the two loose buckle halves, joins them below the chin, pulls the right free tail and releases his hands before mounting. `CinematicChinStrap` builds reusable webbing segments and buckle halves; transforms and hand targets share the director clock. The loose webbing follows the helmet while it is held/raised; riding and memory poses retain a closed buckle. Unhelmeted actors hide it. A reused fabric cue plays at 2.5 seconds; no new sound asset, save field or physics simulation is added.

Checks sample 101 times for hand targets, shell attachment points, buckle/tail clearance from the torso, planted shoes, stationary motorcycle, caption framing and node stability. Pause/focus, rewind, reduced motion, loose/secured handoffs, departure persistence, interior reset and all-shot Skip snapshots include the webbing. Captures: `chin_strap_loose.png`, `chin_strap_joined.png`, `chin_strap_pull.png`, `chin_strap_secured.png`.

- [x] Add buckle closure, a tightening pull and secured-strap continuity into mounting/departure.
- [ ] Refine production shell/cheek/neck contact, fingers, webbing deformation and actual buckle hardware; authored endpoints are not a complete collision or mechanical simulation.
- [ ] Review natural-speed hand occlusion, phone-size visibility, recorded buckle/strap sound and real Web/Android behavior.

## Motorcycle mounting pass

The five-second `departure/mount` shot follows the chin-strap check and precedes the title/departure. Raka is already helmeted at the cut. His left foot stays planted during the initial right-leg lift and crossing, then both feet move toward the cinematic footrests while his body settles and hands reach the grips. The bag sits farther back on the seat; the strap-check actor position follows it. The bike remains stationary until departure, which starts from the exact final mounting pose.

`CinematicMount` reuses the ride clip and samples root, torso and analytic two-bone leg/hand targets in motorcycle coordinates. Shoes remain level and reset for other clips; pose snapshots include their transforms. No extra animation clock, physics, nodes per frame, gameplay cargo or save fields are introduced. The memory sound now fades during helmet preparation; mounting retains its fabric cue at 2.5 seconds. The eight original clips and five sound assets remain the same.

Automated checks cover 101 samples for the initial planted foot, level shoes above the surface, shoe-corner clearance from the luggage, caption-safe framing and constant node count. They also check lift height, feet on opposite sides, final grip contact, pause/focus, rewind, reduced motion, unchanged journey state, exact natural handoff and movement with the bike. All-shot Skip equivalence includes the new shot and shoe transforms. Captures: `mount_ready.png`, `mount_lift.png`, `mount_cross.png`, `mount_seated.png`.

- [x] Add the bounded mounting performance and retain its seated pose through departure.
- [ ] Review natural-speed weight transfer, support hands, hip/torso alignment and leg clearance with production meshes; sampled shoe points do not certify full body collision or physical balance.
- [ ] Animate helmet retrieval, cloth storage, preparation movements and remaining morning/office sitting transitions.
- [ ] Replace synthesized fabric with recorded movement/seat foley and review pacing with the memory bridge.
- [ ] Repeat framing, touch Skip, pause/background and sound tests in actual Web/Android builds.

## Bike touch pass

The new five-second `departure/bike_touch` insert follows `straps` and precedes `father_memory`, matching the GDD's tank/cluster touch before the memory. `bike_touch: true` selects standing Raka and hides the seated rider. He already holds a small cloth at the editorial cut, brings it to the tank's near flank, wipes out and back, holds briefly, then withdraws it. Moving from the luggage to this standing position and taking out/putting away the cloth are not animated.

`CinematicBikeTouch` samples an ellipsoid path from the existing tank mesh bounds and transform, keeps the path away from the center fuel cap, aligns a rigid cloth to the surface normal and drives the right hand with the existing two-joint reach. The tank is exposed as `BikeVisual.tank`; its geometry and riding behavior are unchanged. The standing pose reuses the walk clip at time zero. The director owns the only clock, and non-wipe shots reset/hide the cloth. The secured luggage is preserved through this shot and restored after memory.

The Cinematic suite samples 101 times to check palm/cloth contact, modeled surface offset and fuel-cap separation, stationary legs/bike, cloth framing, an unobstructed view past the torso and constant node count. It also checks stroke travel/return, pause/focus, rewind, reduced motion, unchanged journey state, memory/departure cleanup and morning reset. All-shot Skip comparison includes the cloth. Captures: `bike_touch_ready.png`, `bike_touch_contact.png`, `bike_touch_wipe.png`, `bike_touch_withdrawn.png`.

- [ ] Review the wipe, reflective hold and memory transition at natural speed; confirm the gesture supports Raka's connection to the motorcycle.
- [ ] Refine actual faceted-mesh contact, palm/fingers, cloth deformation, visible dust removal and expressive body/head motion using production assets. Ellipsoid checks do not certify full mesh contact.
- [ ] Add standing-position transitions and cloth retrieval/storage, then replace synthesized cloth with recorded wiping foley.
- [ ] Inspect both cloth and caption readability at phone sizes and in real Web/Android builds.

## Luggage strap check pass

The five-second `departure/straps` shot sets `luggage_check: true` and uses a standing Raka beside the motorcycle, with the seated rider hidden. `CinematicLuggage` builds a closed bag, two bands, buckles and free tails on the bike. The shot begins with the bag already placed and straps threaded around it; Raka pulls each tail, removing the visible slack, then leaves short secured ends. The neutral standing pose reuses the walk clip at time zero; arms reach sampled grip points while the feet stay still. Other parking shots sample the secured luggage state and retain their normal walking/riding behavior.

All segments use fixed meshes with sampled transforms, not simulated ropes or per-frame mesh/node creation. Frame endpoints remain fixed. The five-second duration is unchanged; two fabric cues at 1.5 and 2.8 seconds accompany the pulls. The memory bridge now starts at 4.4 seconds in the following bike-touch insert. The memory frees the present-day stage and hides luggage; returning to departure rebuilds the same secured geometry, then moves it with the bike. The cinematic bag does not add physical cargo to gameplay or save data.

Automated checks sample 101 times for two-hand contact, torso clearance at the grips, planted legs, fixed frame endpoints, projected luggage/grip bounds and constant node count. They cover ordered tightening, pause/focus, rewind, reduced motion, story-state isolation, memory cleanup, departure attachment and morning reset. All-shot Skip comparisons include strap geometry. Native captures: `straps_ready.png`, `straps_first_pull.png`, `straps_second_pull.png`, `straps_secured.png`.

- [ ] Watch the two pulls at natural speed and verify both hands, buckles and short tails read clearly at phone sizes.
- [ ] Review production finger/forearm contact, strap routing, cloth tension and final recorded buckle/fabric timing. Authored point checks are not a complete mesh or cloth assessment.
- [ ] Add carrying/placing the bag, initial threading/fastening with production assets; refine the mounting prototype below.
- [ ] Repeat pause, Skip, memory continuity and departure framing in actual browser/Android builds.

## Laptop packing pass

`departure/laptop_packing` adds eight seconds after the route screen. The editorial cut starts with Raka and his chair nearer the laptop, the laptop pulled to the near-left table edge, and the bag reopened. He closes the lid, grips both sides, lifts before moving across the bag wall, lowers the laptop above the raincoat, releases it, and closes the flap. Preparation actions across the cut are not animated. The bag dimensions accommodate the laptop; the desk prop is reused rather than copied.

`CinematicLaptop` owns the hinged screen and sampled prop/hand motion. `CinematicStage` resets it to the original open desk transform before sampling each shot, restores the chair on other shots, and frees it on the parking cut. Screen text is hidden when the lid closes. The existing actor clip and analytic hand reach use the same director clock; no new animation or physics clock is introduced.

The Cinematic suite samples 101 times to check lid/two-hand/flap contact, closed-lid clearance, bag-wall bounds, base/lid framing and node stability. It also checks contents fitting under the closed flap, route-before-packing order, open-screen restoration, pause/background, rewind, reduced motion, unchanged story state and parking cleanup. All-shot Skip comparison includes the laptop, bag and chair. Captures: `laptop_ready.png`, `laptop_closed.png`, `laptop_lift.png`, `laptop_packed.png`.

- [ ] Review the preparation cut, two-handed weight transfer, torso lean and final release at natural speed.
- [ ] Inspect fingers, elbows, lid and bag contact using production meshes; bounded prop checks are not full character collision or cloth validation.
- [ ] Review route readability, framing and cue timing on phone-size displays and actual Web/Android builds.
- [ ] Add preparation movements and remaining item/luggage-fastening performances; replace synthesized fabric with recorded foley.

## Waking performance pass

The existing morning `room` shot now uses `performance: "wake"` and a bedside medium camera. The eight-clip actor can lie face-up with its head supported by the pillow, rise and move to the foot edge, then lower the shins into a seated pose. Bare feet replace the walking shoes only during this clip. All transforms derive from normalized director progress; there is no separate animation clock. Other clips explicitly reset torso rotation/translation, head offset, leg-root height and footwear visibility.

`bedside_phone: true` on `alarm` and `room` places the three existing phone parts on the bedside table; other shots restore the original desk placement. This is shot presentation data, not a save field. The five-second duration, `room` ID and sequence/skip checkpoint contract are unchanged. A `fabric` cue at 1.6 seconds reuses the synthesized cloth asset through the existing SFX/Master buses.

Automated checks cover horizontal/upright torso orientation, initial/final bed placement, bare-foot visibility, intermediate motion, pause/focus, reduced camera motion, deterministic backward seeking, pose/phone reset and unchanged story state. Forty-one timeline samples check knee/shin centerline clearance before bending below the mattress. This is a bounded geometry check, not production collision/IK or a complete contact assessment. Native captures: `wake_alarm.png`, `wake_lying.png`, `wake_rising.png`, `wake_seated.png` in the ignored screenshot folder. All-shot skip tests include the waking clip; audio tests cover cue onset, once-only scheduling and Skip cleanup.

- [ ] Watch the five-second action at natural speed; review the slide toward the bed edge, weight transfer and pacing before the coffee cut.
- [ ] Refine torso/pillow/mattress and hand contact, clothing, bare feet and facial/eye performance with final rigs.
- [ ] Add appropriate authored cloth deformation and final recorded bedsheet foley; the current bed has no simulated cloth.
- [ ] Check bedside alarm readability and head/torso framing across phone sizes and enlarged UI/text settings.
- [ ] Repeat pause/background, Skip and Continue in actual Web/Android exports.

## Cinematic sound pass

Five original mono 22,050 Hz PCM sketches are synthesized by `tools/generate_cinematic_audio.py`. No recordings or third-party sounds are used. This implements the sound timeline and memory transition; final foley/voice performances and listening acceptance remain open.

| Shot | Cue | Start within shot | Duration |
| --- | --- | --- | --- |
| Morning / alarm | alarm | 0.15 s | 2.0 s |
| Morning / room (waking) | fabric | 1.6 s | 0.85 s |
| Office / HR message | message | 0.25 s | 0.45 s |
| Night / Mom calls | phone | 0.20 s | 2.6 s |
| Departure / packing | fabric | 1.6 s and 3.3 s | 0.85 s each |
| Departure / laptop_packing | fabric | 3.0 s and 6.6 s | 0.85 s each |
| Departure / straps | fabric | 1.5 s and 2.8 s | 0.85 s each |
| Departure / bike_touch | fabric | 1.6 s and 3.0 s | 0.85 s each |
| Departure / bike_touch | memory_motor | 4.4 s | 4.0 s, across the next two cuts |
| Departure / mount | fabric | 2.5 s | 0.85 s |
| Departure / helmet_pickup | fabric | 1.6 s | 0.85 s |
| Departure / helmet | fabric | 2.8 s | 0.85 s |
| Departure / chin_strap | fabric | 2.5 s | 0.85 s |

Each shot may contain an ordered `audio` array of `{ "cue": "bank_id", "at": seconds }`. `data/audio/cinematic.json` maps IDs to imported assets and gain in dB. Events must start within their shot. `CinematicAudio` owns two SFX voices and the director advances its clock; ordinary cuts keep remaining tails. Full voices cause additional requests to be discarded. A late frame starts a still-relevant cue at its elapsed offset and drops sounds whose duration has already passed. No queued event survives its shot, skip, replacement, completion or cancellation.

Audio requires the existing user activation. Master/SFX zero drops new events; existing sound follows its bus mute. Pause/background freezes active stream playback and both shot/audio clocks. Resume continues the same voice. Skipping restores final visual/story state without playing skipped sound events. Existing checkpoint semantics remain: Continue restarts the stable sequence, not a saved mid-sound position.

- [ ] At natural speed, listen to the alarm, HR notification and ringtone. They should remain quiet and readable without resembling urgent gameplay prompts.
- [ ] Compare packing fabric with the prototype reach; record contact/timing adjustments for the final animation pass.
- [ ] Listen from bike touch through the two-second memory, helmet preparation, mounting and title. The motor/air should connect the images, fade naturally and leave space for the present-day road sound.
- [ ] Pause mid-cue, open settings, mute/unmute SFX, background/resume and skip. Check for clicks, stale alarms, duplicate cues or tails under dialogue.
- [ ] Compare headphones and phone speakers at comfortable volume; approve final timbre, gain and ambience balance only after human listening.
- [ ] Repeat activation, pause/focus, touch Skip and Continue on real Web/Android exports.

Run `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite CinematicAudio -FixedFps 30` for logical coverage, or add `-Visual` for native playback/mixer checks. Tests cover asset/event metadata, late frames, once-only scheduling, two-cut memory tails, bounded voices, pause/background, muted/unknown events, replacement/skip/cancel/free cleanup and unchanged journey bytes. Native tests additionally verify playback position, pause/resume and samples reaching SFX. They do not replace human listening or target-platform acceptance.
