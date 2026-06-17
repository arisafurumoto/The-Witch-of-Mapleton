# The Witch of Mapleton — Progress & Handoff

> Living status doc. Read this first when starting a new session.
> Last updated: 2026-06-17.

## Status

**Vertical Slice 0.1 — "First Potion Sale" is complete and playable.** All 14 systems
from the implementation order are built (player movement → camera → collision →
interaction → scene transition → item db → inventory → gathering → crafting → shop
sale → dialogue → cat companion → save/load → day cycle). Real art is now in for the
characters (Marigold, Saffron, generic customer), the shop props (cauldron, bed,
counter, sign), the forest props (moonleaf bush, water spring, spring tree), and the
forest ground/path tiles. Action sound effects, styled DialogueBox/HUD, and a
customer enters/leaves polish are also in. Recent polish replaced the shop floor/walls,
added a first-pass forest ground detail overlay, gave Saffron simple idle glances, and
added small save/load HUD notifications. The project now boots to a simple title/start
menu before entering the playable slice.

**Vertical Slice 0.2 — "Sage's First Village Request" has started.** A minimal quest
database/system now tracks `sage_first_request`, Sage appears in the shop on day 1, the
new Root-Wake Tonic recipe can be crafted at a placeholder potting bench, Sage can
accept the tonic, reward 25 gold + a Moonleaf Seed Packet, and quest state is saved.
The HUD now shows quest start/complete toasts and a small current-objective tracker.
The new tonic and seed-packet inventory icons are in. Sage and the bench are placeholder
scene art for now.

Engine: **Godot 4.1.3** at `/Applications/Godot.app`. Main scene: `scenes/ui/TitleMenu.tscn`.

Long-term vision notes now live in `docs/GDD.md`: **Atelier series meets cosy life
sim**, with Atelier-style gathering/crafting/quests as the main progression, optional
Moonlighter-style shop management, calendar seasons, limited farming, separate
shop/room scenes, cooking/cafe progression, and simple supportive combat. These are
future design directions and should not expand the current vertical-slice scope.
Additional locked design direction: progression is driven mainly by quest chains;
alchemy quality/traits should have readable depth; daily time/stamina should be gentle;
the world is a compact hub with unlocked authored regions; the cast should be roughly
Stardew Valley-sized; romance is a major optional layer; Homunculi are mid-game
automation; the cafe is an optional expansion; the mystery tone is gentle wonder; the
long-term completion fantasy is a thriving Mapleton. Saffron is a home-property
companion in the full design: he speaks early, later mostly meows, stays around the
shop/room/farm/cafe, eventually meets a white village cat, and may have kittens. If
Marigold loses all HP, she wakes at home the next day with the doctor nearby, loses a
small amount of money, and starts later than usual.
Marigold's updated default visual direction is now an autumn village-witch design:
long copper-orange hair, olive hat, moss-green layered dress, cream puff sleeves,
rust-orange shawl, brown boots, and an amber-crystal staff. Future outfit changing is
planned, but not part of the current slice.
Saffron's concept direction is a small black cat with large golden-amber eyes,
oversized triangular ears, warm dark-brown fur highlights, an expressive curled tail,
and an olive collar with a gold-framed amber crystal pendant.

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

0.2 quest loop: start in the shop → talk to Sage → go through the top door to the
forest → gather Moonleaf (×2) and Forest Water (×1) → return → craft Root-Wake Tonic
at the potting bench → talk to Sage → receive 25 gold + Moonleaf Seed Packet → sleep
in the bed → day advances, game saves, quest completion persists.

0.1 shop-sale loop: start in the shop → go through the top door to the forest → gather
Moonleaf (×2) and Forest Water (×1) → return → craft Calming Tea at the cauldron →
talk to the Customer (they buy it for 18 gold, shown in the HUD) → sleep in the bed →
day advances, game saves, gatherables refill. Save auto-loads on next launch.

## Architecture

**Autoload singletons** (order matters — defined in `project.godot`):
`ItemDatabase`, `Inventory`, `RecipeDatabase`, `CraftingSystem`, `ShopRequestDatabase`,
`ShopSystem`, `AudioSystem`, `QuestDatabase`, `QuestSystem`, `DialogueBox` (UI scene),
`DaySystem`, `HUD` (UI scene), `InventoryPanel` (UI scene), `SaveSystem` (last, so it
loads after the systems it writes into). `Inventory` holds items **and** gold and
persists across scene changes.
`DaySystem` holds the day + per-gatherable depletion state. `QuestSystem` stores quest
states (`not_started`, `active`, `ready_to_turn_in`, `completed`). `SaveSystem` stores
inventory, gold, day/gatherable state, quests, current scene path, and player position,
then restores the player position when the saved scene's player is ready.

**Interaction pattern:** `scripts/core/Interactable.gd` (Area2D, has `interact()`,
`show_prompt()`, optional inline `dialogue`). Subclasses: `Door`, `Gatherable`,
`CraftingStation`, `Bed`, `scripts/npc/CustomerNPC.gd`, and `scripts/npc/SageNPC.gd`. The player
(`scripts/player/PlayerController.gd`) detects nearby interactables via an Area2D and
calls `interact()` on the nearest; movement/interaction freeze while a dialogue is open.

**Data-driven content** (JSON loaders validate on load): `data/items.json`,
`data/recipes.json`, `data/shop_requests.json` (customer request + inline dialogue lines),
and `data/quests.json` (Sage quest turn-in/reward/dialogue).

**Scenes:** `scenes/world/{ShopInterior,ForestClearing}.tscn` (Y-sort enabled),
reusable `scenes/world/{Door,Gatherable}.tscn`, `scenes/npc/Cat.tscn`,
`scenes/player/Player.tscn`, `scenes/ui/{DialogueBox,HUD,InventoryPanel}.tscn`.

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
- **The repo is committed to git** (baseline + focused art/system batches). Keep
  committing after each focused batch — it's the real safety net (an early loss of crisp
  Marigold frames predates the baseline). `.gitignore` excludes `.godot/`, `backups/`,
  and keeps `*.import` files. Note: the customer enters/leaves polish
  (`scripts/npc/CustomerNPC.gd`) is currently uncommitted.

## Next steps / backlog

- [ ] Vertical Slice 0.2 — Sage's First Village Request is in progress.
      See `docs/plans/vertical_slice_0_2_sage_first_request.md`. First implementation
      pass adds minimal quest state, Sage's authored interaction, Root-Wake Tonic,
      a placeholder potting bench, rewards, and save/load support. Sage now appears
      on day 1 so this slice starts with a villager request. Needs full manual
      playthrough QA and follow-up polish before marking complete.
- [x] Root-Wake Tonic / Moonleaf Seed Packet icons — native 16×16 pixel icons at
      `art/items/<id>.png`. The inventory panel now shows art for all 0.2 items instead
      of fallback swatches. Done 2026-06-17.
- [x] Quest UX feedback — HUD toast on quest start/completion plus a small active quest
      tracker showing the current Sage objective (`Craft Root-Wake Tonic` or
      `Bring Root-Wake Tonic to Sage`). No full quest journal yet. Done 2026-06-17.
- [x] Initial git baseline exists; continue committing after focused art/system batches.
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
- [x] Forest spring ground tile pass — `art/tilesets/forest/*spring*` source tiles build
      repeated `art/backgrounds/forest/*spring*.png` ground/path layers for
      `ForestClearing.tscn`; collisions unchanged. Done 2026-06-16.
- [x] UI readability pass — styled `DialogueBox` and `HUD` with warm dark panels and
      readable text; signals/data flow unchanged. Done 2026-06-16.
- [x] Basic audio feedback — `AudioSystem` autoload plays short gather, craft, sale, and
      sleep cues from existing success points. No music/settings menu yet. Done 2026-06-16.
- [x] Customer enters/leaves polish — the first customer stays hidden until Calming Tea
      is crafted, then fades/slides in; after a successful sale they leave. One customer
      only; no schedules/queues. Done 2026-06-16.
- [x] Inventory panel — `scenes/ui/InventoryPanel.tscn` + `scripts/ui/InventoryPanel.gd`
      (autoload UI scene). Non-modal panel toggled with the **I** key (`toggle_inventory`
      action), top-right, styled to match the HUD. Rebuilds on `inventory_changed`; each
      row shows the item icon if `art/items/<id>.png` exists, else a colored fallback
      swatch. Done 2026-06-16.
- [x] Item icons (Moonleaf / Forest Water / Calming Tea) — native 16×16 pixel icons at
      `art/items/<id>.png`. The inventory panel displays them automatically in place of
      placeholder swatches. Done 2026-06-16.
- [x] Shop floor/walls pass — `art/backgrounds/shop/{shop_walls,shop_floor}.png`
      replace the large `Polygon2D` background/floor rectangles in `ShopInterior.tscn`;
      collision, props, doors, and interaction zones unchanged. Done 2026-06-16.
- [x] Broader forest detail pass — `art/backgrounds/forest/forest_detail_spring.png`
      adds non-colliding ground detail over the grass/path layer in `ForestClearing.tscn`
      (tufts, flowers, stones, mushrooms, leaf clusters); gameplay zones unchanged.
      Done 2026-06-16.
- [x] Polish: cat idle animation variety — Saffron now occasionally changes idle facing
      while waiting near Marigold, sometimes glancing toward her and sometimes looking
      around. No new art frames; follow behavior unchanged. Done 2026-06-16.
- [x] Restore player position/current scene on load — save data now includes
      `current_scene` and `player_position`; old saves still load with safe defaults.
      Done 2026-06-16.
- [x] Save UX/debug polish — `SaveSystem` emits `game_saved` / `game_loaded` signals;
      `HUD` shows a short "Game saved" or "Loaded Day X" toast while console debug
      prints remain in place. Done 2026-06-16.
- [x] Title/start menu — `project.godot` now starts at `scenes/ui/TitleMenu.tscn`,
      with Continue, New Game, and Quit buttons over a placeholder pixel title
      background. Continue restores the saved scene/position; New Game clears the save
      and starts in the shop. Done 2026-06-16.
- [x] Door transition spawn positions — shop/forest doors now pass a one-shot target
      player position, so returning from the forest places Marigold just inside the shop
      door instead of at the scene default. Done 2026-06-17.
- [ ] Deferred from the slice: `npcs.json` + NPC database; a dialogue-id database
      (lines are currently inline in `shop_requests.json`). Consider this when adding a
      second customer/NPC or more than one reusable dialogue, not for the one-request
      vertical slice.

## Known quirks

- GDScript **warnings are treated as errors** — avoid `Variant` inference (use typed vars,
  `minf`/`maxi`, etc.).
- `.tscn` `load_steps` is a hint; keep it ≥ actual resource count when hand-editing.
- After renaming/adding art files, run the headless `--editor --quit` import pass before
  playing (renames can leave stale `.import` files).
