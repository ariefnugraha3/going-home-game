# M1 riding comfort playtest

Status: **human review pending**. The practice road and automated regression checks are implemented. Neither automated driving nor the session report proves that riding is comfortable or enjoyable.

## Setup

Open the game with Godot 4.7.2 and choose **Practice ride**. Record the device, resolution, input method, and quality preset. Start with steering assist and reduced motion enabled. Choose **Sections → Getting comfortable** to begin at the start.

The track contains seven sections: straight, gentle bend, tighter bends, rise/descent, bumps, junction, and stop area. The junction is a crossing to observe while continuing straight, not a branching route. The barrier on the right near the end is for deliberate collision/recovery checks; normal left-lane riding avoids it.

Practice does not mutate story flags, fuel, odometer, phone, journal, checkpoint, or journey files. Settings remain shared with the main game. There is no timing goal or score.

## Five-minute onboarding session

- [ ] Understand acceleration, steering, and braking within 30 seconds.
- [ ] Cruise at a comfortable pace without repeatedly correcting the controls.
- [ ] Slow before the tighter bends and negotiate them without leaving the road.
- [ ] Traverse the rise, descent, and bumps; note any abrupt camera movement.
- [ ] Slow at the junction, glance both ways, then continue straight.
- [ ] Stop at the shelter and switch off the engine using the interaction prompt.
- [ ] Ride again, pause/resume, and verify that no throttle remains held after resuming.

## Fifteen-minute session

Repeat the road using **Ride the road again**. Record actual riding time; pauses and section selection should not count toward the 15 minutes. There are no story cutscenes on this track.

- [ ] Complete 15 minutes of comfortable riding with ordinary stops.
- [ ] Compare steering assist on/off and document which feels more predictable.
- [ ] Compare reduced motion on/off; record dizziness or nausea honestly.
- [ ] Repeat bends, braking, and bumps with **Limit to 30 FPS** enabled.
- [ ] Compare clear skies and rain for road visibility and audio balance.
- [ ] Approach the right-lane test barrier at low speed: expect a forgiving stop, then recover with Backspace or the pause menu.
- [ ] Repeat using touch controls, including steering and throttle held together, brake, pause, and release.

## Record evidence

Choose **Save a local playtest report** from the pause or shelter menu. The file is written to `user://ride_reports/`; on a normal Windows profile this is under `%APPDATA%/Godot/app_userdata/PULANG/ride_reports/`. Test-script reports are isolated under the project's `.godot-test/` directory instead.

Reports include active riding time, actual movement distance, recovery/contact counts, maximum camera roll, settings at export, and the most recent 900 unpaused riding frame intervals (median/p95). They are bounded diagnostic samples, not whole-session profiling or cross-device performance certification. If you change settings, save separate reports before and after each configuration. No report is sent over a network.

Add these **human notes** alongside the report:

| Item | Observation |
| --- | --- |
| Device / OS / display / input | |
| Session duration and configuration | |
| Turning predictability and correction effort | |
| Braking distance and ability to stop where intended | |
| Camera stability on bends and bumps | |
| Dizziness / nausea, including when it started | |
| Collision/recovery frustration | |
| Touch fatigue and obscured view | |
| One change that would improve the ride | |

## Acceptance remains open

M1 can only be accepted after human review confirms understandable controls, pleasant cruising, comfortable camera movement, predictable stopping, and stable collision behavior. Target-platform acceptance also needs actual Web and Android builds; desktop native and fixed-cadence headless runs do not replace those checks.
