# Asset provenance

- All environment, character, vehicle, cockpit, map, and interface geometry in this delivery is original code-authored placeholder work in this repository. No downloaded texture, model, or image pack is used.
- The articulated cinematic actors, six AnimationPlayer clips and father/young-Raka memory set are original code-authored prototypes. No motion-capture files, animation pack or external character model is used.
- The twelve audio WAVs are original synthesized prototypes, including the original 24-second first-night melody. `tools/generate_audio.py` produces the six engine/wind/rain/bird/insect loops; `tools/generate_soundscape.py` produces traffic, crockery, roof rain, ignition, cooldown and the melody. Both use only Python's standard library with seeded randomness. Regenerate with `python tools/generate_audio.py` and `python tools/generate_soundscape.py`, then reimport in Godot. Existing import metadata/UIDs are preserved. These are not location recordings or species-authentic sound studies.
- The default UI font is Godot's bundled Noto Sans; no font file has been copied from the host OS. Retain Godot's bundled third-party notices when distributing engine exports.
- Godot Engine is MIT-licensed. Engine and third-party license information: https://godotengine.org/license/ and https://github.com/godotengine/godot/blob/master/COPYRIGHT.txt .
- Suzuki Thunder 250 is the supplied design reference. No manufacturer-provided assets, logos, or endorsement are included.
- The project owner's game/source licensing decision remains theirs; this file does not assign a new license to the supplied design documents or the overall project.
