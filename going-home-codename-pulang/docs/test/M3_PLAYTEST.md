# M3 narrative delivery and inspection

## Authoring contract

`data/phone/messages.json` owns message content. Each entry has a unique stable `id`, `from`, `type`, namespaced trigger `condition`, nonnegative numeric `delay_seconds`, `text`, and authored `reply`. A true condition schedules the message once. Repeated signals do not restart its delay. Changing public IDs requires a save migration.

Current delays: Dimas 2 s and recruiter 7 s after the layoff condition; Mom 5 s after departure; Dad 3 s after shelter. These are **unlocked gameplay seconds**, so messages triggered during the opening wait until play resumes. Riding, scenic stops, and the ending advance the clock; menus, dialogue, cinematic shots and fades do not. Messages can enter the inbox while a status toast occupies the banner slot. The oldest unread, unannounced delivered message takes the next free slot.

The UI reads message copies from `PhoneDataService`. Delivery order, read/reply state, displayed notice IDs and pending remaining times live in `GameState.phone`. Checkpoints and phone events save these values. No wall-clock or offline delivery is simulated. Reload restores remaining delay at the last save. Read/replied legacy messages migrate without repeated notifications. New Game resets all phone history.

A notice is marked shown when it takes the banner slot. Opening dialogue/pause hides it; it is not replayed afterward, and the message stays in the inbox. Phone home does not mark content read. Opening Messages or Email marks that section's delivered entries read, including entries below the scroll fold; other sections remain unread. Status toasts may replace a notice, but there is only one visible banner. Save failures remain visible and prevent a new notice from covering the error; the notice retries after the banner slot becomes free.

## Story inspection

Launch a debug/editor game with `-- --story-debug` after the usual engine arguments. Use **Story debug** from the story title/pause menu. The viewer pauses gameplay and lists session chapter/checkpoint, sorted searchable flags, dialogue states and phone data. Refresh rebuilds its snapshot. Back returns to title/pause; resume restores the interrupted story. The title viewer shows current memory, not an automatically loaded save.

There are no editing/reset/save commands in the viewer. Normal launches, practice mode, and release builds do not expose it. `tools/test.ps1 -Suite Narrative -StoryDebug -Visual` exercises it with isolated test saves and captures screenshots.

## Human and platform acceptance

- [ ] Play or skip the opening. No phone banner should obscure cinematics/dialogue; the same narrative conditions must schedule the messages.
- [ ] Ride after departure. Check Dimas, Mom, and recruiter arrive in order and each banner gets its own slot after existing status text.
- [ ] Open Phone before every banner has appeared. Read messages must stop notifying; replies must preserve the authored tone and career options.
- [ ] Pause/open settings mid-delay, wait, resume. The remaining gameplay delay must continue from where it stopped.
- [ ] Finish the warung encounter, receive/reply to Dad, rest, select a journal reflection, quit, and Continue. Phone history, journal and chapter checkpoint must agree.
- [ ] Save while notices are pending; quit and Continue. Already shown/read notices must not repeat; pending ones must remain deliverable.
- [ ] Inspect/filter/refresh flags while paused; Back/resume. Verify no story changes or extra save occurred.
- [ ] Load a pre-queue v1 save. Read/replied conversations remain available; other eligible messages can arrive with their configured delay.
- [ ] Repeat in Web iframe/fullscreen and physical Android, including suspend/resume, force-stop/relaunch and available storage. Record device/browser/version and results.

Browser/Android and human acceptance remain pending; native automated results do not close those gates. Completed-call history and the authored photo album are implemented; outgoing calls, voice playback, free-camera Photo Mode and a full localization key table remain open.

## Phone sections and call history

`PhoneDataService.received_messages(channel)`, `unread_count(channel)` and `mark_inbox_read(channel)` filter the existing authored `type` values Messages/Email. Omitting the channel retains the combined service view for legacy callers. Reading a section persists the existing read IDs; the save schema does not change. Unknown nonempty channels match no messages.

`data/phone/calls.json` defines stable call IDs, caller, authored story time, direction, source dialogue, recollection and a remembered dialogue-node reference. `call_history()` exposes a copy only when that source dialogue's saved state is complete. The remembered line comes from the dialogue data; the note is an authored summary shared by both mother-call branches. It is not a recording/transcript. Reading it does not call DialogueManager.start, set flags or write saves. There are no external phone/network integrations.

- [ ] Open Phone with both Messages and Email unread. Confirm home changes neither count; reading one section only clears that section. Return to riding and check unseen/unannounced content can still notify.
- [ ] Reply to the recruiter in Email; the reply stays in Email and persists after Continue. Check readability on small screens, including the scrollable Messages list.
- [ ] Open Calls before and after finishing Mom's conversation on both branches. Before completion it should be empty; afterward it should contain one recollection without replaying the conversation.
- [ ] Open Route/Journal through Phone, then use Back or Escape: return to phone home while paused. Escape at home closes the phone. Direct map/journal hotkeys still close back to gameplay.
- [ ] Start a new journey: no old call history, messages, replies or unread badges should remain.
- [ ] Repeat with touch and physical keyboard in browser/Android builds once platform prerequisites are available.

`powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite Phone -Visual -FixedFps 30`

This suite exercises real UI button callbacks, back-key navigation, separate read status, reply/save round trips, both call branches, partial-call gating, read-only history, movement locks and New Game. Native captures are stored under ignored `tests/screenshots/phone_*.png`. Automated checks do not replace touch ergonomics or human narrative review.

## Photo album

`data/phone/photos.json` contains ordered entries with unique `id`, `title`, authored `when`, `condition`, `image` resource path and first-person `caption`. An empty condition makes the family photo available from the start; trip photos use `story.prologue.departed` and `story.karawang.sheltered`. `PhoneDataService.available_photos()` returns independent copies in authored order; `photo_by_id()` exposes only currently available entries. There are no new save fields, timers, notifications or capture permissions. Continue derives the album from restored flags; New Game retains only the family photo. Do not rename condition flags without considering existing saves.

Three original 960×540 PNGs live in `assets/photos/`. `tools/render_phone_photos.gd` renders the cinematic memory/parking sets and roadside warung once, with a native Compatibility renderer. Gameplay loads the resulting textures and does not render extra 3D viewports. To regenerate from the project directory, use isolated storage and restore the previous environment afterward:

```powershell
$previousAppData = $env:APPDATA
try {
    $env:APPDATA = Join-Path (Get-Location) '.godot-test'
    New-Item -ItemType Directory -Force -Path $env:APPDATA | Out-Null
    & 'D:\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tools/render_phone_photos.gd
} finally {
    $env:APPDATA = $previousAppData
}
```

Run Godot's editor import after regeneration. The generator requires native rendering; `--headless` intentionally fails. PNGs and import metadata belong in source control; captures and logs remain ignored. These are prototype story illustrations, not final art or a player-operated camera.

- [ ] Open Photos before departure: only the family photo should appear. Return after departure and after shelter; check each new photo and caption agree with the story.
- [ ] Use thumbnail title buttons, Previous/Next, Back to album and Escape. Confirm navigation stops at available album edges and riding remains paused until the phone closes.
- [ ] Browse while messages are unread. Confirm counts remain unchanged and messages can still notify afterward.
- [ ] Quit at a saved checkpoint and Continue; check album visibility. Start a New Game and confirm only the family photo remains.
- [ ] Review all photos/captions on a small landscape viewport and physical touch device; verify scrolling and keyboard focus when height is constrained.

The Phone suite covers unlock order, imported textures, content copies, saved-flag round trips, single-photo bounds, stale/locked IDs, empty album, missing-image fallback and unchanged save/message state. It captures the album and all three details in native mode. Platform and human review remain separate acceptance gates.
