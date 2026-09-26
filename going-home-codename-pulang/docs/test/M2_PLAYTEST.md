# M2 input and platform acceptance

Use both Practice ride and the Jakarta–Karawang slice. Local automation covers remapping and synthetic touch events; record actual platform results below before marking M2 accepted.

## Touch size preference

Settings & accessibility offers Standard (100%), Larger (125%) and Largest (150%), plus a scrollable live preview. The preview never sends riding input. `settings.cfg` stores `touch_scale` separately from journey saves; old settings default to 1.0. Finite values normalize to 1.0/1.25/1.5 before saving; invalid types and nonfinite values fall back to Standard. New Game preserves the choice.

`TouchControls` scales both the hit rectangles and their labels. In gameplay, effective scale is limited by safe-area width (four buttons, outside margins and gaps) and one quarter of safe-area height. A narrower logical area can reduce the effective scale without replacing the saved preference. The preview fits its own panel and has no HUD height reservation, so the final screen layout can differ on constrained devices. The interaction prompt stays 30 logical pixels above the buttons. Changing size or bounds clears finger ownership; unrelated settings changes leave input alone. Full menu/HUD scaling and movable controls are not implemented.

- [ ] In both story and practice Settings, choose each size using keyboard/mouse/touch. Scroll to inspect the complete preview and the remaining settings/Back button.
- [ ] Press or drag on the preview. The paused bike must remain stationary, with no stuck inputs when riding resumes.
- [ ] Resume with touch controls visible. Verify four readable buttons, thumb reach and a clear interaction button above them; compare how much scenery each size covers.
- [ ] Steer and accelerate together, lift one finger, drag out/back, and open pause at each size. Confirm the same underlying riding actions and ownership cleanup.
- [ ] Change size, resize the window, or rotate/background the device during input. Old touches must not keep the bike moving; retouching must work.
- [ ] Quit/relaunch and start a new journey. The size choice must remain; journey checkpoints must not change merely from editing size.
- [ ] Check all three sizes in browser iframe/fullscreen and on both Android classes with real safe-area cutouts. Record the preferred size, actual comfort and any occlusion.

Automated coverage is in `tools/test.ps1 -Suite Input` (add `-Visual -FixedFps 30` for native captures). It exercises all sizes at 1280×720, 1600×720 and 960×540 window sizes with simulated insets, plus an explicitly constrained 640×400 logical safe area. Godot's canvas stretching keeps a logical baseline when the physical window shrinks; window size alone does not test the logical fit limit. Native captures are stored in ignored `tests/screenshots/input_touch_size_settings.png` and `input_touch_largest_*.png`.

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
