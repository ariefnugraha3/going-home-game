# M3 narrative delivery and inspection

## Authoring contract

`data/phone/messages.json` owns message content. Each entry has a unique stable `id`, `from`, `type`, namespaced trigger `condition`, nonnegative numeric `delay_seconds`, `text`, and authored `reply`. A true condition schedules the message once. Repeated signals do not restart its delay. Changing public IDs requires a save migration.

Current delays: Dimas 2 s and recruiter 7 s after the layoff condition; Mom 5 s after departure; Dad 3 s after shelter. These are **unlocked gameplay seconds**, so messages triggered during the opening wait until play resumes. Riding, scenic stops, and the ending advance the clock; menus, dialogue, cinematic shots and fades do not. Messages can enter the inbox while a status toast occupies the banner slot. The oldest unread, unannounced delivered message takes the next free slot.

The UI reads message copies from `PhoneDataService`. Delivery order, read/reply state, displayed notice IDs and pending remaining times live in `GameState.phone`. Checkpoints and phone events save these values. No wall-clock or offline delivery is simulated. Reload restores remaining delay at the last save. Read/replied legacy messages migrate without repeated notifications. New Game resets all phone history.

A notice is marked shown when it takes the banner slot. Opening dialogue/pause hides it; it is not replayed afterward, and the message stays in the inbox. Reading the inbox marks its delivered messages read, including entries below the scroll fold. Status toasts may replace a notice, but there is only one visible banner. Save failures remain visible and prevent a new notice from covering the error; the notice retries after the banner slot becomes free.

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

Browser/Android and human acceptance remain pending; native automated results do not close those gates. Calls, Photos, and a full localization key table are not implemented by this update.
