# The Witch of Mapleton — Progress & Handoff

> Living status doc. Read this first when starting a new session.
> Last updated: 2026-06-16.

## Status

**Vertical Slice 0.1 — "First Potion Sale" is complete and playable.** All 14 systems
from the implementation order are built (player movement → camera → collision →
interaction → scene transition → item db → inventory → gathering → crafting → shop
sale → dialogue → cat companion → save/load → day cycle). Real character art is in
for Marigold and the cat (Saffron); most props/tiles are still coloured-rectangle
placeholders.

Engine: **Godot 4.1.3** at `/Applications/Godot.app`. Main scene: `scenes/world/ShopInterior.tscn`.

## How to run & verify

```bash
# Headless import (run after adding/renaming art or on a fresh checkout)
/Applications/Godot.app/Contents/MacOS/Godot --headless --editor --quit

# Headless load/parse check (should print no ERROR lines; warnings are treated as errors)
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --quit

# Play the game
/Applications/Godot.app/Contents/MacOS/Godot --path .
```

## The playable loop

Start in the shop → go through the top door to the forest → gather Moonleaf (×2) and
Forest Water (×1) → return → craft Calming Tea at the cauldron → talk to the Customer
(they buy it for 18 gold, shown in the HUD) → sleep in the bed → day advances, game
saves, gatherables refill. Save auto-loads on next launch.

## Architecture

**Autoload singletons** (order matters — defined in `project.godot`):
`ItemDatabase`, `Inventory`, `RecipeDatabase`, `CraftingSystem`, `ShopRequestDatabase`,
`ShopSystem`, `DialogueBox` (UI scene), `DaySystem`, `HUD` (UI scene), `SaveSystem` (last,
so it loads after the systems it writes into). `Inventory` holds items **and** gold and
persists across scene changes. `DaySystem` holds the day + per-gatherable depletion state.

**Interaction pattern:** `scripts/core/Interactable.gd` (Area2D, has `interact()`,
`show_prompt()`, optional inline `dialogue`). Subclasses: `Door`, `Gatherable`,
`CraftingStation`, `Bed`, and `scripts/npc/CustomerNPC.gd`. The player
(`scripts/player/PlayerController.gd`) detects nearby interactables via an Area2D and
calls `interact()` on the nearest; movement/interaction freeze while a dialogue is open.

**Data-driven content** (JSON loaders validate on load): `data/items.json`,
`data/recipes.json`, `data/shop_requests.json` (customer request + inline dialogue lines).

**Scenes:** `scenes/world/{ShopInterior,ForestClearing}.tscn` (Y-sort enabled),
reusable `scenes/world/{Door,Gatherable}.tscn`, `scenes/npc/Cat.tscn`,
`scenes/player/Player.tscn`, `scenes/ui/{DialogueBox,HUD}.tscn`.

## Art pipeline & conventions (IMPORTANT — learned the hard way)

PixelLab exports a folder per character: `animations/<long-name>/<dir>/frame_NNN.png`
(8 directions × ~9 walk frames) plus `rotations/<dir>.png` (8 idle poses). A Python
generator turns these into a `SpriteFrames` `.tres` with `walk_<dir>` / `idle_<dir>`
animations. Generators live in `tools/` (`build_marigold_spriteframes.py`,
`build_saffron_spriteframes.py`) — run them to regenerate a `.tres` after re-export.

Rules:
1. **Never overwrite/resample source art in place.** Baking a downscale into the PNGs
   (e.g. LANCZOS) blurs pixel art permanently. Instead, keep high-res frames and let
   Godot scale them at *display* time with the Nearest filter (crisp).
   - **Marigold:** 180px frames, `AnimatedSprite2D` `scale = 0.63`, offset `(0,-28)`.
   - **Saffron (cat):** 68px frames authored ~native, `scale = 1.0`, offset `(0,-17)`.
   - Rule of thumb: native-size art → scale 1.0; high-res art → display scale, never bake.
2. **Direction mapping lives in the `.tres`/generator, not in guesswork.** The generator
   maps each `walk_<dir>` animation to a source folder. Marigold currently uses the
   **identity** mapping (folder name = direction) because the art folders are correctly
   organised. If a character faces the wrong way, fix the folder→animation mapping in its
   generator — **trust the in-game observation over reading the frames.** (We lost time
   applying a wrong "mirror" remap; reverted to identity.)
3. **Feet/base at bottom-centre of the canvas**; set the sprite offset so the feet sit at
   the node origin. Y-sort uses node position, so this keeps depth + collision aligned.
4. Project setting `textures/canvas_textures/default_texture_filter = 0` (Nearest) — keep it.

## Backups & safety

- `backups/` holds local art snapshots; it has a `.gdignore` (Godot skips it) and is
  git-ignored. See `backups/README.md`. Snapshots are taken before destructive art ops.
- **The repo is NOT committed to git yet.** This is the biggest gap — committing is the
  real safety net (would have prevented an earlier loss of crisp Marigold frames).
  `.gitignore` already excludes `.godot/`, `backups/`, and keeps `*.import` files.

## Next steps / backlog

- [ ] **Make the initial git commit** (everything is untracked).
- [x] Cauldron & bed sprites (milestone 0.2a) — `art/props/shop/{cauldron,bed}.png`
      (native 72×56 / 72×44, scale 1.0) replace the `Polygon2D` "Visual" nodes in
      `ShopInterior.tscn`; zones/scripts/collision unchanged. Done 2026-06-16.
- [x] Forest gatherable sprites — `art/props/forest/{moonleaf_bush,forest_water_spring}.png`
      replace the reusable gatherable `Visual`; zones/scripts/collision unchanged.
      Done 2026-06-16.
- [x] Generic customer sprite — `art/characters/npcs/generic_customer.png` replaces the
      customer `Polygon2D`; sale request logic/collision unchanged. Done 2026-06-16.
- [x] Shop sign sprite — `art/props/shop/shop_sign.png` replaces the sign `Polygon2D`;
      sign dialogue/collision unchanged. Done 2026-06-16.
- [x] Shop counter sprite — `art/props/shop/shop_counter.png` replaces the central
      `ObstacleVisual`; obstacle collision unchanged. Done 2026-06-16.
- [x] Spring forest tree sprite — `art/props/forest/tree_spring.png` replaces the forest
      tree polygons; trunk collision unchanged. First season visual direction is spring.
      Done 2026-06-16.
- [ ] Item icons (Moonleaf / Forest Water / Calming Tea) once an inventory UI exists.
- [ ] Replace remaining placeholders: shop/forest tilesets.
- [ ] Polish: styled dialogue/HUD (currently default font); customer "enters/leaves"
      flow; cat idle animation variety.
- [ ] Deferred from the slice: `npcs.json` + NPC database; a dialogue-id database
      (lines are currently inline in `shop_requests.json`); restoring player position on
      load (save format reserves room for it).

## Known quirks

- GDScript **warnings are treated as errors** — avoid `Variant` inference (use typed vars,
  `minf`/`maxi`, etc.).
- `.tscn` `load_steps` is a hint; keep it ≥ actual resource count when hand-editing.
- After renaming/adding art files, run the headless `--editor --quit` import pass before
  playing (renames can leave stale `.import` files).
