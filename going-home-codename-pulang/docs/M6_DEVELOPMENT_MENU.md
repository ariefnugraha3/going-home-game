# M6 development menu

Launch from the project directory with `powershell -ExecutionPolicy Bypass -File tools/development.ps1`, then press **F8** or click **Development**. The helper accepts `-Godot` for another editor executable. Equivalent engine arguments are `--path <project-directory> -- --dev-tools`.

Both the menu and session entry require a debug-capable **editor engine** and the explicit `--dev-tools` argument. Ordinary F5/game launches do not create the menu. Export-template builds lack the editor feature and cannot activate it even with the argument. The old `--story-debug` read-only inspector remains separate.

## Test sessions and persistence

Opening the menu snapshots the current journey in memory, pauses gameplay and starts a temporary test session. While that session is active, all ordinary journey checkpoint writes are suppressed before touching the primary, backup or temporary save files. Continue is disabled to keep test and saved state separate. Closing the panel resumes the previous screen/pause state; **the session remains isolated**, indicated by the persistent test-session badge.

**End test session → title** clears test gameplay, restores the original in-memory journey and re-enables normal persistence. Scene teardown also ends isolation and releases pause. A crash or process kill loses test changes but does not write them to the player's journey. Merely launching with the argument does not activate isolation: normal actions before first opening F8 and after ending a session retain their normal save behavior.

This isolation covers journey state and `journey.json`, `.bak` and `.tmp`. Settings remain normal user preferences and can still be saved by the settings screen. There is deliberately no button to commit test progress to the player's journey.

## Controls

| Control | Behavior |
| --- | --- |
| Chapter/checkpoint | Prologue: morning cinematic, commute, departure cinematic. Karawang: road start, warung, guesthouse reflection, complete. Loads a fresh deterministic fixture with prerequisite flags and a journal for completion; does not simulate all earlier choices. |
| Weather/time preset | Automatic, morning, overcast, drizzle, rain, heavy rain, golden hour, mist, night. Uses the game's combined weather/lighting presets, not a separate astronomical clock. The override persists during road updates; Automatic restores authored behavior. Unavailable during dialogue/cinematics. |
| Teleport | Moves and stops the bike within the current route bounds. Available only while inspecting a riding state. Closing the panel resumes ordinary road triggers, so teleporting to an arrival can start its cinematic. |
| Story flags | Set a `story.*` key to a JSON boolean, quoted string or finite number, or unset it. Changes notify existing narrative listeners. Editing a flag does not undo already delivered phone messages or rebuild earlier choices; load a checkpoint fixture for a clean test. |
| Performance | Optional live FPS, CPU process time, draw calls, object and node counts. Updates while riding or paused. Headless rendering counters are not meaningful graphics measurements. This is inspection, not a device benchmark. |
| F8 / Escape | Open or close the panel. Restores the exact prior pause/UI state, including dialogue. Opening/mutations are blocked during transitions, lost focus and control-remapping capture. |

The menu is scrollable; the close/end controls remain visible. Only implemented content is listed—this does not unlock or stub the remaining Java route. A chapter jump resets temporary flags, phone state, journal and weather override to its fixture; the original pre-session snapshot remains intact until the session ends.

## Validation

```powershell
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Development -FixedFps 30
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Development -Visual -FixedFps 30
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite All -FixedFps 30
```

The test helper passes `--dev-tools` only to DevelopmentTests and redirects APPDATA to `.godot-test`. Other suites verify the normal launch path without opt-in. Development checks chapter restoration, prerequisite fixtures, weather override/automatic, flag validation, teleport bounds, input/pause/focus guards, F8/Escape, real dialogue checkpoint writes, original-state restoration and byte-for-byte save/backup/temp preservation. It also verifies normal saving resumes after the session ends and isolation is released on scene teardown.

M6's implemented toolkit checklist is now covered. M5 production art, human riding/narrative acceptance and actual Web/Android gates remain prerequisites for mass chapter production.
