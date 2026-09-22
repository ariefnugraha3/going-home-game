# PULANG — GAME DESIGN DOCUMENT
## Revised Technical & Narrative Production GDD
### Version 2.0

**Project Title:** PULANG  
**Genre:** Cozy Narrative Road Trip / First-Person Motorcycle Adventure  
**Target Engine:** Godot Engine (Godot 4.x recommended)  
**Target Platforms:**  
- PC Web Browser (HTML5 export for itch.io)  
- Android Mobile (Google Play Store)  

**Primary Language:** English  
**Game Perspective During Riding:** First-Person View  
**Visual Style:** Stylized 3D Low Poly  
**Game Setting:** Indonesia (Jakarta to Banyuwangi, East Java)  
**Target Session Length:** 20–45 minutes per play session  
**Estimated Total Playtime:** 8–12 hours main story / 12–18 hours with optional interactions  

---

# 1. DOCUMENT PURPOSE

This document is intended to serve as the **master design reference** for the development of **PULANG**.

It has two simultaneous goals:

1. **Creative Goal**  
   To define the emotional, narrative, aesthetic, and experiential identity of the game.

2. **Production Goal**  
   To provide enough technical and structural detail so that a human developer, technical designer, or AI-assisted development workflow can build the game while staying aligned with the intended design.

This document should be treated as the **source of truth** for the following:

- tone;
- gameplay direction;
- narrative structure;
- target platforms;
- control scheme philosophy;
- technical implementation expectations;
- cutscene language;
- content boundaries;
- asset requirements;
- UI language rules;
- core interaction model.

---

# 2. HIGH CONCEPT

**PULANG** is a cozy, story-driven road trip game in which the player rides a motorcycle from **Jakarta to Banyuwangi** after being laid off from work.

The player controls **Raka**, a capable professional in his early 30s who has spent nearly a decade building a career in Jakarta. After losing his job due to company restructuring, Raka could immediately pursue another opportunity.

Instead, he chooses to go home.

He takes a long ride across Java on his old but well-maintained **Suzuki Thunder 250 (2000)** — a motorcycle connected to his family history — and travels back to his hometown in **Banyuwangi**, not to solve his life instantly, but to breathe, think, and be still for a while.

The game is not about racing, winning, or maximizing efficiency.

It is about:

- slowing down;
- paying attention;
- meeting ordinary people;
- noticing small things;
- moving through space and memory;
- and rediscovering what “home” means.

---

# 3. CORE EXPERIENCE STATEMENT

> **PULANG should make the player feel like they are physically traveling across Java, emotionally decompressing from city life, and gradually reconnecting with themselves through a motorcycle journey home.**

---

# 4. DESIGN PILLARS

## 4.1 The Road Is the Story

The road is not a corridor between cutscenes.  
The road is a core narrative space.

Riding, stopping, waiting, listening, and observing are all meaningful parts of the story.

---

## 4.2 Slow Is Valid

The player is never rewarded for rushing through the game.  
Stopping is valuable.  
Resting is valuable.  
Doing nothing for a moment is valuable.

---

## 4.3 Grounded Human Encounters

NPCs are not life coaches.  
They are ordinary people living ordinary lives.

The game should never sound preachy or philosophical in an artificial way.  
Its wisdom must come from context, not speeches.

---

## 4.4 Strong Indonesian Identity

The game must feel distinctly Indonesian.

Not generic Southeast Asia.  
Not anonymous tropical scenery.  
Not abstract “road trip vibes.”

The world must contain recognizable Indonesian textures, rhythms, and social details.

---

## 4.5 Career Is Not the Villain

The game must not imply that:

- work is bad;
- ambition is fake;
- urban life is empty by default;
- rural life is automatically better;
- quitting is inherently noble.

The emotional question is not “Which lifestyle is best?”

The emotional question is:

> **What happens when someone finally has enough silence to ask whether they are still living on purpose?**

---

# 5. PRODUCT GOALS

## 5.1 Creative Product Goal

Deliver an emotionally resonant interactive road trip that feels warm, quiet, reflective, and personal.

## 5.2 Market/Product Goal

Create a game that is small-to-mid scope, platform-accessible, browser-playable for itch.io, and mobile-adaptable for Android.

## 5.3 Development Goal

Design the game so it can be built in a modular, scene-based way inside **Godot**, allowing staged production, vertical slicing, and AI-assisted implementation.

---

# 6. PLATFORM & ENGINE REQUIREMENTS

## 6.1 Engine

**Godot Engine** is mandatory.

Recommended baseline:
- **Godot 4.x** for the main production line.

If severe HTML5 performance or compatibility issues arise during implementation, optimization decisions may be required, but the design should initially assume **Godot 4.x**.

---

## 6.2 Target Platforms

### A. PC Web Browser
Target usage:
- playable on itch.io via browser;
- keyboard input;
- mouse for menu navigation;
- optional gamepad support if feasible.

### B. Android
Target usage:
- touch controls;
- adaptive UI scaling;
- simplified HUD;
- performance-conscious rendering.

---

## 6.3 Performance Goals

### Browser Target
- Preferred: **60 FPS**
- Minimum acceptable: **30 FPS**
- Quick initial load time
- Controlled memory footprint
- Avoid excessive draw calls and overcomplicated shaders

### Android Target
- Preferred: **30–60 FPS depending on device class**
- Must remain playable on mid-range devices
- Avoid heavy post-processing
- Use simplified material setups
- Reduce physics complexity where possible

---

# 7. LANGUAGE RULES

## 7.1 Full Language Policy

The game must be **full English**.

This includes:
- Main menu
- Settings menu
- Tutorial text
- Dialogue text
- Journal text
- Smartphone UI
- Objective text
- Interaction prompts
- Save/load UI
- Credits
- Achievement names and descriptions
- Any gameplay-relevant text

---

## 7.2 Indonesian Setting, English Delivery

Although the game is set in Indonesia and strongly grounded in Indonesian culture, the player-facing language remains English.

Allowed:
- Indonesian location names (Jakarta, Banyuwangi, Jember, etc.)
- Proper nouns
- Cultural objects or place names where appropriate
- Selected environmental signs for authenticity, as long as they are not required for gameplay comprehension

Recommended approach:
- English dialogue with Indonesian cultural context
- No need for all characters to speak “perfect global English”; they may have local phrasing styles in text, but grammar should remain readable and natural

---

## 7.3 Voice Acting Policy

MVP assumption:
- No full voice acting required
- Dialogue primarily text-based
- Optional short ambient voice barks, sighs, laughter, greetings, and emotional sounds

If voice acting is later added:
- Dialogue voice should be in English
- Tone should remain grounded and natural

---

# 8. TARGET AUDIENCE

- Players who enjoy cozy games
- Players who enjoy emotional, reflective storytelling
- Players who like travel-based atmosphere
- Players interested in Southeast Asian / Indonesian settings
- Players who enjoy non-combat exploration
- Players who appreciate slow, contemplative pacing

---

# 9. PLAYER FANTASY

The player should feel like they are:

- riding across Java alone;
- hearing the motorcycle beneath them;
- noticing landscapes slowly change;
- stepping into small roadside moments;
- feeling the distance from Jakarta grow;
- carrying emotional weight quietly;
- receiving messages from life back in the city;
- and eventually arriving home, not because all problems are solved, but because going home was the right thing to do for now.

---

# 10. NARRATIVE SUMMARY

Raka, a 30-year-old professional who has spent years working in Jakarta, is laid off because of company restructuring. The layoff is not due to incompetence. In fact, Raka is employable, respected, and capable of finding another position soon.

However, the layoff creates a rupture in his routine.

For the first time in years, he does not know what he is supposed to do tomorrow.

Instead of immediately jumping into another cycle of applications and interviews, he decides to ride home to **Banyuwangi** on his old **Suzuki Thunder 250 (2000)**.

What follows is a road trip across Java: a journey through roads, rain, towns, fields, mountains, people, fatigue, silence, memory, and finally home.

---

# 11. PROTAGONIST

## 11.1 Character Profile

**Name:** Raka  
**Age:** 30  
**Profession before layoff:** Mid-to-senior professional in tech (recommended reference profile: software engineer)  
**Hometown:** Banyuwangi  
**Current city at the start:** Jakarta  
**Current state:** Recently laid off, emotionally tired, not destroyed, but disoriented  

---

## 11.2 Character Design Intent

Raka should not feel melodramatic.

He is:
- competent;
- quiet;
- observant;
- slightly emotionally guarded;
- not socially awkward, but not very expressive;
- used to solving problems practically.

The game is partly about the fact that practical competence does not automatically answer emotional questions.

---

## 11.3 Narrative Arc

### Act I — Disruption
Raka loses the structure that has defined his daily life.

### Act II — Escape or Pause?
Raka starts the trip mainly because he needs distance.

### Act III — Listening
He begins to absorb other people’s lives rather than obsessing over his own next move.

### Act IV — Softening
He becomes less defensive about uncertainty.

### Act V — Arrival
He does not gain a perfect answer.  
He gains room to breathe.

---

# 12. THE MOTORCYCLE

## 12.1 Core Requirement

Raka’s motorcycle must be based on:

> **Suzuki Thunder 250, model year 2000**

This is a non-negotiable visual and design reference.

---

## 12.2 Motorcycle Design Intent

The motorcycle is:

- old but well-maintained;
- mechanically reliable;
- visually aged, but not shabby;
- not heavily rusted;
- not broken;
- seat is intact;
- paint has age, but the bike still looks respectable.

This is important.

The bike should **not** communicate neglect.  
It should communicate age, memory, and continuity.

---

## 12.3 Visual Traits to Preserve

The 3D model should reflect the recognizable silhouette of the Suzuki Thunder 250 (2000), especially:

- classic naked-bike form;
- round headlamp;
- analog instrument cluster;
- muscular fuel tank;
- exposed engine;
- upright riding position;
- simple tail section;
- twin rear shock feel;
- old-school street motorcycle proportions.

---

## 12.4 Condition Notes

**Allowed aging details:**
- subtle paint wear;
- minor surface dullness;
- small scratches from use;
- slightly worn grips;
- realistic engine discoloration from age.

**Not allowed:**
- major rust patches;
- torn seat;
- visually broken panels;
- severe neglect;
- exaggerated grime that makes it feel abandoned.

---

## 12.5 Emotional Role

The motorcycle is effectively the second main character.

It represents:
- Raka’s history;
- his father’s practical presence;
- continuity across time;
- movement between city life and home;
- the physical object through which memory travels.

---

# 13. CAMERA & PLAYER VIEW

## 13.1 Core Camera Decision

When riding the motorcycle, the game must use **First-Person View**.

This is a non-negotiable design update.

---

## 13.2 Why First-Person?

The first-person camera strengthens:
- immersion;
- road presence;
- quiet introspection;
- atmospheric driving;
- proximity to the motorcycle;
- the sense that the player is personally taking the trip.

It also supports:
- stronger weather feeling;
- better road intimacy;
- stronger sound-body connection to the bike.

---

## 13.3 First-Person Riding Camera Rules

During active riding:
- camera sits at rider eye level;
- slight head bob allowed, but must remain subtle;
- camera reacts lightly to acceleration, braking, and road bumps;
- avoid extreme shaking;
- preserve readability and comfort;
- allow visible parts of the bike in frame when possible:
  - handlebar;
  - mirrors;
  - speedometer;
  - top of tank.

---

## 13.4 Mirror Usage

Rear-view mirrors must be visible when possible in first-person riding.  
They support:
- road awareness;
- cinematic memory triggers;
- immersion.

The player does not need precise simulation-level mirror accuracy.  
Readability is more important than perfect realism.

---

## 13.5 Non-Riding Camera Usage

Other camera contexts may use non-first-person setups:

- cutscenes;
- interaction scenes;
- scenic stop cameras;
- dialogue framing;
- inspect moments;
- optional photo mode.

This means:
- gameplay riding = first-person
- cinematic scenes = directed camera language

---

# 14. GAMEPLAY LOOP

**Ride → Notice → Stop → Meet → Interact → Reflect → Rest → Continue**

---

## 14.1 Ride

The player rides along curated road segments across Java.

Key feeling:
- stable;
- immersive;
- atmospheric;
- slightly tactile;
- not racing-focused.

---

## 14.2 Notice

The player notices:
- roadside stalls;
- mechanics;
- signs;
- rain shelters;
- scenic spots;
- gas stations;
- towns;
- people;
- small anomalies;
- optional stops.

---

## 14.3 Stop

Stopping should feel natural and low-friction.

The player may stop:
- by choice;
- for fuel;
- due to weather;
- due to maintenance moments;
- due to story events.

---

## 14.4 Meet

Players meet NPCs in grounded, ordinary situations:
- at a warung;
- while sheltering from rain;
- at a gas station;
- at a guesthouse;
- beside a broken vehicle;
- in a small town.

---

## 14.5 Interact

Interactions are lightweight and human-scale:
- conversation;
- helping someone briefly;
- waiting together;
- sharing food;
- receiving directions;
- fixing something small;
- looking at an object;
- making a call.

---

## 14.6 Reflect

Reflection happens through:
- journal prompts;
- smartphone messages;
- short internal monologue;
- memory triggers;
- silence.

---

## 14.7 Rest

Each major chapter closes with rest.

Resting allows:
- narrative processing;
- save opportunity;
- dialogue pacing;
- next-day transitions.

---

# 15. CONTROL SCHEME & INPUT ABSTRACTION

## 15.1 Design Requirement

The game must support both:
- **PC/Web controls**
- **Mobile touch controls**

Therefore, input must be designed around **action abstraction**, not hard-coded key assumptions.

---

## 15.2 Godot Implementation Requirement

All player actions must be defined via **Godot Input Map actions**.

Recommended action map:

- `move_forward`
- `move_backward`
- `steer_left`
- `steer_right`
- `brake`
- `accelerate`
- `look_left`
- `look_right`
- `interact`
- `open_phone`
- `open_journal`
- `toggle_objective`
- `pause_menu`
- `photo_mode`
- `dismount` (if used in stop zones)
- `confirm`
- `cancel`
- `navigate_up`
- `navigate_down`
- `navigate_left`
- `navigate_right`

---

## 15.3 PC/Web Default Controls

### Riding
- **W / Up Arrow** = Accelerate
- **S / Down Arrow** = Brake / Reverse low-speed roll if needed
- **A / Left Arrow** = Steer Left
- **D / Right Arrow** = Steer Right
- **Space** = Strong Brake
- **E** = Interact / Stop Event / Confirm context action
- **Tab** = Open Phone
- **J** = Open Journal
- **M** = Map / Route Overview
- **Esc** = Pause
- **Q / R** = Look left / right (optional glance)
- **P** = Photo Mode (optional)

### UI Navigation
- Mouse + keyboard or controller-style focus navigation

---

## 15.4 Mobile Touch Controls

### On-Screen Control Layout (recommended)
- Left side: virtual steering pad or left/right touch zones
- Right side:
  - accelerate button
  - brake button
  - interact button
- Top/right or top/center:
  - phone
  - journal
  - pause

### Design Rules
- buttons must be large enough for thumb use;
- translucent UI preferred;
- minimal clutter;
- riding HUD must remain readable;
- touch controls must not hide too much of the screen.

---

## 15.5 Input Adaptation Philosophy

The game must behave consistently across platforms.

Do not design “separate games” for PC and mobile.  
Instead:
- same underlying actions,
- different presentation of input.

---

## 15.6 Keybinding System

### PC/Web
- Remappable controls recommended if feasible
- At minimum, support alternate WASD and Arrow Keys

### Mobile
- Position customization optional
- Button scaling helpful if feasible

---

# 16. PLAYER COMFORT RULES

Because the game uses first-person motorcycle riding, player comfort is critical.

## Comfort Guidelines
- avoid excessive camera shake;
- avoid fast forced camera pans;
- use mild damping during steering;
- keep horizon stable enough;
- use subtle head movement only;
- use slow transitions into cutscenes;
- avoid abrupt FOV changes;
- avoid motion-blur dependency.

Recommended default FOV range for riding:
- approximately **75–90** depending on implementation

---

# 17. TECHNICAL ARCHITECTURE OVERVIEW

## 17.1 Project Architecture Goal

The project should be structured modularly so it is easy to extend, test, and maintain.

The game should be built from clearly separated systems.

---

## 17.2 Suggested Folder Structure

```text
/project
  /addons
  /assets
    /art
      /characters
      /environments
      /props
      /vehicles
      /ui
    /audio
      /music
      /sfx
      /ambient
    /data
      /dialogue
      /chapter_data
      /cutscene_data
      /localization
  /scenes
    /boot
    /menus
    /player
    /bike
    /world
    /chapters
    /ui
    /cutscenes
    /npc
    /interactables
  /scripts
    /autoload
    /player
    /bike
    /ui
    /world
    /dialogue
    /cutscene
    /systems
  /tests
```

---

## 17.3 Suggested Autoload Singletons

Recommended global managers:

- `GameState.gd`
- `SaveManager.gd`
- `AudioManager.gd`
- `SceneFlowManager.gd`
- `DialogueManager.gd`
- `InputModeManager.gd`
- `LocalizationManager.gd`
- `ChapterManager.gd`

---

## 17.4 Key Systems

Core runtime systems should include:

1. **Bike Controller**
2. **Player Camera Controller**
3. **Interaction System**
4. **Dialogue System**
5. **Journal System**
6. **Phone UI System**
7. **Chapter Progression System**
8. **Cutscene System**
9. **Save/Load System**
10. **Environment/Weather System**
11. **Audio State System**
12. **NPC Encounter System**

---

# 18. SCENE & NODE DESIGN GUIDANCE

## 18.1 Player/Bike Runtime Structure (Conceptual)

Recommended design philosophy:
- player is effectively “mounted” during riding segments;
- first-person riding camera is attached to a rider anchor;
- the motorcycle is the primary movement body.

Conceptual node structure example:

```text
BikeRoot
  BikeBody
  VisualModel
  FrontWheel
  RearWheel
  Handlebar
  Speedometer
  MirrorLeft
  MirrorRight
  RiderCameraAnchor
    FirstPersonCamera3D
  AudioEngine
  InteractionDetector
```

---

## 18.2 Chapter Scene Composition

Each chapter scene can contain:

```text
ChapterRoot
  EnvironmentRoot
  RoadSplineSystem
  TrafficSpawner
  NPCSpawner
  TriggerZones
  WeatherController
  AmbientAudioZones
  ScenicStops
  DialoguePoints
  GasStations
  RestStopExit
  StoryEventTriggers
```

---

# 19. WORLD STRUCTURE

The game is not a 1:1 open-world recreation of Java.

Instead, it uses a **curated open-road structure**.

This means:
- each chapter contains a compressed but convincing representation of a travel segment;
- roads are explorable within controlled boundaries;
- major story beats happen through designed event placement;
- the experience is open enough to feel like a journey, but scoped enough to be producible.

---

# 20. CHAPTER LIST

Main route structure:

1. Prologue — Jakarta
2. Chapter 1 — Jakarta to Karawang
3. Chapter 2 — Cirebon
4. Chapter 3 — Tegal
5. Chapter 4 — Pekalongan
6. Chapter 5 — Semarang
7. Chapter 6 — Salatiga
8. Chapter 7 — Solo
9. Chapter 8 — Ngawi
10. Chapter 9 — Madiun
11. Chapter 10 — Kediri
12. Chapter 11 — Malang
13. Chapter 12 — Lumajang
14. Chapter 13 — Jember
15. Final Chapter — Banyuwangi
16. Epilogue — Family Home

---

# 21. CHAPTER DESIGN TEMPLATE

Every chapter should ideally define:

- chapter theme;
- environment identity;
- time-of-day profile;
- weather possibilities;
- main road route;
- optional stops;
- one to two important NPC encounters;
- one reflective beat;
- one rest point;
- one transition-out condition.

This template should be used for all narrative content authoring.

---

# 22. NARRATIVE CHAPTER BREAKDOWN

## PROLOGUE — JAKARTA
**Theme:** Structure Lost  
**Mood:** Wet, dense, urban, cold, routine

Raka wakes up, goes through his workday routine, gets laid off, returns home to a quiet apartment, receives messages from colleagues and recruiters, speaks with his mother, and begins considering going home.

---

## CHAPTER 1 — JAKARTA TO KARAWANG
**Theme:** Leaving  
Urban compression gradually opens into industrial outskirts and first stretches of wider road.  
Raka is still mentally trapped in work mode.

---

## CHAPTER 2 — CIREBON
**Theme:** Ambition  
A roadside interaction with someone who once left home for the city creates a mirrored perspective.

---

## CHAPTER 3 — TEGAL
**Theme:** Maintenance  
A small bike-related stop becomes a quiet memory gateway.

---

## CHAPTER 4 — PEKALONGAN
**Theme:** Waiting  
Rain forces Raka to stop. Shared shelter becomes human observation space.

---

## CHAPTER 5 — SEMARANG
**Theme:** Regret  
Raka reconnects with a friend whose outward success hides hesitation.

---

## CHAPTER 6 — SALATIGA
**Theme:** Quiet  
Scenic highland riding with very little dialogue. A major “engine off” contemplation chapter.

---

## CHAPTER 7 — SOLO
**Theme:** Family  
A small encounter with a family highlights what ordinary closeness looks like.

---

## CHAPTER 8 — NGAWI
**Theme:** Loneliness  
Raka meets an older rider whose life changed after loss.

---

## CHAPTER 9 — MADIUN
**Theme:** Ease  
A visit with an old friend reminds Raka what unforced companionship feels like.

---

## CHAPTER 10 — KEDIRI
**Theme:** Career Returns  
A serious interview opportunity resurfaces. The question is not “can he get the job?” but “is he ready to step back in?”

---

## CHAPTER 11 — MALANG
**Theme:** Before Work  
Raka encounters reminders of who he was before professional identity dominated his life.

---

## CHAPTER 12 — LUMAJANG
**Theme:** Scale  
Landscape and travel distance make Raka feel small in a healthy way.

---

## CHAPTER 13 — JEMBER
**Theme:** Almost Home  
Raka senses home approaching. Relief and nervousness coexist.

---

## FINAL CHAPTER — BANYUWANGI
**Theme:** Home  
Raka reaches home. The reunion is simple, quiet, and emotionally restrained.

---

## EPILOGUE
**Theme:** Permission  
The next day, Raka still does not have all the answers. That is okay.

---

# 23. CUTSCENE PHILOSOPHY

## 23.1 Tone Rule

Cutscenes must remain restrained.

No melodramatic over-acting.  
No exaggerated camera tricks.  
No over-scored emotional manipulation.

The tone should feel:
- natural;
- cinematic;
- intimate;
- observant;
- patient.

---

## 23.2 Technical Direction Style

Every cutscene should define:
- purpose;
- location;
- time of day;
- participating characters;
- shot list;
- framing type;
- lens/FOV recommendation;
- movement type;
- audio priority;
- transition style.

---

# 24. CUTSCENE MASTER LIST

Below is the required list of major story cutscenes.  
These are the main non-optional cinematic sequences.

---

## CUTSCENE 01 — OPENING MORNING ROUTINE

### Purpose
Establish Raka’s daily structure before it is broken.

### Location
Jakarta apartment / parking area / office arrival

### Time
Morning

### Visual Tone
Muted urban realism, cool light

### Shot List

**Shot 1 — Alarm Wake-Up**  
- Type: Extreme close-up  
- Subject: Phone alarm on bedside table  
- Lens/FOV: Narrow/50mm equivalent feel  
- Duration: 2–3 sec  
- Movement: Static  
- Audio: Alarm tone, soft room ambience  
- Transition: Fade in from black

**Shot 2 — Raka Wakes**  
- Type: Medium close-up  
- Camera height: Eye level from bedside angle  
- Movement: Slow handheld-style drift or subtle dolly  
- Audio: Bedsheet movement, distant Jakarta ambience

**Shot 3 — Morning Actions Montage**  
- Type: Insert sequence  
- Subjects: Kettle, coffee cup, shirt buttons, work badge, keys  
- Framing: Close-up / detail shots  
- Editing: Clean hard cuts, rhythmic but not fast

**Shot 4 — Parking Area**  
- Type: Medium wide  
- Subject: Raka approaching the motorcycle  
- Camera: Slightly low angle to make bike presence clear  
- Duration: 3 sec  
- Movement: Slow lateral track

**Shot 5 — Engine Start**  
- Type: Close-up insert  
- Subject: Key in ignition / analog cluster wake-up  
- Audio Priority: Starter sound  
- Cut to gameplay after ignition

### Transition to Gameplay
Seamless handoff into first-person riding as Raka leaves for work.

---

## CUTSCENE 02 — HR MESSAGE / LAYOFF MEETING

### Purpose
Introduce the inciting incident.

### Location
Office desk / meeting room

### Time
Late morning

### Shot List

**Shot 1 — Desk Notification**  
- Type: Over-shoulder close shot  
- Subject: Screen message from HR  
- Movement: Static  
- Sound: Soft office ambience

**Shot 2 — Walking to Meeting**  
- Type: Rear follow shot  
- Framing: Medium  
- Camera movement: Slow dolly or gentle follow

**Shot 3 — Meeting Table**  
- Type: Medium two-shot / medium wide  
- Subject: Raka and HR  
- Lens: Normal perspective  
- Movement: Minimal

**Shot 4 — Sound Drop**  
- Type: Close-up on Raka’s face  
- Audio treatment: HR voice gradually muffles  
- Goal: Show emotional dissociation

**Shot 5 — Work Badge on Table**  
- Type: Insert  
- Symbolic object shot  
- Duration: 2 sec

**Shot 6 — Laptop Signing Out**  
- Type: Close-up screen detail  
- Text: “Signing out...”  
- Transition: Hard cut to silence

---

## CUTSCENE 03 — EVENING APARTMENT / MOTHER’S CALL

### Purpose
Create emotional turning point without overt drama.

### Location
Raka’s apartment

### Time
Night, after rain

### Shot List

**Shot 1 — Apartment Wide**  
- Type: Static wide shot  
- Subject: Raka alone in small apartment  
- Lighting: Screen glow + practical lamp

**Shot 2 — Recruiter Messages Montage**  
- Type: Phone inserts  
- Text in English  
- Show multiple professional options

**Shot 3 — Cursor Over “Apply”**  
- Type: Tight over-shoulder  
- Subject: Job posting / apply button  
- Movement: None

**Shot 4 — Phone Vibrates: “Mom”**  
- Type: Close-up insert

**Shot 5 — Call Conversation**  
- Type: Medium profile shot of Raka seated  
- Camera: Locked off  
- Tone: Quiet, intimate  
- Important line: “You can just come home if you’re tired.”

### Transition
Hold on Raka after call. Cut to black or slow dissolve into next morning.

---

## CUTSCENE 04 — DECISION TO GO HOME / PACKING

### Purpose
Mark the point of no return.

### Location
Apartment and parking area

### Time
Morning

### Shot List

**Shot 1 — Late Morning Light**  
- Type: Wide interior  
- Mood: Softer, warmer than prologue

**Shot 2 — Packing Inserts**  
- Clothes, raincoat, charger, toolkit, laptop  
- Type: Close-up inserts

**Shot 3 — Map Route**  
- Type: Over-shoulder shot  
- Subject: Route to Banyuwangi on phone or laptop

**Shot 4 — Bike Touch**  
- Type: Close-up  
- Subject: Raka wiping dust from tank or cluster  
- Goal: emotional connection to bike

**Shot 5 — Flash of Memory**  
- Type: Super short image insert  
- Young Raka on back seat behind father  
- Transitional sound bridge

**Shot 6 — Departure**  
- Type: Low-angle medium shot  
- Subject: Motorcycle pulling out  
- Title reveal here recommended

### Title Card
**PULANG**  
**Jakarta → Banyuwangi**

---

## CUTSCENE 05 — RAIN SHELTER ENCOUNTER

### Purpose
Establish that weather can force human pause.

### Location
Roadside warung shelter

### Time
Afternoon

### Visual Notes
Warm practical light vs grey rain background

### Shot Language
- Wide establishing of rain hitting roadside
- POV cut from first-person ride to stop
- Medium group framing for strangers sharing shelter
- Close-ups on tea glass, steaming noodles, rain runoff

### Narrative Function
Atmospheric encounter, not high plot.

---

## CUTSCENE 06 — SEMARANG DINNER WITH DIMAS

### Purpose
Contrast outward success and internal uncertainty.

### Location
Small restaurant or café in Semarang

### Time
Night

### Shot Language
- Two-shot across table
- Alternate medium close-ups
- Occasional insert of untouched food / phone notification
- Use shallow depth feeling if possible

### Emotional Rule
Conversation should feel honest, not confrontational.

---

## CUTSCENE 07 — SALATIGA SCENIC STOP

### Purpose
Show silence as emotional event.

### Location
Highland scenic turnout

### Time
Late afternoon / golden hour

### Shot Language
**Shot 1** — POV bike slowing into turnout  
**Shot 2** — External wide shot of bike parked against landscape  
**Shot 3** — Medium shot of Raka seated quietly  
**Shot 4** — Sound-focused stillness

Minimal dialogue.  
Primary storytelling is environmental.

---

## CUTSCENE 08 — OLDER RIDER IN NGAWI

### Purpose
Introduce a different model of solitude.

### Location
Roadside resting spot

### Time
Late afternoon

### Shot Language
- Wide shot of two parked motorcycles
- Slow medium two-shot seated side by side, facing road
- Limited eye contact, both looking forward
- Sparse lines, long pauses

---

## CUTSCENE 09 — JOB INTERVIEW IN KEDIRI

### Purpose
Bring Raka’s city-life question back into the trip.

### Location
Guesthouse room / laptop call

### Time
Evening

### Shot Language
- Close-up laptop screen glow
- Profile medium shot during interview
- Audio slightly compressed to simulate call
- After interview, cut to silence and static room tone

Narrative emphasis:
The interview is competent, but emotionally unresolved.

---

## CUTSCENE 10 — APPROACH TO BANYUWANGI

### Purpose
Create emotional anticipation through geography.

### Location
Road approach / familiar roads

### Time
Late afternoon or early evening

### Shot Language
- First-person POV of road signs and familiar landmarks
- Brief memory inserts
- Exterior drone-style or elevated wide shot optional if available
- Audio motif returns here

---

## CUTSCENE 11 — ARRIVAL HOME

### Purpose
Deliver emotional payoff through restraint.

### Location
Family house in Banyuwangi

### Time
Late afternoon / early evening

### Shot List

**Shot 1 — Street Approach**  
- Type: First-person riding POV  
- Movement: Slow, careful

**Shot 2 — Exterior Wide**  
- Subject: House frontage, bike entering frame  
- Camera: Static

**Shot 3 — Engine Off**  
- Type: Close insert  
- Subject: Ignition / hand removing key  
- Audio: Engine shutoff, ambient neighborhood

**Shot 4 — Mother Appears**  
- Type: Medium doorway shot  
- Audio: House ambience, neighborhood sound

**Shot 5 — Raka Reverse Angle**  
- Type: Medium close-up  
- Performance: Small smile only

**Shot 6 — Father Approaches the Bike**  
- Type: Medium shot
- Camera slightly lower than eye level
- Subject priority: father + motorcycle

**Shot 7 — Hand on Handlebar**  
- Type: Insert close-up  
- Emotional anchor image

**Shot 8 — Odometer**  
- Type: Insert  
- Symbolic payoff shot

**Shot 9 — Family Enters House**  
- Type: Wide locked shot from outside  
- Camera stays outside  
- Sound carries from inside  
- End on parked motorcycle

---

## CUTSCENE 12 — EPILOGUE MORNING

### Purpose
Express acceptance, not conclusion.

### Location
Family home / yard

### Time
Morning

### Shot Language
- Calm morning light
- Medium shot of father cleaning bike
- Seated side conversation
- No dramatic music swell
- Final static composition of house + bike + open space

Important line:
> “That’s okay.”

This line must land gently, not theatrically.

---

# 25. GAMEPLAY SYSTEMS

## 25.1 Riding System

### Goal
Deliver a comfortable, immersive first-person riding experience.

### Design Priorities
- stable handling;
- easy readability;
- atmosphere over realism;
- moderate speed feel;
- believable but not punishing controls.

### Non-Goal
This is not a hardcore simulator.  
This is not a racing game.

---

## 25.2 Speed Model

The player should feel road speed, but the game does not need exact simulation-grade motorcycle behavior.

Recommended feel:
- low-speed controllable;
- medium-speed pleasant cruising;
- high-speed limited and not dominant;
- braking readable and forgiving.

---

## 25.3 Fuel System

Fuel exists to support travel fiction, not to harass the player.

Rules:
- fuel depletes slowly enough to be manageable;
- stations appear at believable intervals;
- running low may prompt stops and atmosphere;
- full failure states should be rare.

---

## 25.4 Bike Condition System

Bike condition should create moments, not punishment.

Subsystems may include:
- fuel;
- chain wear;
- tire status;
- general condition.

But all of these must remain lightweight.

Narrative purpose:
small maintenance creates human encounters.

---

## 25.5 Weather System

Required weather states:
- clear;
- overcast;
- light rain;
- heavy rain;
- mist/fog;
- golden-hour lighting conditions.

Weather affects:
- visibility;
- ambience;
- NPC behavior;
- stop opportunities;
- mood.

---

## 25.6 Time of Day System

Time can be semi-authored rather than fully simulation-driven.

Phases:
- morning
- noon
- afternoon
- golden hour
- evening
- night

Narrative pacing takes priority over full dynamic simulation.

---

## 25.7 Interaction System

Interaction must be simple and consistent.

Standard interaction prompt examples:
- **Talk**
- **Sit**
- **Refuel**
- **Inspect**
- **Rest**
- **Open**
- **Help**
- **Continue**

All prompts must remain in English.

---

## 25.8 Dialogue System

Dialogue is branching but not morality-based.

Choice categories:
- honest;
- quiet;
- deflective;
- warm;
- practical;
- uncertain.

The game should never display “good/bad” alignment feedback.

---

## 25.9 Journal System

Each rest stop or important chapter break may unlock a journal reflection.

The player does not free-type.  
They choose from authored internal responses.

Journal functions:
- reveal Raka’s evolving mindset;
- store emotional milestones;
- support player interpretation.

---

## 25.10 Phone System

The smartphone acts as a storytelling interface.

Core sections:
- Messages
- Calls
- Email
- Photos
- Route
- Music (optional flavor)
- Notes / Journal shortcut

Its purpose is to represent:
- unfinished city life;
- social ties;
- work opportunities;
- family connection.

---

## 25.11 Memory Fragment System

Short memory flashes are triggered by:
- sensory cues;
- people;
- road moments;
- father-child visual parallels;
- objects related to the bike.

Duration:
- 2–10 seconds typically

Use sparingly.

---

## 25.12 Scenic Stop System

Important cozy-system feature.

At scenic stops, the player may:
- park;
- turn off engine;
- sit;
- observe;
- trigger quiet music or pure ambience.

These locations often have no quest reward.

That is intentional.

---

# 26. UI / UX

## 26.1 UI Principles
- minimal;
- readable;
- platform-adaptive;
- non-intrusive;
- cozy;
- easy to navigate.

---

## 26.2 Riding HUD

Recommended elements:
- speed
- fuel
- subtle objective cue
- interaction prompt when relevant

Optional:
- time-of-day indicator
- tiny phone notification icon

Do not clutter the center of the screen.

---

## 26.3 Menus

Required menus:
- Main Menu
- New Game
- Continue
- Chapters / Save Slots if supported
- Settings
- Controls
- Accessibility
- Credits
- Quit

All menu text must be in English.

---

## 26.4 Accessibility Features

Recommended:
- subtitle size options
- UI scale options
- riding assist toggle
- reduced camera motion option
- simplified touch layout option
- color-safe UI contrast
- auto-center steering assist (optional)

---

# 27. VISUAL DIRECTION

## 27.1 Art Style

Stylized 3D Low Poly.

The style should be:
- warm;
- elegant;
- readable;
- cohesive;
- slightly idealized rather than gritty realism.

---

## 27.2 Environment Identity by Region

### Jakarta
- cooler tones;
- wet asphalt;
- urban density;
- apartment interiors;
- office lighting;
- traffic presence.

### West Java / Early Route
- industrial outskirts;
- flatter road stretches;
- signs of transition.

### Central Java
- fields;
- hills;
- older urban textures;
- roadside life;
- rain shelters.

### East Java
- longer roads;
- mountain massing;
- larger sense of air and distance;
- home-approach warmth.

### Banyuwangi
- warm, open, familiar;
- modest neighborhood intimacy;
- a sense of arrival rather than spectacle.

---

## 27.3 Color Direction

### Emotional palette progression:
- Jakarta: cool grey-blue
- early road: muted green + warm asphalt tones
- mid-journey: balanced warm/cool natural palette
- near home: warmer sunlight, softer earth tones
- Banyuwangi: warm cream, faded green, lived-in warmth

---

# 28. AUDIO DIRECTION

## 28.1 Audio Pillars
1. Motorcycle identity
2. Road ambience
3. Weather presence
4. Human intimacy
5. Selective music usage

---

## 28.2 Motorcycle Audio

The bike must have a distinctive sonic presence.

Important sound categories:
- startup
- idle
- light throttle
- cruising
- heavier acceleration
- braking
- engine off
- tick/cool-down after stopping

This is essential for immersion in first-person riding.

---

## 28.3 Ambient Sound

Use Indonesian ambience texture:
- distant calls
- birds
- insects
- traffic
- warung chatter
- dishes
- TV from houses
- mosque ambience in distance where appropriate
- rain on roof metal / helmet context
- roadside wind

---

## 28.4 Music

Music should be used sparingly.

Suggested sound:
- soft acoustic guitar
- piano
- gentle ambient textures
- restrained emotional cues

Silence and ambience are equally important.

---

# 29. NPC PRINCIPLES

NPCs must feel like people, not message-delivery devices.

Avoid:
- fake wisdom monologues;
- direct moral lessons;
- self-aware “theme” dialogue.

Prefer:
- unfinished thoughts;
- practical concerns;
- humor;
- awkwardness;
- ordinary warmth.

---

# 30. SIDE CONTENT DESIGN

Optional content should remain aligned with the main tone.

Examples:
- helping someone find a missing item;
- waiting out rain with strangers;
- briefly helping with a motorcycle issue;
- taking a meal break with conversation;
- stopping for coffee;
- taking a scenic photo.

Do not add:
- collectibles for the sake of collectibles;
- arcade mini-games that break tone;
- combat;
- random “busywork” filler.

---

# 31. SAVE STRUCTURE

Recommended save model:
- checkpoint saves at major rest locations;
- optional manual save at inns/rest points;
- chapter progression saved reliably;
- current dialogue/journal state saved.

Because the game targets browser and mobile, the save system must be robust and lightweight.

---

# 32. DATA-DRIVEN CONTENT RECOMMENDATION

To support scalability and AI-assisted content generation, it is recommended that the following be defined in external data assets (JSON, dictionaries, resources, or equivalent Godot-friendly formats):

- chapter metadata
- NPC dialogue trees
- cutscene shot metadata
- journal prompt data
- phone message sets
- weather profiles
- scenic stop definitions
- interaction prompt tables

This allows content iteration without rewriting core code.

---

# 33. IMPLEMENTATION NOTES FOR AI-ASSISTED DEVELOPMENT

## 33.1 Non-Negotiable Design Constraints
Any AI system assisting development must preserve the following:
- riding gameplay is first-person;
- the motorcycle is based on a Suzuki Thunder 250 (2000);
- the bike is old but well-kept, not rusty or broken;
- the entire game UI and dialogue are in English;
- the tone is cozy, warm, grounded, and non-preachy;
- no combat;
- no racing focus;
- no moral point system;
- the game is built in Godot;
- the game targets both web and Android;
- controls must adapt between keyboard and touch.

---

## 33.2 AI Content Guardrails
AI-generated scenes, dialogue, or systems must avoid:
- turning the game into a simulator-heavy title;
- turning NPCs into philosophers;
- adding action-chase sequences;
- adding extreme drama not justified by tone;
- making the bike appear ruined or neglected;
- changing the hometown goal away from Banyuwangi;
- translating the player-facing content into Indonesian.

---

## 33.3 AI-Friendly Content Schema Suggestion

### Chapter Data Fields
- `chapter_id`
- `chapter_name`
- `theme`
- `start_location`
- `end_location`
- `time_of_day`
- `weather_profile`
- `main_route_length`
- `scenic_stops`
- `mandatory_events`
- `optional_events`
- `primary_npcs`
- `journal_prompt`
- `rest_location`

### Cutscene Data Fields
- `cutscene_id`
- `title`
- `purpose`
- `location`
- `time_of_day`
- `characters`
- `shot_list`
- `audio_notes`
- `transition_in`
- `transition_out`

---

# 34. TECHNICAL MVP / VERTICAL SLICE

## 34.1 MVP Goal
Build a playable slice that proves:
- first-person riding feels good;
- tone is correct;
- English UI/dialogue pipeline works;
- bike identity works;
- web/mobile input abstraction works;
- a small chapter can carry narrative emotion.

---

## 34.2 Vertical Slice Scope

Recommended slice:
- Prologue apartment
- Opening commute
- Layoff meeting
- Apartment night scene
- Departure sequence
- Short first travel segment
- One roadside stop
- One conversation
- One rain shelter event
- One rest stop + journal
- Save/load basic flow

Estimated slice playtime:
- 30–60 minutes

---

# 35. PRODUCTION PRIORITIES

1. Input system abstraction  
2. First-person motorcycle controller  
3. Bike model & cockpit/readability  
4. Camera comfort tuning  
5. Dialogue/UI flow  
6. One chapter slice  
7. Weather + ambience  
8. Phone + journal  
9. Cutscene framework  
10. Save/load  
11. Additional chapters  
12. Polish and optimization  

---

# 36. ART & ASSET REQUIREMENTS

## 36.1 Essential Assets
- Raka base character model
- Suzuki Thunder 250 (2000)-inspired bike model
- First-person cockpit/handlebar view setup
- Apartment environment
- Office environment
- Road segment kits
- Warung set
- Gas station set
- Guesthouse/inn set
- Family house in Banyuwangi
- Props for roadside Indonesia

---

## 36.2 Bike Model Requirements
The motorcycle model needs:
- full exterior model
- high-priority first-person visible cockpit elements
- readable analog instruments
- mirrors
- handlebar
- front fork visible from cockpit angle
- suitable animation hooks for steering and suspension response

---

# 37. ENVIRONMENT DETAILS FOR INDONESIAN AUTHENTICITY

World-building details should include:
- roadside stalls
- plastic chairs
- thermos flasks
- snack jars
- small repair shops
- gasoline station structures
- modest homes
- local gates and neighborhood signage
- utility poles
- school zones
- rice fields
- roadside trees
- buses, trucks, scooters, and cars in local proportions
- informal commerce textures
- familiar roadside rhythms

All must be stylized and readable, not overcomplicated.

---

# 38. ENDING PHILOSOPHY

There is no “best ending” and no “bad ending” in a moral sense.

Possible variations may reflect:
- whether Raka has replied to job opportunities,
- whether he has taken an interview,
- how he frames uncertainty in his journal,
- and how openly he speaks.

But every valid ending path resolves the same essential journey:

> **Raka makes it home.**

The emotional success condition is not “he solved his career.”

The emotional success condition is:

> **he allowed himself to arrive.**

---

# 39. TAGLINES

Possible English taglines:

- **PULANG — For now, just go home.**
- **PULANG — A long ride home across Java.**
- **PULANG — You do not need the next answer yet.**
- **PULANG — One motorcycle. One island. One quiet return.**

---

# 40. ONE-SENTENCE DESIGN RULE

> **If a feature makes the player feel rushed, competitive, punished, or disconnected from Raka’s emotional journey home, it probably does not belong in PULANG.**

---

# 41. FINAL CREATIVE SUMMARY

PULANG is a first-person motorcycle road trip game about a man who leaves Jakarta after a layoff and rides home to Banyuwangi on an old but well-kept Suzuki Thunder 250.

It must feel:
- intimate,
- grounded,
- warm,
- reflective,
- Indonesian,
- and emotionally honest.

It must be:
- in English,
- built in Godot,
- adaptable to web and Android,
- and structured clearly enough for AI-assisted production.

It is not a game about mastering the road.

It is a game about what the road gives back when you finally stop forcing your life to move faster than your heart can follow.
