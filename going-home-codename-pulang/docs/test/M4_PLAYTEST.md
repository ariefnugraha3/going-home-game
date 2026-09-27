# M4 lighting, weather and ambience review

## Compare moods

Open Practice ride, select a road section, then Pause → Light & weather. Compare Morning, Overcast, Drizzle, Rain, Heavy rain, Morning mist, Golden hour and Night. Selecting a profile resumes riding and blends the world over three seconds. Pause freezes the visual transition; rapid changes replace the previous blend. Ambient loops continue quietly across pause and crossfade rather than restart. Section selection keeps the active mood; local reports record `weather_profile` alongside the existing comfort metrics.

The same resources drive the story road. `data/chapters/karawang.json` contains ordered `atmosphere` distance cues. Rest and completed checkpoints restore night. Profiles live in `data/weather/*.tres`, use `WeatherProfile`, and are editable in the inspector. Colors, energy, rotation, fog, rainfall, wetness and night amount are authored together. `RoadWorld.weather_profile_changed` is available for future NPC responses; NPC weather behavior is not implemented yet.

Wetness adjusts road color and roughness. It does not add a reflection pass, puddle simulation, traction penalties, or a full-screen wet lens shader. Rain is limited to 44 streaks on Low and 90 on Medium/High, with fewer and shorter streaks for drizzle. Night uses one unshadowed motorcycle beam and warm unshadowed stop lights; Low keeps them for readability while disabling directional shadows.

The added insect audio is synthesized placeholder material from `tools/generate_audio.py`. Rain volume follows the profile's intensity; birds fade toward silence at night. Existing loop playback continues at boundaries. The first-night music phrase and location/vehicle cues are now implemented as original synthesis from `tools/generate_soundscape.py`; recorded motorcycle/regional sound remains pending.

## Human acceptance — pending

- [ ] Inspect all profiles at the warung and on the practice bends. Record recognizable Indonesian roadside cues, warmth, silhouette clarity, and color consistency.
- [ ] Confirm Night reads as night while road edges, corners, cockpit and stops remain legible. Review the beam and warm practical lighting at Low / 30 FPS.
- [ ] Compare drizzle and heavy rain: visibility, streak density/speed, wet road and rain volume should communicate different conditions without discomfort.
- [ ] Switch rapidly between rain/night/morning and pause during a blend. Look for flashes, stale lighting, or overlapping transitions.
- [ ] Ride through the chapter's weather cues and continue a completed save. Check clearing weather and night at the guesthouse against narrative pacing.
- [ ] Listen on headphones and phone speakers, including pause/section changes. Review insect tone/repetition, rain balance, bird fade and engine masking. Automated audio target checks do not assess mix quality.
- [ ] Run the same scenes in real Web and Android exports. Record FPS/frame time, draw calls, thermals and visibility; native desktop captures are not platform acceptance.
- [ ] Complete final hero bike/character, regional recordings and final music/mix review before accepting M4/M5 art and audio.

## Reproduce technical checks

`powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Mood -Visual -FixedFps 30`

The test helper isolates player storage. Mood tests check resource references, environment targets, interrupted/paused blends, quality bounds, UI selection, report metadata, save isolation and story restoration. Native screenshots are written to ignored `tests/screenshots/mood_*.png`. The rain and audio targets are numerical checks; screenshot review and human listening remain distinct.

## Audio listening pass — pending

- [ ] Start from a fresh title: silence before the first user gesture. Ride from city to fields, then stop at the warung: traffic should blend down, crockery appear without restarting ambience, and rain sound sheltered. No roof rain in dry weather.
- [ ] Compare idle, acceleration, braking, actual stop and restart. Wind should fade out at rest. Check ignition/cooldown balance; pause/resume must not replay ignition. Recorded brake/mechanical detail remains future work.
- [ ] Finish the guesthouse conversation: the sparse 24-second phrase should support reflection and then leave silence. Choose a journal entry mid-phrase; it should continue. Return to title or start practice; music must stop. Continue at rest/completion must not restart it.
- [ ] Adjust all six audio sliders, including zero, and restart the game. Check independent Music/SFX settings persist without changing the journey checkpoint.
- [ ] Pause and background during music or ignition: no cue progression while suspended, no output while backgrounded, and no new cue on resume. Repeat in a browser iframe and on physical Android after exports are available.
- [ ] Listen on headphones and phone speakers at comfortable volume: assess melody audibility, harshness, loop seams/repetition, traffic masking, indoor leakage and rain balance. Record findings; numerical/native playback tests cannot approve this mix.

`powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Audio -Visual -FixedFps 30`

Audio tests cover activation, regional crossfades, shelter/weather mixing, bus mute and settings/save isolation, non-looping music, pause/focus suspension, scene cleanup, actual stop/restart and Continue deduplication. Headless tests check state and gains; native tests additionally check live stream playback, pause state and retained loop position. Settings capture: `tests/screenshots/audio_settings.png` (ignored).

## Interface feedback review

`data/audio/soundscape.json` defines three UI cues and gains. `tools/generate_ui_audio.py` generates original mono 22,050 Hz PCM WAVs with short attack/release envelopes: select (100 ms), confirm (180 ms), back (120 ms). Run `python tools/generate_ui_audio.py`, then reimport in Godot. Existing import metadata/UIDs are retained. No external audio library or recording is used.

`GameUI._button` plays the assigned cue before invoking its original callback; selectors/toggles and explicit keyboard navigation also trigger feedback. Showing a panel, focus movement, hover, slider dragging, and notifications do not trigger tones. `AudioManager.ui_event` requires activation, accepts paused menus, rejects background/muted/unknown events, and uses a single UI player with an 80 ms minimum interval. Rejected sounds never block the UI action or enter a queue. The UI bus sends to SFX, then Master. Focus loss stops the short UI tone; scene transitions can let its remaining tail finish. These tones indicate input/selection, not successful checkpoint writes.

- [ ] Start with a fresh title and activate Settings using keyboard, mouse and touch. Confirm silence beforehand and exactly one subtle cue after activation.
- [ ] Compare select, confirm and back on menus, phone album, replies, dialogue choices and journal options. Review volume relative to the engine, rain and quiet interior scenes.
- [ ] Open and close pause by Escape in story and practice; browse while paused. UI feedback should remain available without restarting the engine.
- [ ] Set SFX and Master to zero separately. Menu interactions must remain functional and quiet; raising the slider must not replay missed sounds.
- [ ] Navigate rapidly, hold a key, hover and drag volume sliders. No layered tones or continuous chatter; all intended menu actions still work.
- [ ] Background/return during feedback. No continuing UI tone or replay when focus returns. Repeat browser user-gesture activation in an iframe/fullscreen and on Android.
- [ ] Listen on headphones and phone speakers. Record harshness, distraction, audibility and desired gain changes; prototype tones and numerical waveform checks are not final mix acceptance.

The Audio suite covers imported nonlooping streams, routing, repeat limiting, zero-volume/background suppression, paused native playback, keyboard menu activation, real button/selector callbacks, Escape navigation and checkpoint isolation. The native test preserves its requested FPS setting through settings save/load. Human listening and actual platform acceptance remain pending.

## Analog cockpit review

`BikeInstruments` builds two analog dials with a 4.5-radian sweep: 0–100 km/h and 0–10,000 RPM. Needles start at zero. Dial units, larger numbers and major/minor ticks use the same geometry in riding and cinematic bikes. The cluster tilts 22 degrees toward the rider. The current camera, glance input and FOV remain unchanged; the numerical speed HUD is still the easiest reading on small displays.

The controller supplies real controller speed and a deliberately simplified RPM presentation: 1,300 idle + up to 3,900 from speed + up to 900 from throttle, approached at 3,600 RPM/second. This does not change acceleration, steering, fuel, sound or introduce gears. Pause freezes the readings. Stop clears both needles immediately; recovery/teleport shows zero speed and powered idle when appropriate. An engine-off moving bike can retain speed while the tachometer reads zero.

Headlight/night intensity drives low-cost emission on three per-cluster materials; lit labels become unshaded above a small night threshold. No extra lights or subviewports are used. Unpowered/parked/cinematic bikes remain unlit and do not share those materials. No journey or settings schema changes are involved.

- [ ] Compare Morning and Night in Practice ride, both straight ahead and looking down. Check that speed and RPM are distinct, labels remain legible and the panel does not distract from the road.
- [ ] Test actual phone sizes, Low/Medium quality and supported FOV values. Record the smallest comfortable instrument reading; retain the numeric HUD as the primary fallback.
- [ ] Idle, accelerate, release throttle, brake, recover and stop at the shelter. Check that needles settle calmly and stop/recovery cannot leave stale speed.
- [ ] Pause, open settings, resume, background the app and Continue a story checkpoint. Confirm readings follow the same motorcycle state.
- [ ] Review the final cluster against supplied motorcycle references when available. This code-authored assembly is not an approved manufacturer-accurate model.

Run `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Cockpit -Visual -FixedFps 30`. The suite covers both dial calibrations, bounds/nonfinite input, idle/throttle/coasting, 30/60-update agreement, per-bike material isolation, no per-update geometry allocation, physical riding, stop/recovery, pause, day/night lighting, Continue and unchanged practice story/save bytes. Native captures are `tests/screenshots/cockpit_morning.png`, `cockpit_morning_glance.png`, `cockpit_night.png`, `cockpit_night_glance.png` and `cockpit_night_off.png` (ignored). Automated calibration and desktop captures do not close the human/device acceptance gates.
