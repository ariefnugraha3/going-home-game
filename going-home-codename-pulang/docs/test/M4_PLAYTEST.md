# M4 lighting, weather and ambience review

## Compare moods

Open Practice ride, select a road section, then Pause → Light & weather. Compare Morning, Overcast, Drizzle, Rain, Heavy rain, Morning mist, Golden hour and Night. Selecting a profile resumes riding and blends the world over three seconds. Pause freezes the visual transition; rapid changes replace the previous blend. Ambient loops continue quietly across pause and crossfade rather than restart. Section selection keeps the active mood; local reports record `weather_profile` alongside the existing comfort metrics.

The same resources drive the story road. `data/chapters/karawang.json` contains ordered `atmosphere` distance cues. Rest and completed checkpoints restore night. Profiles live in `data/weather/*.tres`, use `WeatherProfile`, and are editable in the inspector. Colors, energy, rotation, fog, rainfall, wetness and night amount are authored together. `RoadWorld.weather_profile_changed` is available for future NPC responses; NPC weather behavior is not implemented yet.

Wetness adjusts road color and roughness. It does not add a reflection pass, puddle simulation, traction penalties, or a full-screen wet lens shader. Rain is limited to 44 streaks on Low and 90 on Medium/High, with fewer and shorter streaks for drizzle. Night uses one unshadowed motorcycle beam and warm unshadowed stop lights; Low keeps them for readability while disabling directional shadows.

The added insect audio is synthesized placeholder material from `tools/generate_audio.py`. Rain volume follows the profile's intensity; birds fade toward silence at night. Existing loop playback continues at boundaries. No music cue or recorded motorcycle/regional sound is claimed.

## Human acceptance — pending

- [ ] Inspect all profiles at the warung and on the practice bends. Record recognizable Indonesian roadside cues, warmth, silhouette clarity, and color consistency.
- [ ] Confirm Night reads as night while road edges, corners, cockpit and stops remain legible. Review the beam and warm practical lighting at Low / 30 FPS.
- [ ] Compare drizzle and heavy rain: visibility, streak density/speed, wet road and rain volume should communicate different conditions without discomfort.
- [ ] Switch rapidly between rain/night/morning and pause during a blend. Look for flashes, stale lighting, or overlapping transitions.
- [ ] Ride through the chapter's weather cues and continue a completed save. Check clearing weather and night at the guesthouse against narrative pacing.
- [ ] Listen on headphones and phone speakers, including pause/section changes. Review insect tone/repetition, rain balance, bird fade and engine masking. Automated audio target checks do not assess mix quality.
- [ ] Run the same scenes in real Web and Android exports. Record FPS/frame time, draw calls, thermals and visibility; native desktop captures are not platform acceptance.
- [ ] Complete final hero bike/character, regional recordings and first music cue before accepting M4/M5 art and audio.

## Reproduce technical checks

`powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Mood -Visual -FixedFps 30`

The test helper isolates player storage. Mood tests check resource references, environment targets, interrupted/paused blends, quality bounds, UI selection, report metadata, save isolation and story restoration. Native screenshots are written to ignored `tests/screenshots/mood_*.png`. The rain and audio targets are numerical checks; screenshot review and human listening remain distinct.
