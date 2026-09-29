# M6 localization and template validation

The English-only game now resolves 195 authored JSON text fields through `data/localization/en.json`. Dialogue, cinematic captions/screens, chapter/journal/stop text, practice signs and phone content retain their previous English wording. The catalog is loaded by `ContentText`; content loaders receive resolved copies without modifying source objects, progression IDs or saves.

## Stable keys

Each object owns a `text_keys` map alongside its inline source text:

```json
{
  "text": "Take your time. The road will still be there.",
  "next": "end",
  "text_keys": {"text": "dialogue.authoring_example.authoring.greeting.nodes.rest.text"}
}
```

The English catalog has `locale: "en"` and a `strings` object mapping those keys to the same English source text. Keep an existing key when editing wording, moving a record or reordering choices/shots. Update both the source and English catalog when revising text. A key belongs to one field; duplicated records need new keys. Do not bind enum/control fields such as message `type`, call `direction`, shot movement/performance or narrative IDs.

`seed_localization.py` supplies missing bindings and English entries. It defaults to a dry run; only `--write` changes files. Initial names are derived from the current source location, but are then persisted on the object and never recalculated. Numeric segments in a seeded choice/shot key are part of its permanent name, not a live array lookup. Moving the record preserves the key. Existing catalog values are never overwritten, and duplicate/invalid existing bindings are rejected. The helper does not remove obsolete entries or repair invalid content.

```powershell
python tools/seed_localization.py
python tools/seed_localization.py --write
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Content
```

For a new encounter copied from an existing bundle, remove the copied records' `text_keys` before seeding; keep them when moving the same encounter. Review the generated diff and run Content validation. Renaming a key intentionally requires updating every corresponding catalog. Deleting content requires deleting its unused catalog entries.

## Catalog checks

The read-only content validator requires a unique valid key for every localizable JSON field, an English entry for every used key, exact English/source agreement and no unused entries. It rejects metadata pointing at unknown or non-localizable fields, malformed bindings/catalogs, missing catalogs, duplicate keys and blank translations for nonblank source. Deliberately empty cinematic captions may stay empty. JSON reporting adds `localization_keys`, mapping diagnostic source locations to permanent keys.

Any additional `data/localization/<locale>.json` catalog must have a matching `locale` and complete coverage of the same key set. No extra language is required or shipped. The runtime selects English only; a language picker, translation quality review and GDScript/UI-string migration are outside this pass. Editorial metadata remains in the text inventory but does not receive localization bindings. The validator checks structure and completeness, not the language of prose.

Missing or malformed runtime translations fall back to inline source text so incomplete preview fixtures remain usable. This fallback is not a validation pass: checked-in missing keys fail Content preflight. The seeder and validator never touch player saves.

## Static scene contracts

```powershell
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Toolkit
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite All -FixedFps 30
```

Toolkit discovers `.tscn` files recursively under `scenes/templates` and `tools/authoring`. Godot parses each PackedScene, instantiates it off-tree, checks its authoring contracts and frees it. It never calls `_ready`, builds the road, starts a cinematic or writes story state. This uses Godot's actual resource/inheritance parser instead of a partial text parser for `.tscn`.

Checks cover chapter distances, checkpoint ID, weather/audio references and debug markers; NPC visual/anchor node types, IDs and interaction radius; preview bundle/arrival/dialogue wiring and disabled cinematic story writes; camera/target/end marker types, finite/distinct framing, marker-to-shot IDs and identity cutscene root transforms. Missing shot groups intentionally retain JSON framing. Full JSON shot/graph/schema checking remains in Content preflight. Run Content and Toolkit together through All after changing both content and scenes.

Fault-injection tests break catalog references, source agreement, bindings, translations and scene contracts. Reordering choices/shots verifies key stability; dry-run/idempotence tests verify seeding behavior. Runtime tests verify catalog resolution, fallback and unchanged English bundles; existing narrative and save tests remain the campaign regression gate.

Static validation is bounded to these authoring contracts. It does not prove arbitrary signal scripts correct, certify visual framing, inspect mesh collisions or replace the Authoring runtime suite and human/platform playtests. The [development menu](M6_DEVELOPMENT_MENU.md) now supports live inspection in temporary journey sessions.
