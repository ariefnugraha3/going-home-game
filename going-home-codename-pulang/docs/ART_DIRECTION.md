# Warm low-poly art pass

The shared 3D kit now uses sculpted faceted forms, chamfered furniture/props and a warm cream, terracotta, sage and teal palette. The changes are in the playable project, including the opening, practice track and campaign; these are not concept images pasted over gameplay.

## Asset families

- **Buildings:** full gable infills, thicker tiled roof planes and ridges, fascia, framed windows, shutters, sills, door panels, porch steps and terracotta planters. Urban buildings have separate shopfronts, upper windows, cornices and awnings. Regional shops and warehouses have rooflines and facade trim.
- **Landscape:** clustered faceted tree crowns with branching trunks and varied heights; curved segmented palms with individual fronds; bounded roadside shrub/stone groups; layered distant hills. Continuous shoulder ribbons replace the overlapping slabs visible on bends.
- **Motorcycle:** fuller teal tank, side covers and mounted badges, chrome response, stitched seat, indicators, crankcase and plate, retaining the round headlight, upright bars, analog instruments, spokes, twin springs and intact luggage.
- **Characters:** tapered torsos, fuller faceted heads, sculpted hair, collars, buttons, shirt pockets and restrained eyes/nose. The existing articulated skeleton, director clock and hand-contact targets remain in use.
- **Interior and stops:** floor joints, skirting, curtains, window reveals, a framed geometric landscape, rug, bookshelf, plants, layered bed/linen and supported chairs. Shelters gain timber framing, counter jars, pendants and planters. Fuel pumps have a separate display/housing and hose. Cars have a shaped cabin, window pillars, mirrors, lights, bumpers and wheel hubs.
- **Light:** revised Morning/Golden hour profiles, lighter shadow opacity and soft shadow filtering, with neutral fill to retain readable greens and warm highlights. Rain/night presets retain their story mood.

## Implementation

`CozyForms` builds chamfered boxes, flat-normal subdivided icosahedra and tapered ring forms. `LowPoly` remains the common construction API, so small props across older scenes inherit the new treatment. Thin surface/contact pieces and large ground planes keep their original rectangular extents.

`LowPoly.bake()` combines static geometry by material and preserves transform, normal and vertex-color data. Missing vertex colors are explicitly white, preventing native primitives turning black when merged with colored custom meshes. Houses, trees, roadside groups and room dressing are batched locally; articulated actors, vehicle instruments and animated props are not baked. Resources remain scene-owned rather than accumulating in a global geometry cache.

`CozyDressing` provides room, shelter, car and urban-building details. Cinematic props keep their authored locations; the new bookshelf is outside the bed footprint, homecoming standing actors no longer intersect a bench, and the open-door overlay remains in front of the new door panels.

## Native review

`tools/CarReview.tscn` (F6) captures the production hatchback and wagon from front/rear three-quarter and orthographic side views, plus one in-road view. Seven `car_*.png` images are written under `tests/screenshots/`. It exits after capture without saving the journey. Use F5 for normal play.

`tools/BikeReview.tscn` (F6) renders the production motorcycle from orthographic side/front, perspective front/rear and seated-rider views. It writes `bike_side`, `bike_front`, `bike_three_quarter`, `bike_rear` and `bike_rider` PNGs under the same ignored screenshot folder and exits without touching the journey. Use these neutral views to assess the entire silhouette before judging environment lighting.

Four additional close-ups show `bike_right_controls`, `bike_left_controls`, `bike_right_boot` and `bike_left_boot`: review the brake/gear lever assembly both uncovered and with the seated rider's shoes.

Launch `tools/ArtReview.tscn` in Godot with F6 to capture nine native views under `tests/screenshots/`: six `cozy_*.png` views (warung, motorcycle, riding environment, home, character and room), plus `hero_laptop`, `hero_id_card` and `hero_nadia`. The scene does not load or save the journey; its quality settings are temporary in memory. It exits after rendering the gallery. Use F5 for the normal game.

The image files are ignored local artifacts. Reproduce them after art changes instead of treating old screenshots as current. `tools/test.ps1 -Suite CampaignStaging -Visual -FixedFps 30` additionally captures every region and story staging; Cinematic checks the opening performances, and RoadRender measures native draw calls and resource disposal.

This pass changes the common art language; it does not claim that all artist/narrative/audio acceptance gates in the original roadmap have been signed off. No external models, texture packs or generated images were introduced.

## Traffic car revision · 2026-10-02

- `TrafficCar` replaces the stacked-box traffic model through the existing `CozyDressing.vehicle` factory. Two original compact/family silhouettes share ochre, sage, muted blue and clay paint, sloped glazing and softly crowned hood/roof surfaces. Body length is 3.63/3.87 m, wheelbase 2.18/2.34 m and tire diameter .64 m.
- Body shoulders taper toward the front and rear. Actual semicircular openings, recessed wheel-house liners and thin painted arch lips clear the tires. Matched hood/end-cap vertices and cabin skirts close visible seams. Six-spoke rims, rounded bumpers, grille slats, indicators, tail/reverse lights, door handles, mirrors, wipers and number plates add detail at road-view scale.
- Four wheel pivots rotate from traffic travel distance. Static body and individual wheels are batched separately; scene-owned meshes release with the road. Existing traffic count, path, quality visibility and decorative behavior remain in use. No external car assets or textures are required.

## Character and close-up revision · 2026-10-02

- Nadia (called Nadi in the user's correction) is a woman. The existing story name and localization keys stay intact; the opening now selects a female model with a shaped jaw, bob hairstyle and tailored blouse. The mother also uses the female variant. Roadside figures share the new character forms instead of retaining the old ball heads and box legs.
- `CharacterForms` adds shaped jaw/cheek/temple surfaces, attached facial features, tapered upper/lower limbs, joint coverage, palms, fingers, thumbs, and shoes with soles and laces. Art remains stylized low-poly, rather than claiming a photoreal human rig.
- Reaching solves a two-bone chain with a single elbow hinge and bounded flexion; full joint bases reset before authored poses to avoid residual scale after IK and Skip. Walking stance cancels root movement, swing lifts the foot and knees bend forward with level soles. Neutral start/end poses remain deterministic.
- The motorcycle has a narrower rounded tank, shaped saddle, 36 crossed thin spokes per wheel, front disc/caliper, separate engine crankcase/barrel/cooling fins/rocker cover, fork sliders, chain/guard, bent handlebars, connected ignition housing, and headlamp lens detail. Wheels are locally batched while remaining independently animated. The GDD's Thunder 250 silhouette remains the target; this is an original stylized model, not a dimensional manufacturer replica. The [period Thunder reference](https://otomotifnet.gridoto.com/read/231160754/evolusi-suzuki-thunder-250-sejak-1999-2005-beda-di-baut) supplements the GDD; no reference imagery is bundled as an asset.
- Laptop keys, keyboard recess, trackpad, ports, hinge barrels, screen/bezel, webcam and lid emblem move with their respective parts. The thin base/lid stack clears both keycaps and the closed bag flap; tests inspect every rendered laptop mesh above the raincoat trim. Kediri reuses the same detailed laptop. The ID card has a holder, photo, print, barcode, metal clip and a continuous strap routed away from the mug. Cups now have handles and a visible drink surface.
- The helmet is an open-front shell with an inner surface, a raised brow opening and a lower rear rim. Hair visibility follows retrieval/donning so it cannot protrude through the worn crown. Bare feet have shaped insteps and toes. Helmet framing/seat/luggage checks use all eight actual mesh-bounds corners, replacing the former unit-sphere assumptions.
- Homecoming foot placement accounts for the raised foundation and both porch steps, including the mother's starting position and the family entrance. This corrects feet previously hidden inside the decorative step meshes.
- Static baking now copies visible mesh children before freeing originals and excludes hidden alternate limbs/helmets. Art review remains required for performances and untested contact pairs; sampled contact tests are not a guarantee that no mesh can ever intersect in any frame.

## Motorcycle proportion revision · 2026-10-02

Rebuilt the component layout after the oversized tank, lamp, instruments and controls made the earlier model read as disconnected primitives. The [Thunder side-view reference](https://www.autofun.co.id/berita-motor/harga-bekas-makin-terjangkau-suzuki-thunder-250-bisa-jadi-alternatif-tiger-dan-scorpio-47147) informed the visual balance; the dimensions below are authored game proportions, not manufacturer specifications. No reference image is bundled.

| Component | Previous | Revised (model metres) |
| --- | --- | --- |
| Wheelbase / tire diameter | 1.54 / .68 | 1.42 / .63 |
| Tank width / length | .64 / .91 | .46 / .70 |
| Headlamp diameter | .34 | .216 |
| Distance between hand contacts | 1.02 | .76 |
| Mirror outer span | 1.45 | .955 |
| Twin instrument span | .58 | .307 |

The saddle now has a narrow nose and longitudinal sections with a raised passenger end; the rear bodywork supports the lamp and mudguard. Crowned fenders follow the tire, sliders fit the stanchions, and smaller engine fins, crankcase, shocks, bent headers and silencer retain space within the frame. Indicator brackets, ignition support and footpegs connect to the assembly. Existing teal, warm metal and charcoal materials remain.

Shared handlebar/ignition anchors drive Raka, the memory father and the homecoming contacts. The headlight emitter follows the lamp; wheel rotation uses the new tire radius. The cloth stroke follows the resized tank, the helmet check raycasts the actual saddle triangles, and mounted sole bounds meet the rendered footpegs. The cockpit keeps the existing camera and calibrated instrument behavior.

## Motorcycle curved bodywork revision · 2026-10-02

`BikeForms` adds scene-owned spline cross-sections, rounded plates, turned housings and continuous swept tubes. The tank has broad shoulders, a restrained upper crown and a narrowing rear knee recess. The saddle gains a cushioned crown and rounded nose/tail, side panels have soft teardrop contours, and the rear shell curves into the seat. Engine fins and the rocker cover have radiused corners; crankcase covers, the headlight shell and gauge housings have rounded shoulders. Indicators and mirrors use modest-resolution curved shells. Headers, handlebars, upholstery seams and the grab rail follow continuous curves rather than a chain of visibly mitered cylinders. The muffler tapers into its end rim.

Shared vertex normals soften broad surfaces without changing the low-poly palette, wheelbase, grip anchors or seat contact height. The tail lens and mesh end caps were inspected from the rear to catch missing faces and bodywork intersections. Existing five-view BikeReview renders show the new silhouettes with the same camera and light for comparison.

Both tank-wiping performances now intersect the actual tank triangles, with barycentrically interpolated surface normals so the cloth turns smoothly across triangle edges. The cinematic contact assertion checks the mesh itself instead of the old ellipsoid equation. Contact-face data is cached on each tank node and released with that scene.

## Footrest and pedal revision · 2026-10-02

The rider pegs sit on short frame brackets with hinge pins, mounting bolts, rounded rubber pads and tread ribs. Their support surface is .305 m above the road, replacing the former .18 m surface on long diagonal stalks. The new shared ankle targets place the boots on these pads and bend the knees naturally behind the engine.

With the bike facing local -Z, the right (+X) side has a frame-pivoted curved rear-brake lever, a broad serrated toe pad and a rod to the rear drum brake arm. The left (-X) side has a selector shaft at the gearbox, a short curved gear lever and a transverse ribbed rubber toe peg. The resting right toe clears the brake pad vertically; the left toe clears the shift peg longitudinally. Both are checked against actual shoe/sole and pedal mesh bounds. These are model and rider-pose changes; the game's existing automatic transmission and input behavior remain.
