# Native desktop campaign

Current scope: run the project in Godot on Windows. Web and Android work is deferred at the user's request; their remaining acceptance tasks have not been passed or deleted.

## Play

1. Import `project.godot` using Godot 4.7.2 Stable and press **F5**.
2. Choose **Begin a new journey**, or **Continue** for the last stable checkpoint.
3. Use **W / Up** to accelerate, **S / Down** to brake and **A/D / Left/Right** to steer. The default riding assist follows the left lane when you release steering. Use **Controls** to inspect or change bindings.
4. Slow below 8 km/h near a roadside stop and press the displayed interaction key. Fuel and scenic stops are optional. Each chapter's encounter is required before reflection; missing it does not strand the player.
5. Choose a journal response and **Continue the journey**. After Banyuwangi choose **The next morning**. The epilogue ends with **There is time** and allows reading the complete journal or returning to the title.

**Practice ride** is available immediately and does not change the story save. **Escape** pauses; Settings includes reduced motion, riding assist, FOV, interface size and a 30 FPS cap. New Game replaces the journey only after confirmation and preserves preferences.

The supplied engine can also launch the game directly from the project folder:

```powershell
& 'D:\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe' --path .
```

## What is verified

The native assisted campaign automation begins on the ordinary title menu, drives every road using input actions, visits the optional stops, allows every cinematic to finish naturally and uses the visible dialogue/journal buttons. It neither assigns story checkpoints nor teleports past roads. It completed the Jakarta opening and all fifteen route chapters with **37 checks, zero failures, 23.264 km, zero recoveries and zero blocking contacts** at a native 30 FPS cap. All fifteen reflections were saved.

This measured **36 minutes 3 seconds** of automated play, including authored cutscenes. Dialogue selections are automated about one second apart, so this is not a human reading-time estimate. It does not satisfy the GDD's 8–12 hour content target or establish human comfort. A later decorative roadside-art pass is covered separately by native captures and regressions, not by that full native run's frame report.

Run repeatable checks from the project directory:

```powershell
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite All -FixedFps 30
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite CampaignStaging -Visual -FixedFps 30
powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite NativeJourney -Visual -FixedFps 30
```

`NativeJourney` is deliberately separate from `All`; allow approximately 36 minutes for the rendered run. Helpers isolate saves in `.godot-test`. Do not run two helpers concurrently or launch the test scenes against a normal player profile. The full ride writes separate `native_journey_visual_report.json` / `native_journey_headless_report.json` files beneath `.godot-test/Godot/app_userdata/PULANG/` and a native ending capture under `tests/screenshots/`.

## Remaining M1–M10 acceptance

- M1: actual 5-minute onboarding and 15-minute human comfort/handling sessions. Automated lane tracking cannot evaluate nausea or enjoyment.
- Content: the campaign remains compact. Production pacing, final performances, recorded vehicle/regional sound and final art review are unfinished. The 30–60 minute slice and 8–12 hour campaign targets have not been waived.
- M10: actual narrative/art/audio and planned player-category feedback, issue resolution and content approval. No participant responses or sign-offs are inferred from automation.

See [validation evidence](test/VALIDATION.md), [M1 session guide](test/M1_PLAYTEST.md) and [beta report](test/BETA_PLAYTEST_REPORT.md). The README's roadmap checklist is current; older overview paragraphs were intentionally left untouched under the user's checklist-only editing instruction.
