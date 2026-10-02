# Campaign integration and beta readiness

The playable **prototype** connects the whole route. Current scope is native Godot desktop; Web and Android are deferred by request. The native campaign completes through normal gameplay without test teleports or Skip. It does not pass the original roadmap's M7/M8 production or M10 content-lock gates. New chapters use compact 1.8 km routes with distinct authored bends/grades, regional roadside groups, articulated actors and synthesized audio. They are not the planned 25–45 minute finished chapters or an 8–12 hour release.

## Playing the route

Finish Karawang's journal and choose **Continue the journey**. Existing v1 Karawang completion saves expose the same action. Each later road has fuel, a scenic pause, a mandatory encounter and reflection. The end-of-chapter action advances through Cirebon, Tegal, Pekalongan, Semarang, Salatiga, Solo, Ngawi, Madiun, Kediri, Malang, Lumajang, Jember, Banyuwangi and the epilogue. No development menu is required.

The Banyuwangi closing shot leads directly to reflection; **The next morning** opens the epilogue near the family home. Both parents are alive. The career opportunity remains open, and neither response choice determines a good/bad ending. The final journal records permission to remain uncertain.

## Data and persistence

- `Campaign` is the runtime chapter registry. Each chapter JSON supplies stops, weather, journal, next chapter, environment identity, ambient context and arrival/closing shots.
- `campaign.json` contains fourteen branching encounters. Five additional messages connect Dimas, recruitment and the family to chapter-entry/encounter/completion flags.
- Saves retain schema v1. Chapters and checkpoint combinations are validated. Stable checkpoints are chapter start, encounter completed, reflection pending and reflection completed. An interrupted arrival or dialogue replays from the preceding stable checkpoint.
- Completing a home encounter saves before the closing shot. Continue replays the closing shot if interrupted. Skip and natural playback reach the same dialogue/reflection handoff.
- Journal history displays every completed chapter. Route map progress, HUD destination and chapter completion text follow the active chapter.
- Campaign scenes use the host's paused clock. They release riding input, suppress phone banners, retain accessibility settings and restore their caption after Resume.

## Repeatable checks

Run `tools/test.ps1 -Suite Campaign -FixedFps 30` for both branches across the route. It checks mandatory-stop gating, normal chapter advancement, old-save continuation, resource release, pause, Skip/natural handoff, journal persistence, terminal epilogue and invalid save rejection. This is accelerated progression testing using teleports and sampled shot durations, not a natural-speed playthrough.

Run `-Suite Campaign -Visual -FixedFps 30` for the native renderer and screenshots under `tests/screenshots/campaign_*.png`. Run `-Suite All` for the earlier systems, content and lifecycle regressions. The Python validator now rejects disconnected/cyclic chapter routes, missing dialogue, invalid shot cameras/durations/actions, unknown ambience and missing localization.

`tools/export_beta.ps1` builds Web or Android Debug in `export/`. It isolates editor settings, template copies and debug signing material under `.godot-export`; it does not change the user's editor configuration. Export success is only a packaging check.

Run `python tools/audit_exports.py` after both exports. It checks every JSON against the source, validates the Web pack checksums, rejects packaged development/output directories, and prints build sizes and SHA-256 identifiers.

For a Web regression build, run `python tools/prepare_campaign_qa.py`, then run the generated snapshot's `tools/export_beta.ps1 -Platform Web`. Serve its `export/web` directory on localhost. The snapshot starts `CampaignTests` and uses a separate project name/storage namespace. It is test software, not the player distribution. Read the browser console's final `CAMPAIGN RESULT`; closing a tab early is not a passed run.

## Verified on 2026-10-01

- Latest desktop checks: **2,286 runtime checks in 19 suites and 50 Python tests**, zero failures. Native staging: **58 checks**, covering deterministic ignition/grip/cloth contact, actor reset, doorway exit and caption-safe speaker framing. Regional-art captures cover all fifteen route chapters.
- Native assisted New Game-to-ending drive: **37 checks**, **23.264 km**, **2,163.23 simulated seconds**, zero recoveries/contacts, all fifteen reflections saved. It uses ordinary input actions and visible menu buttons, waits for cutscenes and visits every optional stop; no test checkpoint assignment, teleport or Skip. Dialogue automation is faster than a human reader. The subsequent decorative roadside pass is validated separately from this run; its frame figures are not a benchmark of the later art pass. See [desktop guide](../DESKTOP_PLAY.md).

Earlier integration/platform evidence (historical, before the latest desktop edits):

- Headless: **2,228 runtime checks across 18 suites**, **48 Python tests**, no failures. Content: 27 JSON files, 764 inventoried text fields, 616 stable keys, no validation errors or warnings.
- Native Windows: campaign **287 checks**, audio **76 checks**, cinematic audio **83 checks**, no failures. The short UI-tone mixer test now measures the cue over a bounded 300 ms window after renderer initialization instead of relying on one frame.
- Web: **572 campaign checks**, both response branches through the epilogue, no progression failures. This uses accelerated fixtures, not a natural-speed participant session. The final title-toast cleanup and text-only proofread were validated separately after this snapshot run.
- Fixed a Web `RangeError: Array buffer allocation failed` found in the sample audio backend during the original run. Pause state is now assigned only when it changes, for both ambient/music and cinematic players; the repeated full-route test completed without that exception.
- The successful Web test printed a `WorkerThreadPool::Group` / `PagedAllocator` message after its final result, during explicit engine shutdown. A minimal Web scene with a Label and `SceneTree.quit()` did not reproduce it. This remains an unresolved test-shutdown finding; do not describe the browser console as entirely error-free. The normal Web UI hides Quit, but the finding is not waived as an engine bug.
- Web and signed Android debug packages build successfully and pass the source/content audit. Android physical execution remains untested: the ADB device list is empty.

See [validation evidence](VALIDATION.md) for logs and package fingerprints, and use the [session report](BETA_PLAYTEST_REPORT.md) for actual participant results.

## Open acceptance gates

| Gate | Evidence still required |
| --- | --- |
| M5 production quality | Finished bike/characters, performances and foley; full packing/strap contact; accepted riding comfort; slice pacing and art review |
| M7/M8 production | Unique finished environments, longer authored road/stop pacing, final NPC performances, chapter-specific sound, narrative playtests and all mandatory cinematic shot lists reviewed against the GDD |
| M9 desktop integration | Full ordinary-input native automation passes; human playthrough feedback remains open. Web/Android completion and the explicit Web test-shutdown allocator finding are deferred |
| M10 content lock | Narrative/art/audio sign-off, measured pacing, resolved findings and frozen approved content |
| M10 player categories | Cozy, driving, non-Indonesian, Indonesian, mobile and motion-sensitive participants; record overlap rather than inventing testers |
| M10 desktop usability | Human text/cockpit readability, headphone/speaker mix and comfortable extended riding. Physical touch, notches and browser-specific checks are deferred |

For each human session record build hash, device/browser, participant category, route covered, elapsed time, comfort feedback, issue reproduction, severity, fix and retest result. Unrun sessions remain **not tested**. The older README overview paragraphs are historical; this document and the roadmap checklist describe the expanded scope.
