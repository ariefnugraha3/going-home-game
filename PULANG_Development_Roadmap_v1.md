# PULANG — DEVELOPMENT ROADMAP
## Version 1.0 — From Pre-Production to itch.io + Google Play Release

**Companion Documents:** PULANG GDD v2, PULANG TDD v1  
**Engine:** Godot 4.7.2 Stable  
**Language:** GDScript  
**Renderer:** Compatibility  
**Targets:** PC Web / itch.io, Android / Google Play  
**Project Style:** Milestone-based, vertical-slice-first, AI-assisted-friendly  

---

# 1. ROADMAP PURPOSE

This roadmap defines the recommended production order for PULANG.

It is deliberately designed around one principle:

> **Do not build fifteen chapters before proving that riding one road for fifteen minutes feels good.**

The production plan prioritizes technical risk in this order:

1. browser compatibility;
2. first-person motorcycle feel;
3. mobile controls;
4. visual performance;
5. narrative interaction;
6. production pipeline;
7. content scale.

---

# 2. PRODUCTION PHILOSOPHY

The game should be developed in increasingly complete slices.

Bad production pattern:

```text
Build all roads
→ build all NPCs
→ build all story
→ discover bike feels bad
→ rewrite everything
```

Preferred pattern:

```text
Technical prototype
→ emotional prototype
→ vertical slice
→ production pipeline
→ chapter production
→ alpha
→ beta
→ release
```

---

# 3. HIGH-LEVEL MILESTONES

1. **M0 — Project Foundation**
2. **M1 — Motorcycle Feel Prototype**
3. **M2 — Platform/Input Prototype**
4. **M3 — Narrative Systems Prototype**
5. **M4 — Visual/Audio Mood Prototype**
6. **M5 — Vertical Slice**
7. **M6 — Production Toolkit**
8. **M7 — Chapter Production Wave 1**
9. **M8 — Chapter Production Wave 2**
10. **M9 — Full Game Alpha**
11. **M10 — Content Complete / Beta**
12. **M11 — Optimization & Release Candidate**
13. **M12 — itch.io Launch**
14. **M13 — Google Play Launch**
15. **M14 — Post-Launch Support**

---

# 4. ESTIMATED DEVELOPMENT SCALE

Exact time depends heavily on team size and asset quality.

A realistic independent-production framing:

## Solo developer + AI assistance
Approximately:
**12–24+ months**

## Small focused team
Approximately:
**8–16 months**

Team example:
- 1 programmer/technical designer
- 1 3D environment artist
- 1 character/animation generalist
- 1 narrative/audio contributor part-time

The roadmap should be managed by milestones, not calendar promises.

---

# 5. M0 — PROJECT FOUNDATION

## Objective

Create a clean, reproducible Godot project that can be exported immediately to both target platforms.

## Tasks

### Repository
- create Git repository;
- create `.gitignore`;
- define branch policy;
- create README;
- document required Godot version;
- configure Git LFS if needed.

### Godot
- initialize project;
- select Compatibility renderer;
- set landscape baseline;
- create folder structure;
- create boot scene;
- create main menu stub.

### Autoloads
Create empty/basic:
- GameState
- SaveManager
- SceneFlowManager
- AudioManager
- InputModeManager
- ChapterManager

### Export
- install matching export templates;
- create Web preset;
- create Android debug preset;
- confirm empty project runs in browser;
- confirm empty project runs on a physical Android device.

### Quality
- set coding conventions;
- create issue/task template;
- create AI implementation prompt template.

## Exit Criteria

M0 is complete only when:
- repository can be cloned on a clean machine;
- project opens without missing dependencies;
- Web build launches;
- Android debug build launches;
- main menu appears;
- basic settings file can be written/read.

---

# 6. M1 — MOTORCYCLE FEEL PROTOTYPE

## Objective

Prove that first-person riding is comfortable and enjoyable.

This milestone is more important than story content.

## Tasks

### Greybox Bike
- CharacterBody3D controller;
- accelerate;
- brake;
- steer;
- surface alignment;
- collision response;
- low-speed behavior;
- reset/recovery.

### Camera
- rider camera rig;
- camera damping;
- lean visualization;
- reduced-motion toggle;
- FOV setting;
- look/glance behavior.

### Test Track
Build simple:
- straight road;
- gentle curves;
- tighter curve;
- slope;
- small bumps;
- intersection;
- stop area.

### Audio Placeholder
- idle loop;
- acceleration loop;
- road noise;
- engine off.

### Instrument Placeholder
- speedometer needle;
- fuel display placeholder.

## Testing

Run:
- 5-minute test;
- 15-minute uninterrupted test;
- keyboard test;
- 30 FPS forced test.

Record:
- turning comfort;
- nausea;
- camera stability;
- collision frustration.

## Exit Criteria

Do not continue until:
- riding is understandable within 30 seconds;
- player can cruise without fighting controls;
- camera is comfortable;
- stopping feels predictable;
- no physics explosion occurs during normal riding.

---

# 7. M2 — PLATFORM & INPUT PROTOTYPE

## Objective

Prove that one gameplay system works across keyboard and mobile touch.

## Tasks

### Input Map
Implement all core actions.

### Keyboard
- WASD;
- arrows;
- mouse/menu;
- rebinding architecture.

### Mobile
- steering zone/stick;
- accelerate;
- brake;
- interact;
- pause;
- responsive layout.

### InputModeManager
- platform detection;
- prompt switching;
- touch overlay.

### Browser Validation
- itch.io-style iframe test;
- fullscreen;
- keyboard focus;
- audio start behavior;
- save storage.

### Android Validation
Test multiple aspect ratios if possible.

## Exit Criteria
- same riding scene playable in Web and Android;
- no gameplay code contains hard-coded keyboard requirements;
- UI does not cover critical first-person view;
- touch controls feel acceptable.

---

# 8. M3 — NARRATIVE SYSTEMS PROTOTYPE

## Objective

Build the reusable systems required for the story before writing all content.

## Tasks

### Dialogue
- dialogue data;
- branching;
- conditions;
- flags;
- choice UI;
- fast-forward rules.

### Interaction
- interactables;
- prompts;
- stop zones.

### Phone
- basic phone shell;
- messages;
- notification queue.

### Journal
- prompt;
- choices;
- saved response.

### Story Flags
- namespaced flags;
- debug viewer.

### Save
- checkpoint state;
- story state;
- settings separated.

### Cutscene
- control lock;
- camera switching;
- shot sequencing;
- skip-safe state.

## Prototype Scene

Create one fictional test encounter:
- arrive at roadside stop;
- engine off;
- interact;
- NPC dialogue;
- choose response;
- receive phone message;
- write journal;
- autosave;
- reload.

## Exit Criteria
- entire sequence survives save/reload;
- cutscene skip produces correct state;
- data can be edited without touching system code.

---

# 9. M4 — VISUAL & AUDIO MOOD PROTOTYPE

## Objective

Find the final emotional look and sound before mass asset production.

## Environment Prototype

Build one 300–800 meter Indonesian roadside segment containing:
- asphalt;
- trees;
- electrical poles;
- warung;
- small house;
- road signs;
- parked scooters;
- distant fields.

## Lighting Variants
Create:
- morning;
- overcast;
- golden hour;
- night.

## Weather
Prototype:
- drizzle;
- full rain;
- wet ambience.

## Audio
Prototype:
- road noise;
- distant traffic;
- birds/insects;
- warung ambience;
- rain;
- first music cue.

## Bike Art
Create initial hero motorcycle:
- Thunder 250 silhouette;
- cockpit;
- round headlamp;
- analog cluster;
- maintained condition.

## Exit Criteria
A screenshot/video should communicate:
- Indonesia;
- warmth;
- low-poly identity;
- first-person road-trip mood.

---

# 10. M5 — VERTICAL SLICE

## Objective

Build a 30–60 minute polished section that proves the complete game.

Recommended slice:

**Jakarta opening → layoff → apartment → departure → first road segment → roadside/rain encounter → rest/journal**

---

# 11. VERTICAL SLICE CONTENT

## Scenes

1. Apartment morning
2. Parking area
3. Commute route
4. Office
5. Layoff meeting
6. Apartment night
7. Packing/departure
8. Road segment
9. Warung / rain stop
10. Guesthouse/rest

---

# 12. VERTICAL SLICE CUTSCENES

Implement production-quality versions of:
- morning routine;
- HR message;
- layoff meeting;
- mother phone call;
- packing;
- departure/title reveal.

They establish the cinematic pipeline for the rest of production.

---

# 13. VERTICAL SLICE ART

Required:
- hero bike;
- Raka base model;
- office NPC variants;
- mother only via phone at this point;
- Jakarta environment kit;
- roadside environment kit;
- warung kit;
- guesthouse room;
- basic traffic kit.

---

# 14. VERTICAL SLICE AUDIO

Required:
- complete bike sound set;
- Jakarta ambience;
- office ambience;
- apartment rain;
- roadside ambience;
- warung ambience;
- one music motif;
- UI sound set.

---

# 15. VERTICAL SLICE QA

Test:
- Chrome;
- Firefox;
- Edge;
- itch.io upload;
- at least 2 Android performance classes if available;
- clean save;
- resume save;
- cutscene skip;
- touch UI;
- low graphics preset.

---

# 16. VERTICAL SLICE GATE

Do not begin full content production if any of these remain unresolved:
- bike is not fun;
- first-person camera causes discomfort;
- Web FPS is unacceptable;
- Android controls are weak;
- dialogue pipeline is fragile;
- cutscenes break state;
- chapter loading leaks memory;
- art style is not final.

---

# 17. M6 — PRODUCTION TOOLKIT

## Objective

Turn prototype systems into repeatable content workflows.

## Required Tools

### Chapter Template
Reusable scene with:
- road;
- triggers;
- audio zones;
- weather;
- checkpoint;
- debug markers.

### NPC Template
- visual;
- animation controller;
- dialogue anchor;
- interaction component.

### Cutscene Template
- camera marker system;
- shot track;
- dialogue events;
- skip behavior.

### Validation
- dialogue ID checker;
- missing localization checker;
- broken reference checker.

### Debug Menu
- chapter select;
- weather;
- time;
- story flags;
- teleport;
- performance overlay.

## Exit Criteria
A new simple encounter can be created without modifying global core code.

---

# 18. M7 — CHAPTER PRODUCTION WAVE 1

Recommended chapters:
- Karawang
- Cirebon
- Tegal
- Pekalongan
- Semarang

## Production Pattern per Chapter

### Step A — Narrative Lock
- theme;
- primary NPC;
- emotional beat;
- journal question.

### Step B — Greybox
- road;
- stops;
- chapter length;
- event placement.

### Step C — Gameplay
- triggers;
- dialogue;
- stop events;
- checkpoint.

### Step D — Environment Art
- road kit variation;
- signature props;
- skyline/terrain;
- lighting.

### Step E — Audio
- ambience;
- chapter-specific detail;
- music cue if needed.

### Step F — Cutscenes
- block;
- animate;
- polish.

### Step G — Performance
- Web;
- Android.

### Step H — Narrative Playtest
- pacing;
- dialogue;
- emotional clarity.

---

# 19. CHAPTER BUDGET TEMPLATE

Each major chapter should target approximately:
- 25–45 minutes main path;
- 1 primary narrative encounter;
- 0–2 optional minor encounters;
- 1 key environmental identity;
- 1 reflection/rest sequence;
- limited unique hero props.

Avoid each chapter becoming a separate game.

---

# 20. M8 — CHAPTER PRODUCTION WAVE 2

Recommended chapters:
- Salatiga
- Solo
- Ngawi
- Madiun
- Kediri
- Malang
- Lumajang
- Jember
- Banyuwangi
- Epilogue

Use the same pipeline as Wave 1.

---

# 21. SPECIAL CHAPTER RISKS

## Salatiga
Needs strong scenic silence.  
Risk: nothing happens → boredom.

Solution:
- audio richness;
- beautiful route composition;
- scenic stop timing.

## Ngawi
Dialogue-heavy emotional chapter.  
Risk: NPC becomes preachy.

Solution:
- restrained writing;
- long pauses;
- practical language.

## Kediri
Interactive interview.  
Risk: too much UI/dialogue.

Solution:
- keep concise;
- focus emotional aftermath.

## Banyuwangi
Final payoff.  
Risk: over-dramatization.

Solution:
- preserve simple family arrival.

---

# 22. M9 — FULL GAME ALPHA

## Definition

All main chapters are playable from beginning to end.

Not all assets need final polish.

Must include:
- complete story;
- all required choices;
- all chapter transitions;
- ending;
- save/load;
- basic sound.

---

# 23. ALPHA TASKS

### Integration
- play full game;
- identify broken flags;
- find pacing issues;
- remove repeated systems;
- identify memory leaks.

### Story
- full dialogue continuity pass;
- verify character names;
- verify job timeline;
- verify travel progression;
- verify English-only UI.

### Technical
- ensure all chapters export;
- test save from old chapters to new;
- validate chapter transitions.

---

# 24. ALPHA EXIT CRITERIA

- game can be completed without developer console;
- no blocker bug;
- all mandatory cutscenes work;
- all story flags resolve;
- ending reachable;
- browser build can complete campaign;
- Android build can complete campaign.

---

# 25. M10 — CONTENT COMPLETE / BETA

## Definition

No new major content is planned.

Focus shifts to:
- quality;
- bugs;
- tuning;
- performance;
- accessibility.

---

# 26. BETA POLISH TRACKS

## Riding
- final handling;
- speed perception;
- collision forgiveness;
- reduced-motion tuning.

## Narrative
- text proofread;
- pause timing;
- choice wording;
- phone message sequencing.

## Visual
- lighting;
- LOD;
- pop-in;
- draw-call reduction;
- material consistency.

## Audio
- loudness consistency;
- loop seams;
- music transitions;
- engine mix.

## UI
- touch scaling;
- text readability;
- focus navigation;
- safe areas.

---

# 27. BETA PLAYTEST PLAN

Recruit testers in categories:
- cozy-game players;
- driving-game players;
- people unfamiliar with Indonesia;
- Indonesian players;
- mobile players;
- motion-sensitive players.

Questions:
- When did riding become boring?
- Was any dialogue too preachy?
- Did the layoff feel believable?
- Did the bike feel old but cared for?
- Did the game feel Indonesian?
- Was Banyuwangi arrival emotionally satisfying?
- Did first-person movement feel comfortable?
- Was mobile control tiring?

---

# 28. TELEMETRY WITHOUT ANALYTICS

For early tests, optionally collect manual playtest logs:
- chapter completion time;
- number of stops;
- crashes;
- FPS ranges;
- device;
- tester notes.

No mandatory production analytics system needed.

---

# 29. M11 — OPTIMIZATION & RELEASE CANDIDATE

## Web Optimization

Audit:
- initial download;
- texture sizes;
- audio;
- draw calls;
- transparent materials;
- mirrors;
- traffic;
- vegetation;
- scene unload.

## Android Optimization

Audit:
- thermals;
- battery;
- frame pacing;
- touch latency;
- memory;
- startup;
- app resume.

---

# 30. QUALITY PRESET VALIDATION

Test complete game on:
- Low;
- Medium;
- High.

No chapter should rely on High-only effects to communicate critical gameplay.

---

# 31. RELEASE CANDIDATE BUG POLICY

Blocker:
- cannot progress;
- save destroyed;
- frequent crash;
- broken touch control;
- Web fails to launch.

Critical:
- major cutscene broken;
- narrative state wrong;
- severe performance collapse.

Major:
- visible but recoverable system issue.

Minor:
- visual polish;
- typo;
- small animation defect.

Release requires:
- zero known blocker;
- zero known critical;
- major bugs reviewed explicitly.

---

# 32. M12 — ITCH.IO RELEASE PREPARATION

## Store Assets
Prepare:
- cover;
- screenshots;
- GIF/video trailer;
- short description;
- long description;
- control instructions;
- content notes;
- browser requirements.

## Web Upload
- export release build;
- ensure `index.html` at archive root;
- upload ZIP;
- configure viewport;
- test fullscreen;
- test fresh browser profile.

## Compatibility Page
State recommended browsers:
- Chrome/Chromium;
- Edge;
- Firefox.

---

# 33. ITCH.IO RELEASE TEST

Fresh user flow:
1. open page;
2. launch;
3. sound starts after interaction;
4. main menu;
5. new game;
6. save;
7. close tab;
8. reopen;
9. continue.

All must work.

---

# 34. M13 — GOOGLE PLAY RELEASE PREPARATION

## Android Production Requirements
- unique package ID;
- version code;
- version name;
- app icons;
- adaptive icon;
- landscape settings;
- release keystore;
- Gradle/AAB export;
- privacy declarations;
- store screenshots;
- feature graphic;
- content rating;
- target SDK compliance.

Because Play requirements can change, verify current Google Play rules immediately before submission.

---

# 35. RELEASE KEY MANAGEMENT

Create release keystore.

Rules:
- back it up securely;
- never commit it;
- document recovery ownership;
- protect password.

Losing signing credentials can create serious release-management problems.

---

# 36. ANDROID DEVICE TEST MATRIX

Suggested classes:

## Low-ish Supported Target
- older mid-range device;
- 4–6 GB RAM;
- moderate GPU.

## Typical Mid-Range
- recent Snapdragon/Dimensity mid-tier.

## High-End
- recent flagship.

Test:
- install;
- cold boot;
- 30-minute ride;
- rain;
- crowded route;
- cutscene;
- app background/resume;
- low battery mode if relevant.

---

# 37. M14 — POST-LAUNCH

First priorities:
- crash/blocker fixes;
- save issues;
- device-specific rendering;
- severe control issues.

Only after stability:
- optional features;
- additional graphics settings;
- quality-of-life updates.

---

# 38. FEATURE PRIORITY FRAMEWORK

Use four levels.

## P0 — Must Ship
- bike riding;
- story;
- save;
- first-person camera;
- keyboard;
- touch;
- all chapters;
- English UI;
- Web;
- Android.

## P1 — Strongly Desired
- phone;
- journal;
- weather;
- scenic stops;
- settings;
- reduced motion.

## P2 — Nice to Have
- photo mode;
- extensive key rebinding;
- additional optional encounters.

## P3 — Post-Launch Candidate
- platform achievements;
- advanced photo sharing;
- extra cosmetic bike states.

---

# 39. DO-NOT-BUILD LIST

To protect scope:
- no multiplayer;
- no combat;
- no skill trees;
- no crafting;
- no loot;
- no character stats;
- no open-world Java map;
- no procedural city generation;
- no realistic manual clutch simulation;
- no large inventory;
- no live service backend.

---

# 40. ASSET PRODUCTION ROADMAP

## Hero Priority
1. Suzuki Thunder 250
2. Raka
3. family house
4. office/apartment
5. recurring road kit

## Environment Kits
Create reusable modular kits:
- urban Jakarta;
- industrial outskirts;
- Pantura roadside;
- Central Java town;
- highland;
- East Java rural;
- Banyuwangi neighborhood.

---

# 41. PROP LIBRARY PLAN

Reusable props:
- plastic chair;
- table;
- warung shelf;
- snack jars;
- cup/glass;
- kettle;
- gas station objects;
- tire stack;
- repair tools;
- roadside signs;
- utility poles;
- scooters;
- helmets;
- bags;
- umbrellas;
- rain tarp.

One strong prop library greatly lowers chapter cost.

---

# 42. CHARACTER PRODUCTION PLAN

## Raka
Highest priority.

Needs:
- riding;
- standing;
- sitting;
- phone;
- walking;
- cutscene gestures.

## Parents
Appear mainly in final chapter.

Need:
- simple but emotionally credible facial/body performance.

## Story NPCs
Moderate variation.

## Ambient NPCs
Reuse body/animation base with costume variation.

---

# 43. ANIMATION PRIORITIES

1. bike/rider pose;
2. hands/handlebar alignment;
3. head/upper body;
4. dialogue idle;
5. simple walking;
6. seated gestures;
7. cinematic prop interactions.

Do not overinvest in complex locomotion if most gameplay is riding.

---

# 44. AUDIO PRODUCTION ROADMAP

## Phase A
Placeholder engine/ambience.

## Phase B
Final motorcycle layers.

## Phase C
Regional ambience library.

## Phase D
Music themes.

## Phase E
Full mix/master.

---

# 45. NARRATIVE PRODUCTION ROADMAP

For each chapter:

1. one-sentence theme;
2. encounter purpose;
3. dialogue outline;
4. first draft;
5. naturalism edit;
6. “remove philosophy” pass;
7. English proofreading;
8. implementation;
9. playtest;
10. trim.

---

# 46. DIALOGUE QUALITY RULE

Any line that sounds like it could be printed on an inspirational poster should be challenged.

Prefer:
- incomplete sentences;
- ordinary jokes;
- practical questions;
- pauses;
- changes of subject.

---

# 47. CUTSCENE PRODUCTION PIPELINE

Per cutscene:

1. narrative purpose approved;
2. technical shot list;
3. greybox blocking;
4. camera test;
5. character animation;
6. dialogue timing;
7. sound;
8. lighting;
9. skip test;
10. Web/Android performance test.

---

# 48. CUTSCENE REVIEW CHECKLIST

Check:
- Does the shot add information?
- Is it too dramatic?
- Can one shot be removed?
- Does the camera respect cozy tone?
- Does skip restore correct state?
- Is subtitle/dialogue readable on mobile?
- Does it perform in Compatibility renderer?

---

# 49. WEB PERFORMANCE ROADMAP

Performance checkpoints:
- M1 prototype;
- M5 vertical slice;
- every 2–3 chapters;
- Alpha;
- Beta;
- RC.

Never postpone browser optimization until the end.

---

# 50. ANDROID PERFORMANCE ROADMAP

Physical-device testing begins in M2.

Repeat:
- each major system;
- each chapter wave;
- Alpha;
- Beta;
- RC.

---

# 51. WEB-SPECIFIC RISKS

- shader incompatibility;
- browser memory;
- slow first load;
- audio autoplay restrictions;
- keyboard focus in embed;
- persistent storage expectations.

Each must have a test case.

---

# 52. ANDROID-SPECIFIC RISKS

- thermal throttling;
- many resolutions;
- touch fatigue;
- lifecycle pause/resume;
- vendor GPU quirks;
- store target SDK changes.

---

# 53. SAVE COMPATIBILITY ROADMAP

Never casually break saves after public demo.

Before first public demo:
- freeze initial schema.

After:
- add migrations;
- preserve IDs;
- test old save fixtures.

---

# 54. PUBLIC DEMO STRATEGY

Recommended:
Release a polished vertical slice/demo on itch.io before full launch.

Benefits:
- browser hardware feedback;
- motorcycle comfort feedback;
- narrative tone validation;
- device coverage.

Demo should end at a natural rest beat.

---

# 55. DEMO SUCCESS METRICS

Qualitative:
- players understand premise;
- bike feels pleasant;
- players stop voluntarily;
- dialogue feels natural;
- players want to continue east.

Technical:
- acceptable crash rate;
- browser launch reliability;
- stable save;
- Android performance.

---

# 56. AI-ASSISTED DEVELOPMENT WORKFLOW

Use AI for:
- scaffolding;
- repetitive GDScript;
- editor tools;
- content validation;
- dialogue data transformation;
- test generation;
- documentation;
- boilerplate scene setup.

Human review is mandatory for:
- core bike feel;
- narrative voice;
- camera comfort;
- final visual taste;
- store release configuration.

---

# 57. AI TASK SIZE

Prefer tasks that can be verified independently.

Good:
> Implement InputModeManager and touch/keyboard mode switching.

Bad:
> Build the whole game.

Good:
> Implement dialogue condition evaluation with tests.

Bad:
> Make narrative system.

---

# 58. AI PULL-REQUEST RULE

Every AI-generated change should describe:
- what changed;
- why;
- files touched;
- how tested;
- known limitations;
- platform impact.

---

# 59. AI REGRESSION PREVENTION

Before accepting AI code:
- search for hard-coded keys;
- check absolute paths;
- check accidental Forward+ features;
- check desktop-only APIs;
- check save schema changes;
- check unbounded process loops;
- check new global singletons;
- test in Web export.

---

# 60. WEEKLY DEVELOPMENT RHYTHM EXAMPLE

For a solo/small team:

### Day 1
Plan milestone tasks.

### Day 2–3
Implement primary feature/content.

### Day 4
Integrate art/audio.

### Day 5
Web + Android build.

### Day 6
Playtest/fix.

### Day 7
Documentation/backlog cleanup or rest.

Adjust to actual team cadence.

---

# 61. ISSUE TRACKER LABELS

Recommended:
- `system-bike`
- `system-camera`
- `system-dialogue`
- `system-save`
- `platform-web`
- `platform-android`
- `chapter-XX`
- `art`
- `audio`
- `narrative`
- `performance`
- `bug-blocker`
- `bug-critical`
- `accessibility`
- `tech-debt`

---

# 62. DEFINITION OF READY FOR A TASK

A task is ready when:
- goal is clear;
- relevant GDD/TDD section linked;
- acceptance criteria written;
- dependencies identified;
- assets available or placeholder allowed;
- target platform impact known.

---

# 63. DEFINITION OF DONE FOR A FEATURE

Feature is done when:
- implemented;
- reviewed;
- tested in editor;
- tested in Web if relevant;
- tested on Android if relevant;
- no blocker bug;
- documentation updated;
- save implications checked;
- accessibility implications checked.

---

# 64. TECHNICAL DEBT POLICY

Technical debt may be accepted temporarily only if:
- documented;
- ticket created;
- does not threaten save compatibility;
- does not block target platforms.

Do not hide “temporary” hacks inside chapter scripts.

---

# 65. CONTENT LOCK POLICY

At Beta:
- no new major NPCs;
- no new chapters;
- no new global systems;
- no redesign of bike controller unless required by critical issue.

---

# 66. CODE FREEZE POLICY

At Release Candidate:
Only:
- blocker fixes;
- critical fixes;
- carefully reviewed high-value fixes.

Every late code change has regression cost.

---

# 67. RELEASE CHECKLIST — WEB

- release export;
- no debug;
- correct renderer;
- index.html;
- itch.io zip structure;
- fresh browser test;
- fullscreen test;
- audio test;
- keyboard focus;
- save/reload;
- low quality mode;
- credits/licenses.

---

# 68. RELEASE CHECKLIST — ANDROID

- release AAB;
- signed;
- version code;
- package name;
- landscape;
- icons;
- store metadata;
- fresh install;
- upgrade install;
- save migration;
- lifecycle resume;
- low/mid/high device;
- permission review;
- privacy form.

---

# 69. RELEASE CHECKLIST — NARRATIVE

- all UI English;
- all dialogue English;
- all journal English;
- phone messages English;
- no accidental placeholder text;
- all names consistent;
- Banyuwangi finale intact;
- no Bali continuation;
- no contradictory job state.

---

# 70. RELEASE CHECKLIST — MOTORCYCLE

- visually old but maintained;
- no unintended torn/rusty look;
- round headlamp and classic naked-bike silhouette readable;
- first-person cockpit polished;
- analog cluster works;
- engine sounds balanced;
- controls comfortable.

---

# 71. RELEASE CHECKLIST — ACCESSIBILITY

- subtitle readability;
- UI scale;
- reduced motion;
- volume controls;
- touch target sizes;
- low graphics setting;
- key bindings/help page.

---

# 72. POST-LAUNCH PATCH POLICY

Versioning example:
- 1.0.0 launch;
- 1.0.1 hotfix;
- 1.1.0 feature/QoL update.

Never ship a patch that invalidates old saves without migration.

---

# 73. FUTURE FEATURES ONLY AFTER 1.0

Potential:
- expanded photo mode;
- extra roadside encounters;
- additional accessibility;
- controller polish;
- more graphical presets.

Not planned:
- combat;
- multiplayer;
- Bali continuation in base game's ending.

---

# 74. PROJECT SUCCESS DEFINITION

PULANG succeeds if the player remembers:
- the feeling of the road;
- the sound of the bike;
- the quiet after switching the engine off;
- small conversations;
- the changing landscape;
- and the moment Raka finally reaches home.

Technical success means:
- the same emotional experience survives Web constraints;
- the same core experience remains comfortable on Android;
- content can be produced without rewriting architecture.

---

# 75. MASTER PRIORITY RULE

When schedule pressure forces a choice, prioritize in this order:

1. **Riding feel**
2. **Narrative clarity**
3. **Performance**
4. **Audio atmosphere**
5. **Environment identity**
6. **Optional content**
7. **Extra features**

Do not sacrifice the first five to preserve the last two.

---

# 76. FINAL ROADMAP RULE

> **Ship the smallest version of PULANG that fully delivers the journey, rather than the largest version that only partially delivers the feeling.**
