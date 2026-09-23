# M2 input and platform acceptance

Use both Practice ride and the Jakarta–Karawang slice. Local automation covers remapping and synthetic touch events; record actual platform results below before marking M2 accepted.

## Keyboard and menus

- [ ] In title → Controls, change Accelerate to I. W and Up must stop accelerating; I must work in story and practice.
- [ ] Try an occupied key and Ctrl+I; read the explanation, then Escape to cancel without leaving Controls or resuming a paused ride.
- [ ] Change Interact to F and Phone to O. Roadside and message hints must follow the settings.
- [ ] Quit/relaunch, then begin a new journey. Preferences must persist; the existing journey is only replaced after its usual New Game confirmation.
- [ ] Restore defaults. W/Up, S/Down/Space and all other defaults must return.
- [ ] Navigate controls using keyboard, mouse, and touch. Scroll to the reset/back buttons; Escape and Enter must remain usable.

## Browser (Chrome, Firefox, Edge)

Requires matching Web export templates and a served export. Test both an itch.io-style iframe and fullscreen, with browser name/version and OS recorded.

- [ ] Click into the game, ride, open menus, capture a key, then return to riding without losing focus.
- [ ] Switch tabs while holding throttle, then return. Gameplay must pause and held actions must clear.
- [ ] Verify audio begins after a user gesture and resumes correctly after focus changes.
- [ ] Reload and restart the browser. Journey checkpoints and remapped controls must survive where storage is available.
- [ ] Check browser-reserved/default shortcuts, including Tab for Phone and Escape in fullscreen; record any browser interception and required fallback button.
- [ ] Resize the iframe and switch fullscreen during riding and menus. No stuck input, inaccessible buttons, or critical cockpit obstruction.

## Physical Android

Requires matching Android templates, configured SDK/JDK, and a debug APK. Test at least two performance classes, including a cutout/notch device; record model, OS, resolution, render settings and navigation mode.

- [ ] Ride and steer simultaneously with two fingers; lift only one and confirm the other still works.
- [ ] Drag off a riding button and back into it; throttle/steering must release and return predictably.
- [ ] Open Pause, Phone, Settings, and Controls while touching a riding zone. Menus must not leave the bike accelerating.
- [ ] Background, lock/unlock, and resume during touch riding. No stuck throttle, steer, or glance; resume is intentional.
- [ ] Check safe-area insets in 16:9, 20:9 and 4:3 where available, both landscape orientations if supported, and gesture/three-button navigation. All menu, pause, interaction, and ride buttons must remain reachable.
- [ ] Check minimum readable text/touch size and reachability in hand. Synthetic pixel bounds do not establish physical comfort.
- [ ] Force-stop/relaunch; verify journey and input preferences. A new journey must retain settings.
- [ ] Ride the same scene at Low / 30 FPS and record comfort and responsiveness alongside the M1 guide.

## Result record

| Build / date | Platform / device / browser | Aspect / safe area | Scenario | Result / evidence |
| --- | --- | --- | --- | --- |
| Pending | Pending | Pending | Real Web and Android acceptance | Not tested |

Keep failures and limitations explicit. Native desktop rendering and injected touch events do not satisfy browser or physical-device acceptance.
