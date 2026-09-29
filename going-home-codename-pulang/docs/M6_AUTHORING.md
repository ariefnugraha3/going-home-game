# M6 encounter authoring templates

This increment supplies reusable chapter, NPC and cutscene scenes, plus an isolated encounter preview. It is tooling for a small encounter, not a new campaign chapter or acceptance of M5's human/platform gates.

## Run the example

Open `tools/authoring/EncounterPreview.tscn` in Godot 4.7.2 and press **F6**. F5 still launches the main game. Move with the preview buttons or select **Go to host**, then **Say hello**. Watch the three-second arrival scene or use **Skip arrival scene**, choose a reply and continue. Advance past 100 m to see the checkpoint event. Restart to clear local state and replay the other branch.

The 120 m example is a bounded test road. Forward/back buttons sample route distance; they do not simulate riding physics. Its road mesh includes collision for integration into a chapter host. The existing cinematic parking stage and blocking character are reused deliberately; they are not final encounter art.

## Scene contracts

| Scene | Authorable properties and behavior |
| --- | --- |
| `scenes/templates/ChapterTemplate.tscn` | Route length; NPC, weather, ambience and checkpoint distances; weather profile, audio zone, checkpoint ID and debug labels. Samples update weather/audio-zone signals; checkpoint fires once until reset. |
| `scenes/templates/NPCTemplate.tscn` | Display name, shirt color, interaction label, dialogue ID and radius. Includes visual/animation controller, DialogueAnchor and InteractionAnchor. Rejects distant, busy, paused, unfocused and moving (8 km/h or faster in either direction) requests. |
| `scenes/templates/CutsceneTemplate.tscn` | Definitions Path selects the JSON shot track. `Shots/<shot_id>/Camera`, `Target` and optional `End` markers override camera coordinates. Missing markers use JSON values. Natural completion and Skip both emit one dialogue handoff. Reduced motion preserves framing without camera travel. |
| `tools/authoring/EncounterPreview.tscn` | Dialogue File and Arrival ID select content; child scene properties select the encounter. Routes NPC requests through the cutscene into a private dialogue instance. Reports missing IDs and invalid chapter event references. |

Chapter distance is measured along the existing route convention (`RoadWorld.center`), not the node's Z coordinate alone. `sample_distance(distance)` is the host's integration point; route values are clamped to the chapter extent. Backtracking restores the earlier weather/audio zone but does not re-fire the checkpoint. Keep the cutscene root transform at identity; its markers are relative to the staged cinematic origin. Geometry is generated at runtime, so F6 is required for the assembled view.

The chapter emits `ambience_changed(id)` and `checkpoint_requested(id)`; the host chooses audio and persistence behavior. NPC emits `dialogue_requested(id)`. Cutscene emits the same signal after its shot track. `release()` returns the NPC to idle after dialogue or cancellation. The preview wires these contracts and shows checkpoint events without saving them.

## Author another encounter without editing global code

1. Duplicate or inherit `EncounterPreview.tscn`. Enable **Editable Children** on the chapter/NPC/cutscene instances as needed.
2. Copy `data/dialogue/authoring_example.json` to a new file under `data/dialogue`. Assign a unique encounter ID and edit its speaker, lines, choices and flags. Node names are local to that encounter; all branches must reach `end`.
3. Set the preview's **Dialogue File** to that file and the NPC's **Dialogue Id** to its new ID. Change the NPC name, shirt, interaction label and chapter **Npc Distance**. The preview forwards that dialogue ID through the arrival automatically.
4. Copy `data/cutscenes/authoring_example.json` to a new file under `data/cutscenes`, give its sequence a unique ID, and edit the ordered `shots` array. Set **Definitions Path** on the cutscene and **Arrival Id** on the preview. Add/rename marker groups to match shot IDs. Stages and performance names must exist in the current cinematic runtime.
5. Set the chapter's event distances, weather, ambience and checkpoint ID. Keep distances within **Route Length**. Set **Debug Markers** off for a clean view.
6. Remove copied `text_keys` for a new encounter (preserve them when moving existing content), then run `python tools/seed_localization.py --write` and review the new keys/catalog entries. Run `tools/test.ps1 -Suite Content` and `-Suite Toolkit`, then F6 the copied scene and exercise natural completion, Skip, both replies, backtracking and restart. See the [localization workflow](M6_LOCALIZATION.md). No autoload registration, boot flow or global script edit is needed for this preview encounter.

The automated Authoring suite repeats this workflow with a new dialogue bundle/ID, changed NPC placement/weather, and a camera-marker override. It also checks both dialogue branches, node/choice flags, pause/focus, restart, event boundaries, missing references and unchanged campaign state/save bytes.

## Isolation and remaining work

The preview uses `write_story_state = false` for its private dialogue and cutscene instances. Node/choice flags and dialogue conditions use local flags. Cutscene story flags are suppressed. No preview path calls SaveManager; checkpoint IDs are diagnostic only. Exiting restores the previous ambience, rain and night targets. Main-game loader defaults and story writes remain unchanged.

This is not automatic registration of an encounter in the playable campaign. Campaign scene composition, supported save checkpoints, progression and chapter transitions still need explicit chapter-host integration and tests. The current SaveManager continues to accept only the existing prototype checkpoints. The standalone preview lives under `tools/`, excluded by shipping export presets; it adds no player-facing debug menu.

Stable JSON localization keys/catalog checks and static template contracts are validated by Content and Toolkit. The Python validator discovers the example bundles; Toolkit uses Godot to inspect `.tscn` wiring off-tree. The [development menu](M6_DEVELOPMENT_MENU.md) adds live campaign test controls. Native Windows review does not certify Web/Android or production animation quality.

```powershell
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Authoring -FixedFps 30
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Authoring -Visual -FixedFps 30
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite All -FixedFps 30
```
