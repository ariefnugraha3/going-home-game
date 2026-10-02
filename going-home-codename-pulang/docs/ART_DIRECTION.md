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

Launch `tools/ArtReview.tscn` in Godot with F6 to capture nine native views under `tests/screenshots/`: six `cozy_*.png` views (warung, motorcycle, riding environment, home, character and room), plus `hero_laptop`, `hero_id_card` and `hero_nadia`. The scene does not load or save the journey; its quality settings are temporary in memory. It exits after rendering the gallery. Use F5 for the normal game.

The image files are ignored local artifacts. Reproduce them after art changes instead of treating old screenshots as current. `tools/test.ps1 -Suite CampaignStaging -Visual -FixedFps 30` additionally captures every region and story staging; Cinematic checks the opening performances, and RoadRender measures native draw calls and resource disposal.

This pass changes the common art language; it does not claim that all artist/narrative/audio acceptance gates in the original roadmap have been signed off. No external models, texture packs or generated images were introduced.

## Character and close-up revision · 2026-10-02

- Nadia (called Nadi in the user's correction) is a woman. The existing story name and localization keys stay intact; the opening now selects a female model with a shaped jaw, bob hairstyle and tailored blouse. The mother also uses the female variant. Roadside figures share the new character forms instead of retaining the old ball heads and box legs.
- `CharacterForms` adds shaped jaw/cheek/temple surfaces, attached facial features, tapered upper/lower limbs, joint coverage, palms, fingers, thumbs, and shoes with soles and laces. Art remains stylized low-poly, rather than claiming a photoreal human rig.
- Reaching solves a two-bone chain with a single elbow hinge and bounded flexion; full joint bases reset before authored poses to avoid residual scale after IK and Skip. Walking stance cancels root movement, swing lifts the foot and knees bend forward with level soles. Neutral start/end poses remain deterministic.
- The motorcycle has a narrower rounded tank, shaped saddle, 36 crossed thin spokes per wheel, front disc/caliper, separate engine crankcase/barrel/cooling fins/rocker cover, fork sliders, chain/guard, bent handlebars, connected ignition housing, and headlamp lens detail. Wheels are locally batched while remaining independently animated. The GDD's Thunder 250 silhouette remains the target; this is an original stylized model, not a dimensional manufacturer replica. The [period Thunder reference](https://otomotifnet.gridoto.com/read/231160754/evolusi-suzuki-thunder-250-sejak-1999-2005-beda-di-baut) supplements the GDD; no reference imagery is bundled as an asset.
- Laptop keys, keyboard recess, trackpad, ports, hinge barrels, screen/bezel, webcam and lid emblem move with their respective parts. The thin base/lid stack clears both keycaps and the closed bag flap; tests inspect every rendered laptop mesh above the raincoat trim. Kediri reuses the same detailed laptop. The ID card has a holder, photo, print, barcode, metal clip and a continuous strap routed away from the mug. Cups now have handles and a visible drink surface.
- The helmet is an open-front shell with an inner surface, a raised brow opening and a lower rear rim. Hair visibility follows retrieval/donning so it cannot protrude through the worn crown. Bare feet have shaped insteps and toes. Helmet framing/seat/luggage checks use all eight actual mesh-bounds corners, replacing the former unit-sphere assumptions.
- Homecoming foot placement accounts for the raised foundation and both porch steps, including the mother's starting position and the family entrance. This corrects feet previously hidden inside the decorative step meshes.
- Static baking now copies visible mesh children before freeing originals and excludes hidden alternate limbs/helmets. Art review remains required for performances and untested contact pairs; sampled contact tests are not a guarantee that no mesh can ever intersect in any frame.
