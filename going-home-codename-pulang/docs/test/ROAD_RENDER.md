# Road rendering comparison and review

## Implemented scope

`RoadMarkings.build()` groups center/edge paint boxes into 96-meter road chunks. Story uses 468 instances in 42 MultiMeshInstance3D nodes; practice uses 90 instances in eight. Each marking type shares its BoxMesh/material across chunks. Original transforms, sizes and colors are retained; no physics shapes are created for paint. Road surfaces, shoulder geometry, collisions, traffic and route sampling are unchanged.

Visibility is now per chunk, with the previous range plus 96 meters (story 316 m; practice 276 m) to conservatively retain marks near the original cutoff. More distant paint may remain visible beyond its old individual cutoff. This trades a few extra small instances for fewer draw calls while avoiding one batch spanning the whole route. New routes with significantly different lateral geometry should recheck chunk extents and culling margins.

## Native before/after measurement · 2026-09-28

Godot 4.7.2.stable.official.ed1daf0bf, Compatibility, Windows / NVIDIA RTX 3050 Laptop GPU, 1280x720, native 30 FPS cap. Measurements use direct story/practice worlds, a 70-degree camera at rider height in the left lane, a -0.14-radian pitch, authored route heading, Morning, fixed traffic positions and explicit Low/Medium quality. HUD and motorcycle are omitted from these probes. The global RenderingServer draw-call counter is sampled after a rendered frame. These counts are not frame-time, FPS or mobile thermal claims.

| World | Quality | Route distance | Before | After | Reduction |
| --- | --- | ---: | ---: | ---: | ---: |
| Story | Low | 20 m | 729 | 680 | 6.7% |
| Story | Low | 650 m | 549 | 502 | 8.6% |
| Story | Low | 1100 m | 440 | 392 | 10.9% |
| Story | Medium | 20 m | 1094 | 994 | 9.1% |
| Story | Medium | 650 m | 827 | 736 | 11.0% |
| Story | Medium | 1100 m | 860 | 758 | 11.9% |
| Practice | Low | 20 m | 89 | 70 | 21.3% |
| Practice | Low | 260 m | 82 | 64 | 22.0% |
| Practice | Low | 650 m | 33 | 27 | 18.2% |
| Practice | Medium | 20 m | 169 | 130 | 23.1% |
| Practice | Medium | 260 m | 187 | 139 | 25.7% |
| Practice | Medium | 650 m | 131 | 105 | 19.8% |

The before measurement used the original individual MeshInstance3D markings. The optimized measurement repeated the same probes and produced the listed counts in two native runs. Numbers depend on engine/backend/device and are not hardcoded acceptance thresholds. Quality is explicitly applied before sampling, so a pending `_process` update cannot contaminate the comparison.

## Reproduce and verify

Run `powershell -ExecutionPolicy Bypass -File tools/test.ps1 -Suite RoadRender -Visual -FixedFps 30`. The native run writes `user://road_render.json` inside the helper's isolated `.godot-test` profile and captures `tests/screenshots/road_render_*.png`. Logs `.godot-test/road-render-before.log` and `RoadRenderTests-native30.log` contain the recorded comparison; baseline captures are in `.godot-test/road-before/`. These local outputs are ignored by Git; the table above preserves the results in source control.

The suite verifies every original transform exactly once, shared mesh dimensions, batch/instance counts, visibility margin, no added paint collision, quality application and unchanged checkpoint bytes. It frees both measured worlds plus four alternating extra worlds; node counts return to baseline and weak references to MultiMesh/BoxMesh resources expire. Native lifecycle probes render a new world before disposal and wait for a post-disposal frame. This checks these scene resources, not OS working-set/driver memory or a long session's complete transition graph. Headless runs omit rendering counters, screenshots, transform-buffer comparisons and per-instance culling-extents checks: this engine's Dummy rendering backend returns identity transforms when queried. Those four checks are native-only and passed there; headless still validates instance counts, mesh dimensions/sharing, node counts and resource disposal.

- [ ] Review moving-camera transitions at chunk/visibility boundaries, slopes, bends and every stop in real Web and Android exports.
- [ ] Measure actual frame time, load time, GPU/CPU memory and thermals on target devices with HUD, motorcycle, weather and gameplay active.
- [ ] Run long repeated scene transitions and background/resume with platform memory tools before declaring the memory gate passed.
- [ ] Profile other repeat geometry (poles, vegetation, field rows) before deciding whether further batching is worth its culling tradeoff.
