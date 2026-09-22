# PULANG — TECHNICAL DESIGN DOCUMENT (TDD)
## Version 1.0 — Production Architecture for Godot
### Companion Document to PULANG GDD v2

**Project:** PULANG  
**Engine Baseline:** Godot 4.7.2 Stable  
**Primary Scripting Language:** GDScript  
**Primary Renderer:** Compatibility  
**Target Platforms:** PC Web Browser / itch.io, Android / Google Play  
**Game Language:** English only for all player-facing content  
**Riding Perspective:** First-Person  
**Reference Motorcycle:** Suzuki Thunder 250, model year 2000  
**Document Purpose:** Technical source of truth for human and AI-assisted implementation  

---

# 1. DOCUMENT PURPOSE

This Technical Design Document describes how **PULANG** should be implemented in Godot.

The GDD defines:
- what the game is;
- what the player should feel;
- narrative structure;
- art direction;
- gameplay intent.

This TDD defines:
- architecture;
- systems;
- data flow;
- scene structure;
- technical constraints;
- code responsibilities;
- platform strategy;
- performance budgets;
- save format;
- testing strategy;
- implementation conventions;
- AI coding guardrails.

If the TDD conflicts with the emotional or narrative intent of the GDD, the GDD's creative intent wins unless the feature is technically impossible on the supported platforms.

---

# 2. LOCKED TECHNICAL DECISIONS

The following decisions are considered locked unless formally revised.

## 2.1 Engine

Use:

**Godot 4.7.2 Stable**

Reason:
- current stable production baseline at the time this document was written;
- mature Godot 4 feature set;
- stable web and Android export workflows.

Do not develop production against a development/RC build unless a required bug fix makes it necessary.

Pin the exact engine version in:
- repository README;
- CI configuration;
- development setup documentation.

---

## 2.2 Scripting Language

Use:

**GDScript**

Do not use C# as the primary gameplay language.

Reason:
Godot 4 C# projects are not supported for Web export in the same way as GDScript projects. Since browser deployment is a core release target, the project architecture should avoid depending on C#.

---

## 2.3 Rendering Method

Use:

**Compatibility renderer**

Reason:
Godot 4 Web exports use WebGL 2.0 and require the Compatibility rendering method.

The native Android build should also use the same baseline rendering path unless profiling proves a platform-specific override is necessary.

Benefits:
- visual parity;
- simpler shader authoring;
- fewer platform-specific rendering bugs;
- lower-end device compatibility;
- one common performance baseline.

---

# 3. TECHNICAL DESIGN PRINCIPLES

## 3.1 Browser First, Android Always Tested

Every major feature must be validated on:
1. desktop editor;
2. browser export;
3. Android device.

A feature that only works in the desktop editor is not considered complete.

---

## 3.2 Data Over Hard-Coding

Narrative content should be data-driven whenever practical.

Prefer external Resources/JSON/config data for:
- dialogue;
- chapter definitions;
- messages;
- journal prompts;
- environmental schedules;
- cutscene shot definitions;
- event flags.

Core gameplay logic remains code-driven.

---

## 3.3 Composition Over Large Monolithic Scripts

Avoid a single large Player or GameManager script.

Prefer specialized components:
- BikeMotorController
- BikeSteeringController
- BikeAudioController
- RideCameraController
- InteractionScanner
- ChapterRuntime
- DialoguePresenter
- SaveManager

---

## 3.4 Event-Driven Communication

Use signals for system boundaries.

Examples:
- `bike_speed_changed`
- `interaction_available`
- `dialogue_started`
- `dialogue_finished`
- `chapter_checkpoint_reached`
- `weather_changed`
- `phone_notification_received`

Avoid tightly coupling systems by direct node-path calls when a signal or typed service interface is appropriate.

---

## 3.5 No Runtime Dependency on Editor-Only State

All scenes and data must run correctly in exports.

Do not rely on:
- editor-only paths;
- manually selected nodes;
- unexported debug resources;
- development machine absolute paths.

---

# 4. REPOSITORY STRUCTURE

Recommended repository layout:

```text
PULANG/
├── project.godot
├── README.md
├── LICENSES/
├── docs/
│   ├── GDD/
│   ├── TDD/
│   ├── roadmap/
│   ├── narrative/
│   ├── art/
│   └── test/
├── addons/
├── assets/
│   ├── 3d/
│   │   ├── bike/
│   │   ├── characters/
│   │   ├── environment/
│   │   ├── props/
│   │   └── traffic/
│   ├── textures/
│   ├── materials/
│   ├── shaders/
│   ├── audio/
│   │   ├── ambient/
│   │   ├── bike/
│   │   ├── ui/
│   │   ├── dialogue/
│   │   └── music/
│   ├── fonts/
│   └── icons/
├── data/
│   ├── chapters/
│   ├── dialogue/
│   ├── phone/
│   ├── journal/
│   ├── encounters/
│   ├── cutscenes/
│   └── localization/
├── scenes/
│   ├── boot/
│   ├── menus/
│   ├── common/
│   ├── bike/
│   ├── player/
│   ├── ui/
│   ├── npc/
│   ├── props/
│   ├── traffic/
│   ├── weather/
│   ├── cutscenes/
│   └── chapters/
├── scripts/
│   ├── autoload/
│   ├── bike/
│   ├── camera/
│   ├── input/
│   ├── interaction/
│   ├── dialogue/
│   ├── narrative/
│   ├── save/
│   ├── ui/
│   ├── world/
│   ├── audio/
│   └── utilities/
├── tests/
│   ├── unit/
│   ├── integration/
│   └── fixtures/
└── export/
    ├── web/
    └── android/
```

---

# 5. NAMING CONVENTIONS

## 5.1 GDScript

Use Godot conventions:
- files: `snake_case.gd`
- variables: `snake_case`
- functions: `snake_case()`
- classes: `PascalCase`
- constants: `UPPER_SNAKE_CASE`
- signals: `snake_case`

Example:

```gdscript
class_name BikeMotorController

signal engine_started
signal speed_changed(speed_kph: float)

const MAX_CRUISE_SPEED_KPH := 95.0

var current_speed_kph: float = 0.0
```

---

## 5.2 Scenes

Use `PascalCase.tscn`.

Examples:
- `BikePlayer.tscn`
- `MainMenu.tscn`
- `DialogueOverlay.tscn`
- `Chapter_Cirebon.tscn`

---

## 5.3 Asset Naming

Examples:
- `bike_thunder250_body.glb`
- `prop_warung_plastic_chair_01.glb`
- `tex_asphalt_dry_01.webp`
- `sfx_bike_idle_loop_01.ogg`
- `amb_rain_warung_loop_01.ogg`

---

# 6. BOOT FLOW

Recommended application startup:

```text
Boot.tscn
    ↓
Initialize autoload services
    ↓
Load user settings
    ↓
Detect input device/platform
    ↓
Load localization table
    ↓
MainMenu.tscn
    ↓
New Game / Continue
    ↓
SceneFlowManager loads chapter
```

---

# 7. AUTOLOAD SERVICES

Use autoloads only for genuinely global state.

## 7.1 GameState

Responsibilities:
- current save slot;
- current chapter ID;
- narrative flags;
- player preferences that belong to the save;
- global game state.

Must NOT:
- control UI directly;
- own chapter nodes;
- contain unrelated utility functions.

---

## 7.2 SaveManager

Responsibilities:
- serialize save state;
- load save state;
- schema versioning;
- autosave;
- save integrity checks;
- migration.

Suggested signals:
- `save_started`
- `save_completed`
- `save_failed`
- `load_completed`

---

## 7.3 SceneFlowManager

Responsibilities:
- chapter loading;
- loading-screen transitions;
- scene unloading;
- fade transitions;
- memory cleanup.

---

## 7.4 AudioManager

Responsibilities:
- global buses;
- music state;
- ambience state;
- UI audio;
- master volume settings;
- platform audio focus handling where practical.

---

## 7.5 InputModeManager

Responsibilities:
- detect last-used input class;
- PC keyboard/mouse mode;
- gamepad mode if supported;
- mobile touch mode;
- update prompts/icons;
- expose current control scheme.

---

## 7.6 DialogueManager

Responsibilities:
- load dialogue data;
- evaluate conditions;
- set flags;
- expose dialogue events.

It should not render the dialogue UI itself.  
Presentation should be handled by a scene/controller.

---

## 7.7 ChapterManager

Responsibilities:
- chapter metadata;
- checkpoint progression;
- chapter completion;
- chapter-local flags;
- transition to rest segment.

---

# 8. MAIN SCENE ARCHITECTURE

Suggested chapter runtime scene:

```text
ChapterRoot (Node3D)
├── ChapterEnvironment
├── RoadSystem
├── PlayerSpawn
├── BikePlayer
├── TrafficSystem
├── EncounterSystem
├── WeatherSystem
├── TimeOfDaySystem
├── AudioZones
├── StoryTriggers
├── ScenicStops
├── NavMarkers
├── CutsceneDirector
└── ChapterUI
```

---

# 9. BIKE PLAYER ARCHITECTURE

## 9.1 Recommended Root

Use a custom controller based on `CharacterBody3D` for the initial implementation rather than a fully physical motorcycle simulation.

Reason:
- stable across browser/mobile;
- deterministic;
- easier first-person comfort;
- easier AI implementation;
- less expensive;
- better aligned with cozy traversal rather than simulation.

A `VehicleBody3D` prototype may be evaluated, but should not be adopted unless it clearly improves handling without hurting browser/mobile stability.

---

## 9.2 Bike Scene

```text
BikePlayer (CharacterBody3D)
├── CollisionShape3D
├── BikeVisualRoot
│   ├── FrameMesh
│   ├── FrontWheelPivot
│   │   └── FrontWheelMesh
│   ├── RearWheelMesh
│   ├── HandlebarPivot
│   ├── SpeedometerNeedle
│   ├── MirrorLeft
│   └── MirrorRight
├── GroundProbeRoot
│   ├── RayFront
│   ├── RayCenter
│   └── RayRear
├── RiderCameraRig
│   ├── LeanPivot
│   │   └── HeadPivot
│   │       └── Camera3D
├── InteractionScanner
├── BikeAudioController
│   ├── EngineIdle
│   ├── EngineLoad
│   ├── RoadNoise
│   └── MechanicalNoise
└── BikeStateController
```

---

# 10. MOTORCYCLE PHYSICS MODEL

## 10.1 Objective

The bike should feel believable without simulating every motorcycle dynamic.

Priority order:
1. comfort;
2. predictable steering;
3. sense of speed;
4. visual authenticity;
5. simulation realism.

---

## 10.2 Core State

Suggested runtime variables:

```text
speed_mps
speed_kph
target_speed_mps
steering_input
throttle_input
brake_input
surface_grip
lean_visual_angle
engine_rpm_normalized
is_grounded
is_engine_on
fuel_liters
condition_normalized
```

---

## 10.3 Acceleration Model

Use authored acceleration curves.

Pseudo-behavior:

```text
target_acceleration =
    throttle_curve(speed)
    - drag(speed)
    - braking_force
    - slope_modifier
```

Do not emulate a complete gearbox for MVP unless it noticeably improves the experience.

Automatic transmission abstraction is acceptable.

The visual/audio system can still imply engine rev changes.

---

## 10.4 Speed Limits

Recommended gameplay tuning range:
- walking / maneuver: 0–10 km/h
- town cruising: 20–50 km/h
- open-road cruise: 50–85 km/h
- practical soft maximum: approximately 90–100 km/h

Exact tuning must be playtested.

The game should not encourage sustained top-speed riding.

---

## 10.5 Steering

Steering sensitivity should decrease with speed.

Example conceptual function:

```text
low_speed_steer_strength = high
high_speed_steer_strength = low
```

Add:
- mild steering smoothing;
- self-centering;
- optional riding assist.

---

## 10.6 Lean

Use **visual lean**, not full unstable rigid-body motorcycle balancing.

Lean should derive from:
- speed;
- steering amount;
- turn rate.

Clamp aggressively for comfort.

---

## 10.7 Ground Alignment

Use multiple downward raycasts to estimate road normal.

Smoothly align bike visual to terrain.

Avoid allowing collision geometry to violently rotate the camera.

---

# 11. FIRST-PERSON CAMERA SYSTEM

## 11.1 Camera Goals

Camera must:
- feel embodied;
- retain horizon stability;
- show enough motorcycle detail;
- avoid motion sickness;
- work on touch input.

---

## 11.2 Camera Layers

Suggested rig:

```text
Bike movement transform
    ↓
LeanPivot
    ↓
HeadDampingPivot
    ↓
LookPivot
    ↓
Camera3D
```

Each layer has a distinct responsibility.

---

## 11.3 Camera Effects

Allowed:
- very subtle acceleration pitch;
- slight braking dip;
- low-amplitude road vibration;
- gentle look-ahead into turns;
- optional head glance.

Avoid:
- heavy procedural shake;
- large roll angles;
- artificial sprint-style FOV pulses.

---

## 11.4 FOV

Default target:
**82° horizontal-feel equivalent**, tuned based on Godot's FOV semantics and target aspect ratio.

Settings options:
- lower FOV;
- default;
- higher FOV.

Mobile may use slightly adjusted FOV based on aspect ratio.

---

## 11.5 Reduced Motion Mode

When enabled:
- disable head bob;
- reduce lean camera coupling;
- remove acceleration FOV response;
- reduce cinematic shake.

---

# 12. MIRROR IMPLEMENTATION

Realtime mirrors are expensive on WebGL/mobile.

Recommended hierarchy:

## Tier 1 — Production Default
Stylized or simplified mirror rendering:
- limited update frequency;
- reduced viewport resolution;
- aggressive culling;
- only render nearby road/traffic layers.

## Tier 2 — Low Quality
Static/environment approximation or disabled dynamic mirrors.

## Tier 3 — High Quality
Higher resolution subviewports where platform allows.

Quality setting should control mirror behavior.

Do not let mirrors dominate frame time.

---

# 13. SUZUKI THUNDER 250 MODEL REQUIREMENTS

## 13.1 Reference

Model target:
**Suzuki Thunder 250, year 2000**

The attached reference images should be used as visual inspiration.

---

## 13.2 Modeling Priorities

Highest detail:
1. fuel tank silhouette;
2. round headlamp;
3. cockpit/instrument cluster;
4. handlebars;
5. visible engine profile;
6. front fork;
7. seat silhouette;
8. twin rear shock visual character.

Because the player rides in first-person, cockpit-facing geometry matters more than hidden underside detail.

---

## 13.3 Condition

Bike appearance:
- well maintained;
- clean enough to show care;
- aged;
- subtle wear;
- no major rust;
- no torn seat.

---

## 13.4 LOD

Recommended:
- LOD0: player bike / cinematic;
- LOD1: medium exterior shots;
- LOD2: distant/reflection use.

If one main hero bike is always near the camera, prioritize good geometry budgeting over excessive LOD complexity.

---

# 14. INPUT ARCHITECTURE

All gameplay must use named input actions.

Never write gameplay logic like:

```gdscript
if Input.is_key_pressed(KEY_W):
```

Instead:

```gdscript
var throttle := Input.get_action_strength("accelerate")
```

---

# 15. INPUT MAP

Required actions:

```text
accelerate
brake
steer_left
steer_right
look_left
look_right
look_up
look_down
interact
confirm
cancel
open_phone
open_journal
open_map
pause
photo_mode
skip_cutscene
ui_up
ui_down
ui_left
ui_right
```

Optional:
```text
horn
toggle_headlight
```

Only add flavor actions if they do not overcrowd mobile controls.

---

# 16. PC / WEB CONTROLS

Suggested defaults:

| Action | Keyboard |
|---|---|
| Accelerate | W / Up |
| Brake | S / Down |
| Steer Left | A / Left |
| Steer Right | D / Right |
| Interact | E |
| Phone | Tab |
| Journal | J |
| Map | M |
| Pause | Esc |
| Skip Cutscene | Hold Space or Esc |
| Look | Mouse or optional Q/E glance |
| Photo Mode | P |

Avoid browser-reserved shortcuts.

Test all shortcuts inside itch.io iframe/fullscreen behavior.

---

# 17. MOBILE CONTROLS

## 17.1 Layout

Left:
- steering touch area or virtual stick.

Right:
- accelerate;
- brake;
- context/interact.

Top:
- phone;
- pause.

Optional:
- swipe-look when stationary.

---

## 17.2 Touch Rules

- minimum comfortable touch target size;
- no tiny icons;
- avoid placing important controls under common system gesture zones;
- UI scales based on safe area;
- allow left/right handed layout later if feasible.

---

# 18. INPUT MODE SWITCHING

Desktop builds should detect latest input source.

Example:
- keyboard press → keyboard prompts;
- controller event → gamepad prompts.

Android native always loads touch overlay unless external controller mode is detected and supported.

---

# 19. INTERACTION SYSTEM

## 19.1 Scanner

Use:
- forward raycast or shape cast;
- context candidate interface;
- priority selection.

Interactable contract:

```gdscript
func can_interact(context: InteractionContext) -> bool
func get_interaction_label(context: InteractionContext) -> String
func interact(context: InteractionContext) -> void
```

---

## 19.2 Interaction Contexts

Examples:
- while mounted;
- while stopped;
- dialogue;
- inspect;
- rest;
- refuel;
- scenic stop.

---

# 20. STOP-ZONE SYSTEM

Many narrative interactions occur after stopping.

Use explicit authored stop zones.

A stop zone can:
- request low speed;
- offer contextual interaction;
- transition from bike control to local interaction mode;
- trigger dialogue/cutscene.

This avoids building a completely free-roaming first-person walking simulator unless needed.

---

# 21. ON-FOOT SCOPE

Recommended production scope:

**Limited contextual on-foot mode**, not full open-world walking.

Possible implementation:
- small bounded areas;
- simplified CharacterBody3D;
- used at warung, guesthouse, scenic stop, family home.

This supports human encounters without multiplying world-production cost.

---

# 22. CHAPTER SYSTEM

Each chapter is a separately loadable major scene.

Benefits:
- memory control;
- faster iteration;
- safer web memory footprint;
- clean checkpointing;
- isolated lighting/environment tuning.

---

# 23. CHAPTER DATA RESOURCE

Suggested typed resource:

```gdscript
class_name ChapterDefinition
extends Resource

@export var chapter_id: StringName
@export var display_name: String
@export var start_location: String
@export var end_location: String
@export var theme: String
@export var default_weather_profile: Resource
@export var next_chapter_id: StringName
@export var journal_prompt_id: StringName
```

---

# 24. STORY TRIGGER SYSTEM

Use Area3D trigger volumes with data references.

Trigger types:
- dialogue;
- memory;
- weather shift;
- cutscene;
- phone message;
- music cue;
- checkpoint;
- scenic stop.

Triggers should support:
- fire once;
- fire per save;
- conditional fire;
- cooldown;
- debug reset.

---

# 25. NARRATIVE FLAG SYSTEM

Flags should use structured IDs.

Example:

```text
story.prologue.laid_off = true
story.cirebon.met_warung_owner = true
story.kediri.accepted_interview = false
phone.mom.replied_03 = true
journal.identity.answer = "uncertain"
```

Do not scatter arbitrary booleans across node scripts.

---

# 26. DIALOGUE SYSTEM

## 26.1 Requirements

Must support:
- speaker;
- text;
- choices;
- conditions;
- flag changes;
- optional events;
- pauses;
- portrait-free presentation;
- skip/advance behavior;
- English text.

---

## 26.2 Recommended Data Format

JSON or Godot Resource.

Example:

```json
{
  "id": "ngawi_seno_01",
  "nodes": [
    {
      "id": "start",
      "speaker": "Pak Seno",
      "text": "Long ride?",
      "next": "raka_reply"
    },
    {
      "id": "raka_reply",
      "speaker": "Raka",
      "choices": [
        {
          "text": "Jakarta to Banyuwangi.",
          "next": "seno_response"
        },
        {
          "text": "Long enough.",
          "next": "seno_response_alt"
        }
      ]
    }
  ]
}
```

---

# 27. DIALOGUE PRESENTATION

Default UI:
- bottom dialogue panel;
- speaker name;
- text;
- choice list;
- subtle animation;
- no anime-style portrait requirement.

During cinematic conversations, camera framing carries emotion.

---

# 28. CUTSCENE SYSTEM

## 28.1 Implementation

Use:
- `AnimationPlayer`;
- `AnimationTree` when character animation blending is required;
- authored camera markers;
- scripted shot director;
- dialogue event synchronization.

Do not create every cutscene as a giant one-off script.

---

# 29. CUTSCENE SHOT DATA

Recommended shot resource fields:

```text
shot_id
camera_marker
duration
transition
look_target
fov
dof_enabled
audio_event
dialogue_event
animation_event
skip_policy
```

---

# 30. CUTSCENE DIRECTOR

Responsibilities:
- take player control;
- switch camera;
- run shot timeline;
- dispatch dialogue;
- handle skip;
- restore gameplay state safely.

Skip must:
- land on deterministic final state;
- set all expected narrative flags;
- place actors correctly;
- restore controls.

---

# 31. CUTSCENE CAMERA RULES

Use technical conventions from GDD:
- static wide shots for quiet domestic spaces;
- inserts for emotionally symbolic objects;
- restrained dolly/tracking;
- medium close-ups for personal conversation;
- first-person approach shots when arrival matters;
- never overuse dramatic orbit shots.

---

# 32. PHONE SYSTEM

Phone is a diegetic-but-screen-based UI.

Sections:
- Messages
- Calls
- Email
- Photos
- Route
- Journal shortcut

Architecture:

```text
PhoneDataService
    ↓
PhoneScreenController
    ↓
Individual App Panels
```

Data should not live in UI nodes.

---

# 33. MESSAGE DELIVERY

Messages may be triggered by:
- chapter progression;
- time;
- entering location;
- completing dialogue;
- rest event.

Notification queue:
- supports delayed delivery;
- prevents overlapping banners;
- respects cutscene lock.

---

# 34. JOURNAL SYSTEM

Journal stores:
- authored prompts;
- player's selected reflection;
- chapter timestamp;
- optional internal narration.

Data structure:

```text
journal_entry_id
chapter_id
prompt
selected_option_id
unlocked_at
```

---

# 35. SAVE SYSTEM

## 35.1 Save Slots

Recommended:
- 3 manual slots;
- autosave for active slot.

For MVP:
- 1 active slot is acceptable.

---

## 35.2 Save Contents

Must include:
- schema version;
- current chapter;
- checkpoint;
- narrative flags;
- dialogue states;
- journal choices;
- phone states;
- current bike fuel/condition;
- settings that are save-specific;
- optional photo metadata.

Do not serialize whole node trees.

---

## 35.3 Save Format

Use JSON or Godot ConfigFile with explicit schema.

Example root:

```json
{
  "schema_version": 1,
  "save_id": "slot_01",
  "chapter": "chapter_cirebon",
  "checkpoint": "rest_stop_02",
  "flags": {},
  "bike": {},
  "journal": {},
  "phone": {}
}
```

---

## 35.4 Save Migration

Implement version migration from day one.

Example:
- v1 → v2 transforms renamed flags;
- unknown future fields ignored safely.

---

# 36. WEB SAVE CONSIDERATIONS

Browser saves should use Godot's user storage path.

Important:
- users can clear browser storage;
- private/incognito sessions may not persist;
- test itch.io embedding behavior.

The game should communicate save success clearly.

---

# 37. AUDIO ARCHITECTURE

Audio buses:

```text
Master
├── Music
├── Ambience
├── Vehicle
├── Dialogue
├── UI
└── SFX
```

Settings:
- Master
- Music
- Ambience
- Vehicle
- Dialogue/SFX as needed

---

# 38. BIKE AUDIO SYSTEM

Use layered loops rather than one single engine loop.

Potential layers:
- idle;
- low RPM;
- mid RPM;
- high/load;
- road noise;
- chain/mechanical detail.

Blend using normalized RPM/speed.

Avoid expensive DSP.

---

# 39. AMBIENT AUDIO ZONES

Area-based ambience:
- city;
- roadside;
- rice field;
- rain shelter;
- warung;
- night insects;
- neighborhood home.

Use crossfades.

Do not restart loops abruptly at boundaries.

---

# 40. WEATHER SYSTEM

Weather controller manages:
- rain particles;
- sky;
- light;
- wetness parameter;
- audio;
- fog;
- NPC behavior signals.

Profiles:
- clear;
- cloudy;
- drizzle;
- rain;
- heavy rain;
- mist.

---

# 41. WEB-FRIENDLY WEATHER

Avoid:
- thousands of transparent particles;
- expensive fullscreen wet shaders;
- multiple realtime reflection passes.

Prefer:
- camera-local rain;
- simple material wetness;
- sound;
- fog;
- selective puddle decals.

---

# 42. TIME OF DAY

Use authored lighting states.

Do not require full astronomical simulation.

Possible blending:
- Morning
- Noon
- Afternoon
- Golden Hour
- Evening
- Night

Chapter events can push the state.

---

# 43. TRAFFIC SYSTEM

Traffic supports atmosphere, not driving challenge.

Use:
- pooled vehicles;
- spline/path following;
- simple avoidance;
- distance culling;
- low AI tick rate for distant traffic.

Avoid complex city traffic simulation.

---

# 44. TRAFFIC SPAWNING

Spawn based on:
- road zone;
- density profile;
- time;
- weather;
- performance quality.

Mobile/low:
- reduced density.

Web/Desktop medium:
- moderate density.

---

# 45. NPC SYSTEM

NPC categories:
- ambient;
- interactable;
- story;
- cinematic.

Only story-critical NPCs require high complexity.

Ambient NPCs use:
- simple loops;
- state switching;
- minimal AI.

---

# 46. NPC SCHEDULES

Do not build a full simulation.

Use authored states:
- sitting;
- serving;
- sweeping;
- talking;
- repairing;
- walking short path.

Schedule can depend on time profile.

---

# 47. ANIMATION SYSTEM

Characters:
- idle;
- talk;
- listen;
- gesture;
- walk;
- sit;
- simple interaction.

Raka:
- riding pose;
- mount/dismount if shown;
- standing;
- sitting;
- phone;
- bag handling;
- key/ignition interactions.

---

# 48. ART PIPELINE

Recommended:
1. concept/reference;
2. Blender low-poly model;
3. UV;
4. texture/material;
5. export glTF/GLB;
6. import into Godot;
7. collision proxy;
8. LOD;
9. performance validation.

---

# 49. TEXTURE GUIDELINES

Target:
- stylized;
- compressed;
- mostly 512–2048 depending on hero importance;
- avoid unnecessary 4K textures.

Suggested:
- bike hero atlas: 2K;
- major environment atlas: 1K–2K;
- small props: 256–1024;
- decals/signage: atlas.

Use texture compression compatible with target platforms.

---

# 50. MATERIAL GUIDELINES

Prefer:
- simple StandardMaterial3D;
- limited unique materials;
- texture atlases;
- baked lighting where feasible.

Avoid:
- many transparent materials;
- complex per-object shaders;
- expensive screen reads.

---

# 51. LIGHTING STRATEGY

Because Web uses Compatibility:
- design visuals around lightweight lighting;
- bake or fake where possible;
- limit realtime shadow-casting lights;
- hero sunlight + selective practical lights.

Night warung scenes:
- warm emissive materials;
- one or two important lights;
- baked/static support.

---

# 52. SHADOW BUDGET

Use shadows selectively:
- directional sun;
- hero practical light only when needed.

Disable distant shadows on:
- background props;
- small clutter;
- low-impact NPCs.

---

# 53. ENVIRONMENT STREAMING

Because chapters are segmented, large world streaming is not required initially.

Within a chapter:
- use visibility ranges;
- occlusion where beneficial;
- spawn/despawn distant traffic/NPCs;
- separate heavy interiors.

---

# 54. MEMORY BUDGET PHILOSOPHY

Web memory pressure is a major constraint.

Rules:
- chapter-based asset scope;
- unload previous chapter completely;
- do not preload all game audio;
- stream music/long ambience where appropriate;
- avoid huge uncompressed images;
- reuse environment kits.

---

# 55. PERFORMANCE TARGETS

## Web/Desktop Browser

Target:
- 60 FPS on reasonable desktop/laptop
- 30 FPS minimum fallback

Frame budget:
- 16.7 ms at 60 FPS
- 33.3 ms at 30 FPS

---

## Android

Target tiers:
- Mid-range: stable 30 FPS
- Higher-end: optional 60 FPS mode

Do not promise 60 FPS across all devices.

---

# 56. QUALITY SETTINGS

Profiles:

## Low
- low traffic;
- low shadow distance;
- low mirror quality;
- low vegetation density;
- reduced particles.

## Medium
- default browser/mobile target.

## High
- improved shadows;
- more environment density;
- better mirrors where practical.

---

# 57. DYNAMIC RESOLUTION / SCALING

If needed:
- provide render scale option;
- default lower scale on weaker mobile devices.

UI remains full resolution.

---

# 58. WEB EXPORT REQUIREMENTS

Use:
- Compatibility renderer;
- single-threaded Web export unless a strong reason exists otherwise;
- `index.html` as export page;
- custom HTML shell only when needed.

Test:
- Chrome;
- Edge;
- Firefox;
- itch.io embed;
- itch.io fullscreen.

WebGL 2.0 support is required.

---

# 59. ITCH.IO PACKAGING

Recommended export folder:

```text
build/web/
  index.html
  index.js
  index.wasm
  index.pck
  ...
```

Zip contents so `index.html` is at archive root.

Test:
- compressed upload;
- browser launch;
- fullscreen;
- keyboard focus;
- sound unlock after user gesture;
- save persistence.

---

# 60. ANDROID EXPORT REQUIREMENTS

Use:
- native Android export;
- Gradle build when preparing Google Play release;
- AAB for Play Store release;
- release keystore kept outside repository.

Development:
- debug APK for device tests.

---

# 61. ANDROID ORIENTATION

Recommended:
**Landscape only**

Reason:
- riding field of view;
- touch control ergonomics;
- cinematic framing.

Lock orientation unless design later proves portrait support necessary.

---

# 62. ANDROID SAFE AREA

UI must support:
- notches;
- rounded corners;
- navigation gesture regions;
- different aspect ratios.

Use responsive anchors/containers.

---

# 63. MOBILE THERMAL & BATTERY STRATEGY

Avoid:
- unrestricted FPS;
- excessive particles;
- realtime mirrors at full resolution;
- heavy overdraw.

Provide:
- 30 FPS mode;
- reduced quality option.

---

# 64. MAIN MENU ARCHITECTURE

Required:
- Continue
- New Game
- Settings
- Credits

If no save:
- Continue disabled.

Settings categories:
- Video
- Audio
- Controls
- Accessibility

---

# 65. SETTINGS PERSISTENCE

Separate **user settings** from **game save**.

Settings file:
- volume;
- graphics preset;
- FOV;
- reduced motion;
- input preferences;
- UI scale.

Do not reset these when starting a new game.

---

# 66. LOCALIZATION ARCHITECTURE

Even though v1 is English-only, all player-facing text should still use localization keys where reasonable.

Example:

```text
ui.main_menu.continue
ui.main_menu.new_game
dialogue.prologue.mom_001
journal.chapter_03.prompt
```

Reason:
- consistency;
- future localization;
- prevents hard-coded text.

English is the only required shipped language.

---

# 67. FONT STRATEGY

Use:
- one UI sans-serif;
- optional secondary handwritten/journal font.

Requirements:
- readable on mobile;
- legal for commercial use;
- embedded appropriately;
- avoid tiny weights.

---

# 68. LOADING SYSTEM

Between chapters:
1. fade out;
2. show chapter transition;
3. unload current;
4. load next asynchronously if practical;
5. warm important shaders/resources;
6. fade in.

Avoid long black hangs.

---

# 69. CHECKPOINTS

Suggested checkpoint locations:
- chapter start;
- major story encounter complete;
- rest location;
- chapter end.

Never save during unstable cutscene state unless snapshot behavior is explicit.

---

# 70. ERROR HANDLING

Player-facing:
- save failure message;
- corrupted save fallback;
- load fallback to previous checkpoint if possible.

Developer:
- `push_error()` with system prefix;
- validation warnings for missing IDs.

---

# 71. DEBUG TOOLING

Create a developer debug overlay.

Recommended commands:
- jump chapter;
- teleport checkpoint;
- set weather;
- set time;
- grant message;
- set flag;
- reset flag;
- fuel full;
- toggle collision visualization;
- FPS/memory display;
- force low quality;
- start cutscene.

Disable in release builds.

---

# 72. CONTENT VALIDATION TOOL

Build an editor/debug validator that checks:
- duplicate dialogue IDs;
- missing localization keys;
- missing next node;
- missing chapter references;
- missing cutscene camera markers;
- unknown story flags;
- nonexistent audio event IDs.

This is especially important for AI-assisted content creation.

---

# 73. AI IMPLEMENTATION CONTRACT

AI-generated code must obey:

1. Do not change engine or renderer.
2. Do not introduce C#.
3. Do not hard-code keyboard keys into gameplay.
4. Do not create new global managers without justification.
5. Do not silently change narrative canon.
6. Do not rename public data IDs without migration.
7. Do not add dependencies without documenting them.
8. Do not add network/multiplayer systems.
9. Do not add combat.
10. Do not convert bike handling into hardcore simulation.
11. Preserve Web and Android compatibility.
12. Run or provide tests for nontrivial systems.
13. Keep public methods typed.
14. Document exported properties.
15. Avoid 1,000-line monolithic scripts.

---

# 74. AI TASK INPUT TEMPLATE

Every AI coding task should contain:

```text
TASK:
SYSTEM:
RELATED GDD SECTION:
RELATED TDD SECTION:
FILES ALLOWED TO CHANGE:
FILES NOT ALLOWED TO CHANGE:
ACCEPTANCE CRITERIA:
PLATFORM TESTS:
PERFORMANCE CONSTRAINTS:
SAVE COMPATIBILITY:
```

---

# 75. DEFINITION OF DONE FOR CODE TASKS

A code task is done only when:
- feature works in editor;
- no new parser/runtime errors;
- keyboard path works if applicable;
- touch path works if applicable;
- no obvious Web-incompatible API is introduced;
- state restores correctly after scene reload;
- acceptance criteria are demonstrated;
- new configuration/data is documented.

---

# 76. TEST STRATEGY

Four levels:

## Unit
Pure logic:
- save migration;
- dialogue conditions;
- speed curve utilities;
- flag evaluation.

## Integration
Godot scenes:
- bike input;
- cutscene handoff;
- phone message trigger;
- chapter transition.

## Platform
- browser;
- Android physical device.

## Playtest
- comfort;
- narrative pacing;
- control feel.

---

# 77. MOTORCYCLE TEST CASES

Minimum:
- accelerate from stop;
- brake to stop;
- steering at low speed;
- steering at cruise;
- steep-ish road segment;
- collision recovery;
- stop zone;
- pause/unpause;
- touch accelerate/brake;
- low FPS behavior;
- scene reload state.

---

# 78. CAMERA COMFORT TESTS

Test:
- 15-minute ride;
- continuous turns;
- road bumps;
- rain;
- 30 FPS;
- phone opening/closing;
- cutscene transitions.

Collect player feedback:
- nausea;
- dizziness;
- camera overreaction;
- FOV comfort.

---

# 79. SAVE TESTS

Test:
- fresh save;
- autosave;
- manual restart;
- browser reload;
- Android app kill/relaunch;
- version migration;
- corrupted file;
- cutscene skipped before save;
- chapter transition.

---

# 80. PERFORMANCE PROFILING

Use Godot profiler and platform tools.

Record:
- frame time;
- physics time;
- draw calls;
- object count;
- texture memory;
- audio streams;
- GC-like allocation spikes from script patterns.

Profile actual exports, not editor only.

---

# 81. ASSET BUDGET GUIDELINES

These are targets, not absolute laws.

Hero motorcycle:
- optimized enough for continuous close view;
- approximately tens of thousands of triangles rather than hundreds of thousands.

NPCs:
- moderate low-poly;
- shared skeleton where possible.

Background props:
- aggressively simpler;
- atlas materials.

Vegetation:
- low-poly cards/meshes;
- avoid expensive transparency density.

---

# 82. WEB DOWNLOAD SIZE GOAL

Keep initial playable build as small as practical.

Recommended production target:
- vertical slice: preferably under ~200 MB compressed;
- full game: aggressively optimize and evaluate chapter asset delivery strategy.

Exact final target depends on audio and environment scope.

---

# 83. AUDIO COMPRESSION

Long music/ambient:
- streamed compressed audio.

Short SFX:
- imported for low-latency use.

Avoid uncompressed long WAV files in final export unless necessary.

---

# 84. PHOTO MODE TECHNICAL NOTE

Photo mode is optional for MVP.

If implemented:
- freeze gameplay;
- allow limited free camera;
- hide UI;
- platform-aware screenshot support.

Browser/mobile screenshot/storage behavior must be tested before promising persistent export.

---

# 85. ACHIEVEMENT SYSTEM

MVP:
- internal achievement tracking only or omit.

Post-MVP:
- itch.io has no standardized native achievement API comparable to major stores;
- Android Play Games integration would add platform complexity.

Therefore achievements should not be required for core progression.

---

# 86. CRASH-SAFE STATE DESIGN

Critical state changes should be committed at:
- checkpoint;
- chapter completion;
- important narrative choice.

Avoid relying only on end-of-session save.

---

# 87. VERSION CONTROL

Use Git.

Branches:
- `main`
- `develop`
- `feature/...`
- `fix/...`

Small team can simplify, but `main` should remain releaseable.

Use Git LFS for:
- large audio;
- large source art;
- heavy binaries if needed.

Do not commit:
- export builds;
- Android keystore;
- local editor caches;
- secret signing credentials.

---

# 88. CI/CD RECOMMENDATION

Recommended pipeline:

On pull request:
- GDScript/static validation where available;
- content validation;
- headless project parse;
- unit tests.

On tagged release:
- Web export;
- Android release candidate export;
- artifact checksum.

Manual approval before store upload.

---

# 89. SECURITY / SECRETS

Never commit:
- Play Store service credentials;
- signing keystore;
- passwords;
- API keys.

Use environment secrets in CI.

The game should not require server-side personal-data collection.

---

# 90. PRIVACY

Target architecture is offline-first.

No account required.

No analytics required for MVP.

If analytics are later added:
- disclose clearly;
- minimize collection;
- do not block gameplay if declined where applicable.

---

# 91. NETWORKING

No networking is required.

Do not introduce multiplayer/backend complexity.

Optional future services should be isolated.

---

# 92. PLATFORM FEATURE MATRIX

| Feature | Web | Android |
|---|---:|---:|
| Keyboard | Yes | Optional external |
| Touch controls | Not required | Yes |
| Controller | Optional | Optional |
| Local save | Yes | Yes |
| Fullscreen | Yes | Yes |
| Compatibility renderer | Yes | Yes |
| GDScript | Yes | Yes |
| First-person ride | Yes | Yes |
| Dynamic mirrors | Quality-dependent | Quality-dependent |

---

# 93. VERTICAL SLICE TECHNICAL SCOPE

Must prove:
- boot/menu;
- settings;
- first-person bike;
- keyboard;
- mobile touch;
- one complete environment route;
- one rain event;
- one stop zone;
- one dialogue;
- one cutscene;
- phone notification;
- journal entry;
- save/reload;
- Web export;
- Android export.

---

# 94. VERTICAL SLICE ACCEPTANCE CRITERIA

The slice is accepted when:
- player can launch in browser;
- ride comfortably for 10+ minutes;
- stop and interact;
- dialogue works;
- cutscene can play and skip safely;
- game saves at rest stop;
- page reload restores state;
- Android touch controls complete the same loop;
- mid-range Android can sustain target minimum;
- bike visually reads as the intended Thunder 250-era model;
- all player text is English.

---

# 95. PRODUCTION RISKS

## Web Performance
Mitigation:
- Compatibility renderer from day one;
- browser profiling every milestone.

## Mobile Heat
Mitigation:
- 30 FPS option;
- low quality;
- reduced mirror cost.

## Scope Creep
Mitigation:
- chapter modularity;
- strict content budgets.

## Narrative Content Explosion
Mitigation:
- one primary encounter per chapter;
- optional encounters capped.

## AI Code Drift
Mitigation:
- locked architecture;
- acceptance criteria;
- code review;
- content validator.

---

# 96. TECHNICAL NON-GOALS

Do not build:
- seamless 1:1 Java island;
- full traffic simulation;
- realistic motorcycle drivetrain simulator;
- multiplayer;
- procedural story generator;
- combat AI;
- complex inventory;
- crafting;
- economy;
- character leveling.

---

# 97. RELEASE ENGINEERING CHECKLIST

Before release candidate:
- lock Godot version;
- regenerate export templates;
- verify Web export;
- verify Android AAB;
- verify signing;
- verify English strings;
- verify credits/licenses;
- test clean install;
- test save migration;
- test no-dev-overlay build;
- profile representative chapters.

---

# 98. TECHNICAL REFERENCE NOTES

At the time this TDD was authored:
- Godot 4.7.2 is the current stable release baseline.
- Godot 4 Web export targets WebGL 2.0 through the Compatibility renderer.
- Single-threaded Web export is the preferred/default approach for broad hosting compatibility.
- Godot 4 C# remains unsuitable for this project's required Web target; therefore GDScript is the project language.
- Google Play distribution requires an Android App Bundle (AAB), produced through the Android/Gradle release workflow.

Always re-check official Godot and Google Play documentation before the final production release because platform requirements may change.

---

# 99. FINAL TECHNICAL RULE

> **Every system must be judged against three simultaneous requirements: does it preserve the intended emotional experience, does it run reliably in a browser, and can it remain comfortable on a mid-range Android device?**
