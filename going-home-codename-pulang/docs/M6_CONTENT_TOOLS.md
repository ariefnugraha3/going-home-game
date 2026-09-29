# M6 content validation

The first toolkit increment provides a read-only validator for the existing JSON content contracts. It runs without Godot or third-party Python packages. Python 3.11+ is required for `Content` and `All` in `tools/test.ps1`; other suites retain their existing Godot-only requirements. Use `-Python C:\path\to\python.exe` if Python is not on PATH.

From the project directory:

```powershell
python tools/validate_content.py
python tools/validate_content.py --strict
python tools/validate_content.py --format json
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Content
```

The default project is derived from the script location, so the command also works from another working directory. `--project` can select a copied fixture project. The tool prints diagnostics with a file and field location, never repairs content or writes saves. JSON output includes errors, warnings and a text inventory. Exit status is 0 for no errors, 1 for errors (or warnings with `--strict`), and 2 for invalid CLI arguments.

## Checked contracts

| Content | Checks |
| --- | --- |
| All `data/**/*.json` | Valid JSON, duplicate object keys, finite numbers; unknown schema files receive a warning |
| Dialogue bundles | IDs unique across files, start node, existing next/choice targets, reachability, path to end, unconditional choice fallback, speaker/line/choice text |
| Cutscene bundles | Unique sequence/shot IDs, nonempty shots, duration, FOV, camera vectors, supported stage/clip names, walking vectors/cycles, captions, audio cue IDs and ordered in-shot times |
| Cinematic/UI/music audio | Resource paths stay inside the project, files exist, bounded gain, readable nonempty PCM WAV data without truncated payload |
| Soundscape | Zone references, blend weights and positive region lengths |
| Chapter data | Unique chapter IDs, route length, stop IDs/distances/text, mandatory stop references, ordered weather with existing profiles, journal choices and next-chapter references |
| Practice route | Nonempty sections, unique IDs, ordered non-overlapping positive spans within the route, signs/hints |
| Phone | Unique IDs per section, channel/delay/text, photo resources, call dialogue and remembered-node references |

The missing `karawang → cirebon` link is an explicit warning for the existing slice boundary. Other missing chapter IDs are errors. Strict mode intentionally fails until that boundary is resolved; do not use a normal-mode pass as proof of a complete campaign.

## Text inventory and limits

`text_inventory` maps source-field locations to current strings for review. Array indices are diagnostic locations, not permanent localization keys. The [localization pass](M6_LOCALIZATION.md) adds persistent `text_keys`, an English catalog and runtime resolution for 195 authored JSON fields. `localization_keys` maps diagnostic locations to those keys. Missing/duplicate/unused keys, stale English text, invalid bindings and incomplete optional catalogs fail validation. GDScript/UI text extraction and language-quality review remain outside this checker.

The validator discovers dialogue/cutscene/chapter bundles for authoring checks, but discovery does not register new files with the game. The [encounter templates](M6_AUTHORING.md) now select dialogue/cutscene bundles through Inspector properties. Campaign integration remains explicit. Supported stage/clip names mirror the current cinematic runtime and must be maintained when adding performances. A graph path to `end` is a structural check, not exhaustive simulation of flag combinations. `.tres` existence is checked; Godot import/runtime tests remain responsible for resource parsing. Scene wiring, progression flags, saves, pacing, visual contact and platform acceptance still require their existing tests/reviews.

## Regression workflow

`tools/test.ps1 -Suite Content` checks real content and runs the Python fault-injection suite. `-Suite All` runs it before the Godot import and runtime suites, stopping early on invalid content. Fixtures copy data/audio/photo files into disposable `.godot-test/content-*` folders; tests mutate only those copies. Coverage includes duplicate IDs/keys, malformed types/JSON, missing and escaping paths, missing dialogue edges, trapped cycles, unavailable choices, blank text, corrupt/truncated WAV, cue timing, weather references, out-of-road stops, broken phone links, strict status and byte-for-byte read-only behavior.

Reusable chapter/NPC/cutscene templates and the standalone new-encounter proof are available in the authoring pass. `-Suite Toolkit` checks static template contracts using Godot's scene parser, and `All` includes it. The [development menu](M6_DEVELOPMENT_MENU.md) now supports live test sessions. M5 human and target-platform acceptance remains open.
